# APIPark Helm Chart

這是一個用於部署 APIPark API 管理平台的 Helm Chart。

## 概述

APIPark 是一個完整的 API 管理平台，包含以下組件：

- **APIPark 主應用**: 核心 API 管理功能
- **MySQL**: 資料庫存儲
- **Redis**: 快取和會話存儲
- **InfluxDB**: 時序資料存儲
- **Loki**: 日誌聚合
- **Grafana**: 監控和可視化
- **NSQ**: 訊息佇列
- **Apinto Gateway**: API 閘道

## 安裝

### 前置條件

- Kubernetes 1.19+
- Helm 3.0+
- 持久化存儲支援 (PersistentVolume)

### 安裝步驟

1. 添加 Helm repository (如果需要):
```bash
helm repo add apipark https://your-repo-url
helm repo update
```

2. 安裝 APIPark:
```bash
helm install apipark ./apipark
```

3. 或者使用自定義 values 檔案:
```bash
helm install apipark ./apipark -f custom-values.yaml
```

### 升級

```bash
helm upgrade apipark ./apipark
```

### 卸載

```bash
helm uninstall apipark
```

## 配置

### Values 檔案

主要配置選項在 `values.yaml` 中：

- `global.imageRegistry`: 全域映像倉庫
- `global.storageClass`: 全域存儲類別
- 各組件的啟用/停用設定
- 資源限制和請求
- 持久化存儲配置
- 服務類型配置

### 環境變數

APIPark 主應用支援以下環境變數：

- `MYSQL_USER_NAME`: MySQL 用戶名
- `MYSQL_PWD`: MySQL 密碼
- `MYSQL_IP`: MySQL 服務地址
- `MYSQL_PORT`: MySQL 端口
- `MYSQL_DB`: 資料庫名稱
- `REDIS_ADDR`: Redis 地址
- `REDIS_PWD`: Redis 密碼
- `ADMIN_PASSWORD`: 管理員密碼
- `InfluxdbToken`: InfluxDB 令牌

### 持久化存儲

所有組件都支援持久化存儲，可以通過以下方式配置：

```yaml
mysql:
  persistence:
    enabled: true
    storageClass: "fast-ssd"
    size: 20Gi
```

### 服務類型

支援以下 Kubernetes 服務類型：

- **ClusterIP** (預設) - 內部服務使用
- **NodePort** - 外部連接使用 (APIPark、MySQL、Grafana)
- **LoadBalancer** - 雲端環境使用

### 外部連接

使用 NodePort 方式處理外部連接：

```yaml
apipark:
  service:
    type: NodePort
    nodePort: 31288

mysql:
  service:
    type: NodePort
    nodePort: 31306

grafana:
  service:
    type: NodePort
    nodePort: 31300
```

## 監控和日誌

- **Grafana**: 提供監控儀表板，預設端口 3000
- **Loki**: 日誌聚合系統，預設端口 3100
- **InfluxDB**: 時序資料存儲，預設端口 8086

## 故障排除

### 檢查 Pod 狀態

```bash
kubectl get pods -l app.kubernetes.io/name=apipark
```

### 檢查服務狀態

```bash
kubectl get svc -l app.kubernetes.io/name=apipark
```

### 查看日誌

```bash
kubectl logs -l app.kubernetes.io/name=apipark
```

### 檢查持久化存儲

```bash
kubectl get pvc -l app.kubernetes.io/name=apipark
```

## 支援

如有問題，請聯繫 APIPark 支援團隊或查看專案文檔。

## 授權

請參考 LICENSE 檔案了解授權詳情。
