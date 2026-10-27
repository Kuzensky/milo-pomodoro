import AppKit
import Combine
import MiloCore

@MainActor
final class MiloStore: ObservableObject {
    @Published private(set) var engine: SessionEngine
    @Published private(set) var now = Date()
    @Published private(set) var completionPulse = 0
    @Published var panelVisible = false
    @Published var showSettings = false { didSet { onResize?() } }
    // Appearance has its own keys so a visual change never resets a ready timer
    // or reschedules a running session's notification.
    @Published var liquidGlassEnabled: Bool {
        didSet {
            defaults.set(liquidGlassEnabled, forKey: "milo.appearance.liquidGlass")
            onResize?()
        }
    }
    @Published var glassDarkness: Double {
        didSet {
            defaults.set(glassDarkness, forKey: "milo.appearance.glassDarkness")
            onResize?()
        }
    }
    @Published var scanlineCatEnabled: Bool {
        didSet { defaults.set(scanlineCatEnabled, forKey: "milo.appearance.scanlineCat") }
    }
    @Published var storageMessage: String?
    let notifications: NotificationService
    var onResize: (() -> Void)?
    var onClose: (() -> Void)?
    private let defaults: UserDefaults
    private let storageKey = "milo.session.v1"
    private var ticker: Timer?

    init(defaults: UserDefaults = .standard, notifications: NotificationService) {
        self.defaults = defaults
        self.notifications = notifications
        liquidGlassEnabled = defaults.object(forKey: "milo.appearance.liquidGlass") as? Bool ?? true
        let darkness = defaults.object(forKey: "milo.appearance.glassDarkness") as? Double ?? 0.18
        glassDarkness = darkness.isFinite ? min(1, max(0, darkness)) : 0.18
        scanlineCatEnabled = defaults.object(forKey: "milo.appearance.scanlineCat") as? Bool ?? true
        if let data = defaults.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode(SessionEngine.self, from: data) {
            engine = saved
            engine.repairIfNeeded()
        } else {
            engine = SessionEngine()
        }
        reconcile()
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.reconcile() }
        }
        RunLoop.main.add(ticker!, forMode: .common)
    }

    var remaining: TimeInterval { engine.secondsRemaining(at: now) }
    var countdown: String {
        let seconds = max(0, Int(ceil(remaining)))
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
    var todayCount: Int { engine.completedToday(at: now) }
    var progress: Double { min(1, max(0, 1 - remaining / engine.duration)) }
    var pose: CatPose {
        if engine.phase == .completed { return .idle }
        if engine.kind != .focus { return .rest }
        return engine.phase == .running ? .focus : .idle
    }
    var status: String {
        switch engine.phase {
        case .completed: return engine.kind == .focus ? "One session closer. Well done." : "Rested? Milo is ready when you are."
        case .paused: return "Take your time. Milo’s here."
        case .running: return engine.kind == .focus ? "Quiet company. You’ve got this." : "Stretch. Breathe. Take your time."
        case .ready: return engine.kind == .focus ? "A little focus. Together." : "A little rest does you good."
        }
    }
    var primaryTitle: String {
        switch engine.phase {
        case .running: return "Pause"
        case .paused: return "Resume"
        case .completed: return "Start \(engine.nextKind == .focus ? "focus" : engine.nextKind.title.lowercased())"
        case .ready: return "Start \(engine.kind == .focus ? "focus" : "break")"
        }
    }

    func reconcile() {
        now = Date()
        if engine.reconcile(at: now) {
            completed()
            persist()
            // Let the already scheduled system notification deliver at the deadline.
        }
    }

    func restoreNotifications() async {
        await notifications.refresh()
        reconcile()
        notifications.synchronize(engine)
    }

    func primaryAction() {
        now = Date()
        if engine.performPrimaryAction(at: now) { completed() }
        changed()
    }

    func select(_ mode: SessionKind) {
        reconcile()
        engine.select(mode)
        changed()
    }

    func reset() {
        reconcile()
        engine.reset()
        changed()
    }

    func updateSettings(_ change: (inout MiloSettings) -> Void) {
        var settings = engine.settings
        change(&settings)
        engine.updateSettings(settings)
        changed()
        onResize?()
    }

    func enableNotifications(_ value: Bool) {
        updateSettings { $0.notificationsEnabled = value }
        guard value else { return }
        Task {
            await notifications.requestPermission()
            notifications.synchronize(engine)
        }
    }

    func persist() {
        do {
            defaults.set(try JSONEncoder().encode(engine), forKey: storageKey)
            storageMessage = nil
        } catch { storageMessage = "Milo couldn’t save this session." }
    }

    private func changed() {
        now = Date()
        persist()
        notifications.synchronize(engine)
    }

    private func completed() {
        completionPulse += 1
        if engine.settings.soundEnabled && !(engine.settings.notificationsEnabled && notifications.isAuthorized) {
            NSSound(named: .init("Glass"))?.play()
        }
    }
}
