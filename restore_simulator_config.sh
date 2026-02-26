#!/bin/bash

# 恢复模拟器配置脚本

echo "🔄 恢复模拟器配置"
echo "================================"

API_CONFIG="dogreal_app/lib/utils/api_config.dart"

if [ -f "${API_CONFIG}.backup" ]; then
    cp "${API_CONFIG}.backup" "$API_CONFIG"
    echo "✅ 已恢复到模拟器配置"
    echo ""
    echo "当前配置:"
    echo "  API地址: http://localhost:3000/api"
else
    # 手动恢复
    sed -i '' 's|// static const String baseUrl = _simulatorUrl;|static const String baseUrl = _simulatorUrl;|g' "$API_CONFIG"
    sed -i '' 's|static const String baseUrl = _deviceUrl;|// static const String baseUrl = _deviceUrl;|g' "$API_CONFIG"
    echo "✅ 已切换回模拟器模式"
fi

echo ""
echo "🎉 现在可以继续在模拟器上开发了"
