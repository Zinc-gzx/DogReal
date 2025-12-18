# DogReal 开发命令速查表

## 🚀 快速启动

```bash
# 启动应用 (推荐)
./run_ios.sh

# 或者手动启动
cd dogreal_app && flutter run
```

---

## 📱 Flutter 命令

### 基础命令
```bash
# 查看 Flutter 版本
flutter --version

# 检查环境配置
flutter doctor

# 查看可用设备
flutter devices

# 查看可用模拟器
flutter emulators
```

### 项目管理
```bash
# 获取依赖
flutter pub get

# 更新依赖
flutter pub upgrade

# 清理项目
flutter clean

# 代码分析
flutter analyze

# 格式化代码
flutter format lib/
```

### 运行和构建
```bash
# 运行应用 (自动选择设备)
flutter run

# 在特定设备上运行
flutter run -d <device_id>

# 在 iOS 模拟器上运行
flutter run -d C7F8655C-8240-420B-86D3-007994372F50

# 构建 iOS (模拟器)
flutter build ios --simulator --debug

# 构建 iOS (真机)
flutter build ios --release

# 构建 Android APK
flutter build apk

# 构建 Android App Bundle
flutter build appbundle
```

---

## 🎮 运行时快捷键

运行 `flutter run` 后可用的快捷键:

```
r  - 热重载 (Hot reload)
R  - 热重启 (Hot restart)
h  - 显示帮助
p  - 切换网格叠加层
o  - 切换平台 (iOS/Android)
P  - 显示性能叠加层
i  - 切换 Widget Inspector
q  - 退出应用
```

---

## 🔧 iOS 模拟器命令

```bash
# 列出所有模拟器
xcrun simctl list devices

# 启动特定模拟器
xcrun simctl boot <UDID>

# 打开模拟器应用
open -a Simulator

# 重置模拟器
xcrun simctl erase all

# 截图
xcrun simctl io booted screenshot screenshot.png
```

---

## 📦 依赖管理

```bash
# 添加新依赖 (在 pubspec.yaml 中添加后)
flutter pub get

# 搜索包
https://pub.dev

# 查看过期的包
flutter pub outdated

# 升级特定包
flutter pub upgrade <package_name>
```

---

## 🛠 故障排查

```bash
# 清理并重新获取依赖
flutter clean
flutter pub get

# 重新构建 iOS Pods
cd ios
pod deintegrate
pod install
cd ..

# 重置 Flutter
flutter clean
flutter pub cache repair

# 检查 Flutter 环境
flutter doctor -v
```

---

## 📝 Git 命令

```bash
# 查看状态
git status

# 添加所有更改
git add .

# 提交
git commit -m "描述你的更改"

# 推送到远程
git push origin main

# 查看提交历史
git log --oneline

# 创建新分支
git checkout -b feature/新功能名称
```

---

## 🔍 调试命令

```bash
# 启用详细日志
flutter run --verbose

# 查看应用日志
flutter logs

# 打开 DevTools
flutter pub global activate devtools
flutter pub global run devtools

# 分析应用性能
flutter run --profile
```

---

## 📊 测试命令

```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/widget_test.dart

# 查看测试覆盖率
flutter test --coverage

# 运行集成测试
flutter drive --target=test_driver/app.dart
```

---

## 🎨 代码质量

```bash
# 格式化所有 Dart 文件
flutter format .

# 检查代码问题
flutter analyze

# 修复可自动修复的问题
dart fix --apply
```

---

## 📱 iOS 特定命令

```bash
# 清理 iOS 构建
rm -rf ios/Pods ios/Podfile.lock
cd ios && pod install && cd ..

# 打开 Xcode 项目
open ios/Runner.xcworkspace

# 查看 iOS 证书
security find-identity -v -p codesigning
```

---

## 🤖 Android 特定命令

```bash
# 清理 Android 构建
cd android && ./gradlew clean && cd ..

# 打开 Android Studio 项目
open -a "Android Studio" android/

# 列出已连接的 Android 设备
adb devices

# 查看 Android 日志
adb logcat
```

---

## 🔐 环境变量

```bash
# 添加 Flutter 到 PATH (在 ~/.zshrc 中)
export PATH="$PATH:/opt/homebrew/bin/flutter/bin"

# 重新加载配置
source ~/.zshrc

# 查看 Flutter 路径
which flutter
```

---

## 💡 常用组合命令

```bash
# 完全重置并运行
flutter clean && flutter pub get && flutter run

# 构建前检查
flutter analyze && flutter test && flutter build ios --simulator

# 更新并运行
flutter pub upgrade && flutter run
```

---

## 📚 有用的链接

- Flutter 官方文档: https://docs.flutter.dev/
- Dart 包管理: https://pub.dev/
- Flutter API 文档: https://api.flutter.dev/
- Flutter GitHub: https://github.com/flutter/flutter

---

## 🆘 常见问题快速解决

```bash
# 问题: "Waiting for another flutter command..."
killall -9 dart

# 问题: Pod install 失败
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# 问题: 构建缓存问题
flutter clean
rm -rf build/

# 问题: 依赖冲突
flutter pub get --verbose
```

---

**提示**: 将此文件加入书签，方便随时查阅！
