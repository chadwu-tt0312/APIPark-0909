#!/bin/bash

echo "APIPark WSL2 端口轉發配置..."
echo ""

# 取得 WSL2 的 IP 地址
WSL_IP=$(hostname -I | awk '{print $1}')
echo "WSL2 IP: $WSL_IP"

# 檢查服務狀態
echo "檢查 Kubernetes 服務狀態..."
if ! kubectl get pods | grep -q "Running"; then
    echo "⚠️  Kubernetes 服務未運行，請先啟動服務"
    exit 1
fi

echo "✅ Kubernetes 服務運行正常"
echo ""

# 檢查端口是否被佔用
if lsof -Pi :31288 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  端口 31288 已被佔用，正在停止現有進程..."
    pkill -f "kubectl port-forward.*31288"
    sleep 2
fi

echo "啟動端口轉發服務..."
echo "- APIPark 主應用程式: 0.0.0.0:31288"
echo ""

# 啟動 port-forward 服務
kubectl port-forward --address 0.0.0.0 svc/apipark 31288:8288

echo ""
echo "✅ 端口轉發已啟動！"
echo ""
echo "🌐 現在您可以在 Windows 中訪問："
echo "   - APIPark: http://$WSL_IP:31288/"
echo ""
echo "💡 提示："
echo "   - 保持此終端開啟以維持端口轉發"
echo "   - 按 Ctrl+C 停止所有端口轉發"
echo "   - 管理員密碼：aToh0eag"
echo ""

# 等待用戶中斷
trap 'echo "停止端口轉發..."; pkill -f "kubectl port-forward"; exit' INT
wait
