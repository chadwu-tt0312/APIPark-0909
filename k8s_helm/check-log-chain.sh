#!/bin/bash

# APIPark 日誌收集鏈路檢查腳本
# 用於診斷 API 通訊紀錄問題

echo "🔍 APIPark 日誌收集鏈路檢查開始..."
echo "================================================"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 檢查函數
check_service() {
    local service_name=$1
    local namespace=${2:-default}
    
    echo -e "\n${BLUE}檢查服務: $service_name${NC}"
    echo "----------------------------------------"
    
    # 檢查 Pod 狀態
    local pod_status=$(kubectl get pods -n $namespace -l app.kubernetes.io/name=$service_name --no-headers 2>/dev/null | awk '{print $3}')
    
    if [ -z "$pod_status" ]; then
        echo -e "${RED}❌ 服務 $service_name 未找到${NC}"
        return 1
    elif [ "$pod_status" = "Running" ]; then
        echo -e "${GREEN}✅ Pod 狀態: $pod_status${NC}"
    else
        echo -e "${YELLOW}⚠️  Pod 狀態: $pod_status${NC}"
    fi
    
    # 檢查服務狀態
    local svc_status=$(kubectl get svc -n $namespace -l app.kubernetes.io/name=$service_name --no-headers 2>/dev/null | wc -l)
    if [ "$svc_status" -gt 0 ]; then
        echo -e "${GREEN}✅ 服務已建立${NC}"
    else
        echo -e "${RED}❌ 服務未建立${NC}"
    fi
    
    # 檢查最近日誌
    echo -e "\n${BLUE}最近日誌 (最後 5 行):${NC}"
    kubectl logs -n $namespace -l app.kubernetes.io/name=$service_name --tail=5 2>/dev/null || echo "無法取得日誌"
    
    return 0
}

# 檢查連線性
check_connectivity() {
    local from_service=$1
    local to_service=$2
    local port=$3
    local namespace=${4:-default}
    
    echo -e "\n${BLUE}檢查連線: $from_service → $to_service:$port${NC}"
    echo "----------------------------------------"
    
    # 取得來源 Pod
    local from_pod=$(kubectl get pods -n $namespace -l app.kubernetes.io/name=$from_service --no-headers 2>/dev/null | head -1 | awk '{print $1}')
    
    if [ -z "$from_pod" ]; then
        echo -e "${RED}❌ 找不到來源 Pod: $from_service${NC}"
        return 1
    fi
    
    # 測試連線
    echo "從 Pod $from_pod 測試連線到 $to_service:$port"
    local test_result=$(kubectl exec -n $namespace $from_pod -- nc -z $to_service $port 2>&1)
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 連線成功${NC}"
    else
        echo -e "${RED}❌ 連線失敗: $test_result${NC}"
    fi
}

# 檢查儲存空間
check_storage() {
    echo -e "\n${BLUE}檢查儲存空間${NC}"
    echo "----------------------------------------"
    
    # 檢查 PVC 狀態
    echo "PVC 狀態:"
    kubectl get pvc | grep -E "(loki|apinto|log)"
    
    # 檢查儲存使用量
    echo -e "\n儲存使用量:"
    kubectl exec -n default $(kubectl get pods -l app.kubernetes.io/name=loki --no-headers | head -1 | awk '{print $1}') -- df -h /var/log 2>/dev/null || echo "無法檢查 Loki 儲存"
    kubectl exec -n default $(kubectl get pods -l app.kubernetes.io/name=apinto --no-headers | head -1 | awk '{print $1}') -- df -h /var/log/apinto 2>/dev/null || echo "無法檢查 Apinto 儲存"
}

# 檢查日誌配置
check_log_config() {
    echo -e "\n${BLUE}檢查日誌配置${NC}"
    echo "----------------------------------------"
    
    # 檢查 Apinto 日誌配置
    echo "Apinto 日誌配置:"
    kubectl exec -n default $(kubectl get pods -l app.kubernetes.io/name=apinto --no-headers | head -1 | awk '{print $1}') -- cat /etc/apinto/log.yaml 2>/dev/null || echo "無法讀取 Apinto 日誌配置"
    
    # 檢查 Loki 配置
    echo -e "\nLoki 配置:"
    kubectl exec -n default $(kubectl get pods -l app.kubernetes.io/name=loki --no-headers | head -1 | awk '{print $1}') -- cat /etc/loki/local-config.yaml 2>/dev/null || echo "無法讀取 Loki 配置"
}

# 檢查日誌流程
check_log_flow() {
    echo -e "\n${BLUE}檢查日誌流程${NC}"
    echo "----------------------------------------"
    
    # 檢查 NSQ 主題
    echo "NSQ 主題狀態:"
    kubectl exec -n default $(kubectl get pods -l app.kubernetes.io/name=nsq --no-headers | head -1 | awk '{print $1}') -- nsq_tail --topic=apipark_ai_event --channel=test 2>/dev/null &
    local nsq_pid=$!
    sleep 3
    kill $nsq_pid 2>/dev/null
    
    # 檢查 Loki 查詢
    echo -e "\nLoki 查詢測試:"
    local loki_pod=$(kubectl get pods -l app.kubernetes.io/name=loki --no-headers | head -1 | awk '{print $1}')
    if [ ! -z "$loki_pod" ]; then
        kubectl exec -n default $loki_pod -- curl -s "http://localhost:3100/loki/api/v1/query?query={job=\"apinto\"}" 2>/dev/null | head -c 200
        echo ""
    fi
}

# 主檢查流程
main() {
    echo -e "${BLUE}開始檢查 APIPark 日誌收集鏈路...${NC}"
    
    # 1. 檢查核心服務狀態
    echo -e "\n${YELLOW}=== 1. 檢查核心服務狀態 ===${NC}"
    check_service "loki"
    check_service "nsq" 
    check_service "apinto"
    check_service "influxdb"
    
    # 2. 檢查服務間連線
    echo -e "\n${YELLOW}=== 2. 檢查服務間連線 ===${NC}"
    check_connectivity "apinto" "loki" "3100"
    check_connectivity "apinto" "nsq" "4150"
    check_connectivity "apipark" "loki" "3100"
    check_connectivity "apipark" "nsq" "4150"
    
    # 3. 檢查儲存空間
    echo -e "\n${YELLOW}=== 3. 檢查儲存空間 ===${NC}"
    check_storage
    
    # 4. 檢查日誌配置
    echo -e "\n${YELLOW}=== 4. 檢查日誌配置 ===${NC}"
    check_log_config
    
    # 5. 檢查日誌流程
    echo -e "\n${YELLOW}=== 5. 檢查日誌流程 ===${NC}"
    check_log_flow
    
    # 6. 提供診斷建議
    echo -e "\n${YELLOW}=== 6. 診斷建議 ===${NC}"
    echo "如果發現問題，請檢查以下項目："
    echo "1. 確保所有服務 Pod 狀態為 Running"
    echo "2. 檢查服務間網路連線是否正常"
    echo "3. 確認儲存空間充足"
    echo "4. 驗證日誌配置正確"
    echo "5. 檢查日誌驅動程式是否正確載入"
    
    echo -e "\n${GREEN}日誌收集鏈路檢查完成！${NC}"
}

# 執行主函數
main
