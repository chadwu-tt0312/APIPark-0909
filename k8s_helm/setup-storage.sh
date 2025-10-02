#!/bin/bash

# WSL2 中建立 Kubernetes Storage 的腳本
# 請確保 kubectl 已正確配置並能連接到 Kubernetes 集群

echo "開始建立 Kubernetes Storage 資源..."

# 1. 建立 StorageClass
echo "建立 StorageClass..."
kubectl apply -f ls-storageclass.yaml

# 2. 建立 PersistentVolume
echo "建立 PersistentVolume..."
kubectl apply -f pv-v1.yaml

# 3. 建立 PersistentVolumeClaim
echo "建立 PersistentVolumeClaim..."
kubectl apply -f pvc-v1.yaml

# 4. 檢查資源狀態
echo "檢查 StorageClass 狀態..."
kubectl get storageclass

echo "檢查 PersistentVolume 狀態..."
kubectl get pv

echo "檢查 PersistentVolumeClaim 狀態..."
kubectl get pvc

echo "Storage 資源建立完成！"
