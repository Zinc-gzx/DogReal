#!/bin/bash

# DogReal 阿里云快速部署脚本
# 用途：将后端代码打包并上传到阿里云服务器

echo "🚀 DogReal 阿里云部署助手"
echo "================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否在项目根目录
if [ ! -d "backend" ]; then
    echo -e "${RED}❌ 错误：请在DogReal项目根目录运行此脚本${NC}"
    exit 1
fi

# 询问服务器信息
echo "📝 请输入服务器信息："
echo ""
read -p "服务器IP地址: " SERVER_IP
read -p "服务器用户名 (默认: dogreal): " SERVER_USER
SERVER_USER=${SERVER_USER:-dogreal}

echo ""
echo -e "${YELLOW}⚠️  确认信息：${NC}"
echo "服务器IP: $SERVER_IP"
echo "用户名: $SERVER_USER"
read -p "是否继续？(y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "取消部署"
    exit 0
fi

echo ""
echo "================================"
echo "📦 步骤1: 打包后端代码"
echo "================================"

# 创建临时目录
TEMP_DIR="deploy_temp"
mkdir -p $TEMP_DIR

# 复制后端代码
echo "复制后端文件..."
cp -r backend $TEMP_DIR/
cd $TEMP_DIR/backend

# 删除不需要的文件
echo "清理不必要的文件..."
rm -rf node_modules
rm -f .env
rm -f package-lock.json

# 创建.env.example用于参考
cat > .env.example << 'EOL'
# Server Configuration
PORT=3000
NODE_ENV=production

# MongoDB Configuration (使用MongoDB Atlas)
MONGODB_URI=mongodb+srv://username:password@cluster.xxxxx.mongodb.net/dogreal

# JWT Configuration (使用 node -e "console.log(require('crypto').randomBytes(64).toString('hex'))" 生成)
JWT_SECRET=your-super-secret-key-change-this
JWT_EXPIRE=7d

# CORS Configuration
CLIENT_URL=*
EOL

cd ..

# 打包
echo "打包中..."
tar -czf dogreal-backend.tar.gz backend/
mv dogreal-backend.tar.gz ../

cd ..
rm -rf $TEMP_DIR

echo -e "${GREEN}✅ 打包完成: dogreal-backend.tar.gz${NC}"
echo ""

echo "================================"
echo "📤 步骤2: 上传到服务器"
echo "================================"

# 上传文件
echo "上传代码包到服务器..."
scp dogreal-backend.tar.gz $SERVER_USER@$SERVER_IP:~/

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 上传成功${NC}"
else
    echo -e "${RED}❌ 上传失败，请检查服务器连接${NC}"
    exit 1
fi

echo ""
echo "================================"
echo "🔧 步骤3: 服务器端部署"
echo "================================"
echo ""
echo "正在连接服务器并执行部署命令..."

# SSH到服务器并执行部署
ssh $SERVER_USER@$SERVER_IP << 'ENDSSH'
    echo "📦 解压代码包..."
    tar -xzf dogreal-backend.tar.gz
    cd backend
    
    echo "📥 安装依赖..."
    npm install --production
    
    echo "📁 创建上传目录..."
    mkdir -p uploads/avatars
    mkdir -p uploads/posts
    
    echo ""
    echo "⚠️  重要：请配置环境变量"
    echo "================================"
    echo "1. 编辑 .env 文件："
    echo "   nano ~/backend/.env"
    echo ""
    echo "2. 参考 .env.example 填写配置"
    echo ""
    echo "3. 生成JWT密钥："
    echo "   node -e \"console.log(require('crypto').randomBytes(64).toString('hex'))\""
    echo ""
    echo "4. 启动应用："
    echo "   pm2 start src/server.js --name dogreal-api"
    echo "   pm2 save"
    echo ""
    echo "5. 查看日志："
    echo "   pm2 logs dogreal-api"
    echo ""
    echo "================================"
ENDSSH

echo ""
echo "================================"
echo "✨ 部署完成！"
echo "================================"
echo ""
echo -e "${GREEN}后端代码已上传到服务器${NC}"
echo ""
echo "📋 接下来的步骤："
echo ""
echo "1️⃣  SSH到服务器："
echo "   ssh $SERVER_USER@$SERVER_IP"
echo ""
echo "2️⃣  配置环境变量："
echo "   cd backend"
echo "   nano .env"
echo "   (参考 .env.example 填写)"
echo ""
echo "3️⃣  生成JWT密钥并填入.env："
echo '   node -e "console.log(require('"'"'crypto'"'"').randomBytes(64).toString('"'"'hex'"'"'))"'
echo ""
echo "4️⃣  启动应用："
echo "   pm2 start src/server.js --name dogreal-api"
echo "   pm2 startup"
echo "   pm2 save"
echo ""
echo "5️⃣  测试API："
echo "   curl http://localhost:3000/health"
echo "   (或在浏览器访问 http://$SERVER_IP:3000/health)"
echo ""
echo "6️⃣  配置Nginx和SSL（可选）："
echo "   参考 ALIYUN_DEPLOYMENT.md 第6章节"
echo ""
echo "7️⃣  修改Flutter应用配置："
echo "   编辑 dogreal_app/lib/utils/api_config.dart"
echo "   将 baseUrl 改为服务器地址"
echo ""
echo "================================"
echo ""
echo -e "${YELLOW}💡 提示：详细步骤请查看 ALIYUN_DEPLOYMENT.md${NC}"
echo ""
echo "🎉 祝部署顺利！"
echo ""

# 清理本地打包文件
read -p "是否删除本地打包文件 dogreal-backend.tar.gz？(y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f dogreal-backend.tar.gz
    echo "已删除本地打包文件"
fi

echo ""
