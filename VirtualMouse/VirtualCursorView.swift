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

    // Public update method
    public func updateCursor(image: NSImage, hotSpot: NSPoint, location: NSPoint) {
        // Calculate the area that needs to be redrawn
        let oldRect = calculateCursorRect()

        // Update internal state
        self.cursorImage = image
        self.cursorHotSpot = hotSpot
        self.cursorLocation = location

        let newRect = calculateCursorRect()

        // Request the system to redraw the changed regions
        self.setNeedsDisplay(oldRect)
        self.setNeedsDisplay(newRect)
    }

    // System-invoked drawing method
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Obtain the graphics context
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        // Clear the background to transparent
        context.clear(dirtyRect)

        // Draw the cursor image
        guard let image = cursorImage else { return }

        // Check whether the cursor is within the view bounds
        guard NSPointInRect(cursorLocation, self.bounds) else { return }

        // Compute the draw position
        let drawPoint = NSPoint(
            x: cursorLocation.x - cursorHotSpot.x,
            y: cursorLocation.y - cursorHotSpot.y
        )

        // Because the view uses isFlipped = true, flip the image vertically for correct display
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
