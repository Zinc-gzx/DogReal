#!/bin/bash

# DogReal 阿里云服务器初始化脚本
# 用途：在新的Ubuntu服务器上自动安装所有必要软件
# 使用方法：
#   1. 上传此脚本到服务器: scp server_setup.sh user@server-ip:~/
#   2. SSH到服务器: ssh user@server-ip
#   3. 运行脚本: bash server_setup.sh

echo "🐾 DogReal 服务器环境初始化"
echo "================================"
echo ""
echo "此脚本将安装："
echo "  ✓ Node.js 20.x LTS"
echo "  ✓ PM2 进程管理器"
echo "  ✓ Nginx 反向代理"
echo "  ✓ UFW 防火墙"
echo "  ✓ Git 版本控制"
echo "  ✓ Certbot SSL证书工具"
echo ""
read -p "按回车开始安装..." 

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查是否为root或有sudo权限
if [ "$EUID" -ne 0 ]; then 
    if ! sudo -n true 2>/dev/null; then
        echo -e "${RED}❌ 此脚本需要sudo权限${NC}"
        exit 1
    fi
fi

echo ""
echo "================================"
echo "📦 步骤1: 更新系统"
echo "================================"
sudo apt update
sudo apt upgrade -y
echo -e "${GREEN}✅ 系统更新完成${NC}"

echo ""
echo "================================"
echo "📦 步骤2: 安装Node.js"
echo "================================"
if command -v node &> /dev/null; then
    echo -e "${YELLOW}⚠️  Node.js已安装: $(node --version)${NC}"
    read -p "是否重新安装？(y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "跳过Node.js安装"
    else
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt install -y nodejs
    fi
else
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
fi
echo -e "${GREEN}✅ Node.js安装完成: $(node --version)${NC}"
echo -e "${GREEN}✅ npm版本: $(npm --version)${NC}"

echo ""
echo "================================"
echo "📦 步骤3: 安装PM2"
echo "================================"
if command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}⚠️  PM2已安装: $(pm2 --version)${NC}"
else
    sudo npm install -g pm2
    echo -e "${GREEN}✅ PM2安装完成: $(pm2 --version)${NC}"
fi

echo ""
echo "================================"
echo "📦 步骤4: 安装Git"
echo "================================"
if command -v git &> /dev/null; then
    echo -e "${YELLOW}⚠️  Git已安装: $(git --version)${NC}"
else
    sudo apt install git -y
    echo -e "${GREEN}✅ Git安装完成: $(git --version)${NC}"
fi

echo ""
echo "================================"
echo "📦 步骤5: 安装Nginx"
echo "================================"
if command -v nginx &> /dev/null; then
    echo -e "${YELLOW}⚠️  Nginx已安装${NC}"
else
    sudo apt install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo -e "${GREEN}✅ Nginx安装并启动完成${NC}"
fi

echo ""
echo "================================"
echo "🔒 步骤6: 配置防火墙"
echo "================================"
if sudo ufw status | grep -q "Status: active"; then
    echo -e "${YELLOW}⚠️  UFW防火墙已启用${NC}"
else
    sudo apt install ufw -y
    
    echo "配置防火墙规则..."
    sudo ufw allow 22/tcp    # SSH
    sudo ufw allow 80/tcp    # HTTP
    sudo ufw allow 443/tcp   # HTTPS
    sudo ufw allow 3000/tcp  # Node.js
    
    echo "启用防火墙..."
    echo "y" | sudo ufw enable
    
    echo -e "${GREEN}✅ 防火墙配置完成${NC}"
fi

sudo ufw status numbered

echo ""
echo "================================"
echo "📦 步骤7: 安装SSL证书工具"
echo "================================"
if command -v certbot &> /dev/null; then
    echo -e "${YELLOW}⚠️  Certbot已安装${NC}"
else
    sudo apt install certbot python3-certbot-nginx -y
    echo -e "${GREEN}✅ Certbot安装完成${NC}"
fi

echo ""
echo "================================"
echo "✨ 安装完成！"
echo "================================"
echo ""
echo -e "${GREEN}已安装的软件:${NC}"
echo "  ✓ Node.js: $(node --version)"
echo "  ✓ npm: $(npm --version)"
echo "  ✓ PM2: $(pm2 --version)"
echo "  ✓ Git: $(git --version)"
echo "  ✓ Nginx: $(nginx -v 2>&1)"
echo "  ✓ Certbot: $(certbot --version 2>&1 | head -n1)"
echo ""
echo "================================"
echo "📋 接下来的步骤"
echo "================================"
echo ""
echo "1️⃣  上传后端代码到服务器"
echo "   在本地运行:"
echo "   cd /path/to/DogReal"
echo "   bash deploy_to_aliyun.sh"
echo ""
echo "2️⃣  配置环境变量"
echo "   cd ~/backend"
echo "   nano .env"
echo ""
echo "3️⃣  启动应用"
echo "   pm2 start src/server.js --name dogreal-api"
echo "   pm2 startup"
echo "   pm2 save"
echo ""
echo "4️⃣  测试API"
echo "   curl http://localhost:3000/health"
echo ""
echo "5️⃣  配置域名（可选）"
echo "   sudo nano /etc/nginx/sites-available/dogreal"
echo "   (参考 ALIYUN_DEPLOYMENT.md)"
echo ""
echo "6️⃣  安装SSL证书（可选）"
echo "   sudo certbot --nginx -d api.yourdomain.com"
echo ""
echo "================================"
echo ""
echo -e "${BLUE}💡 详细部署步骤请查看: ALIYUN_DEPLOYMENT.md${NC}"
echo ""
echo "🎉 服务器环境准备完成！"
echo ""
