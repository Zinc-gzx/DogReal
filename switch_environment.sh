#!/bin/bash

# 快速切换真机/模拟器配置脚本

echo "🔄 DogReal 环境配置切换"
echo "================================"
echo ""

# 获取Mac的IP地址
MAC_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)

if [ -z "$MAC_IP" ]; then
    echo "❌ 无法获取IP地址，请确保Mac已连接WiFi"
    MAC_IP="YOUR_MAC_IP"
fi

echo "检测到Mac IP: $MAC_IP"
echo ""
echo "请选择环境:"
echo "  1) 真机测试（使用Mac IP: $MAC_IP）"
echo "  2) 模拟器调试（使用 localhost）"
echo ""
read -p "请输入选择 (1/2): " choice

case $choice in
    1)
        echo ""
        echo "📱 切换到真机模式..."
        
        # 修改后端 .env
        if [ -f "backend/.env" ]; then
            # 更新或添加 BASE_URL
            if grep -q "^BASE_URL=" backend/.env; then
                sed -i '' "s|^BASE_URL=.*|BASE_URL=http://$MAC_IP:3000|" backend/.env
            else
                echo "" >> backend/.env
                echo "# Base URL for image links" >> backend/.env
                echo "BASE_URL=http://$MAC_IP:3000" >> backend/.env
            fi
            echo "✅ 后端配置已更新: BASE_URL=http://$MAC_IP:3000"
        else
            echo "⚠️  找不到 backend/.env"
        fi
        
        # 修改前端 api_config.dart
        API_CONFIG="dogreal_app/lib/utils/api_config.dart"
        if [ -f "$API_CONFIG" ]; then
            # 更新 _deviceUrl
            sed -i '' "s|static const String _deviceUrl = 'http://.*:3000/api';|static const String _deviceUrl = 'http://$MAC_IP:3000/api';|" "$API_CONFIG"
            
            # 切换到真机模式
            sed -i '' 's|static const String baseUrl = _simulatorUrl;|// static const String baseUrl = _simulatorUrl;|' "$API_CONFIG"
            sed -i '' 's|// static const String baseUrl = _deviceUrl;|static const String baseUrl = _deviceUrl;|' "$API_CONFIG"
            
            echo "✅ 前端配置已更新: http://$MAC_IP:3000/api"
        else
            echo "⚠️  找不到 $API_CONFIG"
        fi
        
        echo ""
        echo "✅ 真机模式配置完成！"
        echo ""
        echo "📝 接下来的步骤:"
        echo "  1. 重启后端: cd backend && node src/server.js"
        echo "  2. 连接iPhone到Mac（数据线）"
        echo "  3. 运行: cd dogreal_app && flutter run"
        echo "  4. 在iPhone Safari访问测试: http://$MAC_IP:3000/health"
        ;;
        
    2)
        echo ""
        echo "💻 切换到模拟器模式..."
        
        # 修改后端 .env
        if [ -f "backend/.env" ]; then
            if grep -q "^BASE_URL=" backend/.env; then
                sed -i '' "s|^BASE_URL=.*|BASE_URL=http://localhost:3000|" backend/.env
            else
                echo "" >> backend/.env
                echo "# Base URL for image links" >> backend/.env
                echo "BASE_URL=http://localhost:3000" >> backend/.env
            fi
            echo "✅ 后端配置已更新: BASE_URL=http://localhost:3000"
        else
            echo "⚠️  找不到 backend/.env"
        fi
        
        # 修改前端 api_config.dart
        API_CONFIG="dogreal_app/lib/utils/api_config.dart"
        if [ -f "$API_CONFIG" ]; then
            # 切换到模拟器模式
            sed -i '' 's|// static const String baseUrl = _simulatorUrl;|static const String baseUrl = _simulatorUrl;|' "$API_CONFIG"
            sed -i '' 's|static const String baseUrl = _deviceUrl;|// static const String baseUrl = _deviceUrl;|' "$API_CONFIG"
            
            echo "✅ 前端配置已更新: http://localhost:3000/api"
        else
            echo "⚠️  找不到 $API_CONFIG"
        fi
        
        echo ""
        echo "✅ 模拟器模式配置完成！"
        echo ""
        echo "📝 接下来的步骤:"
        echo "  1. 重启后端: cd backend && node src/server.js"
        echo "  2. 运行: cd dogreal_app && flutter run"
        ;;
        
    *)
        echo "❌ 无效的选择"
        exit 1
        ;;
esac

echo ""
echo "================================"
echo ""
echo "⚠️  重要提示:"
echo "  • 配置修改后需要重启后端服务器"
echo "  • Flutter使用热重启 (R) 加载新配置"
echo "  • 真机需要Mac和iPhone在同一WiFi"
echo ""
