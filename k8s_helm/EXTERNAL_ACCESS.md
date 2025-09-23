# 外部連接配置說明

## 概述

根據需求，以下服務已配置為支援外部連接：

- **APIPark 管理介面** - 網頁管理介面
- **MySQL 資料庫** - 外部管理需求
- **Grafana 監控** - 網頁管理介面

其他服務（Redis、InfluxDB、Loki、NSQ、Apinto）保持 ClusterIP 類型，僅供內部服務使用。

## 外部連接方式

### 1. NodePort 模式（預設）

使用 NodePort 服務類型，通過節點 IP 和固定端口存取：

```bash
# 獲取節點 IP
export NODE_IP=$(kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}")

# 存取服務
APIPark 管理介面: http://$NODE_IP:31288
MySQL 資料庫: $NODE_IP:31306
Grafana 監控: http://$NODE_IP:31000
```

### 2. LoadBalancer 模式（雲端環境）

如果在雲端環境（如 AWS、GCP、Azure），可以使用 LoadBalancer：

```yaml
# values.yaml
apipark:
  service:
    type: LoadBalancer
    port: 8288

mysql:
  service:
    type: LoadBalancer
    port: 3306

grafana:
  service:
    type: LoadBalancer
    port: 3000
```

## 端口對應表

| 服務 | 內部端口 | 外部端口 (NodePort) | 用途 |
|------|----------|-------------------|------|
| APIPark | 8288 | 31288 | 管理介面 |
| MySQL | 3306 | 31306 | 資料庫連接 |
| Grafana | 3000 | 31000 | 監控介面 |

## 安全考量

### 1. 防火牆配置
建議在防火牆中限制這些端口的存取：

```bash
# 只允許特定 IP 存取 MySQL
iptables -A INPUT -p tcp --dport 31306 -s 192.168.1.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 31306 -j DROP

# 只允許特定 IP 存取管理介面
iptables -A INPUT -p tcp --dport 31288 -s 192.168.1.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 31288 -j DROP
```

### 2. 密碼安全
建議在生產環境中更改預設密碼：

```yaml
# values.yaml
mysql:
  auth:
    rootPassword: "your-secure-password"
    password: "your-secure-password"

apipark:
  env:
    ADMIN_PASSWORD: "your-secure-admin-password"
    MYSQL_PWD: "your-secure-password"
    REDIS_PWD: "your-secure-password"
```

### 3. TLS/SSL 加密
建議在應用層面配置 HTTPS，或使用反向代理（如 Nginx）處理 SSL 終止：

```bash
# 使用 Nginx 作為反向代理
# 配置 SSL 證書並代理到 NodePort 服務
```

## 內部服務連接

以下服務僅供內部使用，不開放外部連接：

- **Redis** (6379) - 快取服務
- **InfluxDB** (8086) - 時序資料庫
- **Loki** (3100) - 日誌聚合
- **NSQ** (4150/4151) - 訊息佇列
- **Apinto Gateway** (8099/9400/9401) - API 閘道

這些服務通過 Kubernetes Service 名稱在叢集內部互相連接。

## 故障排除

### 1. 檢查服務狀態
```bash
kubectl get svc -l app.kubernetes.io/name=apipark
```

### 2. 檢查端口是否開放
```bash
kubectl get nodes -o wide
telnet <NODE_IP> 31288  # APIPark
telnet <NODE_IP> 31306  # MySQL
telnet <NODE_IP> 31000  # Grafana
```

### 3. 查看服務日誌
```bash
kubectl logs -l app.kubernetes.io/name=apipark
kubectl logs -l component=mysql
kubectl logs -l component=grafana
```

### 4. 端口轉發（測試用）
如果 NodePort 無法存取，可以使用端口轉發：

```bash
# APIPark
kubectl port-forward svc/apipark 8080:8288

# MySQL
kubectl port-forward svc/apipark-mysql 3306:3306

# Grafana
kubectl port-forward svc/apipark-grafana 3000:3000
```

## 部署後檢查清單

- [ ] 確認所有 Pod 運行正常
- [ ] 確認外部端口可以存取
- [ ] 測試 APIPark 管理介面登入
- [ ] 測試 MySQL 資料庫連接
- [ ] 測試 Grafana 監控介面
- [ ] 確認內部服務間連接正常
- [ ] 檢查日誌輸出
- [ ] 驗證持久化存儲
