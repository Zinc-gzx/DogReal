# MongoDB Atlas 配置指南

## ❌ 当前错误

```
MongoDB Connection Error: Could not connect to any servers in your MongoDB Atlas cluster.
```

## 🔧 解决方案

### 方法 1: 添加当前 IP 到白名单 (推荐)

1. 访问 [MongoDB Atlas](https://cloud.mongodb.com/)
2. 登录你的账号
3. 选择你的项目
4. 点击左侧菜单的 **Network Access**
5. 点击 **Add IP Address**
6. 选择以下之一:
   - **Add Current IP Address** (添加当前 IP)
   - **Allow Access from Anywhere** (允许任何 IP) - 仅用于开发环境
     - IP: `0.0.0.0/0`
7. 点击 **Confirm**

### 方法 2: 使用本地 MongoDB (开发环境)

如果你想使用本地 MongoDB:

1. 安装 MongoDB:
```bash
brew tap mongodb/brew
brew install mongodb-community
```

2. 启动 MongoDB:
```bash
brew services start mongodb-community
```

3. 更新 `.env` 文件:
```env
MONGODB_URI=mongodb://localhost:27017/dogreal
```

## ✅ 验证连接

启动后端服务器后，你应该看到:
```
✅ MongoDB Connected: ac-9eugq2c-shard-00-02.yyucypf.mongodb.net
```

## 🔗 你的连接字符串

```
mongodb+srv://zincgao_db_user:FjCcSVfLbzvAgn3M@test.yyucypf.mongodb.net/dogreal?retryWrites=true&w=majority
```

## 📝 注意事项

- 如果使用 Atlas，确保 IP 白名单已配置
- 如果使用本地 MongoDB，确保服务已启动
- 密码中的特殊字符需要 URL 编码

## 🚀 下一步

配置完成后:
1. 重启后端服务器: `cd backend && node src/server.js`
2. 测试连接: `curl http://localhost:3000/health`
3. 测试注册: `curl -X POST http://localhost:3000/api/v1/auth/register -H "Content-Type: application/json" -d '{"username":"test","email":"test@test.com","password":"123456"}'`
