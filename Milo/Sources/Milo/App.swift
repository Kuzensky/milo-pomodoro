import AppKit
import Combine
import MiloCore
import QuartzCore
import SwiftUI

@main
@MainActor
enum MiloLauncher {
    static func main() {
        let app = NSApplication.shared
        let args = ProcessInfo.processInfo.arguments
        if let index = args.firstIndex(of: "--export-icon"), args.count > index + 1 {
            do { try IconWriter.write(to: URL(fileURLWithPath: args[index + 1])) }
            catch { fputs("Milo icon export failed: \(error)\n", stderr) }
            return
        }
        if let index = args.firstIndex(of: "--check-notifications"), args.count > index + 1 {
            app.setActivationPolicy(.accessory)
            Task {
                await NotificationProbe.run(output: args[index + 1])
                app.terminate(nil)
            }
            app.run()
            return
        }
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
        withExtendedLifetime(delegate) {}
    }
}

final class MiloPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let notifications: NotificationService
    private let store: MiloStore
    private var item: NSStatusItem!
    private var panel: MiloPanel!
    private var hosting: NSHostingView<MiloPanelView>!
    private var glass: NSGlassEffectView!
    private var surface: NSView!
    private var transitionContainer: NSView!
    private var menuTransition: MenuBarTransition!
    private var requestedVisible = false
    private var transitionBodyFrame: NSRect?
    private var transitionChecks: [[String: Any]] = []
    private var outsideClickMonitor: Any?
    private var subscriptions = Set<AnyCancellable>()
    private var workspaceObservers: [NSObjectProtocol] = []
    private let arguments = ProcessInfo.processInfo.arguments
    private var previewPath: String? {
        guard let index = arguments.firstIndex(of: "--render-preview"), arguments.count > index + 1 else { return nil }
        return arguments[index + 1]
    }

    override init() {
        notifications = NotificationService()
        let args = ProcessInfo.processInfo.arguments
        let preview = args.contains("--render-preview")
        let defaults = preview ? UserDefaults(suiteName: "local.milo.preview.\(UUID().uuidString)")! : .standard
        store = MiloStore(defaults: defaults, notifications: notifications)
        super.init()
        if preview {
            store.updateSettings {
                $0.notificationsEnabled = false
                $0.soundEnabled = false
                $0.animationEnabled = args.contains("--animated")
            }
            if args.contains("--focus") { store.primaryAction() }
            if args.contains("--rest") { store.select(.shortBreak) }
            if args.contains("--settings") { store.showSettings = true }
            if args.contains("--solid") { store.liquidGlassEnabled = false }
            if args.contains("--dark-glass") { store.glassDarkness = 1 }
            if args.contains("--clear-glass") { store.glassDarkness = 0 }
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        if previewPath == nil {
            let peers = NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier ?? "local.milo.personal")
                .filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
            if !peers.isEmpty {
                DistributedNotificationCenter.default().postNotificationName(.init("local.milo.show"), object: nil)
                NSApp.terminate(nil)
                return
            }
        }
        createStatusItem()
        createPanel()
        store.onResize = { [weak self] in self?.resizePanel() }
        store.onClose = { [weak self] in self?.closePanel() }
        notifications.onOpen = { [weak self] in self?.showPanel() }
        notifications.$authorization.sink { [weak self] _ in
            DispatchQueue.main.async { self?.resizePanel() }
        }.store(in: &subscriptions)
        notifications.$message.sink { [weak self] _ in
            DispatchQueue.main.async { self?.resizePanel() }
        }.store(in: &subscriptions)
        store.$now.sink { [weak self] _ in
            guard let self else { return }
            self.item.button?.toolTip = "Milo · \(self.store.countdown) · \(self.store.engine.kind.title)"
        }.store(in: &subscriptions)

        if previewPath == nil {
            outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                let location = NSEvent.mouseLocation
                Task { @MainActor in self?.handleOutsideClick(at: location) }
            }
        }
        workspaceObservers.append(NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in Task { @MainActor in await self?.wake() } })
        workspaceObservers.append(NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification, object: nil, queue: .main
        ) { [weak self] _ in Task { @MainActor in self?.resizePanel() } })
        NotificationCenter.default.addObserver(self, selector: #selector(becameActive), name: NSApplication.didBecomeActiveNotification, object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(showFromSignal), name: .init("local.milo.show"), object: nil)
        showPanel()

        if let previewPath {
            if arguments.contains("--exercise-transitions") {
                runTransitionDiagnostics(output: previewPath)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                if self?.arguments.contains("--exercise-glass") == true {
                    self?.runGlassDiagnostics(output: previewPath)
                }
                self?.exportPreview(to: previewPath)
                if self?.arguments.contains("--motion-frames") == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        self?.exportPreview(to: previewPath + ".motion.png")
                        NSApp.terminate(nil)
                    }
                } else { NSApp.terminate(nil) }
            }
        } else {
            Task {
                await notifications.refresh()
                if store.engine.settings.notificationsEnabled && notifications.authorization == .notDetermined {
                    await notifications.requestPermission()
                }
                await store.restoreNotifications()
            }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showPanel()
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        store.persist()
        if let outsideClickMonitor { NSEvent.removeMonitor(outsideClickMonitor) }
        for observer in workspaceObservers { NSWorkspace.shared.notificationCenter.removeObserver(observer) }
        // A running session's system alert intentionally survives quitting Milo.
    }

    private func createStatusItem() {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = item.button else { return }
        button.image = menuBarImage()
        button.imagePosition = .imageOnly
        button.setAccessibilityLabel("Milo")
        button.target = self
        button.action = #selector(statusClicked)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    private func createPanel() {
        let size = panelSize
        panel = MiloPanel(contentRect: .init(origin: .zero, size: size), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.title = "Milo"
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .popUpMenu
        panel.hidesOnDeactivate = false
        panel.animationBehavior = .none
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.appearance = NSAppearance(named: .darkAqua)
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = false

        // Clip the whole window surface, not only the SwiftUI background. Otherwise
        // the hosting/glass backing can expose rectangular pixels around the corners.
        surface = NSView(frame: .init(origin: .zero, size: size))
        surface.wantsLayer = true
        surface.layer?.backgroundColor = NSColor.clear.cgColor
        surface.layer?.cornerRadius = 28
        surface.layer?.cornerCurve = .continuous
        surface.layer?.masksToBounds = true
        surface.clipsToBounds = true
        glass = NSGlassEffectView(frame: .init(origin: .zero, size: size))
        glass.style = .clear
        glass.cornerRadius = 28
        glass.tintColor = NSColor.black.withAlphaComponent(0.04)
        glass.autoresizingMask = [.width, .height]
        hosting = NSHostingView(rootView: MiloPanelView(store: store, notifications: notifications))
        // This panel is sized explicitly. Do not let intrinsic hosting sizes stretch it.
        hosting.sizingOptions = []
        hosting.frame = glass.bounds
        hosting.autoresizingMask = [.width, .height]
        hosting.wantsLayer = true
        hosting.layer?.backgroundColor = NSColor.clear.cgColor
        hosting.layer?.cornerRadius = 28
        hosting.layer?.cornerCurve = .continuous
        hosting.layer?.masksToBounds = true
        hosting.clipsToBounds = true
        hosting.focusRingType = .none
        glass.contentView = hosting
        surface.addSubview(glass)
        // Temporary transparent headroom lets the surface reach the real menu icon.
        transitionContainer = NSView(frame: .init(origin: .zero, size: size))
        transitionContainer.wantsLayer = true
        transitionContainer.layer?.backgroundColor = NSColor.clear.cgColor
        transitionContainer.addSubview(surface)
        panel.contentView = transitionContainer
        menuTransition = MenuBarTransition(layer: transitionContainer.layer!, surface: surface)
        panel.invalidateShadow()
    }

    private var panelSize: NSSize {
        if store.showSettings {
            let accessibilitySpace: CGFloat = NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency ? 18 : 0
            return .init(width: 352, height: (notifications.message == nil ? 520 : 552) + accessibilitySpace)
        }
        // A single compact landscape layout replaces the old portrait preference.
        return .init(width: 420, height: store.storageMessage == nil ? 224 : 246)
    }

    private func position(size: NSSize) -> NSRect {
        let screen = item.button?.window?.screen ?? NSScreen.main!
        let anchor = menuIconFrame
        let visible = screen.visibleFrame
        let x = min(max(anchor.midX - size.width / 2, visible.minX + 10), visible.maxX - size.width - 10)
        let y = max(visible.minY + 10, anchor.minY - size.height - 8)
        return .init(origin: .init(x: x, y: y), size: size)
    }

    private var menuIconFrame: NSRect {
        if let button = item.button, let window = button.window {
            return window.convertToScreen(button.convert(button.bounds, to: nil))
        }
        let visible = NSScreen.main!.visibleFrame
        return .init(x: visible.maxX - 80, y: visible.maxY, width: 24, height: 24)
    }

    private func resizePanel() {
        guard panel != nil else { return }
        updateGlassSurface()
        if menuTransition.isAnimating {
            return
        }
        let frame = position(size: panelSize)
        panel.setFrame(frame, display: true)
        surface.frame = .init(origin: .zero, size: frame.size)
        surface.layer?.backgroundColor = store.showSettings
            ? NSColor(srgbRed: 0.075, green: 0.075, blue: 0.075, alpha: 1).cgColor
            : NSColor.clear.cgColor
        hosting.frame = glass.bounds
        panel.invalidateShadow()
    }

    private func updateGlassSurface() {
        let useGlass = store.liquidGlassEnabled && !store.showSettings &&
            !NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
        if useGlass {
            if glass.contentView !== hosting {
                hosting.removeFromSuperview()
                glass.contentView = hosting
            }
            glass.isHidden = false
        } else {
            if glass.contentView === hosting {
                glass.contentView = nil
                surface.addSubview(hosting)
            }
            glass.isHidden = true
        }
        hosting.frame = surface.bounds
    }

    private func showPanel() {
        guard panel != nil else { return }
        store.reconcile()
        if requestedVisible {
            if !menuTransition.isAnimating { resizePanel(); panel.makeKeyAndOrderFront(nil) }
            return
        }
        requestedVisible = true
        store.panelVisible = true
        transitionPanel(opening: true)
        if previewPath == nil { Task { await store.restoreNotifications() } }
    }

    private func closePanel(animated: Bool = true) {
        guard panel != nil, requestedVisible else { return }
        requestedVisible = false
        if animated { transitionPanel(opening: false) }
        else { finishPanelTransition(opening: false) }
    }

    private func handleOutsideClick(at location: NSPoint) {
        // macOS can report status-item mouse-downs to the global monitor before
        // the button's mouse-up action. Let that action own the icon's toggle.
        guard !menuIconFrame.contains(location) else { return }
        closePanel()
    }

    private func togglePanel() {
        if requestedVisible { closePanel() }
        else { showPanel() }
    }

    private func transitionPanel(opening: Bool) {
        let animate = previewPath == nil || arguments.contains("--exercise-transitions")
        guard animate else { finishPanelTransition(opening: opening); return }
        let desiredBody = position(size: panelSize)
        // A settings-size change during a reversed animation must not distort layout.
        if menuTransition.isAnimating, transitionBodyFrame?.size != desiredBody.size {
            finishPanelTransition(opening: opening)
            return
        }
        let bodyFrame = transitionBodyFrame ?? desiredBody
        transitionBodyFrame = bodyFrame
        let icon = menuIconFrame
        let expanded = NSRect(x: bodyFrame.minX - 8, y: bodyFrame.minY, width: bodyFrame.width + 16,
                              height: max(bodyFrame.height, icon.maxY + 3 - bodyFrame.minY))
        if !menuTransition.isAnimating {
            panel.hasShadow = false
            panel.setFrame(expanded, display: false)
            surface.frame = .init(origin: .init(x: 8, y: 0), size: bodyFrame.size)
            hosting.frame = glass.bounds
        }
        panel.ignoresMouseEvents = true
        if opening { panel.makeKeyAndOrderFront(nil) }
        let anchor = CGPoint(x: icon.midX - expanded.minX, y: icon.midY - expanded.minY)
        let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion || arguments.contains("--reduce-motion-preview")
        menuTransition.animate(opening: opening, anchor: anchor, reduceMotion: reduceMotion) { [weak self] in
            guard let self, self.requestedVisible == opening else { return }
            self.finishPanelTransition(opening: opening)
        }
    }

    private func finishPanelTransition(opening: Bool) {
        if !opening { panel.orderOut(nil); store.panelVisible = false }
        menuTransition.reset()
        transitionBodyFrame = nil
        panel.ignoresMouseEvents = false
        panel.hasShadow = true
        resizePanel()
        if opening { panel.makeKeyAndOrderFront(nil) }
    }

    @objc private func statusClicked() {
        if NSApp.currentEvent?.type == .rightMouseUp {
            closePanel(animated: false)
            let menu = NSMenu()
            menu.addItem(withTitle: "Show Milo", action: #selector(showFromSignal), keyEquivalent: "")
            menu.addItem(withTitle: store.primaryTitle, action: #selector(timerAction), keyEquivalent: "")
            menu.addItem(withTitle: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
            menu.addItem(.separator())
            menu.addItem(withTitle: "Quit Milo", action: #selector(quit), keyEquivalent: "q")
            for entry in menu.items { entry.target = self }
            if let event = NSApp.currentEvent, let button = item.button { NSMenu.popUpContextMenu(menu, with: event, for: button) }
        } else { togglePanel() }
    }

    @objc private func showFromSignal() { showPanel() }
    @objc private func openSettings() { store.showSettings = true; showPanel() }
    @objc private func timerAction() { store.primaryAction() }
    @objc private func quit() { NSApp.terminate(nil) }
    @objc private func becameActive() { Task { await wake() } }

    private func wake() async { await store.restoreNotifications() }

    private func menuBarImage() -> NSImage {
        let image = NSImage(size: .init(width: 20, height: 20), flipped: true) { _ in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            context.scaleBy(x: 20 / 512, y: 20 / 512)
            for part in MiloVectors.icon {
                context.setBlendMode(part.white ? .destinationOut : .normal)
                context.setFillColor(NSColor.black.cgColor)
                context.setStrokeColor(NSColor.black.cgColor)
                context.addPath(part.path.cgPath)
                if part.stroke > 0 {
                    context.setLineWidth(part.stroke)
                    context.setLineCap(.round)
                    context.strokePath()
                } else { context.fillPath() }
            }
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Milo"
        return image
    }

    private func exportPreview(to path: String) {
        hosting.layoutSubtreeIfNeeded()
        guard let bitmap = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else { return }
        hosting.cacheDisplay(in: hosting.bounds, to: bitmap)
        // Flatten only this app's own view over charcoal for geometry/contrast QA.
        // Capturing a hosting view doesn't capture the desktop-sampled glass backdrop.
        let flat = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: bitmap.pixelsWide, pixelsHigh: bitmap.pixelsHigh,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        )!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: flat)
        NSColor(calibratedWhite: 0.065, alpha: 1).setFill()
        let rect = NSRect(x: 0, y: 0, width: bitmap.pixelsWide, height: bitmap.pixelsHigh)
        rect.fill()
        bitmap.draw(in: rect)
        NSGraphicsContext.restoreGraphicsState()
        guard let data = flat.representation(using: .png, properties: [:]) else { return }
        do { try data.write(to: URL(fileURLWithPath: path)) }
        catch { NSLog("Milo preview: %@", error.localizedDescription) }
    }

    private func runGlassDiagnostics(output: String) {
        store.showSettings = false
        store.primaryAction()
        let session = store.engine
        var checks: [[String: Any]] = []
        for (name, enabled, darkness) in [("clear", true, 0.0), ("dark", true, 1.0), ("solid", false, 0.18)] {
            store.liquidGlassEnabled = enabled
            store.glassDarkness = darkness
            let expectsGlass = enabled && !NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
            checks.append([
                "phase": name,
                "passed": glass.isHidden != expectsGlass && hosting.window === panel && store.engine == session,
            ])
            exportPreview(to: output + ".\(name).png")
        }
        store.liquidGlassEnabled = true
        store.glassDarkness = 0.18
        store.showSettings = true
        checks.append([
            "phase": "settings retain content and running session",
            "passed": glass.isHidden && hosting.window === panel && store.engine == session && panel.frame.size == panelSize,
        ])
        exportPreview(to: output + ".settings.png")
        store.showSettings = false
        checks.append([
            "phase": "glass restored after settings",
            "passed": hosting.window === panel && store.engine == session && panel.frame.size == panelSize,
        ])
        do {
            try JSONSerialization.data(withJSONObject: ["checks": checks, "passed": checks.allSatisfy { $0["passed"] as? Bool == true }], options: [.prettyPrinted, .sortedKeys])
                .write(to: URL(fileURLWithPath: output + ".json"))
        } catch { NSLog("Milo glass diagnostics: %@", error.localizedDescription) }
    }

    /// Isolated native lifecycle checks, enabled only by an explicit preview flag.
    private func runTransitionDiagnostics(output: String) {
        func after(_ seconds: Double, _ action: @escaping @MainActor @Sendable () -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: action)
        }
        after(0.06) { self.togglePanel() }
        after(0.11) { self.togglePanel() }
        after(0.17) { self.togglePanel() }
        after(0.22) { self.togglePanel() }
        after(0.24) {
            let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion || self.arguments.contains("--reduce-motion-preview")
            let warped = self.menuTransition.hasGenieMesh && self.surface.isHidden
            self.transitionChecks.append([
                "phase": "live transition",
                "passed": self.menuTransition.isAnimating && self.panel.ignoresMouseEvents && (reduceMotion || warped),
                "warped": warped,
            ])
        }
        after(0.94) {
            self.recordTransitionCheck("rapid reversals", visible: true)
            let icon = self.menuIconFrame
            self.handleOutsideClick(at: CGPoint(x: icon.midX, y: icon.midY))
            self.recordTransitionCheck("icon mouse-down leaves toggle to button", visible: true)
            self.togglePanel()
        }
        after(1.56) {
            self.recordTransitionCheck("fully closed", visible: false)
            self.showPanel()
        }
        after(2.26) {
            self.recordTransitionCheck("reopened", visible: true)
            self.store.showSettings = true
        }
        after(2.32) {
            self.recordTransitionCheck("settings resize", visible: true)
            self.exportPreview(to: output)
            self.handleOutsideClick(at: CGPoint(x: self.panel.frame.minX - 20, y: self.panel.frame.minY - 20))
        }
        after(3.20) {
            self.recordTransitionCheck("settings closed", visible: false)
            self.store.showSettings = false
            self.showPanel()
        }
        after(4.10) {
            self.recordTransitionCheck("timer restored", visible: true)
            self.exportPreview(to: output + ".timer.png")
            let anchor = CGPoint(x: self.menuIconFrame.midX - self.panel.frame.minX,
                                 y: self.menuIconFrame.midY - self.panel.frame.minY)
            let collapsed = GenieGeometry.section(at: 0.5, progress: 1, body: self.surface.frame, anchor: anchor)
            let error = hypot((collapsed.left + collapsed.right) / 2 - anchor.x, collapsed.y - anchor.y)
            self.transitionChecks.append(["phase": "menu anchor preserved", "passed": error < 0.01, "error": error])
            self.menuTransition.exportDiagnosticFrames(to: output, anchor: anchor)
            let report: [String: Any] = [
                "checks": self.transitionChecks,
                "passed": self.transitionChecks.allSatisfy { $0["passed"] as? Bool == true },
                "reducedMotion": NSWorkspace.shared.accessibilityDisplayShouldReduceMotion || self.arguments.contains("--reduce-motion-preview"),
            ]
            do {
                try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
                    .write(to: URL(fileURLWithPath: output + ".json"))
            } catch { NSLog("Milo transition diagnostics: %@", error.localizedDescription) }
            NSApp.terminate(nil)
        }
    }

    private func recordTransitionCheck(_ phase: String, visible: Bool) {
        let correctFrame = abs(panel.frame.width - panelSize.width) < 0.5 && abs(panel.frame.height - panelSize.height) < 0.5
        let settled = !menuTransition.isAnimating && !panel.ignoresMouseEvents &&
            !menuTransition.hasGenieMesh && !surface.isHidden &&
            CATransform3DIsIdentity(transitionContainer.layer!.sublayerTransform) && transitionContainer.layer!.opacity == 1
        transitionChecks.append([
            "phase": phase,
            "passed": panel.isVisible == visible && requestedVisible == visible && store.panelVisible == visible && correctFrame && settled,
            "visible": panel.isVisible,
            "requestedVisible": requestedVisible,
            "settled": settled,
            "width": panel.frame.width,
            "height": panel.frame.height,
        ])
    }
}
