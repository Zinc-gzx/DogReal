#!/bin/bash

# DogReal 快速启动脚本

echo "🐾 启动 DogReal 应用..."
echo ""

# 检查是否在正确的目录
if [ ! -d "dogreal_app" ]; then
    echo "❌ 错误: 请在 DogReal 根目录运行此脚本"
    exit 1
fi

cd dogreal_app

# 检查 Flutter 是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ 错误: Flutter 未安装"
    echo "请运行: brew install --cask flutter"
    exit 1
fi

echo "✅ Flutter 已安装"
echo ""

# 获取依赖
echo "📦 安装依赖..."
flutter pub get
echo ""

# 检查可用设备
echo "📱 检查可用设备..."
flutter devices
echo ""

# 运行应用
echo "🚀 启动应用..."
flutter run

