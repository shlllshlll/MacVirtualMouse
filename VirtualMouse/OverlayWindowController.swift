// OverlayWindowController.swift
import Cocoa

class OverlayWindowController {
    private var window: NSWindow
    private var virtualCursorView: VirtualCursorView
    private var screenName: String
    private var screenFrame: NSRect
    private var wasMouseInWindow: Bool = false

    init(screen: NSScreen) {
        self.screenName = screen.localizedName
        self.screenFrame = screen.frame

        // 关键：视图的坐标系应该从 (0,0) 开始，而不是屏幕的全局坐标
        let viewFrame = NSRect(origin: .zero, size: screen.frame.size)

        // 1. 创建我们的自定义绘图视图
        self.virtualCursorView = VirtualCursorView(frame: viewFrame)

        // 2. 创建窗口，frame 初始使用屏幕局部坐标，随后再对齐到全局 frame
        let localRect = NSRect(origin: .zero, size: screen.frame.size)
        self.window = NSWindow(
            contentRect: localRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )

        // 3. 配置窗口关键属性
        window.level = .floating
        window.isOpaque = false
        // 🔍 可视化调试: 设置一个半透明的背景色，方便观察窗口位置和大小
        window.backgroundColor = NSColor.red.withAlphaComponent(0.2)
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.hasShadow = false
        window.isReleasedWhenClosed = false
        window.alphaValue = 1.0

        // 窗口 frame 必须设置为当前屏幕的全局坐标，否则在非主显示器上会偏移
        window.setFrame(screen.frame, display: false)

        // 4. 将自定义视图设置为窗口的内容视图
        window.contentView = virtualCursorView
    }

    func showWindow() {
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        window.contentView?.needsDisplay = true
    }

    func close() {
        window.close()
    }

    // 公开接口，用于更新光标状态
    func updateCursor(image: NSImage, hotSpot: NSPoint, location: NSPoint) {
        let windowFrame = window.frame
        let mouseInWindow = NSPointInRect(location, windowFrame)

        // 只有当鼠标进入或离开此屏幕窗口，或者在窗口内移动时，才更新并记录日志
        if mouseInWindow || wasMouseInWindow {
            // 步骤1: 将全局坐标转换为窗口坐标 (原点在左下角)
            let windowX = location.x - windowFrame.origin.x
            let windowY = location.y - windowFrame.origin.y

            // 步骤2: 将窗口坐标转换为视图坐标 (原点在左上角)
            let viewX = windowX
            let viewY = windowFrame.size.height - windowY
            let localPoint = NSPoint(x: viewX, y: viewY)

            // 当鼠标状态（进入/离开）改变时，打印详细日志
            if mouseInWindow != wasMouseInWindow {
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("🖱️ [屏幕变化 - \(screenName)]")
                print("   - 状态: 鼠标\(mouseInWindow ? "进入" : "离开")此屏幕")
                print("   - 全局位置: (x: \(String(format: "%.1f", location.x)), y: \(String(format: "%.1f", location.y)))")
                print("   - 屏幕 Frame: (x: \(String(format: "%.1f", windowFrame.origin.x)), y: \(String(format: "%.1f", windowFrame.origin.y)), w: \(String(format: "%.1f", windowFrame.width)), h: \(String(format: "%.1f", windowFrame.height)))")
                print("   - 转换后视图坐标: (x: \(String(format: "%.1f", localPoint.x)), y: \(String(format: "%.1f", localPoint.y)))")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            }

            wasMouseInWindow = mouseInWindow

            // 调用视图更新
            virtualCursorView.updateCursor(image: image, hotSpot: hotSpot, location: localPoint)
        }
    }
}
