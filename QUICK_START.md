# 🐾 DogReal - 快速开始指南

## 🎉 恭喜！你的 DogReal 应用已经搭建完成！

### ✅ 已完成的功能

1. **登录页面** - BeReal 风格的黑色主题登录界面
2. **注册页面** - 完整的用户注册流程
3. **UI 组件库** - 可复用的自定义组件
4. **表单验证** - 完善的输入验证系统

---

## 🚀 如何运行应用

### 方法 1: 使用快速启动脚本 (推荐)

```bash
./run_ios.sh
```

这个脚本会:
- ✅ 启动 iPhone 16 Pro 模拟器
- ✅ 安装依赖
- ✅ 运行应用

### 方法 2: 手动启动

1. 启动模拟器:
```bash
open -a Simulator
```

2. 运行应用:
```bash
cd dogreal_app
flutter run
```

### 方法 3: 在真机上运行

1. 连接 iPhone 到 Mac
2. 信任设备
3. 运行:
```bash
cd dogreal_app
flutter run
```

---

## 📱 应用截图预览

启动应用后，你将看到:

### 登录页面
- 🎨 黑色背景 + 白色文字 (BeReal 风格)
- 📧 邮箱输入框
- 🔒 密码输入框 (可切换可见性)
- 🔘 登录按钮 (带加载状态)
- 🍎 Apple 登录按钮 (预留)
- 🔗 "立即注册" 链接

### 注册页面
- 👤 用户名输入
- 📧 邮箱输入
- 🔒 密码输入
- ✅ 密码确认
- 📝 服务条款同意复选框
- 🔘 注册按钮
- 🍎 Apple 注册按钮 (预留)

---

## 🎮 开发模式快捷键

运行应用后，在终端中可以使用:

- **r** - 热重载 (快速更新 UI)
- **R** - 热重启 (完全重启应用)
- **p** - 显示网格叠加层
- **o** - 切换平台 (iOS/Android)
- **q** - 退出应用

---

## 📝 测试账号

目前登录/注册是模拟的，你可以输入任何符合格式的信息:

- 邮箱: 任何格式正确的邮箱 (例: `test@dogreal.com`)
- 密码: 至少 6 个字符 (例: `123456`)
- 用户名: 至少 2 个字符

点击登录/注册按钮会显示 2 秒的加载动画，然后显示成功消息。

---

## 🛠 开发技巧

### 修改 UI 样式

所有样式定义在 `lib/utils/constants.dart`:

```dart
// 修改主题颜色
class AppColors {
  static const Color primary = Color(0xFFFFFFFF);
  // ...
}

// 修改文字大小
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    // ...
  );
}
```

### 添加新页面

1. 在 `lib/screens/` 创建新文件
2. 使用 `Navigator.push` 导航

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
);
```

### 添加新组件

在 `lib/widgets/` 创建可复用的组件:

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // ...
    );
  }
}
```

---

## 📂 项目结构说明

```
dogreal_app/
├── lib/
│   ├── main.dart              # 应用入口，包含主题配置
│   ├── screens/               # 所有页面
│   │   ├── login_screen.dart  # 登录页面
│   │   └── register_screen.dart # 注册页面
│   ├── widgets/               # 可复用组件
│   │   ├── custom_button.dart # 自定义按钮
│   │   └── custom_textfield.dart # 自定义输入框
│   └── utils/
│       └── constants.dart     # 颜色、样式、间距等常量
```

---

## 🔜 下一步开发任务

### 1. 后端 API (优先级: 高)
- [ ] 创建 Node.js + Express 项目
- [ ] 实现用户注册/登录 API
- [ ] JWT 认证
- [ ] MongoDB 数据库连接

### 2. 集成后端 (优先级: 高)
- [ ] 创建 API 服务类 (`lib/services/`)
- [ ] 实现真实的登录/注册逻辑
- [ ] Token 存储和管理

### 3. 主页功能 (优先级: 中)
- [ ] 相机界面
- [ ] 双镜头拍照
- [ ] 照片预览和编辑

### 4. 推送通知 (优先级: 中)
- [ ] Firebase Cloud Messaging 配置
- [ ] 每日随机时间推送
- [ ] 通知权限请求

### 5. 社交功能 (优先级: 低)
- [ ] 好友系统
- [ ] 照片浏览
- [ ] 评论和反应

---

## 📚 学习资源

- [Flutter 官方文档](https://docs.flutter.dev/)
- [Dart 语言指南](https://dart.dev/guides)
- [Flutter Widget 目录](https://docs.flutter.dev/ui/widgets)
- [Material Design 3](https://m3.material.io/)

---

## 🐛 常见问题

### Q: 模拟器启动失败？
```bash
# 重置模拟器
xcrun simctl erase all
```

### Q: 热重载不工作？
按 `R` 进行热重启，或重新运行 `flutter run`

### Q: 出现包依赖错误？
```bash
cd dogreal_app
flutter clean
flutter pub get
```

### Q: Xcode 构建失败？
```bash
cd dogreal_app/ios
pod install
cd ..
flutter run
```

---

## 💡 开发提示

1. **保持热重载**: 修改代码后保存文件，应用会自动更新
2. **使用 print()**: 调试时打印日志到终端
3. **Flutter DevTools**: 使用 `flutter pub global activate devtools` 安装开发工具
4. **Git 提交**: 记得定期提交代码

---

## 📞 需要帮助？

如果遇到问题:
1. 查看 `DEVELOPMENT.md` 开发文档
2. 查看 `API_DESIGN.md` 了解后端 API 设计
3. 运行 `flutter doctor` 检查环境配置

---

## 🎯 当前项目状态

- ✅ Flutter 项目搭建完成
- ✅ 登录/注册 UI 完成
- ✅ 设计系统建立
- ⏳ 后端 API 待开发
- ⏳ 前后端集成待完成

---

**准备好了吗？运行 `./run_ios.sh` 启动你的应用！** 🚀

祝开发愉快！🐾
