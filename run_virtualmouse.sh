#!/bin/bash

# VirtualMouse 启动脚本

APP_PATH="/Users/shihaolei/Library/Developer/Xcode/DerivedData/VirtualMouse-brtsfohiswaoeuhbbeulogvqncwv/Build/Products/Debug/VirtualMouse.app"

echo "🖱️  启动 Virtual Mouse..."
echo ""

# 检查应用是否存在
if [ ! -d "$APP_PATH" ]; then
    echo "❌ 应用未找到，请先构建项目"
    echo "   运行: xcodebuild -project VirtualMouse.xcodeproj -scheme VirtualMouse -configuration Debug build"
    exit 1
fi

# 关闭已运行的实例
killall VirtualMouse 2>/dev/null
sleep 0.5

# 启动应用并显示日志
echo "✅ 正在启动应用..."
echo "📋 应用日志输出："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 使用 osascript 启动应用，这样可以在终端看到日志
"$APP_PATH/Contents/MacOS/VirtualMouse"
