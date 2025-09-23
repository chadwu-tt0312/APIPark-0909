# APIPark Helm Chart 故障排除指南

## MySQL 相關問題

### 問題 1: MySQL Pod 無法啟動或 readiness probe 失敗

**症狀：**
```
Warning  Unhealthy  3h2m (x2425 over 4h26m)  kubelet  Readiness probe failed: mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
```

**解決方案：**

1. **檢查 Secret 是否正確創建：**
   ```bash
   kubectl get secret apipark-secret -o yaml
   kubectl get secret apipark-secret -o jsonpath='{.data.mysql-root-password}' | base64 -d
   ```

2. **檢查 MySQL Pod 日誌：**
   ```bash
   kubectl logs apipark-mysql
   ```

3. **手動測試 MySQL 連接：**
   ```bash
   kubectl exec -it apipark-mysql -- mysql -u root -p123456 -e "SELECT 1;"
   ```

4. **如果密碼問題持續，重新創建 Secret：**
   ```bash
   kubectl delete secret apipark-secret
   helm upgrade apipark ./apipark
   ```

### 問題 2: MySQL 初始化失敗

**症狀：**
```
ERROR 1049 (42000): Unknown database '1'
```

**解決方案：**

1. **檢查初始化腳本：**
   ```bash
   kubectl get configmap apipark-shared-config -o yaml | grep -A 20 "mysql-init.sql"
   ```

2. **重新部署 MySQL：**
   ```bash
   kubectl delete pod apipark-mysql
   ```

## Apinto Gateway 相關問題

### 問題 1: Apinto Pod 無法啟動或 readiness probe 失敗

**症狀：**
```
Warning  Unhealthy  41s (x14 over 116s)  kubelet  Readiness probe failed: Get "http://10.244.0.76:9400/health": dial tcp 10.244.0.76:9400: connect: connection refused
Warning  BackOff    9s (x8 over 102s)    kubelet  Back-off restarting failed container apinto
```

**解決方案：**

1. **檢查 Apinto 配置：**
   ```bash
   kubectl get configmap apipark-shared-config -o yaml
   ```

2. **檢查 Apinto Pod 日誌：**
   ```bash
   kubectl logs apipark-apinto
   ```

3. **檢查端口是否正常監聽：**
   ```bash
   kubectl exec -it apipark-apinto -- netstat -tlnp
   ```

4. **手動測試連接：**
   ```bash
   kubectl exec -it apipark-apinto -- curl http://localhost:9400
   ```

5. **如果配置問題，重新部署：**
   ```bash
   kubectl delete pod apipark-apinto
   ```

## Loki 相關問題

### 問題 1: Loki Pod CrashLoopBackOff

**症狀：**
```
State:          Waiting
Reason:         CrashLoopBackOff
Last State:     Terminated
Reason:         Error
Exit Code:      1
```

**解決方案：**

1. **檢查 Loki 日誌：**
   ```bash
   kubectl logs apipark-loki
   ```

2. **檢查 Loki 配置：**
   ```bash
   kubectl get configmap apipark-shared-config -o yaml
   ```

3. **檢查配置檔案格式：**
   ```bash
   kubectl exec -it apipark-loki -- cat /etc/loki/loki-config.yaml
   ```

4. **重新部署 Loki：**
   ```bash
   kubectl delete pod apipark-loki
   ```

5. **使用修復腳本：**
   ```bash
   ./fix-loki.sh
   ```

### 問題 2: Loki 配置錯誤

**症狀：**
```
Error: failed to load config: yaml: unmarshal errors
```

**解決方案：**

1. **檢查 YAML 格式：**
   ```bash
   kubectl get configmap apipark-shared-config -o yaml | grep -A 50 "loki-config.yaml"
   ```

2. **驗證配置：**
   ```bash
   kubectl exec -it apipark-loki -- /usr/bin/loki -config.file=/etc/loki/loki-config.yaml -verify-config
   ```

## 外部連接問題

### 問題 1: 瀏覽器無法連接但 curl 可以

**症狀：**
```
curl http://172.18.0.2:31288  # 可以連接
瀏覽器訪問 http://172.18.0.2:31288  # 無法連接
```

**解決方案：**

1. **檢查防火牆規則：**
   ```bash
   # UFW
   sudo ufw allow 31288/tcp
   sudo ufw reload
   
   # iptables
   sudo iptables -A INPUT -p tcp --dport 31288 -j ACCEPT
   ```

2. **檢查 Kubernetes 網路策略：**
   ```bash
   kubectl get networkpolicies
   kubectl describe networkpolicy <policy-name>
   ```

3. **重新創建服務：**
   ```bash
   kubectl delete svc apipark
   helm upgrade apipark ./apipark
   ```

4. **使用診斷腳本：**
   ```bash
   ./diagnose-external-access.sh
   ```

5. **使用修復腳本：**
   ```bash
   ./fix-external-access.sh
   ```

6. **替代連接方案：**
   ```bash
   # 端口轉發（推薦用於測試）
   kubectl port-forward svc/apipark 8080:8288
   # 然後訪問 http://localhost:8080
   ```

### 問題 2: 所有外部連接都失敗

**症狀：**
```
curl http://172.18.0.2:31288  # 連接失敗
telnet 172.18.0.2 31288       # 連接失敗
```

**解決方案：**

1. **檢查節點 IP：**
   ```bash
   kubectl get nodes -o wide
   ```

2. **檢查服務配置：**
   ```bash
   kubectl get svc apipark -o yaml
   ```

3. **檢查 Pod 狀態：**
   ```bash
   kubectl get pods -l component=apipark
   kubectl describe pod <pod-name>
   ```

4. **檢查防火牆：**
   ```bash
   sudo ufw status
   # 或
   sudo iptables -L
   ```

## 一般故障排除步驟

### 1. 檢查所有 Pod 狀態
```bash
kubectl get pods -l app.kubernetes.io/name=apipark
```

### 2. 檢查服務狀態
```bash
kubectl get svc -l app.kubernetes.io/name=apipark
```

### 3. 檢查事件
```bash
kubectl get events --sort-by=.metadata.creationTimestamp
```

### 4. 檢查特定 Pod 日誌
```bash
# APIPark 主應用
kubectl logs apipark-xxx

# MySQL
kubectl logs apipark-mysql

# Redis
kubectl logs apipark-redis

# Grafana
kubectl logs apipark-grafana
```

### 5. 檢查持久化存儲
```bash
kubectl get pvc -l app.kubernetes.io/name=apipark
kubectl describe pvc apipark-mysql-pvc
```

## 常見問題和解決方案

### 問題 1: Pod 一直處於 Pending 狀態

**可能原因：**
- 資源不足
- 存儲問題
- 節點選擇器問題

**解決方案：**
```bash
kubectl describe pod <pod-name>
kubectl get nodes
kubectl top nodes
```

### 問題 2: 服務無法連接

**可能原因：**
- 服務配置錯誤
- 端口配置問題
- 網路策略限制

**解決方案：**
```bash
kubectl get svc
kubectl describe svc <service-name>
kubectl get endpoints <service-name>
```

### 問題 3: 外部連接失敗

**檢查步驟：**
1. 確認 NodePort 服務正常：
   ```bash
   kubectl get svc apipark apipark-mysql apipark-grafana
   ```

2. 檢查節點 IP：
   ```bash
   kubectl get nodes -o wide
   ```

3. 測試連接：
   ```bash
   # APIPark
   curl http://<NODE_IP>:31288/health
   
   # MySQL
   telnet <NODE_IP> 31306
   
   # Grafana
   curl http://<NODE_IP>:30000
   ```

### 問題 4: 密碼或認證問題

**解決方案：**
1. 檢查 values.yaml 中的密碼配置
2. 重新生成 Secret：
   ```bash
   kubectl delete secret apipark-secret
   helm upgrade apipark ./apipark
   ```

3. 手動創建 Secret：
   ```bash
   kubectl create secret generic apipark-secret \
     --from-literal=mysql-root-password=123456 \
     --from-literal=mysql-password=123456 \
     --from-literal=redis-password=123456 \
     --from-literal=influxdb-username=admin \
     --from-literal=influxdb-password=Key123qaz \
     --from-literal=influxdb-token=dQ9>fK6&gJ \
     --from-literal=apipark-admin-password=aToh0eag
   ```

## 重新部署

如果問題持續，可以嘗試完全重新部署：

```bash
# 卸載
helm uninstall apipark

# 清理 PVC（注意：這會刪除所有數據）
kubectl delete pvc -l app.kubernetes.io/name=apipark

# 重新安裝
helm install apipark ./apipark
```

## 獲取支援

如果問題仍然存在，請提供以下資訊：

1. Kubernetes 版本：`kubectl version`
2. Helm 版本：`helm version`
3. Pod 狀態：`kubectl get pods -l app.kubernetes.io/name=apipark`
4. 相關日誌：`kubectl logs <pod-name>`
5. 事件資訊：`kubectl get events`
