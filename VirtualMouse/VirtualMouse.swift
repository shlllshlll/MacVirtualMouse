// VirtualMouse.swift
import AppKit

@main
@MainActor // <--- Important! Informs the system that all startup code runs on the MainActor (main actor context)
struct VirtualCopyCursorApp {

    static func main() {
        // --- This code is exactly the same as our previous main.swift ---
        // --- But now it is protected by @MainActor, so it is safe ---

        // 1. Create the Application instance
        let app = NSApplication.shared

        // 2. Create an AppDelegate instance
        let delegate = AppDelegate()

        // 3. Assign the delegate to the app
        //    Since we are now in the MainActor context, this assignment is safe and the warning is gone!
        app.delegate = delegate

        // 4. Run the application's main loop
        app.run()
    }
}
