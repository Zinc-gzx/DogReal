# 🚀 DogReal 阿里云部署完整指南

本指南将帮助你把 DogReal 应用部署到阿里云服务器，实现真正的生产环境部署。

## 📋 目录
1. [购买和配置阿里云服务器](#1-购买和配置阿里云服务器)
2. [服务器初始化设置](#2-服务器初始化设置)
3. [安装必要软件](#3-安装必要软件)
4. [配置MongoDB数据库](#4-配置mongodb数据库)
5. [部署后端代码](#5-部署后端代码)
6. [配置域名和SSL](#6-配置域名和ssl-可选但推荐)
7. [修改Flutter应用配置](#7-修改flutter应用配置)
8. [编译和发布应用](#8-编译和发布应用)
9. [监控和维护](#9-监控和维护)

---

## 1. 购买和配置阿里云服务器

### 1.1 购买ECS服务器

1. 访问 [阿里云官网](https://www.aliyun.com/)
2. 产品 → 云服务器ECS → 立即购买

**推荐配置：**
- **付费模式**：按量付费（测试）或 包年包月（生产）
- **地域**：选择离你的用户最近的区域（如：华东1-杭州）
- **实例规格**：
  - 轻量级应用：**2核2GB**（约￥60-80/月）
  - 中等流量：**2核4GB**（约￥120-150/月）
- **镜像**：Ubuntu 22.04 64位
- **网络**：分配公网IP，带宽建议至少3M-5M
- **安全组**：创建新安全组（后面会配置）

### 1.2 配置安全组规则

进入ECS控制台，配置安全组：

| 规则方向 | 授权策略 | 协议类型 | 端口范围 | 授权对象 | 说明 |
|---------|---------|---------|---------|---------|------|
| 入方向 | 允许 | TCP | 22 | 0.0.0.0/0 | SSH登录 |
| 入方向 | 允许 | TCP | 80 | 0.0.0.0/0 | HTTP |
| 入方向 | 允许 | TCP | 443 | 0.0.0.0/0 | HTTPS |
| 入方向 | 允许 | TCP | 3000 | 0.0.0.0/0 | Node.js后端（临时，后期建议通过Nginx代理） |

---

## 2. 服务器初始化设置

### 2.1 连接到服务器

在终端执行（替换成你的服务器IP）：
```bash
ssh root@你的服务器IP
# 例如: ssh root@47.96.123.456
```

首次连接会要求输入密码（购买时设置的）。

### 2.2 创建非root用户（安全最佳实践）

```bash
# 创建新用户
adduser dogreal

# 授予sudo权限
usermod -aG sudo dogreal

# 切换到新用户
su - dogreal
```

### 2.3 更新系统

```bash
sudo apt update
sudo apt upgrade -y
```

### 2.4 配置防火墙

```bash
# 安装UFW防火墙
sudo apt install ufw -y

# 配置防火墙规则
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 3000/tcp  # Node.js (临时)

# 启用防火墙
sudo ufw enable

# 查看状态
sudo ufw status
```

---

## 3. 安装必要软件

### 3.1 安装Node.js（使用NodeSource）

```bash
# 安装Node.js 18.x LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 验证安装
node --version  # 应显示 v18.x.x
npm --version   # 应显示 9.x.x
```

### 3.2 安装PM2（进程管理器）

```bash
sudo npm install -g pm2

# 验证安装
pm2 --version
```

### 3.3 安装Git

```bash
sudo apt install git -y

# 验证安装
git --version
```

### 3.4 安装Nginx（用于反向代理）

```bash
sudo apt install nginx -y

# 启动Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# 检查状态
sudo systemctl status nginx
```

---

## 4. 配置MongoDB数据库

**强烈推荐使用MongoDB Atlas云数据库**，无需在服务器上安装MongoDB。

### 4.1 创建MongoDB Atlas账户

1. 访问 [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. 注册免费账户（Free Tier足够测试使用）
3. 创建新集群（Cluster）：
   - 选择 AWS / 区域：选择离阿里云服务器近的区域（如：Singapore或Hong Kong）
   - Cluster Tier：M0 Sandbox（免费）

### 4.2 配置数据库访问

1. **Database Access**（数据库访问）：
   - 创建数据库用户
   - 用户名：`dogreal_user`
   - 密码：使用自动生成的强密码（保存好！）

2. **Network Access**（网络访问）：
   - 点击 "ADD IP ADDRESS"
   - 添加你的阿里云服务器IP地址
   - 或者添加 `0.0.0.0/0`（允许所有IP，仅测试时使用）

### 4.3 获取连接字符串

1. 在Cluster页面点击 "Connect"
2. 选择 "Connect your application"
3. 复制连接字符串，格式如下：
```
mongodb+srv://dogreal_user:<password>@cluster0.xxxxx.mongodb.net/dogreal?retryWrites=true&w=majority
```

**注意**：将 `<password>` 替换为实际密码。

---

## 5. 部署后端代码

### 5.1 克隆代码到服务器

**方式1：使用Git（推荐）**

如果你的代码在GitHub/Gitee：
```bash
cd ~
git clone https://github.com/yourusername/DogReal.git
cd DogReal/backend
```

**方式2：手动上传代码**

在本地电脑执行：
```bash
# 打包后端代码
cd /Users/zincgao/Documents/DogReal/DogReal
tar -czf dogreal-backend.tar.gz backend/

# 上传到服务器
scp dogreal-backend.tar.gz dogreal@你的服务器IP:~/

# 在服务器上解压
ssh dogreal@你的服务器IP
tar -xzf dogreal-backend.tar.gz
cd backend
```

### 5.2 安装依赖

```bash
cd ~/DogReal/backend  # 或 ~/backend
npm install --production
```

### 5.3 配置环境变量

```bash
# 创建.env文件
nano .env
```

输入以下内容（**替换为你的实际值**）：
```env
# Server Configuration
PORT=3000
NODE_ENV=production

# MongoDB Configuration (使用MongoDB Atlas连接字符串)
MONGODB_URI=mongodb+srv://dogreal_user:你的密码@cluster0.xxxxx.mongodb.net/dogreal?retryWrites=true&w=majority

# JWT Configuration (生成一个随机的强密钥)
JWT_SECRET=请使用以下命令生成随机密钥
JWT_EXPIRE=7d

# CORS Configuration (允许所有来源，或指定你的应用域名)
CLIENT_URL=*
```

**生成JWT密钥**：
```bash
# 在服务器上运行
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```
复制输出的字符串，粘贴到 `JWT_SECRET=` 后面。

保存文件（Ctrl+O，回车，Ctrl+X）。

### 5.4 创建上传目录

```bash
mkdir -p uploads/avatars
mkdir -p uploads/posts
```

### 5.5 使用PM2启动后端

```bash
# 启动应用
pm2 start src/server.js --name dogreal-api

# 设置开机自启
pm2 startup
pm2 save

# 查看日志
pm2 logs dogreal-api

# 查看状态
pm2 status
```

### 5.6 测试后端

```bash
# 在服务器上测试
curl http://localhost:3000/health

# 在本地浏览器访问
http://你的服务器IP:3000/health
```

如果返回 `{"status":"ok","message":"DogReal API is running",...}`，说明部署成功！

---

## 6. 配置域名和SSL（可选但推荐）

### 6.1 购买域名

1. 在阿里云购买域名（如：`dogreal.com`）
2. 进行实名认证（中国大陆地区必需）

### 6.2 配置域名解析

1. 进入域名控制台 → 解析设置
2. 添加A记录：

| 记录类型 | 主机记录 | 解析线路 | 记录值 | TTL |
|---------|---------|---------|--------|-----|
| A | @ | 默认 | 你的服务器IP | 10分钟 |
| A | api | 默认 | 你的服务器IP | 10分钟 |

等待5-10分钟生效。

### 6.3 配置Nginx反向代理

```bash
# 创建Nginx配置文件
sudo nano /etc/nginx/sites-available/dogreal
```

输入以下内容（**替换域名**）：
```nginx
server {
    listen 80;
    server_name api.dogreal.com;  # 替换为你的域名

    # 增加上传文件大小限制
    client_max_body_size 50M;

    # API代理
    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # 静态文件（上传的图片）
    location /uploads {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 健康检查
    location /health {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
    }
}
```

启用配置：
```bash
# 创建软链接
sudo ln -s /etc/nginx/sites-available/dogreal /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重启Nginx
sudo systemctl restart nginx
```

### 6.4 安装SSL证书（HTTPS）

使用Let's Encrypt免费SSL证书：

```bash
# 安装Certbot
sudo apt install certbot python3-certbot-nginx -y

# 自动配置SSL
sudo certbot --nginx -d api.dogreal.com

# 按提示输入：
# - 邮箱地址
# - 同意服务条款
# - 选择重定向HTTP到HTTPS（推荐选2）

# 测试自动续期
sudo certbot renew --dry-run
```

现在你可以通过 `https://api.dogreal.com` 访问API了！

---

## 7. 修改Flutter应用配置

### 7.1 更新API配置

编辑本地项目文件：
```bash
code dogreal_app/lib/utils/api_config.dart
```

修改为：
```dart
class ApiConfig {
  // 🔧 环境配置 - 部署前请修改这里
  // ============================================
  
  // 模拟器调试（Mac本地开发）
  static const String _simulatorUrl = 'http://localhost:3000/api';
  
  // 真机调试（需要Mac和手机在同一WiFi）
  static const String _deviceUrl = 'http://192.168.3.7:3000/api';
  
  // 生产环境（部署到云服务器后）
  static const String _productionUrl = 'https://api.dogreal.com/api';  // ✅ 使用你的域名
  
  // ============================================
  // 当前使用的环境（根据需要修改）
  // ============================================
  static const String baseUrl = _productionUrl; // 👈 改为生产环境
  
  // ... 其他代码保持不变
}
```

### 7.2 配置iOS网络权限

编辑 `dogreal_app/ios/Runner/Info.plist`：

如果使用HTTP（IP地址访问），需要添加：
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

如果使用HTTPS（域名+SSL），无需配置。

### 7.3 测试连接

在你的iPhone上，使用Safari浏览器访问：
- `http://你的服务器IP:3000/health`
- 或 `https://api.dogreal.com/health`

应该能看到 `{"status":"ok",...}` 响应。

---

## 8. 编译和发布应用

### 8.1 编译iOS应用

```bash
cd dogreal_app

# 清理构建缓存
flutter clean
flutter pub get

# 编译到真机
flutter build ios --release

# 或直接运行到连接的设备
flutter run --release
```

### 8.2 TestFlight测试（推荐）

1. 在Xcode中打开 `dogreal_app/ios/Runner.xcworkspace`
2. 选择 Product → Archive
3. 上传到App Store Connect
4. 使用TestFlight进行内部测试
5. 邀请测试用户下载

### 8.3 发布到App Store

1. 在App Store Connect创建应用
2. 填写应用信息、截图、描述
3. 提交审核
4. 等待Apple审核通过（通常1-3天）

---

## 9. 监控和维护

### 9.1 PM2常用命令

```bash
# 查看所有进程
pm2 list

# 查看日志
pm2 logs dogreal-api

# 重启应用
pm2 restart dogreal-api

# 停止应用
pm2 stop dogreal-api

# 查看详细信息
pm2 show dogreal-api

# 监控资源使用
pm2 monit
```

### 9.2 查看Nginx日志

```bash
# 访问日志
sudo tail -f /var/log/nginx/access.log

# 错误日志
sudo tail -f /var/log/nginx/error.log
```

### 9.3 更新后端代码

```bash
cd ~/DogReal/backend

# 拉取最新代码
git pull

# 安装新依赖（如果有）
npm install --production

# 重启应用
pm2 restart dogreal-api
```

### 9.4 备份数据库

MongoDB Atlas会自动备份，也可以手动导出：

```bash
# 安装MongoDB工具
sudo apt install mongodb-database-tools -y

# 导出数据
mongodump --uri="你的MongoDB连接字符串" --out=backup-$(date +%Y%m%d)

# 压缩备份
tar -czf backup-$(date +%Y%m%d).tar.gz backup-$(date +%Y%m%d)
```

### 9.5 设置监控告警

**使用阿里云云监控**：
1. 进入云监控控制台
2. 添加ECS监控
3. 设置告警规则：
   - CPU使用率 > 80%
   - 内存使用率 > 90%
   - 磁盘使用率 > 85%

---

## 🎯 快速部署检查清单

- [ ] 购买阿里云ECS服务器
- [ ] 配置安全组（开放22、80、443、3000端口）
- [ ] 安装Node.js、PM2、Nginx
- [ ] 注册MongoDB Atlas账户并创建集群
- [ ] 上传后端代码到服务器
- [ ] 配置.env环境变量
- [ ] 使用PM2启动后端服务
- [ ] 测试API连接（http://服务器IP:3000/health）
- [ ] （可选）配置域名解析
- [ ] （可选）安装SSL证书
- [ ] （可选）配置Nginx反向代理
- [ ] 修改Flutter应用的API配置
- [ ] 编译并测试应用
- [ ] 发布到TestFlight或App Store

---

## 🆘 常见问题

### Q1: 无法连接到服务器
**A**: 检查安全组和防火墙规则，确保开放了3000端口。

### Q2: MongoDB连接失败
**A**: 
- 检查MongoDB Atlas的Network Access是否添加了服务器IP
- 验证连接字符串是否正确，密码中的特殊字符需要URL编码

### Q3: 应用连接不上服务器
**A**:
- 确认Flutter应用中的baseUrl是否正确
- 在手机浏览器测试API地址是否可访问
- 检查iOS的网络权限配置

### Q4: 上传图片失败
**A**:
- 检查uploads目录权限：`chmod -R 755 uploads`
- 确认Nginx配置中的`client_max_body_size`足够大

### Q5: PM2进程崩溃
**A**:
- 查看日志：`pm2 logs dogreal-api --err`
- 检查.env文件配置是否正确
- 确认MongoDB连接是否正常

---

## 📞 获取帮助

如果遇到问题：
1. 查看日志：`pm2 logs`、`sudo tail -f /var/log/nginx/error.log`
2. 检查服务状态：`pm2 status`、`sudo systemctl status nginx`
3. 查阅阿里云文档：https://help.aliyun.com/
4. MongoDB Atlas文档：https://docs.atlas.mongodb.com/

---

## 🎉 完成！

恭喜！你已经成功将DogReal部署到阿里云服务器。现在无论在哪里，用户都可以使用你的应用了！

**性能优化建议**：
- 启用Gzip压缩：在Nginx配置中启用
- 使用CDN加速静态资源（阿里云OSS + CDN）
- 配置Redis缓存（高级功能）
- 数据库索引优化

祝你的应用运营顺利！🐾
