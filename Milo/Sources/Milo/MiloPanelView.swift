import AppKit
import MiloCore
import SwiftUI
import UserNotifications

struct MiloPanelView: View {
    @ObservedObject var store: MiloStore
    @ObservedObject var notifications: NotificationService
    @State private var pendingMode: SessionKind?
    @State private var confirmingReset = false
    @State private var confirmingMode = false
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var hasSessionToDiscard: Bool { store.engine.phase == .running || store.engine.phase == .paused }

    var body: some View {
        VStack(spacing: 0) {
            header
            if store.showSettings { settings }
            else { timer }
        }
        .padding(store.showSettings ? 16 : 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            if store.showSettings {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.sRGB, red: 0.075, green: 0.075, blue: 0.075))
            } else if reduceTransparency || !store.liquidGlassEnabled {
                RoundedRectangle(cornerRadius: 28).fill(Color(white: 0.10))
            } else {
                RoundedRectangle(cornerRadius: 28).fill(
                    LinearGradient(stops: [
                        .init(color: .black, location: 0),
                        .init(color: .black, location: 0.18),
                        .init(color: .black.opacity(0.86 + store.glassDarkness * 0.12), location: 0.38),
                        .init(color: .black.opacity(0.28 + store.glassDarkness * 0.58), location: 0.72),
                        .init(color: .black.opacity(0.04 + store.glassDarkness * 0.76), location: 1),
                    ], startPoint: .top, endPoint: .bottom)
                )
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28).strokeBorder(
                LinearGradient(colors: [.white.opacity(0.24), .white.opacity(0.055), .white.opacity(0.14)], startPoint: .topLeading, endPoint: .bottomTrailing),
                lineWidth: 0.75
            )
            .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
        .onExitCommand { store.onClose?() }
        .confirmationDialog("Reset this session?", isPresented: $confirmingReset, titleVisibility: .visible) {
            Button("Reset session", role: .destructive) { store.reset() }
            Button("Keep session", role: .cancel) {}
        } message: { Text("Your current timer will be cleared. Completed sessions are kept.") }
        .confirmationDialog("Switch timer mode?", isPresented: $confirmingMode, titleVisibility: .visible) {
            Button("Switch mode", role: .destructive) { if let pendingMode { store.select(pendingMode) } }
            Button("Keep session", role: .cancel) {}
        } message: { Text("This ends the current timer without counting it as a completed focus session.") }
    }

    private var header: some View {
        HStack(spacing: 7) {
            CatDrawing(pose: .icon)
                .frame(width: 22, height: 22)
                .accessibilityHidden(true)
            Text(store.showSettings ? "Milo settings" : "Milo")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            Spacer()
            if !store.showSettings {
                Text("\(store.todayCount)/\(store.engine.settings.dailyGoal) today")
                    .font(.system(size: 10.5))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.6))
                    .accessibilityLabel("\(store.todayCount) of \(store.engine.settings.dailyGoal) focus sessions completed today")
                    .padding(.trailing, 5)
            }
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { store.showSettings.toggle() }
            } label: {
                Image(systemName: store.showSettings ? "chevron.left" : "slider.horizontal.3")
                    .font(.system(size: 14))
                    .frame(width: 30, height: 30)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(store.showSettings ? "Back to timer" : "Settings")
            .help(store.showSettings ? "Back to timer" : "Settings")
        }
        .padding(.bottom, store.showSettings ? 12 : 8)
    }

    private var timer: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                MiloCatView(store: store)
                    .frame(width: 120, height: 138)
                VStack(alignment: .leading, spacing: 8) {
                    modePicker
                    Text(store.countdown)
                        .font(.system(size: 46, weight: .light, design: .rounded))
                        .monospacedDigit()
                        .tracking(-1.5)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .contentTransition(.numericText(value: ceil(store.remaining)))
                        .animation(reduceMotion ? nil : .snappy(duration: 0.25), value: store.countdown)
                        .accessibilityLabel("Time remaining")
                        .accessibilityValue(store.countdown)
                        .accessibilityHint(store.status)
                    timerControls
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let message = store.storageMessage {
                Text(message).font(.system(size: 11))
            }
        }
    }

    private var modePicker: some View {
        HStack(spacing: 2) {
            ForEach(SessionKind.allCases, id: \.self) { mode in
                Button {
                    guard mode != store.engine.kind else { return }
                    if hasSessionToDiscard { pendingMode = mode; confirmingMode = true }
                    else { store.select(mode) }
                } label: {
                    Text(mode.title)
                        .font(.system(size: 11, weight: store.engine.kind == mode ? .semibold : .medium))
                        .foregroundStyle(.white.opacity(store.engine.kind == mode ? 1 : 0.90))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background {
                            if store.engine.kind == mode {
                                Capsule().fill(Color(.sRGB, red: 0.25, green: 0.25, blue: 0.25))
                                    .overlay(Capsule().strokeBorder(.white.opacity(0.32), lineWidth: 0.75))
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(store.engine.kind == mode ? .isSelected : [])
            }
        }
        .padding(3)
        // Keep desktop text from showing through the labels on bright backgrounds.
        .background(Color(.sRGB, red: 0.075, green: 0.075, blue: 0.075), in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 0.75))
    }

    private var timerControls: some View {
        HStack(spacing: 7) {
            Button(action: store.primaryAction) {
                Label(store.primaryTitle, systemImage: store.engine.phase == .running ? "pause.fill" : "play.fill")
                    .font(.system(size: 12, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
            }
            .buttonStyle(MiloButtonStyle())
            .keyboardShortcut(.space, modifiers: [])
            Button {
                if hasSessionToDiscard { confirmingReset = true }
                else { store.reset() }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 12))
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(MiloButtonStyle(circle: true))
            .accessibilityLabel("Reset timer")
            .help("Reset timer")
        }
    }

    private var settings: some View {
        VStack(alignment: .leading, spacing: 10) {
            glassSettings
            VStack(spacing: 6) {
                minuteRow("Focus", value: setting(\.focusMinutes), range: 1...180)
                minuteRow("Short break", value: setting(\.shortBreakMinutes), range: 1...60)
                minuteRow("Long break", value: setting(\.longBreakMinutes), range: 1...120)
            }
            Divider().overlay(.white.opacity(0.05))
            VStack(spacing: 6) {
                countRow("Daily goal", value: setting(\.dailyGoal), range: 1...24, suffix: "sessions")
                countRow("Long break after", value: setting(\.longBreakEvery), range: 1...12, suffix: "focus sessions")
            }
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Timer notifications", isOn: Binding(
                    get: { store.engine.settings.notificationsEnabled }, set: store.enableNotifications))
                Toggle("Completion sound", isOn: setting(\.soundEnabled))
                Toggle("Animate Milo", isOn: setting(\.animationEnabled))
            }
            .toggleStyle(MiloToggleStyle())
            .font(.system(size: 12))
            .tint(.white)
            notificationSettings
            Spacer(minLength: 0)
            HStack {
                Spacer()
                Button("Quit Milo") { NSApp.terminate(nil) }
                    .font(.system(size: 11)).buttonStyle(.plain)
                    .keyboardShortcut("q", modifiers: .command)
            }
        }
    }

    private var glassSettings: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Glass")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
            HStack {
                Text("Liquid Glass View")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Toggle("Liquid Glass View", isOn: $store.liquidGlassEnabled)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .tint(.blue)
            }
            .padding(12)
            .background(glassSettingsCard)
            VStack(spacing: 5) {
                HStack(spacing: 10) {
                    Image(systemName: "circle.dotted")
                        .foregroundStyle(.white.opacity(0.5))
                    Slider(value: $store.glassDarkness, in: 0...1)
                        .tint(.white)
                        .accessibilityLabel("Glass darkness")
                        .accessibilityValue("\(Int(store.glassDarkness * 100)) percent")
                    Image(systemName: "circle.fill")
                        .foregroundStyle(.white.opacity(0.85))
                }
                .font(.system(size: 13))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(glassSettingsCard)
                HStack {
                    Text("Clear Glass")
                    Spacer()
                    Text("Dark")
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
                .padding(.horizontal, 12)
            }
            .disabled(!store.liquidGlassEnabled || reduceTransparency)
            .opacity(store.liquidGlassEnabled && !reduceTransparency ? 1 : 0.4)
            if reduceTransparency {
                Text("Reduce Transparency is on in macOS.")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(.bottom, 4)
    }

    private var glassSettingsCard: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color(white: 0.13))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(.white.opacity(0.10), lineWidth: 0.75)
            }
    }

    private var notificationSettings: some View {
        VStack(alignment: .leading, spacing: 6) {
            if notifications.isAuthorized {
                HStack {
                    Label("Notifications allowed", systemImage: "checkmark")
                    Spacer()
                    Button("Send test") { Task { await notifications.testNotification() } }
                        .buttonStyle(.plain)
                        .disabled(!store.engine.settings.notificationsEnabled)
                }
            } else {
                HStack {
                    Text(notifications.authorization == .denied ? "Notifications are blocked by macOS." : "Allow Milo to alert you when time is up.")
                    Spacer(minLength: 4)
                    Button(notifications.authorization == .denied ? "Settings" : "Allow") {
                        if notifications.authorization == .denied { notifications.openSettings() }
                        else { store.enableNotifications(true) }
                    }
                    .buttonStyle(.plain)
                    .disabled(notifications.isRequesting)
                }
            }
            if let message = notifications.message {
                Text(message).lineLimit(2).fixedSize(horizontal: false, vertical: true).help(message)
            }
        }
        .font(.system(size: 11))
        .foregroundStyle(.white.opacity(0.8))
        .padding(8)
        .background(Color(.sRGB, red: 0.12, green: 0.12, blue: 0.12), in: RoundedRectangle(cornerRadius: 10))
    }

    private func setting<Value>(_ path: WritableKeyPath<MiloSettings, Value>) -> Binding<Value> {
        Binding(get: { store.engine.settings[keyPath: path] }, set: { value in store.updateSettings { $0[keyPath: path] = value } })
    }

    private func minuteRow(_ title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        countRow(title, value: value, range: range, suffix: "min")
    }

    private func countRow(_ title: String, value: Binding<Int>, range: ClosedRange<Int>, suffix: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            HStack(spacing: 4) {
                Text(value.wrappedValue, format: .number.grouping(.never))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(value.wrappedValue)))
                    .animation(reduceMotion ? nil : .snappy(duration: 0.25), value: value.wrappedValue)
                Text(suffix)
            }
            .foregroundStyle(.white.opacity(0.7))
            .accessibilityElement(children: .combine)
            HStack(spacing: 3) {
                Button {
                    value.wrappedValue = max(range.lowerBound, value.wrappedValue - 1)
                } label: {
                    Image(systemName: "minus").font(.system(size: 11, weight: .medium))
                        .frame(width: 25, height: 25).contentShape(Rectangle())
                        .opacity(value.wrappedValue <= range.lowerBound ? 0.28 : 1)
                }
                .buttonStyle(.plain)
                .disabled(value.wrappedValue <= range.lowerBound)
                .accessibilityLabel("Decrease \(title.lowercased())")
                Button {
                    value.wrappedValue = min(range.upperBound, value.wrappedValue + 1)
                } label: {
                    Image(systemName: "plus").font(.system(size: 11, weight: .medium))
                        .frame(width: 25, height: 25).contentShape(Rectangle())
                        .opacity(value.wrappedValue >= range.upperBound ? 0.28 : 1)
                }
                .buttonStyle(.plain)
                .disabled(value.wrappedValue >= range.upperBound)
                .accessibilityLabel("Increase \(title.lowercased())")
            }
        }
        .font(.system(size: 12))
    }
}

struct MiloButtonStyle: ButtonStyle {
    var circle = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white.opacity(configuration.isPressed ? 0.95 : 1))
            .background {
                Capsule().fill(LinearGradient(
                    colors: configuration.isPressed
                        ? [Color(.sRGB, red: 0.14, green: 0.14, blue: 0.14), Color(.sRGB, red: 0.10, green: 0.10, blue: 0.10)]
                        : [Color(.sRGB, red: 0.23, green: 0.23, blue: 0.23), Color(.sRGB, red: 0.15, green: 0.15, blue: 0.15)],
                    startPoint: .top, endPoint: .bottom
                ))
            }
            .overlay(Capsule().strokeBorder(.white.opacity(configuration.isPressed ? 0.38 : 0.28), lineWidth: 0.8))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .contentShape(Capsule())
    }
}

struct MiloToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button { configuration.isOn.toggle() } label: {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4).fill(.black.opacity(0.8))
                    RoundedRectangle(cornerRadius: 4).strokeBorder(.white.opacity(0.2), lineWidth: 0.8)
                    if configuration.isOn {
                        Image(systemName: "checkmark").font(.system(size: 9, weight: .semibold)).foregroundStyle(.white)
                    }
                }
                .frame(width: 15, height: 15)
                configuration.label
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityValue(configuration.isOn ? "On" : "Off")
    }
}
