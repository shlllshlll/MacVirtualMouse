// DisplayLinkScheduler.swift
import Cocoa
import QuartzCore

/// Bridges display link callbacks into a handler closure, preferring the modern `CADisplayLink` API on macOS 15+ while
/// keeping a CoreVideo fallback for older systems.
final class DisplayLinkScheduler {
    private var cadDisplayLink: CADisplayLink?
    private var cvDisplayLink: CVDisplayLink?
    private let handler: () -> Void

    init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    deinit {
        stop()
    }

    func start() {
        guard cadDisplayLink == nil, cvDisplayLink == nil else { return }

        if #available(macOS 15.0, *) {
            startUsingDisplayLink()
        } else {
            startUsingCoreVideo()
        }
    }

    func stop() {
        if #available(macOS 15.0, *) {
            cadDisplayLink?.invalidate()
            cadDisplayLink = nil
        } else if let displayLink = cvDisplayLink {
            CVDisplayLinkStop(displayLink)
            cvDisplayLink = nil
        }
    }

    @available(macOS 15.0, *)
    private func startUsingDisplayLink() {
        guard let screen = NSScreen.main else { return }

        let displayLink = screen.displayLink(target: self, selector: #selector(step(_:)))
        displayLink.add(to: .main, forMode: .common)
        cadDisplayLink = displayLink
    }

    @available(macOS, deprecated: 15.0)
    private func startUsingCoreVideo() {
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

        cvDisplayLink = displayLink
    }

    @available(macOS 15.0, *)
    @objc private func step(_ displayLink: CADisplayLink) {
        handler()
    }
}
