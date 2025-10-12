

VirtualMouse
=============

[中文](README_zh.md)

VirtualMouse is a small macOS application that provides a virtual mouse cursor. It is intended to solve the missing-cursor problem that appears when using screen-sharing or remote-session software such as Parsec.

Why this project
-----------------

Some screen sharing tools (for example Parsec) do not display the local macOS cursor correctly to remote clients in certain scenarios. This project provides a virtual cursor layer that remains visible when the physical cursor cannot be shown to the remote side.

Origin
------

The idea for this project was inspired by [brgj/MouseHook](https://github.com/brgj/MouseHook). The original project works well in many cases but fails to function correctly on special macOS pages and features (for example Mission Control). VirtualMouse implements a different approach to address those edge cases.

Credits
-------

The majority of this project's code and documentation was produced with the assistance of AI systems: GPT, Gemini and Claude. Their contributions helped accelerate development and design decisions.

Build
-----

To build the app from the command line use xcodebuild. Example:

```bash
xcodebuild -project VirtualMouse.xcodeproj -scheme VirtualMouse -configuration Release build
```

Files of interest
-----------------

The macOS app source is located under the `VirtualMouse/` folder. Notable files include:

- `AppDelegate.swift` — application lifecycle
- `VirtualMouse.swift` — core virtual mouse implementation
- `VirtualCursorView.swift` — view that draws the virtual cursor
- `StatusBarController.swift` — status bar menu and state

License
-------

See the project `LICENSE` file for license details.
