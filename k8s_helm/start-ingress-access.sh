#!/bin/bash

echo "APIPark Ingress 訪問配置..."
echo ""

# 檢查 Ingress Controller 狀態
echo "檢查 Ingress Controller 狀態..."
if ! kubectl get pods -n ingress-nginx | grep -q "Running"; then
    echo "⚠️  Ingress Controller 未運行，請先安裝 Nginx Ingress Controller"
    echo "   安裝指令：kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml"
    exit 1
fi

echo "✅ Ingress Controller 運行正常"
echo ""

# 檢查 Ingress 資源
echo "檢查 Ingress 資源狀態..."
if ! kubectl get ingress apipark 2>/dev/null; then
    echo "⚠️  Ingress 資源不存在，請先部署 Helm Chart"
    echo "   部署指令：helm install apipark ./apipark"
    exit 1
fi

echo "✅ Ingress 資源已存在"
echo ""

# 取得 Node IP 和 NodePort
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODEPORT=$(kubectl get svc -n ingress-nginx apipark-ingress-controller -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}')

echo "🌐 服務訪問方式："
echo "   Node IP: $NODE_IP"
echo "   NodePort: $NODEPORT"
echo ""
echo "   請在 /etc/hosts 或 C:\\Windows\\System32\\drivers\\etc\\hosts 中新增："
echo "   $NODE_IP apipark.local"
echo ""
echo "   然後訪問："
echo "   - APIPark 主應用程式: http://apipark.local:31288/"
echo "   - Apinto API Gateway: http://apipark.local:31288/api"
echo "   - MySQL 資料庫: $NODE_IP:31306 (TCP 協議，非 HTTP)"
echo ""
echo "   或者直接使用 IP 訪問（需要指定 Host header）："
echo "   - APIPark 主應用程式: curl -H 'Host: apipark.local' http://$NODE_IP:31288/"
echo "   - Apinto API Gateway: curl -H 'Host: apipark.local' http://$NODE_IP:31288/api"
echo "   - MySQL 資料庫: $NODE_IP:31306 (使用 MySQL 客戶端連接)"
echo ""

# 測試連線
echo "🔍 測試連線..."
if curl -s -H "Host: apipark.local" -o /dev/null -w "%{http_code}" http://$NODE_IP:31288/ | grep -q "200"; then
    echo "✅ 連線測試成功！"
else
    echo "⚠️  連線測試失敗，請檢查服務狀態"
    echo "   檢查指令：kubectl get pods"
fi

echo ""
echo "💡 提示："
echo "   - 管理員密碼：aToh0eag"
echo "   - 如需修改域名，請編輯 values.yaml 中的 ingress.hosts.host"
echo "   - 如需修改路徑，請編輯 values.yaml 中的 ingress.hosts.paths"
echo ""

# 顯示 Ingress 詳細資訊
echo "📋 Ingress 詳細資訊："
kubectl describe ingress apipark
