# DogReal Backend API

## 🚀 快速开始

### 1. 安装 MongoDB

如果还没有安装 MongoDB:

```bash
# macOS
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community
```

### 2. 配置环境变量

复制 `.env.example` 到 `.env`:
```bash
cp .env.example .env
```

### 3. 启动服务器

```bash
# 开发模式 (自动重启)
npm run dev

# 生产模式
npm start
```

服务器将运行在: `http://localhost:3000`

---

## 📁 项目结构

```
backend/
├── src/
│   ├── config/           # 配置文件
│   │   └── database.js   # MongoDB 连接
│   ├── controllers/      # 控制器
│   │   └── auth.controller.js
│   ├── middleware/       # 中间件
│   │   └── auth.js       # JWT 认证中间件
│   ├── models/           # 数据模型
│   │   └── User.js
│   ├── routes/           # 路由
│   │   ├── auth.routes.js
│   │   ├── user.routes.js
│   │   └── pet.routes.js
│   ├── utils/            # 工具函数
│   │   └── jwt.js
│   └── server.js         # 入口文件
├── .env                  # 环境变量
├── .env.example          # 环境变量示例
└── package.json
```

---

## 🔌 API 端点

### 认证 (Auth)

#### 注册
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "username": "dogowner",
  "email": "user@example.com",
  "password": "password123"
}
```

**响应:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "...",
      "username": "dogowner",
      "email": "user@example.com",
      "avatar": null,
      "createdAt": "2024-..."
    },
    "token": "eyJhbGc..."
  }
}
```

#### 登录
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**响应:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "...",
      "username": "dogowner",
      "email": "user@example.com",
      "avatar": null,
      "pets": [],
      "friends": []
    },
    "token": "eyJhbGc..."
  }
}
```

#### 获取当前用户信息
```http
GET /api/v1/auth/me
Authorization: Bearer <token>
```

**响应:**
```json
{
  "success": true,
  "data": {
    "id": "...",
    "username": "dogowner",
    "email": "user@example.com",
    "avatar": null,
    "pets": [],
    "friends": [],
    "createdAt": "2024-...",
    "updatedAt": "2024-..."
  }
}
```

### 健康检查
```http
GET /health
```

---

## 🧪 测试 API

### 使用 curl

```bash
# 注册
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"123456"}'

# 登录
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"123456"}'

# 获取用户信息 (需要替换 TOKEN)
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 🔒 认证流程

1. 用户注册或登录
2. 服务器返回 JWT token
3. 客户端存储 token
4. 后续请求在 Header 中携带: `Authorization: Bearer <token>`
5. 服务器验证 token 并返回数据

---

## 💾 数据库模型

### User
```javascript
{
  username: String (unique, 2-20 chars),
  email: String (unique, valid email),
  password: String (hashed, min 6 chars),
  avatar: String (url),
  pets: [ObjectId] (ref: Pet),
  friends: [ObjectId] (ref: User),
  createdAt: Date,
  updatedAt: Date
}
```

---

## 🛠 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| PORT | 服务器端口 | 3000 |
| NODE_ENV | 环境 | development |
| MONGODB_URI | MongoDB 连接字符串 | mongodb://localhost:27017/dogreal |
| JWT_SECRET | JWT 密钥 | (必须设置) |
| JWT_EXPIRE | Token 过期时间 | 7d |
| CLIENT_URL | 前端地址 (CORS) | http://localhost:3000 |

---

## 📝 开发注意事项

1. **密码安全**: 使用 bcrypt 加密，永远不要明文存储
2. **JWT Token**: 客户端应安全存储 token
3. **错误处理**: 统一的错误响应格式
4. **验证**: 使用 express-validator 进行输入验证
5. **CORS**: 已配置支持跨域请求

---

## 🐛 常见问题

### MongoDB 连接失败
确保 MongoDB 正在运行:
```bash
brew services start mongodb-community
```

### 端口被占用
修改 `.env` 文件中的 PORT 值

---

## ✅ 已完成功能

- ✅ 用户注册
- ✅ 用户登录
- ✅ JWT 认证
- ✅ 密码加密
- ✅ 获取当前用户信息
- ✅ 输入验证
- ✅ 错误处理

## ⏳ 待开发功能

- ⏳ 宠物管理 (CRUD)
- ⏳ 照片上传
- ⏳ 好友系统
- ⏳ 推送通知
- ⏳ 评论和反应

---

准备好了吗？运行 `npm run dev` 启动服务器！🚀
