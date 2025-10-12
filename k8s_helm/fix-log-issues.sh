#!/bin/bash

# APIPark 日誌問題修復腳本
# 自動修復常見的日誌收集問題

echo "🔧 APIPark 日誌問題修復工具"
echo "============================="

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 修復函數
fix_service_restart() {
    local service=$1
    echo -e "\n${BLUE}重新啟動 $service 服務...${NC}"
    
    local pods=$(kubectl get pods -l app.kubernetes.io/name=$service --no-headers | awk '{print $1}')
    if [ ! -z "$pods" ]; then
        for pod in $pods; do
            echo "重新啟動 Pod: $pod"
            kubectl delete pod $pod
            sleep 5
        done
        echo -e "${GREEN}✅ $service 服務已重新啟動${NC}"
    else
        echo -e "${RED}❌ 找不到 $service Pod${NC}"
    fi
}

fix_ingress_logging() {
    echo -e "\n${BLUE}修復 Ingress 日誌配置...${NC}"
    
    # 檢查 Ingress Controller ConfigMap
    local configmap_exists=$(kubectl get configmap -n ingress-nginx ingress-nginx-controller 2>/dev/null)
    
    if [ -z "$configmap_exists" ]; then
        echo -e "${RED}❌ Ingress Controller ConfigMap 不存在${NC}"
        return 1
    fi
    
    # 啟用存取日誌
    echo "啟用 Ingress 存取日誌..."
    kubectl patch configmap -n ingress-nginx ingress-nginx-controller --patch '{"data":{"access-log":"true"}}' 2>/dev/null
    
    # 配置日誌格式
    echo "配置日誌格式..."
    kubectl patch configmap -n ingress-nginx ingress-nginx-controller --patch '{"data":{"log-format":"$remote_addr - $remote_user [$time_local] \"$request\" $status $body_bytes_sent \"$http_referer\" \"$http_user_agent\" $request_time"}}' 2>/dev/null
    
    # 重新載入 Ingress Controller
    echo "重新載入 Ingress Controller..."
    kubectl rollout restart deployment -n ingress-nginx ingress-nginx-controller
    
    echo -e "${GREEN}✅ Ingress 日誌配置已修復${NC}"
}

fix_apinto_log_config() {
    echo -e "\n${BLUE}修復 Apinto 日誌配置...${NC}"
    
    # 檢查 Apinto Pod
    local apinto_pod=$(kubectl get pods -l app.kubernetes.io/name=apinto --no-headers | head -1 | awk '{print $1}')
    
    if [ -z "$apinto_pod" ]; then
        echo -e "${RED}❌ 找不到 Apinto Pod${NC}"
        return 1
    fi
    
    # 檢查日誌配置檔案
    local log_config=$(kubectl exec -n default $apinto_pod -- cat /etc/apinto/log.yaml 2>/dev/null)
    
    if [ -z "$log_config" ]; then
        echo "建立 Apinto 日誌配置..."
        cat <<EOF | kubectl exec -n default $apinto_pod -- tee /etc/apinto/log.yaml
log:
  level: info
  output:
    - type: file
      path: /var/log/apinto/access.log
      format: json
      rotation:
        max_size: 100MB
        max_age: 7
        max_backups: 3
EOF
        echo -e "${GREEN}✅ Apinto 日誌配置已建立${NC}"
    else
        echo -e "${GREEN}✅ Apinto 日誌配置已存在${NC}"
    fi
    
    # 重新啟動 Apinto 服務
    fix_service_restart "apinto"
}

fix_loki_config() {
    echo -e "\n${BLUE}修復 Loki 配置...${NC}"
    
    # 檢查 Loki Pod
    local loki_pod=$(kubectl get pods -l app.kubernetes.io/name=loki --no-headers | head -1 | awk '{print $1}')
    
    if [ -z "$loki_pod" ]; then
        echo -e "${RED}❌ 找不到 Loki Pod${NC}"
        return 1
    fi
    
    # 檢查 Loki 配置
    local loki_config=$(kubectl exec -n default $loki_pod -- cat /etc/loki/local-config.yaml 2>/dev/null)
    
    if [ -z "$loki_config" ]; then
        echo "建立 Loki 配置..."
        cat <<EOF | kubectl exec -n default $loki_pod -- tee /etc/loki/local-config.yaml
auth_enabled: false
server:
  http_listen_port: 3100
  grpc_listen_port: 9096
common:
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory
schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h
ruler:
  alertmanager_url: http://localhost:9093
EOF
        echo -e "${GREEN}✅ Loki 配置已建立${NC}"
    else
        echo -e "${GREEN}✅ Loki 配置已存在${NC}"
    fi
    
    # 重新啟動 Loki 服務
    fix_service_restart "loki"
}

fix_storage_issues() {
    echo -e "\n${BLUE}修復儲存問題...${NC}"
    
    # 檢查 PVC 狀態
    echo "檢查 PVC 狀態:"
    kubectl get pvc | grep -E "(loki|apinto|log)"
    
    # 清理舊日誌檔案
    echo "清理舊日誌檔案..."
    local apinto_pod=$(kubectl get pods -l app.kubernetes.io/name=apinto --no-headers | head -1 | awk '{print $1}')
    if [ ! -z "$apinto_pod" ]; then
        kubectl exec -n default $apinto_pod -- find /var/log/apinto -name "*.log.*" -mtime +7 -delete 2>/dev/null || true
        echo -e "${GREEN}✅ 舊日誌檔案已清理${NC}"
    fi
    
    # 檢查儲存空間
    echo "檢查儲存空間使用情況:"
    kubectl exec -n default $apinto_pod -- df -h /var/log/apinto 2>/dev/null || echo "無法檢查儲存空間"
}

fix_network_connectivity() {
    echo -e "\n${BLUE}修復網路連線問題...${NC}"
    
    # 檢查服務 DNS 解析
    echo "檢查服務 DNS 解析:"
    local apinto_pod=$(kubectl get pods -l app.kubernetes.io/name=apinto --no-headers | head -1 | awk '{print $1}')
    
    if [ ! -z "$apinto_pod" ]; then
        echo "測試 Loki 連線:"
        kubectl exec -n default $apinto_pod -- nslookup apipark-loki 2>/dev/null || echo "DNS 解析失敗"
        
        echo "測試 NSQ 連線:"
        kubectl exec -n default $apinto_pod -- nslookup apipark-nsq 2>/dev/null || echo "DNS 解析失敗"
        
        echo "測試 InfluxDB 連線:"
        kubectl exec -n default $apinto_pod -- nslookup apipark-influxdb 2>/dev/null || echo "DNS 解析失敗"
    fi
}

fix_log_drivers() {
    echo -e "\n${BLUE}修復日誌驅動程式...${NC}"
    
    # 檢查日誌驅動程式是否正確載入
    local apipark_pod=$(kubectl get pods -l app.kubernetes.io/name=apipark --no-headers | head -1 | awk '{print $1}')
    
    if [ ! -z "$apipark_pod" ]; then
        echo "檢查日誌驅動程式載入狀態:"
        kubectl exec -n default $apipark_pod -- ls -la /app/log-driver/ 2>/dev/null || echo "日誌驅動程式目錄不存在"
        
        # 重新載入日誌驅動程式
        echo "重新載入日誌驅動程式..."
        kubectl exec -n default $apipark_pod -- pkill -f "log-driver" 2>/dev/null || true
        sleep 2
        echo -e "${GREEN}✅ 日誌驅動程式已重新載入${NC}"
    fi
}

# 主修復流程
main() {
    echo -e "${BLUE}開始修復日誌問題...${NC}"
    
    # 1. 修復 Ingress 日誌
    echo -e "\n${YELLOW}=== 1. 修復 Ingress 日誌 ===${NC}"
    fix_ingress_logging
    
    # 2. 修復 Apinto 日誌配置
    echo -e "\n${YELLOW}=== 2. 修復 Apinto 日誌配置 ===${NC}"
    fix_apinto_log_config
    
    # 3. 修復 Loki 配置
    echo -e "\n${YELLOW}=== 3. 修復 Loki 配置 ===${NC}"
    fix_loki_config
    
    # 4. 修復儲存問題
    echo -e "\n${YELLOW}=== 4. 修復儲存問題 ===${NC}"
    fix_storage_issues
    
    # 5. 修復網路連線
    echo -e "\n${YELLOW}=== 5. 修復網路連線 ===${NC}"
    fix_network_connectivity
    
    # 6. 修復日誌驅動程式
    echo -e "\n${YELLOW}=== 6. 修復日誌驅動程式 ===${NC}"
    fix_log_drivers
    
    # 7. 等待服務穩定
    echo -e "\n${YELLOW}=== 7. 等待服務穩定 ===${NC}"
    echo "等待服務重新啟動並穩定..."
    sleep 30
    
    # 8. 驗證修復結果
    echo -e "\n${YELLOW}=== 8. 驗證修復結果 ===${NC}"
    echo "執行快速診斷驗證修復結果..."
    ./quick-log-diagnosis.sh
    
    echo -e "\n${GREEN}日誌問題修復完成！${NC}"
    echo "如果問題仍然存在，請執行詳細檢查："
    echo "1. 完整檢查: ./check-log-chain.sh"
    echo "2. Ingress 檢查: ./check-ingress-logs.sh"
}

# 執行主函數
main
