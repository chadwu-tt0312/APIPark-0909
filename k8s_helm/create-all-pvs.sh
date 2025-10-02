#!/bin/bash

# 建立所有 APIPark 需要的 PersistentVolume
echo "開始建立所有 PersistentVolume..."

# 建立各個服務的 PV
echo "建立 MySQL PV..."
kubectl apply -f pv-mysql.yaml

echo "建立 Redis PV..."
kubectl apply -f pv-redis.yaml

echo "建立 InfluxDB PV..."
kubectl apply -f pv-influxdb.yaml

echo "建立 Loki PV..."
kubectl apply -f pv-loki.yaml

echo "建立 Grafana PV..."
kubectl apply -f pv-grafana.yaml

echo "建立 Apinto Data PV..."
kubectl apply -f pv-apinto-data.yaml

echo "建立 Apinto Log PV..."
kubectl apply -f pv-apinto-log.yaml

# 檢查 PV 狀態
echo "檢查所有 PV 狀態..."
kubectl get pv

echo "所有 PersistentVolume 建立完成！"
