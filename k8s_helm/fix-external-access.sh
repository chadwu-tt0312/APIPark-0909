#!/bin/bash

# APIPark 外部連接修復腳本

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_header "APIPark 外部連接修復"

# 1. 檢查當前狀態
print_message "檢查當前狀態..."
kubectl get svc apipark
kubectl get pods -l component=apipark

# 2. 獲取節點 IP
NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}" 2>/dev/null || echo "無法獲取節點 IP")
print_message "節點 IP: $NODE_IP"

# 3. 檢查防火牆
print_message "檢查並修復防火牆規則..."

if command -v ufw &> /dev/null; then
    print_message "使用 UFW 管理防火牆..."
    sudo ufw allow 31288/tcp comment "APIPark NodePort"
    sudo ufw allow 31306/tcp comment "MySQL NodePort"
    sudo ufw allow 30000/tcp comment "Grafana NodePort"
    sudo ufw reload
elif command -v iptables &> /dev/null; then
    print_message "使用 iptables 管理防火牆..."
    sudo iptables -A INPUT -p tcp --dport 31288 -j ACCEPT
    sudo iptables -A INPUT -p tcp --dport 31306 -j ACCEPT
    sudo iptables -A INPUT -p tcp --dport 30000 -j ACCEPT
    sudo iptables-save > /etc/iptables/rules.v4 2>/dev/null || echo "無法保存 iptables 規則"
else
    print_warning "未找到防火牆管理工具，請手動檢查防火牆設定"
fi

# 4. 重新創建服務
print_message "重新創建 APIPark 服務..."
kubectl delete svc apipark
sleep 5
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: apipark
  labels:
    app.kubernetes.io/name: apipark
    app.kubernetes.io/instance: apipark
    component: apipark
spec:
  type: NodePort
  ports:
    - port: 8288
      targetPort: http
      protocol: TCP
      name: http
      nodePort: 31288
  selector:
    app.kubernetes.io/name: apipark
    app.kubernetes.io/instance: apipark
    component: apipark
EOF

# 5. 等待服務就緒
print_message "等待服務就緒..."
sleep 10

# 6. 檢查服務狀態
print_message "檢查服務狀態..."
kubectl get svc apipark

# 7. 測試連接
print_message "測試連接..."
curl -s -o /dev/null -w "HTTP 狀態碼: %{http_code}\n" http://$NODE_IP:31288 || print_error "連接失敗"

# 8. 提供替代方案
print_header "替代連接方案"

echo "如果外部連接仍有問題，可以使用以下替代方案："
echo ""
echo "1. 端口轉發（推薦用於測試）："
echo "   kubectl port-forward svc/apipark 8080:8288"
echo "   然後訪問 http://localhost:8080"
echo ""
echo "2. 使用 LoadBalancer（如果支援）："
echo "   修改 values.yaml 中的 service.type 為 LoadBalancer"
echo ""
echo "3. 使用 Ingress（需要 Ingress Controller）："
echo "   配置 Ingress 規則"

# 9. 顯示最終連接資訊
print_header "連接資訊"
echo "APIPark 管理介面: http://$NODE_IP:31288"
echo "MySQL 資料庫: $NODE_IP:31306"
echo "Grafana 監控: http://$NODE_IP:30000"

print_message "修復完成！"
