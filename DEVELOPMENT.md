# DogReal 开发指南

## 🎉 恭喜！登录和注册页面已完成

你的 DogReal 应用已经成功搭建完成，包含了 BeReal 风格的登录和注册界面。

## 📱 如何运行应用

### 方法 1: 使用 iOS 模拟器 (推荐)

1. 打开 iOS 模拟器:
```bash
open -a Simulator
```

2. 运行应用:
```bash
cd dogreal_app
flutter run
```

### 方法 2: 使用真机 (需要开发者账号)

1. 用数据线连接你的 iPhone
2. 信任设备并启用开发者模式
3. 运行:
```bash
cd dogreal_app
flutter run
```

## 🎨 已实现的功能

### ✅ 登录页面
- BeReal 风格的黑色主题
- 邮箱和密码输入
- 表单验证
- 忘记密码按钮
- Apple 登录占位（待实现）
- 导航到注册页面

### ✅ 注册页面
- 用户名、邮箱、密码输入
- 密码确认
- 服务条款同意复选框
- 表单验证
- Apple 注册占位（待实现）
- 返回登录页面

### ✅ UI 组件
- 自定义按钮 (CustomButton)
  - 支持加载状态
  - 支持轮廓样式
  - 支持自定义颜色
  
- 自定义输入框 (CustomTextField)
  - 密码可见性切换
  - 前缀图标
  - 表单验证
  - BeReal 风格样式

### ✅ 设计系统
- 颜色配置 (AppColors)
- 文字样式 (AppTextStyles)
- 间距系统 (AppSpacing)
- 圆角系统 (AppRadius)

## 📁 项目结构

```
dogreal_app/
├── lib/
│   ├── main.dart              # 应用入口
│   ├── screens/               # 页面
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── widgets/               # 自定义组件
│   │   ├── custom_button.dart
│   │   └── custom_textfield.dart
│   ├── utils/                 # 工具类
│   │   └── constants.dart
│   ├── models/                # 数据模型 (待添加)
│   ├── services/              # API 服务 (待添加)
│   └── providers/             # 状态管理 (待添加)
├── pubspec.yaml               # 依赖配置
└── README.md
```

## 🔜 下一步开发

### 1. 创建后端 API
- 用户注册/登录接口
- JWT 认证
- 密码加密

### 2. 连接前后端
- 实现 API 服务类
- 集成真实的登录/注册功能
- 添加 token 存储

### 3. 主页面
- 相机界面
- 双镜头拍照功能
- 照片预览

### 4. 推送通知
- 每日随机时间推送
- Firebase Cloud Messaging

### 5. 社交功能
- 好友系统
- 照片浏览
- 评论和反应

## 💡 提示

### 热重载
开发时保存文件会自动热重载，无需重启应用。

### 调试
- 使用 `print()` 打印日志
- 使用 Flutter DevTools 进行调试
- 查看终端输出

### 修改 UI
- 颜色: 修改 `lib/utils/constants.dart` 中的 `AppColors`
- 文字样式: 修改 `AppTextStyles`
- 间距: 修改 `AppSpacing`

## 📚 学习资源

- [Flutter 官方文档](https://docs.flutter.dev/)
- [Dart 语言教程](https://dart.dev/guides)
- [Flutter 中文网](https://flutter.cn/)

## 🐛 常见问题

### 问题: Flutter 命令找不到
```bash
export PATH="$PATH:/opt/homebrew/bin/flutter/bin"
```

### 问题: 依赖冲突
```bash
flutter pub get
flutter clean
flutter pub get
```

### 问题: iOS 模拟器无法连接
```bash
flutter doctor
```

## 🎯 当前进度

- ✅ Flutter 项目搭建
- ✅ UI 设计系统
- ✅ 登录页面
- ✅ 注册页面
- ⏳ 后端 API
- ⏳ 前后端集成
- ⏳ 相机功能
- ⏳ 推送通知

---

准备好开始开发了吗？运行 `flutter run` 查看你的应用吧！🚀
