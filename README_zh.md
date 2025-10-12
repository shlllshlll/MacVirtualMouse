
VirtualMouse
=============

VirtualMouse 是一个 macOS 应用，提供一个“虚拟鼠标”光标层。它用于解决在使用屏幕共享或远程会话软件（例如 Parsec）时，远端无法看到本地鼠标的问题。

为什么要做这个项目
-------------------

一些屏幕共享工具在特定场景下无法正确将 macOS 的本地光标显示给远端客户端。该项目通过在应用层绘制一个虚拟光标，保证在物理光标无法显示给远端时仍能被看见。

项目来源
--------

该项目的想法来自于 [brgj/MouseHook](https://github.com/brgj/MouseHook)。原始项目在许多情况下工作良好，但在诸如 Mission Control 等 macOS 特殊界面下不能正常工作。因此本项目尝试以不同的方式来解决这些边缘情况。

致谢
----

项目大部分代码与文档得到 AI 系统的协助完成：GPT、Gemini 和 Claude。它们显著加快了开发与设计决策的过程。

编译
----

可以通过命令行使用 xcodebuild 编译应用，示例如下：

```bash
xcodebuild -project VirtualMouse.xcodeproj -scheme VirtualMouse -configuration Release build
```

重要文件
--------

应用源码位于 `VirtualMouse/` 目录。关键文件包括：

- `AppDelegate.swift` — 应用生命周期
- `VirtualMouse.swift` — 虚拟鼠标核心实现
- `VirtualCursorView.swift` — 绘制虚拟光标的视图
- `StatusBarController.swift` — 系统状态栏菜单与状态

许可证
----

详见项目根目录下的 `LICENSE` 文件。
