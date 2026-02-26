#!/bin/bash

# DogReal 真机部署检查脚本

echo "🐾 DogReal 真机部署检查"
echo "================================"
echo ""

# 1. 检查Mac的IP地址
echo "📍 第1步: 获取Mac的局域网IP地址"
echo "--------------------------------"
MAC_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)

if [ -z "$MAC_IP" ]; then
    echo "❌ 无法获取IP地址，请确保Mac已连接WiFi"
    echo "   手动查看: 系统设置 → 网络 → WiFi → 详细信息"
else
    echo "✅ Mac的IP地址: $MAC_IP"
    echo ""
    echo "   请在手机浏览器访问测试:"
    echo "   👉 http://$MAC_IP:3000/health"
fi

echo ""
echo "--------------------------------"

# 2. 检查后端是否运行
echo "📍 第2步: 检查后端服务状态"
echo "--------------------------------"
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ 后端服务正在运行"
    curl -s http://localhost:3000/health | grep -o '"status":"ok"' > /dev/null
    if [ $? -eq 0 ]; then
        echo "✅ 后端服务响应正常"
    fi
else
    echo "❌ 后端服务未运行"
    echo "   请在backend目录运行: node src/server.js"
fi

echo ""
echo "--------------------------------"

# 3. 检查MongoDB连接
echo "📍 第3步: 检查数据库配置"
echo "--------------------------------"
if [ -f "backend/.env" ]; then
    if grep -q "mongodb+srv://" backend/.env; then
        echo "✅ 使用云数据库 (MongoDB Atlas)"
    elif grep -q "mongodb://localhost" backend/.env; then
        echo "⚠️  使用本地数据库（真机无法访问）"
        echo "   建议：使用MongoDB Atlas云数据库"
    fi
else
    echo "❌ 找不到 backend/.env 文件"
fi

echo ""
echo "--------------------------------"

# 4. 检查Flutter配置
echo "📍 第4步: 检查Flutter API配置"
echo "--------------------------------"
API_CONFIG="dogreal_app/lib/utils/api_config.dart"
if [ -f "$API_CONFIG" ]; then
    if grep -q "localhost" "$API_CONFIG" | grep -v "//"; then
        echo "⚠️  当前配置: 模拟器模式 (localhost)"
        echo "   真机测试需要修改为: http://$MAC_IP:3000/api"
        echo ""
        echo "   修改文件: $API_CONFIG"
        echo "   找到: static const String baseUrl = "
        echo "   改为: static const String baseUrl = _deviceUrl;"
        echo "   并修改: static const String _deviceUrl = 'http://$MAC_IP:3000/api';"
    fi
else
    echo "❌ 找不到 $API_CONFIG"
fi

echo ""
echo "--------------------------------"

# 5. 检查Xcode配置
echo "📍 第5步: iOS项目配置"
echo "--------------------------------"
if [ -d "dogreal_app/ios" ]; then
    echo "✅ iOS项目存在"
    
    # 检查Info.plist权限
    INFO_PLIST="dogreal_app/ios/Runner/Info.plist"
    if [ -f "$INFO_PLIST" ]; then
        if grep -q "NSCameraUsageDescription" "$INFO_PLIST" && \
           grep -q "NSPhotoLibraryUsageDescription" "$INFO_PLIST" && \
           grep -q "NSUserNotificationsUsageDescription" "$INFO_PLIST"; then
            echo "✅ 权限配置完整（相机、相册、通知）"
        else
            echo "⚠️  权限配置可能不完整"
        fi
    fi
else
    echo "❌ 找不到 iOS 项目"
fi

echo ""
echo "================================"
echo ""

# 6. 总结和下一步
echo "📋 部署检查总结"
echo "================================"
echo ""
echo "接下来的步骤:"
echo ""
echo "1️⃣  修改 API 配置"
echo "   文件: dogreal_app/lib/utils/api_config.dart"
if [ ! -z "$MAC_IP" ]; then
    echo "   改为: static const String baseUrl = 'http://$MAC_IP:3000/api';"
fi
echo ""
echo "2️⃣  连接你的iPhone到Mac（数据线）"
echo ""
echo "3️⃣  在iPhone上信任这台电脑"
echo ""
echo "4️⃣  运行应用到真机："
echo "   cd dogreal_app"
echo "   flutter run"
echo ""
echo "5️⃣  首次安装后，在iPhone上："
echo "   设置 → 通用 → VPN与设备管理 → 信任开发者"
echo ""
echo "6️⃣  测试网络连接："
echo "   在iPhone的Safari浏览器访问:"
if [ ! -z "$MAC_IP" ]; then
    echo "   http://$MAC_IP:3000/health"
fi
echo ""
echo "================================"
echo ""

# 7. 防火墙检查（可选）
echo "💡 如果手机无法访问后端："
echo "   • 检查Mac和iPhone是否在同一WiFi"
echo "   • 临时关闭Mac防火墙: 系统设置 → 网络 → 防火墙"
echo "   • 或允许Node.js通过防火墙"
echo ""
echo "🎉 准备完成！开始部署吧！"
echo ""
