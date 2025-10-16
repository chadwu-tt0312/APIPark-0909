#!/bin/bash

echo "APIPark API 訪問診斷工具"
echo "========================"
echo ""

# 檢查服務狀態
echo "🔍 檢查服務狀態..."
kubectl get pods | grep -E "(apipark|apinto)"

echo ""
echo "🔍 檢查 Ingress 配置..."
kubectl get ingress apipark -o wide

echo ""
echo "🔍 檢查服務端口..."
kubectl get svc | grep -E "(apipark|apinto)"

echo ""
echo "🌐 測試基本連線..."

# 測試主應用程式
echo "測試 APIPark 主應用程式..."
if curl -s -H "Host: apipark.local" http://172.18.0.2:31288/ | grep -q "APIPark\|apipark"; then
    echo "✅ APIPark 主應用程式可訪問"
else
    echo "❌ APIPark 主應用程式無法訪問"
fi

# 測試 API Gateway
echo "測試 Apinto API Gateway..."
API_RESPONSE=$(curl -s -H "Host: apipark.local" http://172.18.0.2:31288/api/)
if echo "$API_RESPONSE" | grep -q "missing or invalid token"; then
    echo "⚠️  API Gateway 需要認證令牌"
elif echo "$API_RESPONSE" | grep -q "404"; then
    echo "⚠️  API Gateway 路由未配置"
else
    echo "✅ API Gateway 可訪問"
fi

echo ""
echo "🔧 解決方案："
echo ""
echo "1. 訪問 APIPark 主應用程式："
echo "   http://apipark.local:31288/"
echo "   或 http://172.18.0.2:31288/"
echo ""
echo "2. 登入 APIPark 管理介面："
echo "   - 管理員密碼：aToh0eag"
echo "   - 在管理介面中配置 API Gateway"
echo ""
echo "3. 配置 API 路由："
echo "   - 在 APIPark 管理介面中設定 API 路由"
echo "   - 配置正確的認證令牌"
echo "   - 設定後端服務指向"
echo ""
echo "4. 檢查 API 配置："
echo "   - 確認 API 路由已正確配置"
echo "   - 檢查認證設定"
echo "   - 驗證後端服務連接"
echo ""

# 提供詳細的 API 配置指導
echo "📋 API 配置指導："
echo ""
echo "要配置 API Gateway，請："
echo "1. 開啟瀏覽器訪問：http://apipark.local:31288/"
echo "2. 使用管理員密碼登入：aToh0eag"
echo "3. 進入 API 管理 → 路由配置"
echo "4. 新增或編輯 API 路由"
echo "5. 設定正確的後端服務和認證"
echo ""

echo "💡 提示："
echo "   - 403 Forbidden 通常表示認證問題"
echo "   - 401 Unauthorized 表示缺少認證令牌"
echo "   - 需要先在 APIPark 管理介面中配置 API 路由"
echo ""
