//
//  CursorMonitor.swift
//  VirtualMouse
//
//  Created by Shihao Lei on 2025/10/12.
//

import Foundation
import AppKit

class CursorMonitor {
    private var timer: Timer?
    private var lastCursor: NSCursor?
    private let handler: (NSCursor) -> Void
    private var updateCounter = 0

    init(handler: @escaping (NSCursor) -> Void) {
        self.handler = handler
    }

    func start(interval: TimeInterval = 0.1) {
        guard timer == nil else { return }
        print("✅ Cursor monitor started")
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.checkCursor()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        print("⏹️ Cursor monitor stopped")
    }

    private func checkCursor() {
        // NSCursor.current is the recommended way to get the system cursor.
        let currentCursor = NSCursor.current

        // The 'isEqual' check might not work for all custom cursors.
        // A more reliable way is to compare their image representations if direct comparison fails.
        if lastCursor == nil || !areCursorsEqual(cursor1: lastCursor!, cursor2: currentCursor) {
            updateCounter += 1

            // 🔍 问题2调试: 光标形态
            let imageData = currentCursor.image.tiffRepresentation
            let imageHash = imageData?.hashValue ?? 0
            let imageSize = currentCursor.image.size

            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("🔄 [光标形态变化 #\(updateCounter)]")
            print("   - 新光标对象: \(currentCursor)")
            print("   - 图像尺寸: \(imageSize.width)x\(imageSize.height)")
            print("   - 图像数据 Hash: \(imageHash)")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

            self.handler(currentCursor)
            self.lastCursor = currentCursor
        }
    }

    private func areCursorsEqual(cursor1: NSCursor, cursor2: NSCursor) -> Bool {
        // Direct object comparison works for standard system cursors
        if cursor1 == cursor2 {
            return true
        }
        // For custom cursors, comparing image data is a fallback
        if let image1 = cursor1.image.tiffRepresentation, let image2 = cursor2.image.tiffRepresentation {
            return image1 == image2
        }
        return false
    }
}
