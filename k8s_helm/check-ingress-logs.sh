#!/bin/bash

# APIPark Ingress-Nginx 日誌檢查腳本
# 專門診斷通過 Ingress 的 API 通訊紀錄問題

echo "🔍 APIPark Ingress-Nginx 日誌檢查開始..."
echo "================================================"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 檢查 Ingress Controller 狀態
check_ingress_controller() {
    echo -e "\n${BLUE}檢查 Ingress Controller 狀態${NC}"
    echo "----------------------------------------"
    
    # 檢查 Ingress Controller Pod
    local ingress_pods=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --no-headers 2>/dev/null)
    
    if [ -z "$ingress_pods" ]; then
        echo -e "${RED}❌ Ingress Controller 未安裝或未運行${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Ingress Controller Pod 狀態:${NC}"
    echo "$ingress_pods"
    
    # 檢查 Ingress Controller 日誌
    echo -e "\n${BLUE}Ingress Controller 最近日誌:${NC}"
    kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --tail=10
    
    return 0
}

# 檢查 Ingress 資源配置
check_ingress_config() {
    echo -e "\n${BLUE}檢查 Ingress 資源配置${NC}"
    echo "----------------------------------------"
    
    # 檢查 APIPark Ingress 資源
    local ingress_config=$(kubectl get ingress apipark-ingress -o yaml 2>/dev/null)
    
    if [ -z "$ingress_config" ]; then
        echo -e "${RED}❌ APIPark Ingress 資源不存在${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ APIPark Ingress 資源存在${NC}"
    echo "Ingress 配置:"
    echo "$ingress_config" | head -20
    
    # 檢查 Ingress 狀態
    echo -e "\n${BLUE}Ingress 狀態:${NC}"
    kubectl describe ingress apipark-ingress
    
    return 0
}

# 檢查 Ingress 日誌配置
check_ingress_log_config() {
    echo -e "\n${BLUE}檢查 Ingress 日誌配置${NC}"
    echo "----------------------------------------"
    
    # 檢查 Ingress Controller ConfigMap
    local configmap=$(kubectl get configmap -n ingress-nginx ingress-nginx-controller -o yaml 2>/dev/null)
    
    if [ -z "$configmap" ]; then
        echo -e "${RED}❌ Ingress Controller ConfigMap 不存在${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Ingress Controller ConfigMap 存在${NC}"
    
    # 檢查日誌相關配置
    echo -e "\n${BLUE}日誌相關配置:${NC}"
    echo "$configmap" | grep -E "(access-log|error-log|log-format)" || echo "未找到日誌配置"
    
    # 檢查是否有自訂日誌格式
    local log_format=$(echo "$configmap" | grep "log-format" | cut -d: -f2- | tr -d ' ')
    if [ ! -z "$log_format" ]; then
        echo -e "${GREEN}✅ 找到自訂日誌格式: $log_format${NC}"
    else
        echo -e "${YELLOW}⚠️  使用預設日誌格式${NC}"
    fi
    
    return 0
}

# 檢查 Ingress 存取日誌
check_ingress_access_logs() {
    echo -e "\n${BLUE}檢查 Ingress 存取日誌${NC}"
    echo "----------------------------------------"
    
    # 取得 Ingress Controller Pod
    local ingress_pod=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --no-headers | head -1 | awk '{print $1}')
    
    if [ -z "$ingress_pod" ]; then
        echo -e "${RED}❌ 找不到 Ingress Controller Pod${NC}"
        return 1
    fi
    
    echo "使用 Pod: $ingress_pod"
    
    # 檢查日誌目錄
    echo -e "\n${BLUE}檢查日誌目錄:${NC}"
    kubectl exec -n ingress-nginx $ingress_pod -- ls -la /var/log/nginx/ 2>/dev/null || echo "無法存取日誌目錄"
    
    # 檢查存取日誌檔案
    echo -e "\n${BLUE}檢查存取日誌檔案:${NC}"
    kubectl exec -n ingress-nginx $ingress_pod -- find /var/log -name "*access*" -type f 2>/dev/null || echo "未找到存取日誌檔案"
    
    # 檢查最近的存取日誌
    echo -e "\n${BLUE}最近的存取日誌 (最後 10 行):${NC}"
    kubectl exec -n ingress-nginx $ingress_pod -- tail -10 /var/log/nginx/access.log 2>/dev/null || echo "無法讀取存取日誌"
    
    return 0
}

# 測試 API 請求並檢查日誌
test_api_and_logs() {
    echo -e "\n${BLUE}測試 API 請求並檢查日誌${NC}"
    echo "----------------------------------------"
    
    # 取得 Ingress IP
    local ingress_ip=$(kubectl get ingress apipark-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    if [ -z "$ingress_ip" ]; then
        ingress_ip=$(kubectl get ingress apipark-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    fi
    
    if [ -z "$ingress_ip" ]; then
        echo -e "${YELLOW}⚠️  無法取得 Ingress IP，使用 NodePort 測試${NC}"
        # 使用 NodePort 測試
        local nodeport=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.spec.ports[?(@.port==80)].nodePort}' 2>/dev/null)
        if [ ! -z "$nodeport" ]; then
            echo "使用 NodePort: $nodeport"
            echo "測試請求: curl -H 'Host: apipark.local' http://localhost:$nodeport/"
            curl -H 'Host: apipark.local' http://localhost:$nodeport/ -s -o /dev/null -w "HTTP Status: %{http_code}\n"
        fi
    else
        echo "使用 Ingress IP: $ingress_ip"
        echo "測試請求: curl -H 'Host: apipark.local' http://$ingress_ip/"
        curl -H 'Host: apipark.local' http://$ingress_ip/ -s -o /dev/null -w "HTTP Status: %{http_code}\n"
    fi
    
    # 等待一下讓日誌寫入
    sleep 2
    
    # 檢查 Ingress 日誌
    echo -e "\n${BLUE}檢查測試後的 Ingress 日誌:${NC}"
    local ingress_pod=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --no-headers | head -1 | awk '{print $1}')
    kubectl exec -n ingress-nginx $ingress_pod -- tail -5 /var/log/nginx/access.log 2>/dev/null || echo "無法讀取存取日誌"
    
    # 檢查 Apinto Gateway 日誌
    echo -e "\n${BLUE}檢查測試後的 Apinto Gateway 日誌:${NC}"
    kubectl logs -l app.kubernetes.io/name=apinto --tail=5 --since=1m
    
    return 0
}

# 檢查日誌收集整合
check_log_integration() {
    echo -e "\n${BLUE}檢查日誌收集整合${NC}"
    echo "----------------------------------------"
    
    # 檢查是否有日誌收集器 (如 Fluentd, Filebeat)
    echo "檢查日誌收集器:"
    kubectl get pods -A | grep -E "(fluentd|filebeat|logstash)" || echo "未找到日誌收集器"
    
    # 檢查 Loki 中的 Ingress 日誌
    echo -e "\n${BLUE}檢查 Loki 中的日誌:${NC}"
    local loki_pod=$(kubectl get pods -l app.kubernetes.io/name=loki --no-headers | head -1 | awk '{print $1}')
    if [ ! -z "$loki_pod" ]; then
        echo "查詢 Loki 中的 nginx 日誌:"
        kubectl exec -n default $loki_pod -- curl -s "http://localhost:3100/loki/api/v1/query?query={job=\"nginx\"}" 2>/dev/null | head -c 300
        echo ""
        
        echo "查詢 Loki 中的 apinto 日誌:"
        kubectl exec -n default $loki_pod -- curl -s "http://localhost:3100/loki/api/v1/query?query={job=\"apinto\"}" 2>/dev/null | head -c 300
        echo ""
    fi
    
    return 0
}

# 提供修復建議
provide_fix_suggestions() {
    echo -e "\n${YELLOW}=== 修復建議 ===${NC}"
    echo "如果發現 Ingress 日誌未整合到 APIPark 系統，請考慮以下解決方案："
    echo ""
    echo "1. 啟用 Ingress-Nginx 存取日誌:"
    echo "   kubectl patch configmap -n ingress-nginx ingress-nginx-controller --patch '{\"data\":{\"access-log\":\"true\"}}'"
    echo ""
    echo "2. 配置自訂日誌格式:"
    echo "   kubectl patch configmap -n ingress-nginx ingress-nginx-controller --patch '{\"data\":{\"log-format\":\"\\$remote_addr - \\$remote_user [\\$time_local] \\\"\\$request\\\" \\$status \\$body_bytes_sent \\\"\\$http_referer\\\" \\\"\\$http_user_agent\\\" \\$request_time\"}}'"
    echo ""
    echo "3. 安裝日誌收集器 (Fluentd):"
    echo "   kubectl apply -f https://raw.githubusercontent.com/fluent/fluentd-kubernetes-daemonset/master/fluentd-daemonset.yaml"
    echo ""
    echo "4. 配置日誌轉發到 Loki:"
    echo "   建立 Fluentd 配置將 Ingress 日誌轉發到 Loki"
    echo ""
    echo "5. 修改 APIPark Ingress 配置:"
    echo "   在 values.yaml 中新增日誌相關的 annotations"
}

# 主檢查流程
main() {
    echo -e "${BLUE}開始檢查 APIPark Ingress-Nginx 日誌...${NC}"
    
    # 1. 檢查 Ingress Controller
    check_ingress_controller
    
    # 2. 檢查 Ingress 配置
    check_ingress_config
    
    # 3. 檢查日誌配置
    check_ingress_log_config
    
    # 4. 檢查存取日誌
    check_ingress_access_logs
    
    # 5. 測試 API 請求
    test_api_and_logs
    
    # 6. 檢查日誌整合
    check_log_integration
    
    # 7. 提供修復建議
    provide_fix_suggestions
    
    echo -e "\n${GREEN}Ingress-Nginx 日誌檢查完成！${NC}"
}

# 執行主函數
main
