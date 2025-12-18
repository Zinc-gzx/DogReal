# DogReal 🐾

一款宠物版的 BeReal 应用 - 分享你宠物的真实时刻

## 项目简介

DogReal 是一款受 BeReal 启发的宠物社交应用，让宠物主人在每天的随机时刻分享他们宠物的真实瞬间。

## 技术栈

### 移动端
- **Flutter** - 跨平台移动应用框架 (iOS & Android)
- **Dart** - 编程语言
- **Provider** - 状态管理
- **Google Fonts** - 字体

### 后端 (计划中)
- **Node.js + Express** - 后端服务器
- **MongoDB** - 数据库
- **JWT** - 身份认证
- **AWS S3 / Cloudinary** - 图片存储
- **Firebase Cloud Messaging** - 推送通知

## 项目结构

```
DogReal/
├── dogreal_app/          # Flutter 移动应用
│   ├── lib/
│   │   ├── screens/      # 页面
│   │   ├── widgets/      # 自定义组件
│   │   ├── services/     # API 服务
│   │   ├── models/       # 数据模型
│   │   ├── providers/    # 状态管理
│   │   └── utils/        # 工具类和常量
│   └── pubspec.yaml
└── backend/              # Node.js 后端 (待创建)
```

## 已完成功能

- ✅ Flutter 项目初始化
- ✅ BeReal 风格的 UI 设计系统
- ✅ 登录页面 UI
- ✅ 注册页面 UI
- ✅ 表单验证
- ✅ 自定义组件 (按钮、输入框)

## 待开发功能

- ⏳ 后端 API (用户认证)
- ⏳ 前后端集成
- ⏳ 相机功能
- ⏳ 每日随机推送通知
- ⏳ 宠物档案
- ⏳ 好友系统
- ⏳ 照片浏览

## 快速开始 🚀

### 方法 1: 使用快速启动脚本 (推荐)
```bash
./run_ios.sh
```

### 方法 2: 手动启动
```bash
cd dogreal_app
flutter pub get
flutter run
```

📖 **详细教程**: 查看 [QUICK_START.md](QUICK_START.md)

## 文档 📚

- 📱 [快速开始指南](QUICK_START.md) - 如何运行和测试应用
- 🛠 [开发指南](DEVELOPMENT.md) - 开发流程和最佳实践
- 🔌 [API 设计文档](API_DESIGN.md) - 后端 API 接口设计

## 运行项目

### 前置要求
- Flutter SDK (3.38.5+) ✅ 已安装
- Xcode (用于 iOS 开发) ✅ 已配置
- iOS 模拟器 ✅ 已就绪

### 快速启动
```bash
# 启动 iOS 模拟器并运行应用
./run_ios.sh
```

### 手动启动
```bash
cd dogreal_app
flutter pub get
flutter run
```

### 开发模式快捷键
- `r` - 热重载 (快速更新 UI)
- `R` - 热重启 (完全重启)
- `q` - 退出应用

## 设计理念

DogReal 遵循 BeReal 的极简黑色主题设计:
- 黑色背景 (#000000)
- 白色主要元素
- 简洁的 UI
- 注重内容本身

## 开发计划

1. ✅ 阶段 1: 登录注册 UI (已完成)
   - ✅ 登录页面设计
   - ✅ 注册页面设计
   - ✅ 表单验证
   - ✅ UI 组件库
   
2. ⏳ 阶段 2: 后端 API 开发 (下一步)
   - ⏳ Node.js + Express 项目搭建
   - ⏳ MongoDB 数据库设计
   - ⏳ 用户认证 API
   - ⏳ JWT Token 管理
   
3. ⏳ 阶段 3: 前后端集成
   - ⏳ API 服务类
   - ⏳ 状态管理
   - ⏳ Token 存储
   
4. ⏳ 阶段 4: 相机和照片功能
   - ⏳ 相机界面
   - ⏳ 双镜头拍照
   - ⏳ 照片上传
   
5. ⏳ 阶段 5: 推送通知系统
   - ⏳ Firebase 配置
   - ⏳ 每日随机推送
   
6. ⏳ 阶段 6: 社交功能
   - ⏳ 好友系统
   - ⏳ 照片浏览
   - ⏳ 评论和反应

## 屏幕预览

### 登录页面
- 🎨 BeReal 风格黑色主题
- 📧 邮箱 & 密码登录
- 🍎 Apple 登录 (预留)
- 🔗 注册链接

### 注册页面
- 👤 用户名 + 邮箱 + 密码
- ✅ 服务条款同意
- 🔒 密码确认验证
- 🍎 Apple 注册 (预留)

## 项目特色

✨ **BeReal 风格设计** - 完全遵循 BeReal 的极简黑色主题  
🚀 **跨平台支持** - 一套代码，iOS 和 Android 都能运行  
🎯 **专注宠物** - 专门为宠物主人设计的社交体验  
🔐 **安全认证** - JWT + 密码加密  
📱 **现代化架构** - Flutter + Node.js 技术栈

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

DogReal
