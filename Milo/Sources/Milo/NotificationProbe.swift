import AppKit
import UserNotifications

/// An explicit local diagnostic. It never requests permission or sends an alert.
@MainActor
enum NotificationProbe {
    static func run(output: String) async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        let names: [UNAuthorizationStatus: String] = [
            .notDetermined: "notDetermined", .denied: "denied", .authorized: "authorized", .provisional: "provisional"
        ]
        var report: [String: Any] = ["authorization": names[settings.authorizationStatus] ?? "unknown"]
        if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
            let id = "milo.validation.\(UUID().uuidString)"
            let content = UNMutableNotificationContent()
            content.title = "Milo validation"
            do {
                try await center.add(.init(identifier: id, content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)))
                report["scheduled"] = await center.pendingNotificationRequests().contains { $0.identifier == id }
                center.removePendingNotificationRequests(withIdentifiers: [id])
                report["cancelled"] = await !center.pendingNotificationRequests().contains { $0.identifier == id }
            } catch { report["error"] = error.localizedDescription }
        }
        do {
            try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
                .write(to: URL(fileURLWithPath: output))
        } catch { NSLog("Milo notification check: %@", error.localizedDescription) }
    }
}
