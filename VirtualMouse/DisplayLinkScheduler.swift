// DisplayLinkScheduler.swift
import Cocoa
import CoreVideo

/// Bridges a `CVDisplayLink` callback into a main-thread closure so cursor updates stay in sync with the display refresh rate.
final class DisplayLinkScheduler {
    private var displayLink: CVDisplayLink?
    private let handler: () -> Void

    init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    deinit {
        stop()
    }

    func start() {
        guard displayLink == nil else { return }

        var link: CVDisplayLink?
        let creationResult = CVDisplayLinkCreateWithActiveCGDisplays(&link)

        guard creationResult == kCVReturnSuccess, let displayLink = link else {
            return
        }

        let handlerResult = CVDisplayLinkSetOutputHandler(displayLink) { [weak self] _, _, _, _, _ in
            guard let handler = self?.handler else {
                return kCVReturnSuccess
            }
            DispatchQueue.main.async(execute: handler)
            return kCVReturnSuccess
        }

        guard handlerResult == kCVReturnSuccess else {
            return
        }

        let startResult = CVDisplayLinkStart(displayLink)
        guard startResult == kCVReturnSuccess else {
            CVDisplayLinkStop(displayLink)
            return
        }

        self.displayLink = displayLink
    }

    func stop() {
        guard let displayLink = displayLink else { return }
        CVDisplayLinkStop(displayLink)
        self.displayLink = nil
    }
}
