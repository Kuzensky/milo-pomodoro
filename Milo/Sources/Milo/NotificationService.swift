import AppKit
import Combine
import MiloCore
import UserNotifications

@MainActor
final class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published private(set) var authorization: UNAuthorizationStatus = .notDetermined
    @Published private(set) var message: String?
    @Published private(set) var isRequesting = false
    var onOpen: (() -> Void)?
    private let center = UNUserNotificationCenter.current()
    private var revision = UUID()
    private var soundEnabled = true

    override init() {
        super.init()
        center.delegate = self
    }

    var isAuthorized: Bool { authorization == .authorized || authorization == .provisional }

    func refresh() async {
        authorization = await center.notificationSettings().authorizationStatus
    }

    func requestPermission() async {
        guard !isRequesting else { return }
        isRequesting = true
        defer { isRequesting = false }
        do {
            _ = try await center.requestAuthorization(options: [.alert, .sound])
            message = nil
        } catch {
            message = "Couldn’t enable notifications: \(error.localizedDescription)"
        }
        await refresh()
    }

    func synchronize(_ engine: SessionEngine) {
        let token = UUID()
        revision = token
        soundEnabled = engine.settings.soundEnabled
        // A wake/relaunch can reconcile completion before macOS presents its alert.
        // Preserve that already scheduled request until a new timer or explicit cancellation.
        if engine.phase == .completed && engine.settings.notificationsEnabled { return }
        // Milo owns this notification namespace, including requests left by a previous launch.
        center.removeAllPendingNotificationRequests()
        guard engine.settings.notificationsEnabled, engine.phase == .running,
              let deadline = engine.deadline else { return }
        Task {
            await refresh()
            guard revision == token, isAuthorized else { return }
            let delay = deadline.timeIntervalSinceNow
            guard delay > 0 else { return }
            let content = UNMutableNotificationContent()
            content.title = engine.kind.notificationTitle
            content.body = engine.kind.notificationBody
            content.threadIdentifier = "milo.sessions"
            content.userInfo = ["sessionID": engine.sessionID.uuidString]
            content.sound = engine.settings.soundEnabled ? .default : nil
            // A unique suffix lets an obsolete asynchronous add remove only its own request.
            let id = engine.notificationIdentifier + "." + token.uuidString
            let request = UNNotificationRequest(
                identifier: id,
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: max(1, delay), repeats: false)
            )
            do {
                try await center.add(request)
                if revision != token { center.removePendingNotificationRequests(withIdentifiers: [id]) }
            } catch {
                if revision == token { message = "Couldn’t schedule the alert: \(error.localizedDescription)" }
            }
        }
    }

    func testNotification() async {
        await refresh()
        guard isAuthorized else {
            message = "Allow notifications for Milo in System Settings first."
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "Milo is here."
        content.body = "Your timer alerts are ready. A little focus, together."
        content.sound = soundEnabled ? .default : nil
        do {
            try await center.add(UNNotificationRequest(
                identifier: "milo.notification-test",
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            ))
            message = "Test alert scheduled for three seconds from now."
        } catch {
            message = error.localizedDescription
        }
    }

    func openSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension")!
        if !NSWorkspace.shared.open(url) {
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/System Settings.app"))
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Task { @MainActor in onOpen?() }
        completionHandler()
    }
}
