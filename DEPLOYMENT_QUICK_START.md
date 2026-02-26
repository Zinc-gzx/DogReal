# 🚀 DogReal 阿里云部署快速开始

本目录包含了将DogReal应用部署到阿里云服务器的完整资源。

## 📁 部署文件说明

| 文件 | 用途 | 在哪里使用 |
|------|------|-----------|
| **ALIYUN_DEPLOYMENT.md** | 📖 完整部署指南 | 阅读了解全部流程 |
| **deploy_to_aliyun.sh** | 📦 代码打包上传脚本 | 本地Mac运行 |
| **server_setup.sh** | ⚙️ 服务器初始化脚本 | 阿里云服务器运行 |
| **nginx.conf** | 🔧 Nginx配置模板 | 阿里云服务器配置 |
| **check_deployment.sh** | ✅ 真机部署检查 | 本地Mac运行（已有） |

## 🎯 快速部署流程（3步完成）

### 第1步：准备服务器（5分钟）

1. **购买阿里云ECS**  
   - 访问 [阿里云控制台](https://ecs.console.aliyun.com/)
   - 选择：2核2GB，Ubuntu 22.04，包年包月
   - 配置安全组：开放 22、80、443、3000 端口

2. **初始化服务器环境**
   ```bash
   # 上传初始化脚本到服务器
   scp server_setup.sh root@你的服务器IP:~/
   
   # SSH到服务器
   ssh root@你的服务器IP
   
   # 运行初始化脚本
   bash server_setup.sh
   ```

   脚本会自动安装：
   - ✓ Node.js 18.x
   - ✓ PM2
   - ✓ Nginx
   - ✓ UFW防火墙
   - ✓ Git
   - ✓ Certbot

### 第2步：配置MongoDB（10分钟）

1. **注册MongoDB Atlas**  
   访问 https://www.mongodb.com/cloud/atlas
   - 注册免费账户
   - 创建M0 Sandbox集群（免费）
   - 区域选择：Singapore 或 Hong Kong

2. **配置数据库访问**
   - **Database Access**：创建用户 `dogreal_user`，记住密码
   - **Network Access**：添加服务器IP（或 `0.0.0.0/0` 测试用）

3. **获取连接字符串**
   - Connect → Connect your application
   - 复制连接字符串：
     ```
     mongodb+srv://dogreal_user:<password>@cluster0.xxxxx.mongodb.net/dogreal
     ```

### 第3步：部署应用（10分钟）

1. **本地打包上传（在Mac上运行）**
   ```bash
   cd /Users/zincgao/Documents/DogReal/DogReal
   bash deploy_to_aliyun.sh
   ```
   
   根据提示输入：
   - 服务器IP地址
   - 用户名（默认：dogreal）

2. **服务器端配置（SSH到服务器）**
   ```bash
   # SSH到服务器
   ssh dogreal@你的服务器IP
   
   # 进入后端目录
   cd backend
   
   # 配置环境变量
   nano .env
   ```

   填写以下内容：
   ```env
   PORT=3000
   NODE_ENV=production
   
   # 填入你的MongoDB Atlas连接字符串
   MONGODB_URI=mongodb+srv://dogreal_user:你的密码@cluster0.xxxxx.mongodb.net/dogreal
   
   # 生成JWT密钥（运行下面命令）
   JWT_SECRET=待填入
   JWT_EXPIRE=7d
   
   CLIENT_URL=*
   ```

   生成JWT密钥：
   ```bash
   node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
   ```
   复制输出，粘贴到 `JWT_SECRET=` 后面。

3. **启动应用**
   ```bash
   # 使用PM2启动
   pm2 start src/server.js --name dogreal-api
   
   # 设置开机自启
   pm2 startup
   pm2 save
   
   # 查看状态
   pm2 status
   ```

4. **测试API**
   ```bash
   # 在服务器上测试
   curl http://localhost:3000/health
   
   # 应该返回：{"status":"ok","message":"DogReal API is running",...}
   ```

5. **在浏览器测试**  
   打开浏览器访问：`http://你的服务器IP:3000/health`

   看到 `{"status":"ok"}` 就成功了！✅

## 📱 修改Flutter应用配置

编辑 `dogreal_app/lib/utils/api_config.dart`：

```dart
class ApiConfig {
  // 生产环境（部署到云服务器后）
  static const String _productionUrl = 'http://你的服务器IP:3000/api';
  
  // 当前使用的环境
  static const String baseUrl = _productionUrl; // 👈 改为生产环境
  
  // ... 其他代码不变
}
```

保存后，重新编译运行：
```bash
cd dogreal_app
flutter clean
flutter pub get
flutter run --release
```

## 🎉 完成！现在可以使用了

现在你的应用已经部署到云端，可以：
- ✅ 不需要数据线连接
- ✅ 不需要Mac开机
- ✅ 任何地方都能访问
- ✅ 多个用户同时使用

## 🔒 进阶配置（可选）

### 配置域名和HTTPS

如果你有域名（如 `dogreal.com`），可以配置更专业的访问方式：

1. **配置DNS解析**
   - 在阿里云域名控制台添加A记录
   - 主机记录：`api`
   - 记录值：你的服务器IP

2. **配置Nginx**
   ```bash
   # 复制配置文件
   sudo cp ~/nginx.conf /etc/nginx/sites-available/dogreal
   
   # 修改域名
   sudo nano /etc/nginx/sites-available/dogreal
   # 将 api.yourdomain.com 改为 api.dogreal.com
   
   # 启用配置
   sudo ln -s /etc/nginx/sites-available/dogreal /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

3. **安装SSL证书（免费）**
   ```bash
   sudo certbot --nginx -d api.dogreal.com
   ```
   
   然后修改Flutter配置为：
   ```dart
   static const String _productionUrl = 'https://api.dogreal.com/api';
   ```

详细步骤查看：[ALIYUN_DEPLOYMENT.md](ALIYUN_DEPLOYMENT.md) 第6章节

## 📊 监控和维护

### 常用PM2命令

```bash
pm2 list                    # 查看所有进程
pm2 logs dogreal-api        # 查看日志
pm2 restart dogreal-api     # 重启应用
pm2 stop dogreal-api        # 停止应用
pm2 monit                   # 监控资源
```

### 更新代码

```bash
# 在本地运行
bash deploy_to_aliyun.sh

# 在服务器上运行
cd ~/backend
npm install --production  # 如果有新依赖
pm2 restart dogreal-api
```

### 查看日志

```bash
# 应用日志
pm2 logs dogreal-api

# Nginx日志
sudo tail -f /var/log/nginx/dogreal_access.log
sudo tail -f /var/log/nginx/dogreal_error.log
```

## 🆘 常见问题

### ❓ 应用无法连接服务器

**检查清单：**
- [ ] 服务器IP是否正确
- [ ] 安全组是否开放3000端口
- [ ] PM2进程是否运行：`pm2 status`
- [ ] 防火墙是否允许：`sudo ufw status`
- [ ] 在手机浏览器访问：`http://服务器IP:3000/health`

### ❓ MongoDB连接失败

**检查清单：**
- [ ] MongoDB Atlas的Network Access是否添加了服务器IP
- [ ] 连接字符串是否正确（特别是密码）
- [ ] 密码中的特殊字符是否URL编码
- [ ] 查看日志：`pm2 logs dogreal-api --err`

### ❓ 图片上传失败

```bash
# 检查上传目录权限
cd ~/backend
chmod -R 755 uploads/
ls -la uploads/
```

### ❓ PM2进程崩溃

```bash
# 查看错误日志
pm2 logs dogreal-api --err

# 手动启动看详细错误
cd ~/backend
node src/server.js
```

## 💡 性能优化建议

部署成功后，可以考虑：

1. **使用CDN**：加速静态资源访问
2. **配置Nginx缓存**：减少后端压力
3. **启用Gzip压缩**：减少传输数据量
4. **使用Redis**：缓存热点数据
5. **配置负载均衡**：支持更多用户

## 📚 相关文档

- [ALIYUN_DEPLOYMENT.md](ALIYUN_DEPLOYMENT.md) - 完整部署指南
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - 本地部署指南
- [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - 部署检查清单
- [MongoDB Atlas文档](https://docs.atlas.mongodb.com/)
- [阿里云ECS文档](https://help.aliyun.com/product/25365.html)

## 🎊 恭喜！

你已经成功将DogReal部署到生产环境！

如果一切顺利：
- ✅ 后端运行在阿里云服务器
- ✅ 数据存储在MongoDB Atlas
- ✅ 应用可在任何地方访问
- ✅ 无需连接开发机器

**下一步：**
- 📱 发布到TestFlight进行测试
- 🍎 提交到App Store审核
- 📊 配置监控告警
- 🔧 持续优化性能

祝你的应用运营顺利！🐾

---

**需要帮助？** 
- 查看详细日志排查问题
- 参考 [ALIYUN_DEPLOYMENT.md](ALIYUN_DEPLOYMENT.md) 完整指南
- 查阅阿里云官方文档
