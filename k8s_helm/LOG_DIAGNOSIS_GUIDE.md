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
