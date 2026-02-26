#!/bin/bash

# DogReal 真机配置脚本
# 自动修改API地址为当前Mac的IP

echo "🔧 DogReal 真机配置"
echo "================================"
echo ""

# 获取Mac的IP地址
MAC_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)

if [ -z "$MAC_IP" ]; then
    echo "❌ 无法获取IP地址，请确保Mac已连接WiFi"
    exit 1
fi

echo "✅ 检测到Mac IP: $MAC_IP"
echo ""

# API配置文件路径
API_CONFIG="dogreal_app/lib/utils/api_config.dart"

if [ ! -f "$API_CONFIG" ]; then
    echo "❌ 找不到 $API_CONFIG"
    exit 1
fi

# 备份原文件
cp "$API_CONFIG" "${API_CONFIG}.backup"
echo "✅ 已备份原配置文件"

# 修改配置
# 1. 修改 _deviceUrl
sed -i '' "s|static const String _deviceUrl = 'http://YOUR_MAC_IP:3000/api';|static const String _deviceUrl = 'http://$MAC_IP:3000/api';|g" "$API_CONFIG"

# 2. 切换到真机模式
sed -i '' 's|static const String baseUrl = _simulatorUrl;|// static const String baseUrl = _simulatorUrl;|g' "$API_CONFIG"
sed -i '' 's|// static const String baseUrl = _deviceUrl;|static const String baseUrl = _deviceUrl;|g' "$API_CONFIG"

echo "✅ 已修改API配置为真机模式"
echo ""
echo "当前配置:"
echo "  API地址: http://$MAC_IP:3000/api"
echo ""
echo "================================"
echo ""
echo "📱 接下来的步骤:"
echo ""
echo "1. 连接你的iPhone到Mac（使用数据线）"
echo ""
echo "2. 在iPhone上点击"信任此电脑""
echo ""
echo "3. 运行应用到真机:"
echo "   cd dogreal_app"
echo "   flutter run"
echo ""
echo "4. 选择你的iPhone设备（而不是模拟器）"
echo ""
echo "5. 首次安装后，在iPhone上:"
echo "   设置 → 通用 → VPN与设备管理 → 信任你的Apple ID"
echo ""
echo "6. 测试网络连接（在iPhone的Safari中访问）:"
echo "   http://$MAC_IP:3000/health"
echo "   应该看到: {\"status\":\"ok\",...}"
echo ""
echo "================================"
echo ""
echo "💡 提示:"
echo "  • 确保Mac和iPhone连接同一个WiFi"
echo "  • 如果无法连接，检查Mac防火墙设置"
echo "  • 恢复模拟器配置: ./restore_simulator_config.sh"
echo ""
echo "🎉 配置完成！"
