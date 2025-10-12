// StatusBarController.swift
import Cocoa

class StatusBarController {
    private var statusItem: NSStatusItem
    private var mouseEventMonitor: MouseEventMonitor?

    // 使用一个字典来管理每个屏幕对应的覆盖窗口控制器
    // 键是屏幕对象，值是该屏幕的窗口控制器
    private var overlayControllers: [NSScreen: OverlayWindowController] = [:]

    // 调试计数器
    private var mouseEventCount = 0
    private var lastDebugPrintTime: Date?

    init() {
        // 1. 创建状态栏项目
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        // 2. 设置状态栏按钮和菜单
        if let button = statusItem.button {
//            // 将你的图标资源名填入这里
            button.image = NSImage(named: "StatusBarIcon")
//            // 如果是模板图像，确保它能正确响应深色/浅色模式
            button.image?.isTemplate = true
//            button.title = "🖱️"
        }
        buildMenu()

        // 4. 启动全局鼠标事件监听
        startMonitoring()
    }

    private func buildMenu() {
        let menu = NSMenu()

        // --- 创建屏幕选择子菜单 ---
        let screensTitleItem = NSMenuItem(title: "显示在屏幕", action: nil, keyEquivalent: "")
        menu.addItem(screensTitleItem)

        let screensMenu = NSMenu()

        // 遍历所有连接的屏幕
        for (index, screen) in NSScreen.screens.enumerated() {
            // 用屏幕的本地化名称或者索引来命名
            let screenName = screen.localizedName.isEmpty ? "屏幕 \(index + 1)" : screen.localizedName
            let screenItem = NSMenuItem(title: screenName, action: #selector(didSelectScreen(_:)), keyEquivalent: "")
            screenItem.target = self
            screenItem.representedObject = screen // 将屏幕对象关联到菜单项
            screenItem.state = .off // 默认不显示
            screensMenu.addItem(screenItem)
        }

        menu.setSubmenu(screensMenu, for: screensTitleItem)
        menu.addItem(NSMenuItem.separator())

        // --- 创建退出按钮 ---
        let quitItem = NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func didSelectScreen(_ sender: NSMenuItem) {
        guard let screen = sender.representedObject as? NSScreen else { return }

        // 切换菜单项的选中状态
        sender.state = (sender.state == .on) ? .off : .on

        if sender.state == .on {
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("✅ [创建屏幕覆盖层]")
            print("   屏幕名称: \(screen.localizedName)")
            print("   屏幕frame: \(screen.frame)")
            print("   是否主屏幕: \(screen == NSScreen.main)")

            let controller = OverlayWindowController(screen: screen)
            controller.showWindow()
            overlayControllers[screen] = controller

            print("   当前活动覆盖层数: \(overlayControllers.count)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        } else {
            overlayControllers[screen]?.close()
            overlayControllers.removeValue(forKey: screen)
        }
    }

    private func startMonitoring() {
        mouseEventMonitor = MouseEventMonitor { [weak self] event in
            self?.handleMouseEvent(event)
        }
        mouseEventMonitor?.start()
    }

    private var lastCursorImage: NSImage?
    private var cursorChangeCount = 0

    private func handleMouseEvent(_ event: NSEvent) {
        guard !overlayControllers.isEmpty else { return }

        // 将 AppKit 操作调度到主线程，确保线程安全
        let globalLocation = event.locationInWindow
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard !self.overlayControllers.isEmpty else { return }

            // NSCursor.currentSystem 捕捉全局光标形态，不局限于当前应用
            let cursor = NSCursor.currentSystem ?? NSCursor.current
            let image = cursor.image
            let hotSpot = cursor.hotSpot

            // 🔍 问题2调试: 检测光标形态是否变化
            var cursorChanged = false
            if let lastImage = self.lastCursorImage {
                if image.size != lastImage.size {
                    cursorChanged = true
                } else if let newData = image.tiffRepresentation,
                          let oldData = lastImage.tiffRepresentation,
                          newData != oldData {
                    cursorChanged = true
                }
            } else {
                cursorChanged = true
            }

            if cursorChanged {
                self.cursorChangeCount += 1
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("🔄 [光标形态变化 #\(self.cursorChangeCount)]")
                print("   新光标尺寸: \(image.size)")
                print("   旧光标尺寸: \(self.lastCursorImage?.size ?? .zero)")
                print("   新光标热点: \(hotSpot)")
                if let tiffData = image.tiffRepresentation {
                    print("   图像数据大小: \(tiffData.count) bytes")
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                self.lastCursorImage = image
            }

            // 将鼠标事件和光标样式广播给所有活动的覆盖窗口
            for controller in self.overlayControllers.values {
                controller.updateCursor(image: image, hotSpot: hotSpot, location: globalLocation)
            }
        }
    }
}
