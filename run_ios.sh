#!/bin/bash

# DogReal iOS 模拟器启动脚本

echo "🐾 DogReal - 启动 iOS 模拟器..."
echo ""

# 检查是否在正确的目录
if [ ! -d "dogreal_app" ]; then
    echo "❌ 错误: 请在 DogReal 根目录运行此脚本"
    exit 1
fi

# 启动 iPhone 16 Pro 模拟器
echo "📱 正在启动 iPhone 16 Pro 模拟器..."
DEVICE_ID="C7F8655C-8240-420B-86D3-007994372F50"
xcrun simctl boot $DEVICE_ID 2>/dev/null || echo "模拟器已在运行"
open -a Simulator

echo "⏳ 等待模拟器启动..."
sleep 3

cd dogreal_app

echo "📦 安装依赖..."
flutter pub get

echo ""
echo "🚀 启动 DogReal 应用..."
echo "提示: 按 'r' 热重载, 按 'R' 热重启, 按 'q' 退出"
echo ""

flutter run -d $DEVICE_ID
