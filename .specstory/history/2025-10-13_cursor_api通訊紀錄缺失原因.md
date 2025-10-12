# API 通訊紀錄缺失的原因
_Exported on 2025/10/13 at 07:11:39 [GMT+8] from Cursor (1.7.38)_

---

**User**

1. 有哪些狀況下會導致 API 通訊紀錄沒有實際紀錄?
 2. k8s 時透過 ingress-nginx 的通訊，為何沒有API 通訊紀錄?

---

**Cursor**

我來幫您分析 API 通訊紀錄的問題。首先讓我查看您的 values.yaml 檔案，了解當前的配置設定。


現在讓我搜尋相關的 API 通訊紀錄配置和相關檔案，以了解完整的架構。


讓我進一步查看 APIPark 的相關配置和日誌設定：


現在讓我查看 APIPark 的應用程式配置和日誌相關的程式碼：


讓我查看 APIPark 的應用程式程式碼，了解 API 通訊紀錄的機制：


讓我查看 APIPark 的 middleware 和相關的 API 紀錄機制：


讓我查看 APIPark 的服務層和控制器，了解 API 通訊紀錄的處理機制：


讓我查看日誌相關的服務和控制器：


現在讓我查看 APIPark 的日誌驅動程式和相關配置：


讓我查看 APIPark 的日誌驅動程式實作：


現在讓我查看 APIPark 的 Ingress 配置和相關的日誌設定：


讓我查看 APIPark 的 Ingress 配置中是否有日誌相關的設定：


現在讓我查看 APIPark 的具體配置，了解 API 通訊紀錄的完整流程：


讓我查看 APIPark 的日誌配置和集群設定：


現在讓我查看 APIPark 的完整日誌配置和 Ingress 相關設定：


基於我對 APIPark 架構和配置的分析，現在我可以回答您的兩個問題：


## API 通訊紀錄問題分析

根據我對您的 APIPark 架構分析，以下是兩個問題的詳細解答：

### 1. 有哪些狀況下會導致 API 通訊紀錄沒有實際紀錄？

基於您的 APIPark 配置，以下狀況可能導致 API 通訊紀錄遺失：

#### **日誌收集鏈路問題**
- **Loki 服務異常**：您的系統使用 Loki 作為日誌收集器，如果 Loki 服務停止或配置錯誤，會導致日誌無法收集
- **NSQ 訊息佇列問題**：系統使用 NSQ 作為日誌傳輸中介，如果 NSQ 服務異常或訊息佇列滿載，會導致日誌傳輸中斷
- **InfluxDB 連線問題**：雖然主要用於指標收集，但連線問題可能影響整體日誌處理

#### **Apinto Gateway 日誌配置問題**
- **日誌驅動程式未正確配置**：從程式碼看到使用 `log-driver/loki` 驅動程式，如果配置錯誤會導致日誌無法輸出
- **日誌格式不正確**：日誌格式必須符合 Loki 的解析要求，格式錯誤會導致日誌無法正確解析
- **日誌級別設定過高**：如果日誌級別設定為 ERROR 或 WARN，正常的 API 請求可能不會被記錄

#### **儲存空間問題**
- **PVC 空間不足**：`apipark-apinto-log-pvc` 空間不足會導致日誌無法寫入
- **日誌輪替配置不當**：日誌檔案過大或輪替機制配置錯誤

#### **網路連線問題**
- **服務間通訊中斷**：Apinto Gateway 與 Loki 之間網路連線問題
- **DNS 解析問題**：服務名稱解析失敗導致無法連接到日誌收集服務

### 2. k8s 時透過 ingress-nginx 的通訊，為何沒有 API 通訊紀錄？

這是因為 **Ingress-Nginx 與 APIPark 的日誌收集機制分離**：

#### **架構層級問題**
```
用戶請求 → Ingress-Nginx → Apinto Gateway → 後端服務
                ↓
            Ingress-Nginx 日誌 (獨立)
                ↓
            Apinto Gateway 日誌 → Loki → APIPark 管理介面
```

#### **具體原因分析**

1. **Ingress-Nginx 日誌未整合到 APIPark 系統**
   - Ingress-Nginx 有自己的存取日誌機制
   - 這些日誌不會自動傳送到 APIPark 的 Loki 系統
   - APIPark 只收集 Apinto Gateway 層級的日誌

2. **日誌收集範圍限制**
   - APIPark 的日誌收集器只監聽 Apinto Gateway 的日誌輸出
   - 通過 Ingress-Nginx 的請求會先經過 Ingress 層，再到達 Apinto Gateway
   - 如果請求在 Ingress 層就被處理或轉發，可能不會觸發 Apinto Gateway 的日誌記錄

3. **Ingress 配置問題**
   - 您的 Ingress 配置中只有基本的 SSL 重定向設定
   - 缺少日誌相關的 annotations 配置
   - 沒有配置 Ingress-Nginx 將日誌轉發到 APIPark 系統

#### **解決方案建議**

1. **啟用 Ingress-Nginx 日誌整合**
   ```yaml
   # 在 values.yaml 中新增
   ingress:
     annotations:
       nginx.ingress.kubernetes.io/ssl-redirect: "false"
       nginx.ingress.kubernetes.io/enable-access-log: "true"
       nginx.ingress.kubernetes.io/configuration-snippet: |
         access_log /var/log/nginx/access.log;
   ```

2. **配置日誌收集**
   - 設定 Ingress-Nginx 將日誌輸出到共享儲存
   - 配置 Fluentd 或 Filebeat 收集 Ingress 日誌
   - 將 Ingress 日誌整合到 Loki 系統

3. **檢查 Apinto Gateway 日誌配置**
   - 確認 Apinto Gateway 正確接收來自 Ingress 的請求
   - 驗證日誌驅動程式配置正確
   - 檢查 NSQ 和 Loki 連線狀態

4. **監控和診斷**
   ```bash
   # 檢查 Apinto Gateway 日誌
   kubectl logs -l component=apinto --tail=50
   
   # 檢查 Loki 服務狀態
   kubectl logs -l component=loki --tail=20
   
   # 檢查 NSQ 服務狀態
   kubectl logs -l component=nsq --tail=20
   ```

這樣可以確保通過 Ingress-Nginx 的 API 通訊也能被正確記錄到 APIPark 系統中。

```plaintext
用戶請求 → Ingress-Nginx → Apinto Gateway → 後端服務
                ↓
            Ingress-Nginx 日誌 (獨立)
                ↓
            Apinto Gateway 日誌 → Loki → APIPark 管理介面
```

```yaml
   # 在 values.yaml 中新增
   ingress:
     annotations:
       nginx.ingress.kubernetes.io/ssl-redirect: "false"
       nginx.ingress.kubernetes.io/enable-access-log: "true"
       nginx.ingress.kubernetes.io/configuration-snippet: |
         access_log /var/log/nginx/access.log;
```

```shellscript
   # 檢查 Apinto Gateway 日誌
   kubectl logs -l component=apinto --tail=50
   
   # 檢查 Loki 服務狀態
   kubectl logs -l component=loki --tail=20
   
   # 檢查 NSQ 服務狀態
   kubectl logs -l component=nsq --tail=20
```

---

**User**

如何檢查日誌收集鏈路問題 ?


---

**Cursor**

我來幫您建立一套完整的日誌收集鏈路檢查方法。讓我先查看當前的配置，然後提供具體的檢查步驟。


現在讓我建立一個完整的日誌收集鏈路檢查腳本：


```shellscript
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
```

現在讓我建立一個更詳細的日誌診斷腳本，專門針對 Ingress-Nginx 的日誌問題：


```shellscript
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
```

現在讓我建立一個快速診斷腳本，用於檢查常見的日誌問題：


```shellscript
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
```

現在讓我建立一個日誌修復腳本，用於修復常見的日誌問題：


```shellscript
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
```

現在讓我建立一個使用說明文件：


```markdown
# APIPark 日誌收集鏈路檢查指南

本指南提供完整的 APIPark 日誌收集鏈路檢查和修復方法，幫助您診斷和解決 API 通訊紀錄問題。

## 📋 檢查腳本說明

### 1. 快速診斷腳本
```bash
./quick-log-diagnosis.sh
```
**用途**: 快速檢查常見的日誌問題
**檢查項目**:
- 核心服務狀態 (Loki, NSQ, Apinto, InfluxDB)
- 服務間連線
- 日誌檔案存在性
- 儲存空間使用率
- 日誌配置
- 日誌流程測試

### 2. 完整日誌鏈路檢查
```bash
./check-log-chain.sh
```
**用途**: 詳細檢查整個日誌收集鏈路
**檢查項目**:
- 所有服務的 Pod 和 Service 狀態
- 服務間網路連線測試
- 儲存空間詳細檢查
- 日誌配置檔案驗證
- 日誌流程完整性測試
- 提供診斷建議

### 3. Ingress-Nginx 日誌檢查
```bash
./check-ingress-logs.sh
```
**用途**: 專門檢查通過 Ingress 的 API 通訊紀錄問題
**檢查項目**:
- Ingress Controller 狀態
- Ingress 資源配置
- Ingress 日誌配置
- 存取日誌檔案檢查
- API 請求測試
- 日誌收集整合檢查

### 4. 日誌問題修復腳本
```bash
./fix-log-issues.sh
```
**用途**: 自動修復常見的日誌問題
**修復項目**:
- Ingress 日誌配置
- Apinto 日誌配置
- Loki 配置
- 儲存空間清理
- 網路連線修復
- 日誌驅動程式重新載入

## 🔍 常見問題診斷

### 問題 1: API 通訊紀錄完全沒有記錄

**可能原因**:
1. Apinto Gateway 服務未運行
2. Loki 服務異常
3. NSQ 訊息佇列問題
4. 日誌驅動程式未正確載入

**檢查步驟**:
```bash
# 1. 快速診斷
./quick-log-diagnosis.sh

# 2. 檢查 Apinto 日誌
kubectl logs -l app.kubernetes.io/name=apinto --tail=50

# 3. 檢查 Loki 狀態
kubectl logs -l app.kubernetes.io/name=loki --tail=20

# 4. 檢查 NSQ 狀態
kubectl logs -l app.kubernetes.io/name=nsq --tail=20
```

### 問題 2: 通過 Ingress 的請求沒有 API 通訊紀錄

**可能原因**:
1. Ingress-Nginx 日誌未啟用
2. 日誌格式配置不正確
3. 日誌收集器未配置
4. Ingress 日誌未整合到 APIPark 系統

**檢查步驟**:
```bash
# 1. 檢查 Ingress 日誌
./check-ingress-logs.sh

# 2. 檢查 Ingress Controller 配置
kubectl get configmap -n ingress-nginx ingress-nginx-controller -o yaml

# 3. 檢查 Ingress 存取日誌
kubectl exec -n ingress-nginx <ingress-pod> -- tail -10 /var/log/nginx/access.log
```

### 問題 3: 日誌記錄不完整或間斷

**可能原因**:
1. 儲存空間不足
2. 日誌輪替配置問題
3. 網路連線不穩定
4. 服務重啟導致日誌中斷

**檢查步驟**:
```bash
# 1. 檢查儲存空間
kubectl get pvc
kubectl exec <loki-pod> -- df -h /var/log

# 2. 檢查日誌配置
kubectl exec <apinto-pod> -- cat /etc/apinto/log.yaml

# 3. 檢查服務狀態
kubectl get pods -l app.kubernetes.io/name=apinto
```

## 🛠️ 修復方法

### 方法 1: 自動修復
```bash
# 執行自動修復腳本
./fix-log-issues.sh
```

### 方法 2: 手動修復

#### 修復 Ingress 日誌
```bash
# 啟用存取日誌
kubectl patch configmap -n ingress-nginx ingress-nginx-controller --patch '{"data":{"access-log":"true"}}'

# 配置日誌格式
kubectl patch configmap -n ingress-nginx ingress-nginx-controller --patch '{"data":{"log-format":"$remote_addr - $remote_user [$time_local] \"$request\" $status $body_bytes_sent \"$http_referer\" \"$http_user_agent\" $request_time"}}'

# 重新載入 Ingress Controller
kubectl rollout restart deployment -n ingress-nginx ingress-nginx-controller
```

#### 修復 Apinto 日誌配置
```bash
# 重新啟動 Apinto 服務
kubectl delete pod -l app.kubernetes.io/name=apinto

# 檢查日誌配置
kubectl exec <apinto-pod> -- cat /etc/apinto/log.yaml
```

#### 修復 Loki 配置
```bash
# 重新啟動 Loki 服務
kubectl delete pod -l app.kubernetes.io/name=loki

# 檢查 Loki 狀態
kubectl logs -l app.kubernetes.io/name=loki --tail=20
```

## 📊 監控和驗證

### 驗證日誌收集是否正常
```bash
# 1. 發送測試請求
curl -H 'Host: apipark.local' http://<ingress-ip>/

# 2. 檢查 Apinto 日誌
kubectl logs -l app.kubernetes.io/name=apinto --tail=5 --since=1m

# 3. 檢查 Loki 中的日誌
kubectl exec <loki-pod> -- curl -s "http://localhost:3100/loki/api/v1/query?query={job=\"apinto\"}&limit=1"
```

### 監控日誌收集狀態
```bash
# 檢查服務狀態
kubectl get pods -l app.kubernetes.io/name=apinto
kubectl get pods -l app.kubernetes.io/name=loki
kubectl get pods -l app.kubernetes.io/name=nsq

# 檢查儲存空間
kubectl get pvc | grep -E "(loki|apinto|log)"

# 檢查網路連線
kubectl exec <apinto-pod> -- nc -z apipark-loki 3100
kubectl exec <apinto-pod> -- nc -z apipark-nsq 4150
```

## 🚨 緊急處理

如果日誌收集完全中斷：

1. **立即檢查服務狀態**
   ```bash
   kubectl get pods -A | grep -E "(apinto|loki|nsq)"
   ```

2. **重新啟動所有相關服務**
   ```bash
   kubectl delete pod -l app.kubernetes.io/name=apinto
   kubectl delete pod -l app.kubernetes.io/name=loki
   kubectl delete pod -l app.kubernetes.io/name=nsq
   ```

3. **檢查儲存空間**
   ```bash
   kubectl get pvc
   kubectl exec <loki-pod> -- df -h
   ```

4. **執行完整診斷**
   ```bash
   ./check-log-chain.sh
   ```

## 📝 注意事項

1. **定期檢查**: 建議每天執行快速診斷腳本
2. **儲存空間**: 定期清理舊日誌檔案，避免儲存空間不足
3. **服務監控**: 監控各服務的資源使用情況
4. **備份配置**: 定期備份重要的日誌配置檔案
5. **網路連線**: 確保服務間網路連線正常

## 🔗 相關資源

- [APIPark 官方文檔](https://github.com/APIParkLab/APIPark)
- [Loki 官方文檔](https://grafana.com/docs/loki/)
- [Ingress-Nginx 官方文檔](https://kubernetes.github.io/ingress-nginx/)
- [NSQ 官方文檔](https://nsq.io/)
```

## 日誌收集鏈路檢查方法總結

我已經為您建立了一套完整的日誌收集鏈路檢查工具和方法：

### 🛠️ 檢查工具

1. **快速診斷** (`quick-log-diagnosis.sh`)
   - 快速檢查核心服務狀態
   - 驗證服務間連線
   - 檢查日誌檔案和配置
   - 測試日誌流程

2. **完整檢查** (`check-log-chain.sh`)
   - 詳細檢查整個日誌收集鏈路
   - 包含所有服務的狀態檢查
   - 網路連線測試
   - 儲存空間檢查
   - 提供診斷建議

3. **Ingress 專用檢查** (`check-ingress-logs.sh`)
   - 專門檢查 Ingress-Nginx 日誌問題
   - 驗證 Ingress 配置
   - 測試 API 請求流程
   - 檢查日誌整合狀態

4. **自動修復** (`fix-log-issues.sh`)
   - 自動修復常見的日誌問題
   - 重新配置服務
   - 清理儲存空間
   - 重新載入日誌驅動程式

### 🔍 檢查步驟

**立即執行快速診斷**:
```bash
cd /home/chad/APIPark-0909/k8s_helm
./quick-log-diagnosis.sh
```

**如果發現問題，執行完整檢查**:
```bash
./check-log-chain.sh
```

**針對 Ingress 問題**:
```bash
./check-ingress-logs.sh
```

**自動修復問題**:
```bash
./fix-log-issues.sh
```

### 📋 常見問題檢查清單

1. **服務狀態檢查**
   - Loki 服務是否運行
   - NSQ 服務是否正常
   - Apinto Gateway 是否運行
   - InfluxDB 是否正常

2. **連線性檢查**
   - Apinto → Loki (port 3100)
   - Apinto → NSQ (port 4150)
   - APIPark → Loki
   - APIPark → NSQ

3. **日誌配置檢查**
   - Apinto 日誌配置檔案
   - Loki 配置檔案
   - Ingress 日誌配置
   - 日誌驅動程式載入

4. **儲存空間檢查**
   - PVC 狀態
   - 磁碟使用率
   - 日誌檔案大小

5. **日誌流程測試**
   - 發送測試 API 請求
   - 檢查日誌是否記錄
   - 驗證 Loki 中的日誌

這套工具可以幫助您快速識別和解決 API 通訊紀錄的問題，特別是通過 Ingress-Nginx 的通訊紀錄遺失問題。

```shellscript
cd /home/chad/APIPark-0909/k8s_helm
./quick-log-diagnosis.sh
```

```shellscript
./check-log-chain.sh
```

```shellscript
./check-ingress-logs.sh
```

```shellscript
./fix-log-issues.sh
```

