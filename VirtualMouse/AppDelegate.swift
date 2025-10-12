// AppDelegate.swift
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBarController: StatusBarController?
    private var permissionCheckTimer: Timer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 首先检查辅助功能权限
        checkAccessibilityPermission()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        permissionCheckTimer?.invalidate()
    }

    // MARK: - 辅助功能权限检查

    private func checkAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if accessEnabled {
            // 权限已授予，启动应用
            startApplication()
        } else {
            // 显示权限提示对话框
            showPermissionAlert()
        }
    }

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "需要辅助功能权限"
        alert.informativeText = "Virtual Mouse 需要辅助功能权限来监听鼠标事件。\n\n请在系统设置中授予权限：\n系统设置 > 隐私与安全性 > 辅助功能\n\n授予权限后，点击\"重新检查\"按钮。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "重新检查")
        alert.addButton(withTitle: "打开系统设置")
        alert.addButton(withTitle: "退出")

        switch alert.runModal() {
        case .alertFirstButtonReturn:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.checkAccessibilityPermission()
            }

        case .alertSecondButtonReturn:
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
            // 打开设置后，开始定时检查权限
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
                    successAlert.messageText = "权限已授予"
                    successAlert.informativeText = "辅助功能权限已成功授予，应用即将启动。"
                    successAlert.alertStyle = .informational
                    successAlert.addButton(withTitle: "确定")
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
