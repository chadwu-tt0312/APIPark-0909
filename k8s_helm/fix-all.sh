#!/bin/bash

# APIPark 全體服務修復腳本

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

print_header "APIPark 全體服務修復腳本"

# 1. 檢查整體狀態
print_message "檢查整體 Pod 狀態..."
kubectl get pods -l app.kubernetes.io/name=apipark

echo
print_header "修復 MySQL"
# 2. 修復 MySQL
print_message "檢查 MySQL 狀態..."
kubectl get pods -l component=mysql

if kubectl get pods -l component=mysql --no-headers | grep -q "Error\|CrashLoopBackOff\|Pending"; then
    print_warning "MySQL 有問題，正在修復..."
    kubectl delete pod -l component=mysql
    sleep 10
    print_message "MySQL 重新部署完成"
else
    print_message "MySQL 狀態正常"
fi

echo
print_header "修復 Redis"
# 3. 修復 Redis
print_message "檢查 Redis 狀態..."
kubectl get pods -l component=redis

if kubectl get pods -l component=redis --no-headers | grep -q "Error\|CrashLoopBackOff\|Pending"; then
    print_warning "Redis 有問題，正在修復..."
    kubectl delete pod -l component=redis
    sleep 10
    print_message "Redis 重新部署完成"
else
    print_message "Redis 狀態正常"
fi

echo
print_header "修復 InfluxDB"
# 4. 修復 InfluxDB
print_message "檢查 InfluxDB 狀態..."
kubectl get pods -l component=influxdb

if kubectl get pods -l component=influxdb --no-headers | grep -q "Error\|CrashLoopBackOff\|Pending"; then
    print_warning "InfluxDB 有問題，正在修復..."
    kubectl delete pod -l component=influxdb
    sleep 10
    print_message "InfluxDB 重新部署完成"
else
    print_message "InfluxDB 狀態正常"
fi

echo
print_header "修復 Loki"
# 5. 修復 Loki
print_message "檢查 Loki 狀態..."
kubectl get pods -l component=loki

if kubectl get pods -l component=loki --no-headers | grep -q "Error\|CrashLoopBackOff\|Pending"; then
    print_warning "Loki 有問題，正在修復..."
    kubectl delete pod -l component=loki
    sleep 10
    print_message "Loki 重新部署完成"
else
    print_message "Loki 狀態正常"
fi

echo
print_header "修復 Grafana"
# 6. 修復 Grafana
print_message "檢查 Grafana 狀態..."
kubectl get pods -l component=grafana

if kubectl get pods -l component=grafana --no-headers | grep -q "Error\|CrashLoopBackOff\|Pending"; then
    print_warning "Grafana 有問題，正在修復..."
    kubectl delete pod -l component=grafana
    sleep 10
    print_message "Grafana 重新部署完成"
else
    print_message "Grafana 狀態正常"
fi

echo
print_header "修復 NSQ"
# 7. 修復 NSQ
print_message "檢查 NSQ 狀態..."
kubectl get pods -l component=nsq

if kubectl get pods -l component=nsq --no-headers | grep -q "Error\|CrashLoopBackOff\|Pending"; then
    print_warning "NSQ 有問題，正在修復..."
    kubectl delete pod -l component=nsq
    sleep 10
    print_message "NSQ 重新部署完成"
else
    print_message "NSQ 狀態正常"
fi

echo
print_header "修復 Apinto"
# 8. 修復 Apinto
print_message "檢查 Apinto 狀態..."
kubectl get pods -l component=apinto

if kubectl get pods -l component=apinto --no-headers | grep -q "Error\|CrashLoopBackOff\|Pending"; then
    print_warning "Apinto 有問題，正在修復..."
    kubectl delete pod -l component=apinto
    sleep 10
    print_message "Apinto 重新部署完成"
else
    print_message "Apinto 狀態正常"
fi

echo
print_header "修復 APIPark 主應用"
# 9. 修復 APIPark 主應用
print_message "檢查 APIPark 主應用狀態..."
kubectl get pods -l component=apipark

if kubectl get pods -l component=apipark --no-headers | grep -q "Error\|CrashLoopBackOff\|Pending"; then
    print_warning "APIPark 主應用有問題，正在修復..."
    kubectl delete pod -l component=apipark
    sleep 10
    print_message "APIPark 主應用重新部署完成"
else
    print_message "APIPark 主應用狀態正常"
fi

echo
print_header "最終狀態檢查"
# 10. 最終狀態檢查
print_message "等待所有服務啟動..."
sleep 30

print_message "最終 Pod 狀態："
kubectl get pods -l app.kubernetes.io/name=apipark

print_message "服務狀態："
kubectl get svc -l app.kubernetes.io/name=apipark

print_message "外部連接資訊："
export NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}" 2>/dev/null || echo "無法獲取節點 IP")
if [ "$NODE_IP" != "無法獲取節點 IP" ]; then
    echo "  APIPark 管理介面: http://$NODE_IP:31288"
    echo "  MySQL 資料庫: $NODE_IP:31306"
    echo "  Grafana 監控: http://$NODE_IP:30000"
else
    echo "  請手動檢查服務狀態以獲取連接資訊"
fi

print_header "修復完成！"
print_message "使用以下命令監控狀態："
echo "  kubectl get pods -l app.kubernetes.io/name=apipark"
echo "  kubectl logs -l component=<component-name>"
echo "  kubectl describe pod <pod-name>"
