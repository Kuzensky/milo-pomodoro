import Foundation
import XCTest
@testable import MiloCore

final class SessionEngineTests: XCTestCase {
    private let epoch = Date(timeIntervalSince1970: 1_800_000_000)

    func testPauseResumePreservesRemainingTimeAndSessionIdentity() {
        var engine = SessionEngine()
        let id = engine.sessionID
        engine.start(at: epoch)
        engine.pause(at: epoch.addingTimeInterval(120))
        XCTAssertEqual(engine.phase, .paused)
        XCTAssertEqual(engine.remaining, 1_380)
        XCTAssertNil(engine.deadline)
        engine.start(at: epoch.addingTimeInterval(1_000))
        XCTAssertEqual(engine.sessionID, id)
        XCTAssertEqual(engine.secondsRemaining(at: epoch.addingTimeInterval(1_030)), 1_350)
    }

    func testSleepAndRelaunchCompleteExactlyOnceAtOriginalDeadline() throws {
        var engine = SessionEngine()
        engine.start(at: epoch)
        let bytes = try JSONEncoder().encode(engine)
        var restored = try JSONDecoder().decode(SessionEngine.self, from: bytes)
        XCTAssertTrue(restored.reconcile(at: epoch.addingTimeInterval(86_400)))
        XCTAssertFalse(restored.reconcile(at: epoch.addingTimeInterval(172_800)))
        XCTAssertEqual(restored.completions.count, 1)
        XCTAssertEqual(restored.completions.first?.date, epoch.addingTimeInterval(1_500))
        XCTAssertEqual(restored.phase, .completed)
    }

    func testPauseAfterDeadlineCompletesInsteadOfCreatingStalePause() {
        var engine = SessionEngine()
        engine.start(at: epoch)
        engine.pause(at: epoch.addingTimeInterval(1_501))
        XCTAssertEqual(engine.phase, .completed)
        XCTAssertEqual(engine.completions.count, 1)
    }

    func testLatePauseClickNeverAutomaticallyStartsTheNextBreak() {
        var engine = SessionEngine()
        engine.performPrimaryAction(at: epoch)
        XCTAssertTrue(engine.performPrimaryAction(at: epoch.addingTimeInterval(1_501)))
        XCTAssertEqual(engine.phase, .completed)
        XCTAssertEqual(engine.kind, .focus)
        XCTAssertNil(engine.deadline)
        // Starting the next timer requires a separate, explicit action.
        XCTAssertFalse(engine.performPrimaryAction(at: epoch.addingTimeInterval(1_502)))
        XCTAssertEqual(engine.kind, .shortBreak)
        XCTAssertEqual(engine.phase, .running)
    }

    func testResetAndModeChangeInvalidateScheduledNotificationIdentity() {
        var engine = SessionEngine()
        engine.start(at: epoch)
        let old = engine.notificationIdentifier
        engine.reset()
        XCTAssertNil(engine.deadline)
        XCTAssertNotEqual(engine.notificationIdentifier, old)
        engine.select(.shortBreak)
        XCTAssertEqual(engine.remaining, 300)
        XCTAssertEqual(engine.phase, .ready)
        XCTAssertFalse(engine.reconcile(at: epoch.addingTimeInterval(10_000)))
        XCTAssertTrue(engine.completions.isEmpty)
    }

    func testFourFocusSessionsRecommendLongBreakAndBreaksDoNotCountAsFocus() {
        var engine = SessionEngine()
        for index in 0..<4 {
            engine.select(.focus)
            let start = epoch.addingTimeInterval(Double(index * 2_000))
            engine.start(at: start)
            engine.reconcile(at: start.addingTimeInterval(1_501))
        }
        XCTAssertEqual(engine.nextKind, .longBreak)
        engine.start(at: epoch.addingTimeInterval(10_000))
        XCTAssertEqual(engine.kind, .longBreak)
        engine.reconcile(at: epoch.addingTimeInterval(11_000))
        XCTAssertEqual(engine.completions.count, 4)
        XCTAssertEqual(engine.focusSessionsSinceLongBreak, 0)
        XCTAssertEqual(engine.nextKind, .focus)
    }

    func testSettingsDoNotChangeRunningOrPausedSessionDuration() {
        var engine = SessionEngine()
        engine.start(at: epoch)
        var settings = engine.settings
        settings.focusMinutes = 50
        engine.updateSettings(settings)
        XCTAssertEqual(engine.duration, 1_500)
        engine.pause(at: epoch.addingTimeInterval(100))
        engine.updateSettings(settings)
        XCTAssertEqual(engine.remaining, 1_400)
        engine.reset()
        XCTAssertEqual(engine.duration, 3_000)
    }

    func testDailyCountUsesActualDeadlineAndLocalMidnight() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Manila")!
        let midnight = calendar.date(from: DateComponents(year: 2026, month: 10, day: 22))!
        var engine = SessionEngine()
        engine.start(at: midnight.addingTimeInterval(-1_600))
        engine.reconcile(at: midnight.addingTimeInterval(5_000))
        XCTAssertEqual(engine.completedToday(at: midnight, calendar: calendar), 0)
        XCTAssertEqual(engine.completedToday(at: midnight.addingTimeInterval(-1), calendar: calendar), 1)
    }

    func testDSTCompletionUsesCalendarDaysRatherThanTwentyFourHourBuckets() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        let start = calendar.date(from: DateComponents(year: 2026, month: 11, day: 1, hour: 1, minute: 45))!
        var engine = SessionEngine()
        engine.start(at: start)
        engine.reconcile(at: start.addingTimeInterval(3_600))
        let evening = calendar.date(from: DateComponents(year: 2026, month: 11, day: 1, hour: 23))!
        XCTAssertEqual(engine.completedToday(at: evening, calendar: calendar), 1)
    }

    func testPausedSessionCanRoundTripWithoutAdvancingWhileAppIsClosed() throws {
        var engine = SessionEngine()
        engine.start(at: epoch)
        engine.pause(at: epoch.addingTimeInterval(40))
        let restored = try JSONDecoder().decode(SessionEngine.self, from: JSONEncoder().encode(engine))
        XCTAssertEqual(restored.secondsRemaining(at: epoch.addingTimeInterval(100_000)), 1_460)
    }
}
