import Foundation

public enum SessionKind: String, Codable, CaseIterable, Sendable {
    case focus, shortBreak, longBreak

    public var title: String {
        switch self {
        case .focus: "Focus"
        case .shortBreak: "Short break"
        case .longBreak: "Long break"
        }
    }

    public var notificationTitle: String {
        self == .focus ? "Time for a little rest." : "Ready for a little focus?"
    }

    public var notificationBody: String {
        self == .focus
            ? "You finished a focus session. Milo is ready for a break with you."
            : "Your break is complete. Milo is here when you’re ready."
    }
}

public enum SessionPhase: String, Codable, Sendable {
    case ready, running, paused, completed
}

public enum PanelLayout: String, Codable, CaseIterable, Sendable {
    case compact, companion
    public var title: String { rawValue.capitalized }
}

public struct MiloSettings: Codable, Equatable, Sendable {
    public var focusMinutes = 25
    public var shortBreakMinutes = 5
    public var longBreakMinutes = 15
    public var longBreakEvery = 4
    public var dailyGoal = 4
    public var notificationsEnabled = true
    public var soundEnabled = true
    public var animationEnabled = true
    public var layout: PanelLayout = .compact

    public init() {}

    public func duration(for kind: SessionKind) -> TimeInterval {
        let minutes: Int
        switch kind {
        case .focus: minutes = focusMinutes
        case .shortBreak: minutes = shortBreakMinutes
        case .longBreak: minutes = longBreakMinutes
        }
        return TimeInterval(max(1, min(180, minutes)) * 60)
    }

    public mutating func normalize() {
        focusMinutes = max(1, min(180, focusMinutes))
        shortBreakMinutes = max(1, min(180, shortBreakMinutes))
        longBreakMinutes = max(1, min(180, longBreakMinutes))
        longBreakEvery = max(1, min(12, longBreakEvery))
        dailyGoal = max(1, min(24, dailyGoal))
    }
}

public struct FocusCompletion: Codable, Equatable, Sendable {
    public let sessionID: UUID
    public let date: Date
    public let duration: TimeInterval
}

public struct SessionEngine: Codable, Equatable, Sendable {
    public private(set) var settings: MiloSettings
    public private(set) var kind: SessionKind
    public private(set) var phase: SessionPhase
    public private(set) var sessionID: UUID
    public private(set) var duration: TimeInterval
    public private(set) var remaining: TimeInterval
    public private(set) var deadline: Date?
    public private(set) var completions: [FocusCompletion]
    public private(set) var focusSessionsSinceLongBreak: Int

    public init(settings: MiloSettings = .init()) {
        var safeSettings = settings
        safeSettings.normalize()
        self.settings = safeSettings
        kind = .focus
        phase = .ready
        sessionID = UUID()
        duration = safeSettings.duration(for: .focus)
        remaining = duration
        deadline = nil
        completions = []
        focusSessionsSinceLongBreak = 0
    }

    public var nextKind: SessionKind {
        guard kind == .focus else { return .focus }
        return focusSessionsSinceLongBreak >= settings.longBreakEvery ? .longBreak : .shortBreak
    }

    public var notificationIdentifier: String { "milo.session.\(sessionID.uuidString)" }

    public func secondsRemaining(at now: Date) -> TimeInterval {
        if phase == .running, let deadline { return max(0, deadline.timeIntervalSince(now)) }
        return remaining
    }

    public func completedToday(at now: Date, calendar: Calendar = .current) -> Int {
        // History follows the user's current local calendar/time zone.
        completions.filter { calendar.isDate($0.date, inSameDayAs: now) }.count
    }

    public mutating func select(_ kind: SessionKind) {
        self.kind = kind
        sessionID = UUID()
        duration = settings.duration(for: kind)
        remaining = duration
        deadline = nil
        phase = .ready
    }

    public mutating func start(at now: Date) {
        guard phase != .running else { return }
        if phase == .completed { select(nextKind) }
        deadline = now.addingTimeInterval(remaining)
        phase = .running
    }

    public mutating func pause(at now: Date) {
        guard phase == .running else { return }
        if reconcile(at: now) { return }
        remaining = secondsRemaining(at: now)
        deadline = nil
        phase = .paused
    }

    /// A late Pause click must finish the current session, never auto-start a break.
    @discardableResult
    public mutating func performPrimaryAction(at now: Date) -> Bool {
        if phase == .running {
            pause(at: now)
            return phase == .completed
        }
        start(at: now)
        return false
    }

    public mutating func reset() { select(kind) }

    /// Completes at most one real session, even after a long sleep or relaunch.
    @discardableResult
    public mutating func reconcile(at now: Date) -> Bool {
        guard phase == .running, let deadline, deadline <= now else { return false }
        if kind == .focus {
            if !completions.contains(where: { $0.sessionID == sessionID }) {
                completions.append(.init(sessionID: sessionID, date: deadline, duration: duration))
                focusSessionsSinceLongBreak += 1
            }
        } else if kind == .longBreak {
            focusSessionsSinceLongBreak = 0
        }
        remaining = 0
        self.deadline = nil
        phase = .completed
        return true
    }

    public mutating func updateSettings(_ newSettings: MiloSettings) {
        settings = newSettings
        settings.normalize()
        // A running/paused session retains the duration it started with.
        if phase == .ready { select(kind) }
    }

    /// Validate persisted data before trusting a running timer.
    public mutating func repairIfNeeded() {
        settings.normalize()
        if !duration.isFinite || !remaining.isFinite || duration <= 0 || remaining < 0 ||
            (phase == .running && deadline == nil) {
            select(kind)
        }
        remaining = min(remaining, duration)
        if phase != .running { deadline = nil }
        focusSessionsSinceLongBreak = max(0, focusSessionsSinceLongBreak)
    }
}
