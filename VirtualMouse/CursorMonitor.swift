//
//  CursorMonitor.swift
//  VirtualMouse
//
//  Created by Shihao Lei on 2025/10/12.
//

import Foundation
import AppKit

/// Legacy polling monitor kept for reference. No longer used by the application.
final class CursorMonitor {
    func start(interval: TimeInterval = 0.1) { /* no-op */ }
    func stop() { /* no-op */ }
}
