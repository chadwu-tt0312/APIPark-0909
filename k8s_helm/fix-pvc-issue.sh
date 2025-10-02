#!/bin/bash

# APIPark PVC 問題修復腳本

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

print_header "APIPark PVC 問題診斷與修復"

# 1. 檢查 StorageClass
print_message "1. 檢查可用的 StorageClass..."
kubectl get storageclass

echo ""
print_message "2. 檢查 PVC 狀態..."
kubectl get pvc

echo ""
print_message "3. 檢查 PV 狀態..."
kubectl get pv

echo ""
print_message "4. 檢查 Pod 狀態..."
kubectl get pods -l app.kubernetes.io/name=apipark

echo ""
print_message "5. 檢查 Pod 事件..."
kubectl get events --sort-by=.metadata.creationTimestamp | grep -i "persistentvolumeclaim\|failed"

print_header "修復建議"

echo "1. 如果沒有 StorageClass，請選擇以下方案之一："
echo "   a) 使用預設 StorageClass（已修改 values.yaml）"
echo "   b) 創建 NFS StorageClass："
echo "      kubectl apply -f nfs-storageclass.yaml"
echo ""

echo "2. 重新部署 APIPark："
echo "   helm upgrade apipark ./apipark"
echo ""

echo "3. 如果問題持續，檢查節點存儲："
echo "   kubectl describe nodes"
echo ""

echo "4. 手動創建 PVC（緊急修復）："
echo "   kubectl apply -f - <<EOF"
echo "   apiVersion: v1"
echo "   kind: PersistentVolumeClaim"
echo "   metadata:"
echo "     name: apipark-apinto-data-pvc"
echo "   spec:"
echo "     accessModes: [ReadWriteOnce]"
echo "     resources:"
echo "       requests:"
echo "         storage: 5Gi"
echo "   EOF"

print_header "診斷完成"
