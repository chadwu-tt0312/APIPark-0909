#!/bin/bash

echo "啟動 APIPark 端口轉發服務..."
echo ""

# 檢查是否已有 port-forward 在運行
if pgrep -f "kubectl port-forward" > /dev/null; then
    echo "停止現有的 port-forward 進程..."
    pkill -f "kubectl port-forward"
    sleep 2
fi

echo "啟動端口轉發："
echo "- APIPark 主應用程式: localhost:31288"
echo "- Apinto Gateway: localhost:31899"
echo "- MySQL: localhost:31306"
echo ""

# 啟動 port-forward 服務
echo "正在啟動服務..."
kubectl port-forward svc/apipark 31288:8288 &
kubectl port-forward svc/apipark-apinto 31899:8099 &
kubectl port-forward svc/apipark-mysql 31306:3306 &

echo ""
echo "✅ 端口轉發已啟動！"
echo ""
echo "🌐 現在您可以在 Windows 瀏覽器中訪問："
echo "   - APIPark: http://localhost:31288"
echo "   - Apinto: http://localhost:31899"
echo "   - MySQL: localhost:31306"
echo ""
echo "💡 提示："
echo "   - 保持此終端開啟以維持端口轉發"
echo "   - 按 Ctrl+C 停止所有端口轉發"
echo "   - 管理員密碼：aToh0eag"
echo ""

# 等待用戶中斷
trap 'echo "停止端口轉發..."; pkill -f "kubectl port-forward"; exit' INT
wait
