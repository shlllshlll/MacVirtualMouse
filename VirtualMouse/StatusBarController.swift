// StatusBarController.swift
import Cocoa

@MainActor
final class StatusBarController {
    private let statusItem: NSStatusItem
    private var overlayControllers: [NSScreen: OverlayWindowController] = [:]
    private lazy var displayLink = DisplayLinkScheduler { [weak self] in
        self?.refreshCursorSnapshot()
    }

    private var lastCursorIdentifier: ObjectIdentifier?
    private var lastHotSpot: NSPoint = .zero
    private var lastLocation: NSPoint = .zero

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarIcon")
            button.image?.isTemplate = true
        }
        buildMenu()
    }

    private func buildMenu() {
        let menu = NSMenu()

        for (index, screen) in NSScreen.screens.enumerated() {
            let defaultScreenName = String(format: NSLocalizedString("screen_format", comment: "Default screen name with index"), index + 1)
            let screenName = screen.localizedName.isEmpty ? defaultScreenName : screen.localizedName
            let screenItem = NSMenuItem(title: screenName, action: #selector(didToggleScreen(_:)), keyEquivalent: "")
            screenItem.target = self
            screenItem.representedObject = screen
            screenItem.state = overlayControllers[screen] == nil ? .off : .on
            menu.addItem(screenItem)
        }

        if !menu.items.isEmpty {
            menu.addItem(NSMenuItem.separator())
        }
    let quitItem = NSMenuItem(title: NSLocalizedString("quit", comment: "Quit menu item title"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func didToggleScreen(_ sender: NSMenuItem) {
        guard let screen = sender.representedObject as? NSScreen else { return }

        if overlayControllers[screen] == nil {
            let controller = OverlayWindowController(screen: screen)
            controller.showWindow()
            overlayControllers[screen] = controller
            sender.state = .on
        } else {
            overlayControllers[screen]?.close()
            overlayControllers.removeValue(forKey: screen)
            sender.state = .off
        }

        syncDisplayLinkState()
        refreshCursorSnapshot(force: true)
    }

    private func syncDisplayLinkState() {
        if overlayControllers.isEmpty {
            displayLink.stop()
            lastCursorIdentifier = nil
            lastLocation = .zero
            lastHotSpot = .zero
        } else {
            displayLink.start()
        }
    }

    private func refreshCursorSnapshot(force: Bool = false) {
        guard !overlayControllers.isEmpty else { return }

        let cursor = NSCursor.currentSystem ?? NSCursor.current
        let image = cursor.image
        let hotSpot = cursor.hotSpot
        let location = NSEvent.mouseLocation
        let identifier = ObjectIdentifier(image)

        let cursorChanged = lastCursorIdentifier != identifier || !NSEqualPoints(lastHotSpot, hotSpot)
        let locationChanged = !NSEqualPoints(lastLocation, location)

        guard force || cursorChanged || locationChanged else { return }

        lastCursorIdentifier = identifier
        lastHotSpot = hotSpot
        lastLocation = location

        for controller in overlayControllers.values {
            controller.updateCursor(image: image, hotSpot: hotSpot, location: location)
        }
    }
}
