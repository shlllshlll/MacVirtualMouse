// MouseEventMonitor.swift
import Cocoa

class MouseEventMonitor {
    private var eventTap: CFMachPort?
    private let handler: (NSEvent) -> Void

    init(handler: @escaping (NSEvent) -> Void) {
        self.handler = handler
    }

    deinit {
        stop()
    }

    func start() {
        let eventMask: CGEventMask = (1 << CGEventType.mouseMoved.rawValue) |
                                     (1 << CGEventType.leftMouseDragged.rawValue) |
                                     (1 << CGEventType.rightMouseDragged.rawValue)

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { proxy, type, event, refcon in
                if let refcon = refcon {
                    let monitor = Unmanaged<MouseEventMonitor>.fromOpaque(refcon).takeUnretainedValue()
                    if let nsEvent = NSEvent(cgEvent: event) {
                        monitor.handler(nsEvent)
                    }
                }
                return Unmanaged.passUnretained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )

        if let eventTap = eventTap {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            print("✅ CGEvent tap for mouse events added successfully")
        } else {
            print("⚠️ Failed to create CGEvent tap - might need accessibility permissions")
        }
    }

    func stop() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            // The run loop source is implicitly invalidated when the tap is invalidated.
            // CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            self.eventTap = nil
            print("⏹️ CGEvent tap stopped")
        }
    }
}
