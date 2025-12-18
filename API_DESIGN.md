# DogReal API 设计文档

## 基础配置

- **Base URL**: `http://localhost:3000/api/v1` (开发环境)
- **Content-Type**: `application/json`
- **认证方式**: JWT Bearer Token

## 认证相关 API

### 1. 用户注册
```
POST /auth/register
```

**请求体:**
```json
{
  "username": "string (2-20字符)",
  "email": "string (有效邮箱)",
  "password": "string (最少6字符)"
}
```

**成功响应 (201):**
```json
{
  "success": true,
  "message": "注册成功",
  "data": {
    "user": {
      "id": "string",
      "username": "string",
      "email": "string",
      "createdAt": "timestamp"
    },
    "token": "string (JWT token)"
  }
}
```

**错误响应:**
- 400: 验证失败
- 409: 邮箱或用户名已存在

---

### 2. 用户登录
```
POST /auth/login
```

**请求体:**
```json
{
  "email": "string",
  "password": "string"
}
```

**成功响应 (200):**
```json
{
  "success": true,
  "message": "登录成功",
  "data": {
    "user": {
      "id": "string",
      "username": "string",
      "email": "string",
      "avatar": "string (url)",
      "pets": []
    },
    "token": "string (JWT token)"
  }
}
```

**错误响应:**
- 400: 验证失败
- 401: 邮箱或密码错误

---

### 3. 获取当前用户信息
```
GET /auth/me
Authorization: Bearer <token>
```

**成功响应 (200):**
```json
{
  "success": true,
  "data": {
    "id": "string",
    "username": "string",
    "email": "string",
    "avatar": "string (url)",
    "pets": [],
    "friends": [],
    "createdAt": "timestamp"
  }
}
```

**错误响应:**
- 401: 未授权

---

### 4. 忘记密码
```
POST /auth/forgot-password
```

**请求体:**
```json
{
  "email": "string"
}
```

**成功响应 (200):**
```json
{
  "success": true,
  "message": "重置密码邮件已发送"
}
```

---

### 5. 重置密码
```
POST /auth/reset-password
```

**请求体:**
```json
{
  "token": "string (来自邮件)",
  "newPassword": "string"
}
```

**成功响应 (200):**
```json
{
  "success": true,
  "message": "密码重置成功"
}
```

---

## 宠物相关 API

### 1. 添加宠物
```
POST /pets
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "name": "string",
  "type": "dog|cat|other",
  "breed": "string (可选)",
  "birthday": "date (可选)",
  "avatar": "string (url)"
}
```

---

### 2. 获取我的宠物列表
```
GET /pets
Authorization: Bearer <token>
```

---

### 3. 更新宠物信息
```
PUT /pets/:petId
Authorization: Bearer <token>
```

---

### 4. 删除宠物
```
DELETE /pets/:petId
Authorization: Bearer <token>
```

---

## 照片相关 API

### 1. 上传照片
```
POST /posts
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**请求体:**
```
frontImage: File
backImage: File
petId: string
caption: string (可选)
location: string (可选)
```

**成功响应 (201):**
```json
{
  "success": true,
  "message": "照片上传成功",
  "data": {
    "id": "string",
    "frontImageUrl": "string",
    "backImageUrl": "string",
    "pet": {},
    "user": {},
    "caption": "string",
    "location": "string",
    "createdAt": "timestamp",
    "reactions": []
  }
}
```

---

### 2. 获取今日照片
```
GET /posts/today
Authorization: Bearer <token>
```

**成功响应 (200):**
```json
{
  "success": true,
  "data": {
    "myPost": {}, // 我的今日照片
    "friendsPosts": [], // 好友的今日照片
    "notificationTime": "timestamp", // 今日通知时间
    "timeRemaining": "number (秒)" // 剩余上传时间
  }
}
```

---

### 3. 获取照片历史
```
GET /posts/history
Authorization: Bearer <token>
Query: page=1&limit=20
```

---

### 4. 删除照片
```
DELETE /posts/:postId
Authorization: Bearer <token>
```

---

## 好友相关 API

### 1. 搜索用户
```
GET /users/search?q=username
Authorization: Bearer <token>
```

---

### 2. 发送好友请求
```
POST /friends/request
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "userId": "string"
}
```

---

### 3. 接受好友请求
```
POST /friends/accept/:requestId
Authorization: Bearer <token>
```

---

### 4. 拒绝好友请求
```
POST /friends/reject/:requestId
Authorization: Bearer <token>
```

---

### 5. 获取好友列表
```
GET /friends
Authorization: Bearer <token>
```

---

### 6. 删除好友
```
DELETE /friends/:friendId
Authorization: Bearer <token>
```

---

## 通知相关 API

### 1. 获取通知设置
```
GET /notifications/settings
Authorization: Bearer <token>
```

---

### 2. 更新通知设置
```
PUT /notifications/settings
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "enabled": true,
  "deviceToken": "string (FCM token)"
}
```

---

### 3. 获取今日通知时间
```
GET /notifications/today
Authorization: Bearer <token>
```

**成功响应 (200):**
```json
{
  "success": true,
  "data": {
    "notificationTime": "timestamp",
    "hasPostedToday": false,
    "timeRemaining": 7200 // 秒
  }
}
```

---

## 反应相关 API

### 1. 给照片添加反应
```
POST /posts/:postId/reactions
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "type": "love|laugh|surprise|sad"
}
```

---

### 2. 添加评论
```
POST /posts/:postId/comments
Authorization: Bearer <token>
```

**请求体:**
```json
{
  "content": "string"
}
```

---

## 数据模型

### User
```javascript
{
  id: ObjectId,
  username: String (唯一),
  email: String (唯一),
  password: String (加密),
  avatar: String (url),
  pets: [ObjectId] (ref: Pet),
  friends: [ObjectId] (ref: User),
  createdAt: Date,
  updatedAt: Date
}
```

### Pet
```javascript
{
  id: ObjectId,
  name: String,
  type: String (enum: dog, cat, other),
  breed: String,
  birthday: Date,
  avatar: String (url),
  owner: ObjectId (ref: User),
  createdAt: Date,
  updatedAt: Date
}
```

### Post
```javascript
{
  id: ObjectId,
  user: ObjectId (ref: User),
  pet: ObjectId (ref: Pet),
  frontImageUrl: String,
  backImageUrl: String,
  caption: String,
  location: String,
  notificationTime: Date, // 该照片对应的通知时间
  reactions: [{
    user: ObjectId (ref: User),
    type: String (enum),
    createdAt: Date
  }],
  comments: [{
    user: ObjectId (ref: User),
    content: String,
    createdAt: Date
  }],
  createdAt: Date,
  updatedAt: Date
}
```

### Notification
```javascript
{
  id: ObjectId,
  date: Date, // 通知日期
  time: Date, // 通知的具体时间
  users: [ObjectId] (ref: User), // 接收该通知的用户
  createdAt: Date
}
```

---

## 错误响应格式

所有错误响应遵循统一格式:

```json
{
  "success": false,
  "message": "错误描述",
  "errors": [
    {
      "field": "email",
      "message": "邮箱格式不正确"
    }
  ]
}
```

### HTTP 状态码
- 200: 成功
- 201: 创建成功
- 400: 请求参数错误
- 401: 未授权
- 403: 禁止访问
- 404: 资源不存在
- 409: 资源冲突
- 500: 服务器错误

---

## 开发优先级

1. ✅ 用户注册/登录
2. ⏳ JWT 认证
3. ⏳ 添加宠物
4. ⏳ 上传照片
5. ⏳ 获取今日照片
6. ⏳ 推送通知系统
7. ⏳ 好友系统
8. ⏳ 反应和评论

---

下一步: 开始实现 Node.js + Express 后端！
