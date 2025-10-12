// AppDelegate.swift
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBarController: StatusBarController?
    private var permissionCheckTimer: Timer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // First, check Accessibility permissions
        checkAccessibilityPermission()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        permissionCheckTimer?.invalidate()
    }

    // MARK: - Accessibility permission checks

    private func checkAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if accessEnabled {
            // Permission granted — start the application
            startApplication()
        } else {
            // Show permission prompt dialog
            showPermissionAlert()
        }
    }

    private func showPermissionAlert() {
    let alert = NSAlert()
    alert.messageText = NSLocalizedString("permission_needed_title", comment: "Title for accessibility permission alert")
    alert.informativeText = NSLocalizedString("permission_needed_info", comment: "Informative text for accessibility permission alert")
    alert.alertStyle = .warning
    alert.addButton(withTitle: NSLocalizedString("permission_retry", comment: "Retry button title"))
    alert.addButton(withTitle: NSLocalizedString("permission_open_settings", comment: "Open settings button title"))
    alert.addButton(withTitle: NSLocalizedString("quit", comment: "Quit button title"))

        switch alert.runModal() {
        case .alertFirstButtonReturn:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.checkAccessibilityPermission()
            }

        case .alertSecondButtonReturn:
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
            // After opening Settings, start a timer to poll for permission
            startPermissionCheckTimer()

        default:
            NSApplication.shared.terminate(nil)
        }
    }

    private func startPermissionCheckTimer() {
        permissionCheckTimer?.invalidate()

        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            let accessEnabled = AXIsProcessTrusted()

            if accessEnabled {
                timer.invalidate()
                self.permissionCheckTimer = nil

                DispatchQueue.main.async {
                    let successAlert = NSAlert()
                    successAlert.messageText = NSLocalizedString("permission_granted_title", comment: "Title shown when permission granted")
                    successAlert.informativeText = NSLocalizedString("permission_granted_info", comment: "Info shown when permission granted")
                    successAlert.alertStyle = .informational
                    successAlert.addButton(withTitle: NSLocalizedString("ok", comment: "OK button title"))
                    successAlert.runModal()

                    self.startApplication()
                }
            }
        }
    }

    private func startApplication() {
        statusBarController = StatusBarController()
    }
}
