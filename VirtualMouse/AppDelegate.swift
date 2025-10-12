// AppDelegate.swift
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBarController: StatusBarController?
    private var permissionCheckTimer: Timer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 在这里添加你的日志打印语句
        print("✅ applicationDidFinishLaunching has been called!")

        // 首先检查辅助功能权限
        checkAccessibilityPermission()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // 应用退出前，可以做一些清理工作
        print("❌ Application will terminate.")
        permissionCheckTimer?.invalidate()
    }

    // MARK: - 辅助功能权限检查

    private func checkAccessibilityPermission() {
        print("🔍 Checking accessibility permission...")

        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if accessEnabled {
            print("✅ Accessibility permission granted!")
            // 权限已授予，启动应用
            startApplication()
        } else {
            print("⚠️ Accessibility permission not granted. Showing alert...")
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

        let response = alert.runModal()

        switch response {
        case .alertFirstButtonReturn:
            // 重新检查
            print("🔄 User clicked 'Recheck', checking permission again...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.checkAccessibilityPermission()
            }

        case .alertSecondButtonReturn:
            // 打开系统设置
            print("🔧 Opening System Preferences...")
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
            // 打开设置后，开始定时检查权限
            startPermissionCheckTimer()

        default:
            // 退出应用
            print("❌ User chose to quit application")
            NSApplication.shared.terminate(nil)
        }
    }

    private func startPermissionCheckTimer() {
        print("⏱️ Starting permission check timer...")
        permissionCheckTimer?.invalidate()

        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            print("🔍 Timer: Checking accessibility permission...")
            let accessEnabled = AXIsProcessTrusted()

            if accessEnabled {
                print("✅ Timer: Permission granted! Stopping timer and starting application...")
                timer.invalidate()
                self.permissionCheckTimer = nil

                // 显示成功提示
                DispatchQueue.main.async {
                    let successAlert = NSAlert()
                    successAlert.messageText = "权限已授予"
                    successAlert.informativeText = "辅助功能权限已成功授予，应用即将启动。"
                    successAlert.alertStyle = .informational
                    successAlert.addButton(withTitle: "确定")
                    successAlert.runModal()

                    self.startApplication()
                }
            } else {
                print("⏱️ Timer: Permission not granted yet, will check again in 2 seconds...")
            }
        }
    }

    private func startApplication() {
        print("🚀 Starting application with full permissions...")
        // 应用启动时，创建并激活状态栏控制器
        statusBarController = StatusBarController()
        print("✅ StatusBarController instance created.")
    }
}
