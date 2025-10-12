// main.swift
import AppKit

@main
@MainActor // <--- 关键！告诉系统，所有启动代码都在“VIP房间”里执行
struct VirtualCopyCursorApp {
    
    static func main() {
        // --- 这里的代码和我们之前的 main.swift 完全一样 ---
        // --- 但现在它被 @MainActor 保护，所以是安全的 ---

        // 1. 创建 Application 实例
        let app = NSApplication.shared
        
        // 2. 创建 AppDelegate 实例
        let delegate = AppDelegate()
        
        // 3. 将 delegate 赋值给 app
        //    因为现在我们在 MainActor 环境下，所以这里的赋值是安全的，警告消失！
        app.delegate = delegate
        
        // 4. 运行应用主循环
        app.run()
    }
}
