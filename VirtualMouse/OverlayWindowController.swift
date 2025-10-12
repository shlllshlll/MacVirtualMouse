// OverlayWindowController.swift
import Cocoa

@MainActor
class OverlayWindowController {
    private var window: NSWindow
    private var virtualCursorView: VirtualCursorView
    private var wasMouseInWindow: Bool = false

    init(screen: NSScreen) {
    // Important: the view's coordinate system should start at (0,0), not the screen's global origin
        let viewFrame = NSRect(origin: .zero, size: screen.frame.size)

    // 1. Create our custom drawing view
        self.virtualCursorView = VirtualCursorView(frame: viewFrame)

    // 2. Create the window using screen-local coordinates for the initial frame, then align to the global frame
        let localRect = NSRect(origin: .zero, size: screen.frame.size)
        self.window = NSWindow(
            contentRect: localRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )

    // 3. Configure important window properties
        window.level = .screenSaver
        window.isOpaque = false
        window.backgroundColor = .clear
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.hasShadow = false
        window.isReleasedWhenClosed = false
        window.alphaValue = 1.0

    // The window frame must be set to the screen's global frame; otherwise it will be offset on secondary displays
    window.setFrame(screen.frame, display: false)

    // 4. Set the custom view as the window's content view
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

    // Public API to update the cursor state
    func updateCursor(image: NSImage, hotSpot: NSPoint, location: NSPoint) {
        let windowFrame = window.frame
        let mouseInWindow = NSPointInRect(location, windowFrame)

        // Only refresh the virtual cursor when the mouse is on this screen
        if mouseInWindow || wasMouseInWindow {
            // Step 1: convert global coordinates to window coordinates (origin at bottom-left)
            let windowX = location.x - windowFrame.origin.x
            let windowY = location.y - windowFrame.origin.y

            // Step 2: convert window coordinates to view coordinates (origin at top-left)
            let viewX = windowX
            let viewY = windowFrame.size.height - windowY
            let localPoint = NSPoint(x: viewX, y: viewY)

            wasMouseInWindow = mouseInWindow

            // Invoke the view update
            virtualCursorView.updateCursor(image: image, hotSpot: hotSpot, location: localPoint)
        }
    }
}
