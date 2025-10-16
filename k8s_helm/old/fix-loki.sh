#!/bin/bash

# Loki 快速修復腳本

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

print_message "開始修復 Loki..."

# 1. 檢查當前狀態
print_message "檢查當前 Loki Pod 狀態..."
kubectl get pods -l component=loki

# 2. 檢查 Loki 日誌
print_message "檢查 Loki Pod 日誌..."
kubectl logs -l component=loki --tail=20

# 3. 檢查配置
print_message "檢查 Loki 配置..."
kubectl get configmap apipark-config -o yaml | grep -A 50 "loki-config.yaml"

# 4. 刪除有問題的 Pod
print_message "刪除有問題的 Loki Pod..."
kubectl delete pod -l component=loki

# 5. 等待 Pod 重新創建
print_message "等待 Pod 重新創建..."
sleep 10

# 6. 檢查新 Pod 狀態
print_message "檢查新 Pod 狀態..."
kubectl get pods -l component=loki

# 7. 檢查新 Pod 日誌
print_message "檢查新 Pod 日誌..."
sleep 10
kubectl logs -l component=loki --tail=20

# 8. 檢查端口監聽
print_message "檢查端口監聽狀態..."
kubectl exec -l component=loki -- netstat -tlnp 2>/dev/null || echo "無法檢查端口狀態"

# 9. 測試連接
print_message "測試 Loki 連接..."
kubectl exec -l component=loki -- curl -s http://localhost:3100/ready 2>/dev/null || echo "Loki 尚未準備就緒"

# 10. 顯示修復結果
print_message "修復完成！"
print_message "使用以下命令檢查狀態："
echo "  kubectl get pods -l component=loki"
echo "  kubectl logs -l component=loki"
echo "  kubectl describe pod -l component=loki"
