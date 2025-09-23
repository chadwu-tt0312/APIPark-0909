#!/bin/bash

# APIPark 外部連接診斷腳本

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

print_header "APIPark 外部連接診斷"

# 1. 檢查節點 IP
print_message "1. 檢查節點 IP..."
NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}" 2>/dev/null || echo "無法獲取節點 IP")
echo "節點 IP: $NODE_IP"

# 2. 檢查服務狀態
print_message "2. 檢查 APIPark 服務狀態..."
kubectl get svc apipark -o wide

# 3. 檢查 Pod 狀態
print_message "3. 檢查 APIPark Pod 狀態..."
kubectl get pods -l component=apipark -o wide

# 4. 檢查端口監聽
print_message "4. 檢查節點端口監聽狀態..."
kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}" | xargs -I {} netstat -tlnp | grep 31288 || echo "端口 31288 未在節點上監聽"

# 5. 檢查防火牆狀態
print_message "5. 檢查防火牆狀態..."
if command -v ufw &> /dev/null; then
    echo "UFW 狀態:"
    sudo ufw status | grep 31288 || echo "端口 31288 未在 UFW 規則中"
elif command -v iptables &> /dev/null; then
    echo "iptables 規則:"
    sudo iptables -L | grep 31288 || echo "端口 31288 未在 iptables 規則中"
else
    echo "未找到防火牆工具"
fi

# 6. 測試內部連接
print_message "6. 測試內部連接..."
kubectl exec -l component=apipark -- curl -s http://localhost:8288/health || echo "內部健康檢查失敗"

# 7. 測試節點連接
print_message "7. 測試節點連接..."
curl -s -o /dev/null -w "%{http_code}" http://$NODE_IP:31288 || echo "節點連接失敗"

# 8. 檢查服務端點
print_message "8. 檢查服務端點..."
kubectl get endpoints apipark

# 9. 檢查 Pod 日誌
print_message "9. 檢查 APIPark Pod 日誌（最後 10 行）..."
kubectl logs -l component=apipark --tail=10

# 10. 提供解決方案
print_header "解決方案建議"

echo "1. 檢查防火牆規則："
echo "   sudo ufw allow 31288"
echo "   # 或"
echo "   sudo iptables -A INPUT -p tcp --dport 31288 -j ACCEPT"

echo ""
echo "2. 檢查 Kubernetes 網路策略："
echo "   kubectl get networkpolicies"

echo ""
echo "3. 重新創建服務："
echo "   kubectl delete svc apipark"
echo "   helm upgrade apipark ./apipark"

echo ""
echo "4. 使用端口轉發測試："
echo "   kubectl port-forward svc/apipark 8080:8288"
echo "   然後訪問 http://localhost:8080"

echo ""
echo "5. 檢查瀏覽器設定："
echo "   - 清除瀏覽器快取"
echo "   - 嘗試無痕模式"
echo "   - 檢查代理設定"
echo "   - 嘗試不同瀏覽器"

print_header "診斷完成"
