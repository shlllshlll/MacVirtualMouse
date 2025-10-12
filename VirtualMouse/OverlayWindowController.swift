// OverlayWindowController.swift
import Cocoa

@MainActor
class OverlayWindowController {
    private var window: NSWindow
    private var virtualCursorView: VirtualCursorView
    private var wasMouseInWindow: Bool = false

    init(screen: NSScreen) {
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
        window.level = .screenSaver
        window.isOpaque = false
        window.backgroundColor = .clear
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

        // 仅在鼠标位于此屏幕时刷新虚拟指针
        if mouseInWindow || wasMouseInWindow {
            // 步骤1: 将全局坐标转换为窗口坐标 (原点在左下角)
            let windowX = location.x - windowFrame.origin.x
            let windowY = location.y - windowFrame.origin.y

            // 步骤2: 将窗口坐标转换为视图坐标 (原点在左上角)
            let viewX = windowX
            let viewY = windowFrame.size.height - windowY
            let localPoint = NSPoint(x: viewX, y: viewY)

            wasMouseInWindow = mouseInWindow

            // 调用视图更新
            virtualCursorView.updateCursor(image: image, hotSpot: hotSpot, location: localPoint)
        }
    }
}
