# 🔧 真机测试问题修复指南

## 问题1: 图片无法加载（Connection refused to localhost）

### 问题原因
后端返回的图片URL使用 `http://localhost:3000/uploads/...`，真机无法访问localhost

### 解决方案

#### 快速修复（自动）
```bash
# 运行环境切换脚本
./switch_environment.sh
# 选择 1) 真机测试
```

#### 手动修复

**步骤1: 修改后端配置**

编辑 `backend/.env`，添加或修改：
```env
# 使用你的Mac的IP地址（不是localhost）
BASE_URL=http://192.168.3.7:3000
```

获取Mac IP:
```bash
ipconfig getifaddr en0   # WiFi
# 或
ipconfig getifaddr en1   # 以太网
```

**步骤2: 重启后端服务器**
```bash
cd backend
node src/server.js
```

**步骤3: 测试图片URL**

现在后端返回的图片URL会是：
```
http://192.168.3.7:3000/uploads/avatars/xxx.jpg
```
而不是：
```
http://localhost:3000/uploads/avatars/xxx.jpg  ❌
```

### 验证修复

1. **重新上传图片测试**
   - 在真机上创建/编辑宠物档案
   - 上传新照片
   - 检查照片是否正常显示

2. **查看网络日志**
   - Flutter终端不应再有 "Connection refused" 错误
   - 图片应该能正常加载

---

## 问题2: 已有账户首次登录提示创建宠物档案

### 问题原因
1. 宠物档案加载失败但被当作"没有档案"
2. 网络延迟导致加载未完成就跳转
3. 错误处理不当，404之外的错误也清空了宠物数据

### 解决方案

已在代码中修复：

#### 修复1: 优化错误处理
```dart
// pet_provider.dart
Future<void> fetchMyPet() async {
  try {
    final pet = await _petService.getMyPet();
    _currentPet = pet;
    _error = null; // 成功加载，清除错误
  } catch (e) {
    // 只在非404错误时设置error
    if (!e.toString().contains('404') && !e.toString().contains('未找到')) {
      _error = e.toString();
      print('获取宠物档案错误: $e');
    } else {
      // 404说明确实没有宠物档案，这不是错误
      _currentPet = null;
      _error = null;
    }
  }
}
```

#### 修复2: 添加调试日志
```dart
// main.dart
if (authProvider.isAuthenticated) {
  try {
    await petProvider.fetchMyPet();
    print('宠物档案加载: ${petProvider.hasPet ? "有档案" : "无档案"}');
  } catch (e) {
    print('加载宠物档案失败: $e');
  }
}
```

### 验证修复

1. **清除应用数据重新登录**
   ```bash
   # Flutter中按 Shift+R 完全重启
   # 或者重新运行
   flutter run
   ```

2. **检查终端日志**
   - 应该看到 "宠物档案加载: 有档案" 或 "宠物档案加载: 无档案"
   - 不应该看到错误信息

3. **测试登录流程**
   - 登出应用
   - 重新登录
   - 应该直接进入主页（如果有宠物档案）
   - 或进入创建页（如果真的没有档案）

---

## 完整修复流程

### 1. 更新代码
已自动修复：
- ✅ `backend/.env` - 添加了 `BASE_URL` 配置
- ✅ `pet_provider.dart` - 优化了错误处理
- ✅ `main.dart` - 添加了调试日志

### 2. 重启服务

**重启后端**:
```bash
cd backend
node src/server.js
```

**重启Flutter应用**:
```bash
# 在Flutter终端按 Shift+R 完全重启
# 或者
cd dogreal_app
flutter run
```

### 3. 测试流程

#### 测试图片加载
1. 登录应用
2. 进入宠物档案
3. 上传新照片
4. 检查照片显示正常
5. 查看终端无 "localhost" 错误

#### 测试登录流程
1. 退出登录
2. 重新登录
3. 检查是否正确跳转
4. 查看终端日志

---

## 常见问题排查

### Q1: 修改BASE_URL后图片还是无法加载？

**检查**:
1. 后端是否重启？
2. BASE_URL格式正确？`http://IP:3000`（不是 `http://IP:3000/api`）
3. 是否是**新上传**的图片？（旧图片URL不会改变）

**解决**:
```bash
# 1. 确认后端配置
cat backend/.env | grep BASE_URL
# 应该看到: BASE_URL=http://192.168.3.7:3000

# 2. 重启后端
cd backend
node src/server.js

# 3. 测试上传新图片
```

### Q2: 登录后还是提示创建宠物档案？

**检查**:
1. 查看终端日志，是否有加载宠物档案的日志？
2. 数据库中是否真的有这个用户的宠物档案？
3. 网络连接是否正常？

**解决**:
```bash
# 1. 查看Flutter日志
# 应该看到: "宠物档案加载: 有档案" 或错误信息

# 2. 在MongoDB中检查
# 在Compass或Atlas中查找 pets 集合
# 找到 owner 字段等于当前用户ID的记录

# 3. 如果数据库中有档案但还是提示创建
# 可能是网络问题，尝试：
flutter run
# 然后在应用中退出重新登录
```

### Q3: 切换环境后出现其他问题？

**完全清理重启**:
```bash
# 1. 清理Flutter缓存
cd dogreal_app
flutter clean
flutter pub get

# 2. 重启后端
cd ../backend
node src/server.js

# 3. 重新运行
cd ../dogreal_app
flutter run
```

---

## 预防措施

### 开发环境管理

使用环境切换脚本：
```bash
# 真机测试前
./switch_environment.sh
# 选择 1) 真机测试

# 模拟器开发前
./switch_environment.sh
# 选择 2) 模拟器调试
```

### 测试检查清单

- [ ] 后端 BASE_URL 配置正确
- [ ] 前端 API 地址配置正确
- [ ] Mac和iPhone在同一WiFi
- [ ] 后端服务正在运行
- [ ] iPhone能访问 `http://MAC_IP:3000/health`
- [ ] 图片能正常上传和显示
- [ ] 登录流程正确跳转
- [ ] 查看终端无错误日志

---

## 配置参考

### 模拟器配置
```env
# backend/.env
BASE_URL=http://localhost:3000

# api_config.dart
static const String baseUrl = _simulatorUrl;
```

### 真机配置
```env
# backend/.env
BASE_URL=http://192.168.3.7:3000

# api_config.dart
static const String baseUrl = _deviceUrl;
```

---

## 成功标志

修复成功后，你应该看到：

✅ **图片加载正常**
- 宠物头像正常显示
- Feed图片正常加载
- 无 "Connection refused" 错误

✅ **登录流程正确**
- 有档案的用户直接进主页
- 无档案的用户进创建页
- 终端显示正确的加载日志

✅ **网络状态稳定**
- 所有API请求正常
- 图片上传成功
- 响应速度快

---

如果还有其他问题，检查：
1. Mac防火墙设置
2. WiFi网络稳定性
3. 后端日志是否有错误
4. Flutter热重启后是否生效
