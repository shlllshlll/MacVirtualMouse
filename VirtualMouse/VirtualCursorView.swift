// VirtualCursorView.swift
import Cocoa

class VirtualCursorView: NSView {
    private var cursorImage: NSImage?
    private var cursorHotSpot: NSPoint = .zero
    private var cursorLocation: NSPoint = .zero

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = false
        self.needsDisplay = true
    }

    override var isFlipped: Bool {
        return true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 公开的更新方法
    public func updateCursor(image: NSImage, hotSpot: NSPoint, location: NSPoint) {
        // 计算需要重绘的区域
        let oldRect = calculateCursorRect()

        // 更新内部状态
        self.cursorImage = image
        self.cursorHotSpot = hotSpot
        self.cursorLocation = location

        let newRect = calculateCursorRect()

        // 通知系统重绘变化的区域
        self.setNeedsDisplay(oldRect)
        self.setNeedsDisplay(newRect)
    }

    // 这是系统调用的绘图方法
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // 获取图形上下文
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        // 清除背景为透明
        context.clear(dirtyRect)

        // 绘制光标图像
        guard let image = cursorImage else { return }

        // 检查光标是否在视图范围内
        guard NSPointInRect(cursorLocation, self.bounds) else { return }

        // 计算绘制位置
        let drawPoint = NSPoint(
            x: cursorLocation.x - cursorHotSpot.x,
            y: cursorLocation.y - cursorHotSpot.y
        )

        // 因为视图使用了 isFlipped = true，需要翻转图像以正确显示
        context.saveGState()
        context.translateBy(x: drawPoint.x, y: drawPoint.y)
        context.translateBy(x: 0, y: image.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        image.draw(at: .zero, from: .zero, operation: .sourceOver, fraction: 1.0)
        context.restoreGState()
    }

    private func calculateCursorRect() -> NSRect {
        guard let image = cursorImage else { return .zero }
        // 使用翻转后的坐标系统
        let drawPoint = NSPoint(
            x: cursorLocation.x - cursorHotSpot.x,
            y: cursorLocation.y - cursorHotSpot.y
        )
        return NSRect(origin: drawPoint, size: image.size)
    }
}
