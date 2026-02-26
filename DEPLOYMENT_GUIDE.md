# 📱 DogReal 真机部署指南

## 🎯 部署前准备清单

### 1. 开发者账号要求

#### 自己的iPhone测试（免费）
- ✅ **无需付费开发者账号**
- ✅ 使用个人Apple ID即可
- ⚠️ 应用7天后需要重新安装
- ⚠️ 每个Apple ID最多3个设备

#### 分发给其他人（需要付费）
- 💰 **需要Apple Developer账号** ($99/年)
- ✅ TestFlight内测（最多10,000用户）
- ✅ App Store正式发布
- ✅ 企业分发（需要企业账号 $299/年）

---

## 🔧 部署前必须修改的配置

### 1. 修改后端API地址（关键！）

#### 步骤 1: 获取Mac的局域网IP地址
```bash
# 在终端运行：
ifconfig | grep "inet " | grep -v 127.0.0.1

# 或者更简洁：
ipconfig getifaddr en0   # WiFi
ipconfig getifaddr en1   # 以太网

# 示例输出: 192.168.1.100
```

#### 步骤 2: 修改Flutter API配置
打开 `dogreal_app/lib/utils/api_config.dart`：

```dart
class ApiConfig {
  // ❌ 模拟器配置（真机无法访问localhost）
  // static const String baseUrl = 'http://localhost:3000/api';
  
  // ✅ 真机配置（使用Mac的局域网IP）
  static const String baseUrl = 'http://192.168.1.100:3000/api';
  
  // 超时时间
  static const Duration timeout = Duration(seconds: 30);
  
  // ... 其他配置不变
}
```

⚠️ **重要提示**：
- IP地址必须是你的Mac在**同一WiFi网络**下的IP
- 手机和Mac必须连接到**同一个WiFi**
- 不能使用 localhost 或 127.0.0.1

---

### 2. 配置后端允许跨域访问

打开 `backend/src/server.js`，确认CORS配置：

```javascript
// 允许所有来源（开发环境）
app.use(cors({
  origin: '*',  // 生产环境应该限制为特定域名
  credentials: true
}));
```

如果要更安全，可以配置允许的IP：

```javascript
app.use(cors({
  origin: ['http://192.168.1.100:3000', 'http://localhost:3000'],
  credentials: true
}));
```

---

### 3. iOS应用签名配置

#### 步骤 1: 打开Xcode项目
```bash
cd dogreal_app/ios
open Runner.xcworkspace
```

#### 步骤 2: 配置签名
1. 在Xcode中，选择左侧的 `Runner` 项目
2. 选择 `Signing & Capabilities` 标签
3. 勾选 ✅ `Automatically manage signing`
4. 在 `Team` 下拉框中：
   - 如果没有团队，点击 `Add Account...`
   - 登录你的Apple ID
   - 选择你的账号
5. 修改 `Bundle Identifier`（必须唯一）：
   ```
   com.yourname.dogreal
   # 例如: com.zincgao.dogreal
   ```

#### 步骤 3: 连接真机
1. 用数据线连接iPhone到Mac
2. 在iPhone上信任这台电脑
3. 在Xcode顶部选择你的iPhone设备

---

## 🧪 部署前测试清单

### 网络连接测试

#### 1. 测试Mac和手机在同一WiFi
```bash
# Mac上运行：
ifconfig | grep "inet "

# 手机上：
# 设置 → WiFi → 点击已连接的WiFi → 查看IP地址
# 确保IP前三段相同，如: 192.168.1.xxx
```

#### 2. 测试后端可访问性

在手机浏览器（Safari）中访问：
```
http://192.168.1.100:3000/health
```

**预期结果**：
```json
{
  "status": "ok",
  "message": "DogReal API is running",
  "timestamp": "2026-02-02T..."
}
```

❌ **如果无法访问**：
- 检查Mac防火墙设置
- 确认后端服务正在运行
- 确认IP地址正确
- 确认手机和Mac在同一WiFi

#### 3. 测试MongoDB连接
```bash
# 确保MongoDB连接字符串使用云数据库
# backend/.env
MONGO_URI=mongodb+srv://...mongodb.net/dogreal

# 不要使用本地MongoDB: mongodb://localhost:27017
```

---

## 🚀 真机部署步骤

### 方法1：使用Xcode直接运行（推荐）

```bash
# 1. 停止当前运行的模拟器
cd dogreal_app
# 按 q 退出当前运行

# 2. 连接iPhone，然后：
flutter run
# Flutter会自动检测到真机设备

# 或者在Xcode中：
# - 选择你的iPhone设备
# - 点击运行按钮 ▶️
```

### 方法2：使用Flutter命令指定设备

```bash
# 查看所有设备
flutter devices

# 输出示例：
# iPhone 15 Pro (mobile) • 00008110-xxxxx • ios • iOS 17.2
# iPhone 16 Pro Simulator (mobile) • C7F8655C-xxxx • ios-simulator • iOS 18.6

# 运行到真机
flutter run -d 00008110-xxxxx  # 使用真机的设备ID
```

---

## ⚙️ iOS首次安装配置

### 信任开发者证书

1. 安装应用后，打开会提示"未受信任的开发者"
2. 前往：**设置 → 通用 → VPN与设备管理**
3. 找到你的Apple ID
4. 点击"信任"

### 授权应用权限

首次运行时会依次请求以下权限：
- 📷 **相机权限** - 拍摄宠物照片
- 🖼️ **相册权限** - 选择宠物照片  
- 🔔 **通知权限** - 接收每日挑战提醒

全部点击"允许"即可。

---

## 🔥 MacOS防火墙配置

如果手机无法访问Mac的后端服务：

### 方法1：临时关闭防火墙（开发环境）
```
系统设置 → 网络 → 防火墙 → 关闭
```

### 方法2：允许Node.js通过防火墙
```
系统设置 → 网络 → 防火墙 → 选项
→ 允许 "node" 接收传入连接
```

### 方法3：使用命令行添加规则
```bash
# 允许3000端口
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/node
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /usr/local/bin/node
```

---

## 📝 完整部署流程

### 第1步：准备工作
- [ ] 获取Mac的局域网IP地址
- [ ] 修改 `api_config.dart` 中的 baseUrl
- [ ] 确保Mac和iPhone连接同一WiFi
- [ ] 后端服务运行在 http://0.0.0.0:3000

### 第2步：配置iOS项目
- [ ] 打开Xcode工作区
- [ ] 配置自动签名
- [ ] 修改Bundle Identifier
- [ ] 连接iPhone设备

### 第3步：测试网络连接
- [ ] 手机浏览器访问 `http://你的IP:3000/health`
- [ ] 确认返回正常响应
- [ ] 如果失败，检查防火墙设置

### 第4步：运行应用
- [ ] 在Xcode中选择真机设备
- [ ] 点击运行 ▶️
- [ ] 或使用 `flutter run`

### 第5步：首次设置
- [ ] 在iPhone上信任开发者
- [ ] 授权相机、相册、通知权限
- [ ] 注册新账号测试
- [ ] 创建宠物档案

### 第6步：功能测试
- [ ] 登录/注册功能
- [ ] 创建宠物档案
- [ ] 拍照上传功能
- [ ] 发布动态到Feed
- [ ] 添加好友
- [ ] 查看今日挑战
- [ ] 接收通知推送

---

## 🌐 让其他人使用的方案

### 方案1：同一WiFi下（免费）
✅ **适合**：朋友、家人在同一网络
- 他们的iPhone连接同一WiFi
- 使用同样的配置安装应用
- 可以一起使用、互相添加好友

❌ **限制**：
- 必须在同一WiFi下
- 你的Mac必须一直开着运行后端
- 最多3台设备（免费Apple ID限制）

### 方案2：TestFlight内测（$99/年）
✅ **适合**：小范围测试（10-10,000人）

**步骤**：
1. 注册Apple Developer账号 ($99/年)
2. 创建App ID和证书
3. 使用Xcode Archive打包应用
4. 上传到App Store Connect
5. 创建TestFlight内测
6. 邀请测试用户（发送邀请链接）

✅ **优点**：
- 用户可以通过TestFlight安装
- 不需要在同一网络
- 最多10,000个外部测试用户
- 每个版本可测试90天

### 方案3：App Store发布（$99/年）
✅ **适合**：正式发布给所有人

**步骤**：
1. 完成TestFlight测试
2. 准备App Store素材：
   - 应用截图（6.7寸、6.5寸、5.5寸）
   - 应用图标（1024x1024）
   - 隐私政策URL
   - 应用描述
3. 提交审核（1-7天）
4. 审核通过后上架

### 方案4：部署到云服务器（推荐）
✅ **适合**：长期使用

**需要**：
1. 购买云服务器（阿里云、腾讯云、AWS）
   - 最低配置：1核2G（约 ¥100/年）
2. 部署后端到服务器
3. 获得公网IP或域名
4. 修改 `api_config.dart` 使用公网地址

```dart
// 使用云服务器
static const String baseUrl = 'http://your-server-ip:3000/api';
// 或使用域名（推荐）
static const String baseUrl = 'https://api.dogreal.com/api';
```

✅ **优点**：
- 不需要Mac一直开着
- 任何人、任何地方都能使用
- 不受WiFi限制
- 更稳定、更安全

---

## 🔐 生产环境安全配置

### 后端安全
```javascript
// backend/.env（生产环境）
NODE_ENV=production
PORT=3000
MONGO_URI=mongodb+srv://...
JWT_SECRET=your-very-long-random-secret-string

// server.js
app.use(cors({
  origin: 'https://your-domain.com',  // 只允许你的域名
  credentials: true
}));
```

### 前端安全
```dart
// 区分开发/生产环境
class ApiConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  static String get baseUrl => isProduction
      ? 'https://api.dogreal.com/api'  // 生产环境
      : 'http://192.168.1.100:3000/api'; // 开发环境
}
```

---

## 📊 部署后监控

### 后端日志
```bash
# 使用PM2管理Node.js进程（推荐）
npm install -g pm2
pm2 start src/server.js --name dogreal-api
pm2 logs dogreal-api
pm2 monit
```

### 错误追踪
考虑集成：
- Sentry（前端+后端错误追踪）
- Firebase Crashlytics（移动端崩溃报告）
- Google Analytics（用户行为分析）

---

## ❓ 常见问题

### Q1: 手机无法连接到后端
**检查**：
1. 手机和Mac在同一WiFi ✓
2. IP地址正确 ✓
3. 后端正在运行 ✓
4. 防火墙已允许 ✓
5. 手机浏览器能访问 `http://IP:3000/health` ✓

### Q2: 应用安装后无法打开
**原因**：未信任开发者证书
**解决**：设置 → 通用 → VPN与设备管理 → 信任

### Q3: 7天后应用无法打开
**原因**：免费Apple ID的限制
**解决**：
- 重新运行 `flutter run` 安装
- 或升级到付费开发者账号

### Q4: 其他人无法添加为好友
**检查**：
1. 他们使用的是同一个后端API地址
2. MongoDB数据库相同
3. 网络连接正常

### Q5: 通知不显示
**检查**：
1. 授予了通知权限
2. iOS设置中通知未被关闭
3. 模拟器不支持通知，必须真机测试

---

## 🎯 推荐的部署方案

### 个人使用 + 几个朋友测试
```
1. 使用免费Apple ID + 同一WiFi
2. Mac运行后端服务
3. MongoDB使用Atlas云数据库
4. 成本：¥0
```

### 小范围内测（10-100人）
```
1. 购买Apple Developer账号 ($99/年)
2. 部署后端到云服务器（¥100-500/年）
3. 使用TestFlight分发
4. 总成本：约 ¥800/年
```

### 正式发布（所有人）
```
1. Apple Developer账号 ($99/年)
2. 云服务器 + 域名（¥300-1000/年）
3. App Store发布
4. 可选：CDN、监控服务
5. 总成本：约 ¥1000-2000/年
```

---

## ✅ 现在开始部署

**推荐流程**：

1. **先在真机上测试**（免费）
   - 修改IP地址配置
   - 真机运行测试所有功能
   - 邀请1-2个朋友同一WiFi测试

2. **如果满意，考虑云部署**
   - 租用云服务器
   - 部署后端到服务器
   - 配置域名和HTTPS

3. **如果要公开发布**
   - 注册开发者账号
   - TestFlight内测
   - App Store审核发布

---

## 🚀 快速开始

```bash
# 1. 获取IP
ipconfig getifaddr en0

# 2. 修改配置
# 编辑: dogreal_app/lib/utils/api_config.dart
# 替换: static const String baseUrl = 'http://你的IP:3000/api';

# 3. 连接iPhone

# 4. 运行
cd dogreal_app
flutter run

# 5. 信任开发者（在iPhone上）

# 6. 开始测试！
```

祝你部署顺利！🎉
