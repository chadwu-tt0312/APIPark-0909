#!/bin/bash

# Apinto Gateway 快速修復腳本

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

print_message "開始修復 Apinto Gateway..."

# 1. 檢查當前狀態
print_message "檢查當前 Apinto Pod 狀態..."
kubectl get pods -l component=apinto

# 2. 刪除有問題的 Pod
print_message "刪除有問題的 Apinto Pod..."
kubectl delete pod -l component=apinto

# 3. 等待 Pod 重新創建
print_message "等待 Pod 重新創建..."
sleep 10

# 4. 檢查新 Pod 狀態
print_message "檢查新 Pod 狀態..."
kubectl get pods -l component=apinto

# 5. 檢查 Pod 日誌
print_message "檢查 Apinto Pod 日誌..."
kubectl logs -l component=apinto --tail=20

# 6. 檢查配置
print_message "檢查 Apinto 配置..."
kubectl get configmap apipark-shared-config -o yaml

# 7. 測試連接
print_message "測試 Apinto 連接..."
sleep 30  # 等待服務完全啟動

# 檢查端口監聽
print_message "檢查端口監聽狀態..."
kubectl exec -l component=apinto -- netstat -tlnp 2>/dev/null || echo "無法檢查端口狀態"

# 8. 顯示修復結果
print_message "修復完成！"
print_message "使用以下命令檢查狀態："
echo "  kubectl get pods -l component=apinto"
echo "  kubectl logs -l component=apinto"
echo "  kubectl describe pod -l component=apinto"
