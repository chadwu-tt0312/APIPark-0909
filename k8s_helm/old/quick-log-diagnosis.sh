#!/bin/bash

# APIPark 快速日誌診斷腳本
# 快速檢查常見的日誌收集問題

echo "🚀 APIPark 快速日誌診斷"
echo "========================"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 快速檢查函數
quick_check() {
    local service=$1
    local check_type=$2
    
    case $check_type in
        "pod")
            local status=$(kubectl get pods -l app.kubernetes.io/name=$service --no-headers 2>/dev/null | awk '{print $3}' | head -1)
            if [ "$status" = "Running" ]; then
                echo -e "${GREEN}✅ $service Pod: Running${NC}"
                return 0
            else
                echo -e "${RED}❌ $service Pod: $status${NC}"
                return 1
            fi
            ;;
        "svc")
            local count=$(kubectl get svc -l app.kubernetes.io/name=$service --no-headers 2>/dev/null | wc -l)
            if [ "$count" -gt 0 ]; then
                echo -e "${GREEN}✅ $service Service: 已建立${NC}"
                return 0
            else
                echo -e "${RED}❌ $service Service: 未建立${NC}"
                return 1
            fi
            ;;
        "connect")
            local from=$1
            local to=$2
            local port=$3
            local from_pod=$(kubectl get pods -l app.kubernetes.io/name=$from --no-headers | head -1 | awk '{print $1}')
            if [ ! -z "$from_pod" ]; then
                kubectl exec -n default $from_pod -- nc -z $to $port 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ $from → $to:$port: 連線正常${NC}"
                    return 0
                else
                    echo -e "${RED}❌ $from → $to:$port: 連線失敗${NC}"
                    return 1
                fi
            else
                echo -e "${RED}❌ 找不到 $from Pod${NC}"
                return 1
            fi
            ;;
    esac
}

# 檢查日誌檔案
check_log_files() {
    local service=$1
    local log_path=$2
    
    echo -e "\n${BLUE}檢查 $service 日誌檔案:${NC}"
    local pod=$(kubectl get pods -l app.kubernetes.io/name=$service --no-headers | head -1 | awk '{print $1}')
    
    if [ ! -z "$pod" ]; then
        local log_exists=$(kubectl exec -n default $pod -- test -f $log_path 2>/dev/null && echo "yes" || echo "no")
        if [ "$log_exists" = "yes" ]; then
            echo -e "${GREEN}✅ 日誌檔案存在: $log_path${NC}"
            local log_size=$(kubectl exec -n default $pod -- stat -c%s $log_path 2>/dev/null || echo "0")
            echo "   檔案大小: $log_size bytes"
            
            # 檢查最近日誌
            echo "   最近 3 行日誌:"
            kubectl exec -n default $pod -- tail -3 $log_path 2>/dev/null | sed 's/^/   /'
        else
            echo -e "${RED}❌ 日誌檔案不存在: $log_path${NC}"
        fi
    else
        echo -e "${RED}❌ 找不到 $service Pod${NC}"
    fi
}

# 檢查儲存空間
check_storage() {
    echo -e "\n${BLUE}檢查儲存空間:${NC}"
    
    # 檢查 PVC
    local pvc_count=$(kubectl get pvc | grep -E "(loki|apinto|log)" | wc -l)
    echo "相關 PVC 數量: $pvc_count"
    
    # 檢查儲存使用量
    local loki_pod=$(kubectl get pods -l app.kubernetes.io/name=loki --no-headers | head -1 | awk '{print $1}')
    if [ ! -z "$loki_pod" ]; then
        local disk_usage=$(kubectl exec -n default $loki_pod -- df -h /var/log 2>/dev/null | tail -1 | awk '{print $5}' | sed 's/%//')
        if [ ! -z "$disk_usage" ]; then
            if [ "$disk_usage" -lt 80 ]; then
                echo -e "${GREEN}✅ Loki 儲存使用率: ${disk_usage}%${NC}"
            else
                echo -e "${YELLOW}⚠️  Loki 儲存使用率: ${disk_usage}% (建議清理)${NC}"
            fi
        fi
    fi
}

# 檢查日誌配置
check_log_config() {
    echo -e "\n${BLUE}檢查日誌配置:${NC}"
    
    # 檢查 Apinto 日誌配置
    local apinto_pod=$(kubectl get pods -l app.kubernetes.io/name=apinto --no-headers | head -1 | awk '{print $1}')
    if [ ! -z "$apinto_pod" ]; then
        local log_config=$(kubectl exec -n default $apinto_pod -- cat /etc/apinto/log.yaml 2>/dev/null)
        if [ ! -z "$log_config" ]; then
            echo -e "${GREEN}✅ Apinto 日誌配置存在${NC}"
            echo "   配置內容:"
            echo "$log_config" | head -5 | sed 's/^/   /'
        else
            echo -e "${RED}❌ Apinto 日誌配置不存在或無法讀取${NC}"
        fi
    fi
}

# 測試日誌流程
test_log_flow() {
    echo -e "\n${BLUE}測試日誌流程:${NC}"
    
    # 發送測試請求
    echo "發送測試 API 請求..."
    curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://apipark.local/ || echo "無法連接到 APIPark"
    
    # 等待日誌寫入
    sleep 3
    
    # 檢查 Apinto 日誌
    echo "檢查 Apinto 日誌更新:"
    kubectl logs -l app.kubernetes.io/name=apinto --tail=3 --since=30s
    
    # 檢查 Loki 中的日誌
    echo "檢查 Loki 中的日誌:"
    local loki_pod=$(kubectl get pods -l app.kubernetes.io/name=loki --no-headers | head -1 | awk '{print $1}')
    if [ ! -z "$loki_pod" ]; then
        local recent_logs=$(kubectl exec -n default $loki_pod -- curl -s "http://localhost:3100/loki/api/v1/query?query={job=\"apinto\"}&limit=1" 2>/dev/null)
        if [ ! -z "$recent_logs" ] && [ "$recent_logs" != "null" ]; then
            echo -e "${GREEN}✅ Loki 中有 Apinto 日誌${NC}"
        else
            echo -e "${RED}❌ Loki 中沒有 Apinto 日誌${NC}"
        fi
    fi
}

# 主診斷流程
main() {
    echo -e "${BLUE}開始快速診斷...${NC}"
    
    # 1. 檢查核心服務狀態
    echo -e "\n${YELLOW}=== 1. 核心服務狀態 ===${NC}"
    quick_check "loki" "pod"
    quick_check "nsq" "pod"
    quick_check "apinto" "pod"
    quick_check "influxdb" "pod"
    
    # 2. 檢查服務連線
    echo -e "\n${YELLOW}=== 2. 服務連線 ===${NC}"
    quick_check "apinto" "connect" "loki" "3100"
    quick_check "apinto" "connect" "nsq" "4150"
    
    # 3. 檢查日誌檔案
    echo -e "\n${YELLOW}=== 3. 日誌檔案 ===${NC}"
    check_log_files "apinto" "/var/log/apinto/access.log"
    check_log_files "loki" "/var/log/loki.log"
    
    # 4. 檢查儲存空間
    echo -e "\n${YELLOW}=== 4. 儲存空間 ===${NC}"
    check_storage
    
    # 5. 檢查日誌配置
    echo -e "\n${YELLOW}=== 5. 日誌配置 ===${NC}"
    check_log_config
    
    # 6. 測試日誌流程
    echo -e "\n${YELLOW}=== 6. 日誌流程測試 ===${NC}"
    test_log_flow
    
    # 7. 總結
    echo -e "\n${YELLOW}=== 診斷總結 ===${NC}"
    echo "如果發現問題，請執行以下詳細檢查："
    echo "1. 完整檢查: ./check-log-chain.sh"
    echo "2. Ingress 檢查: ./check-ingress-logs.sh"
    echo "3. 查看詳細日誌: kubectl logs -l app.kubernetes.io/name=apinto --tail=50"
    
    echo -e "\n${GREEN}快速診斷完成！${NC}"
}

# 執行主函數
main
