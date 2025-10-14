# Docker Compose 到 Kubernetes Helm Chart 轉換總結

## 轉換概述

已成功將 `docker-compose.yml` 轉換為完整的 Kubernetes Helm Chart，包含以下組件：

### 轉換的服務

| Docker Compose 服務 | Kubernetes 資源 | 狀態 |
|-------------------|----------------|------|
| apipark-mysql | MySQL Deployment + Service + PVC | ✅ 完成 |
| apipark-redis | Redis Deployment + Service + PVC | ✅ 完成 |
| apipark-influxdb | InfluxDB Deployment + Service + PVC | ✅ 完成 |
| apipark-loki | Loki Deployment + Service + PVC | ✅ 完成 |
| apipark-grafana | Grafana Deployment + Service + PVC | ✅ 完成 |
| apipark-nsq | NSQ Deployment + Service | ✅ 完成 |
| apipark-apinto | Apinto Deployment + Service + PVC | ✅ 完成 |
| apipark | APIPark 主應用 Deployment + Service | ✅ 完成 |

## 建立的檔案結構

```
k8s_helm/
├── apipark/
│   ├── Chart.yaml                    # Helm chart 元資料
│   ├── values.yaml                   # 預設配置值
│   ├── README.md                     # 使用說明
│   └── templates/
│       ├── _helpers.tpl              # Helm 輔助模板
│       ├── configmap.yaml            # 配置映射
│       ├── secret.yaml               # 密鑰資源
│       ├── serviceaccount.yaml       # 服務帳戶
│       ├── ingress.yaml              # Ingress 配置
│       ├── mysql-deployment.yaml     # MySQL 部署
│       ├── mysql-service.yaml        # MySQL 服務
│       ├── mysql-pvc.yaml            # MySQL 持久化存儲
│       ├── redis-deployment.yaml     # Redis 部署
│       ├── redis-service.yaml        # Redis 服務
│       ├── redis-pvc.yaml            # Redis 持久化存儲
│       ├── influxdb-deployment.yaml  # InfluxDB 部署
│       ├── influxdb-service.yaml     # InfluxDB 服務
│       ├── influxdb-pvc.yaml         # InfluxDB 持久化存儲
│       ├── loki-deployment.yaml      # Loki 部署
│       ├── loki-service.yaml         # Loki 服務
│       ├── loki-pvc.yaml             # Loki 持久化存儲
│       ├── grafana-deployment.yaml   # Grafana 部署
│       ├── grafana-service.yaml      # Grafana 服務
│       ├── grafana-pvc.yaml          # Grafana 持久化存儲
│       ├── nsq-deployment.yaml       # NSQ 部署
│       ├── nsq-service.yaml          # NSQ 服務
│       ├── apinto-deployment.yaml    # Apinto 部署
│       ├── apinto-service.yaml       # Apinto 服務
│       ├── apinto-pvc.yaml           # Apinto 持久化存儲
│       ├── apinto-configmap.yaml     # Apinto 配置
│       ├── apipark-deployment.yaml   # APIPark 主應用部署
│       ├── apipark-service.yaml      # APIPark 主應用服務
│       └── NOTES.txt                 # 安裝後說明
├── deploy.sh                         # 部署腳本
└── CONVERSION_SUMMARY.md             # 本文件
```

## 主要轉換特點

### 1. 環境變數轉換
- 將 Docker Compose 的 `environment` 轉換為 Kubernetes 的 `env` 配置
- 敏感資訊（密碼、令牌）使用 Kubernetes Secret 管理
- 非敏感配置使用 ConfigMap 管理

### 2. 網路配置
- Docker Compose 的 `networks` 轉換為 Kubernetes 的 Service
- 內部服務通訊使用 Service 名稱解析
- 外部存取通過 NodePort 服務（APIPark、MySQL、Grafana）

### 3. 存儲配置
- Docker Compose 的 `volumes` 轉換為 Kubernetes 的 PersistentVolumeClaim
- 支援動態存儲配置
- 可配置存儲類別和存取模式

### 4. 健康檢查
- 將 Docker Compose 的 `healthcheck` 轉換為 Kubernetes 的 `livenessProbe` 和 `readinessProbe`
- 支援 HTTP 和命令式健康檢查

### 5. 資源管理
- 添加了 CPU 和記憶體限制配置
- 支援資源請求和限制設定

## 配置亮點

### 安全性
- 所有密碼和敏感資訊使用 Kubernetes Secret 管理
- 支援 ServiceAccount 配置
- 可配置 Pod 安全上下文

### 可擴展性
- 支援水平擴展（replicaCount）
- 可配置節點選擇器和親和性規則
- 支援污點容忍度配置

### 監控和日誌
- 整合 Loki 用於日誌聚合
- 整合 Grafana 用於監控可視化
- 整合 InfluxDB 用於時序資料存儲

### 靈活性
- 所有組件可獨立啟用/停用
- 支援自定義映像倉庫
- 可配置存儲類別和大小
- 簡化的外部連接配置（NodePort 模式）

## 使用方式

### 1. 基本安裝
```bash
cd k8s_helm
helm install apipark ./apipark
```

### 2. 使用自定義配置
```bash
helm install apipark ./apipark -f custom-values.yaml
```

### 3. 使用部署腳本
```bash
./deploy.sh deploy apipark default
```

### 4. 查看狀態
```bash
./deploy.sh status apipark default
```

## 注意事項

1. **前置條件**：需要 Kubernetes 1.19+ 和 Helm 3.0+
2. **存儲**：需要配置 PersistentVolume 或動態存儲供應商
3. **網路**：使用 NodePort 方式處理外部連接，無需 Ingress Controller
4. **資源**：根據實際需求調整資源限制和請求
5. **密碼**：建議在生產環境中更改預設密碼
6. **防火牆**：確保 NodePort 端口（18288、33306、30000）已開放

## 後續建議

1. 根據實際環境調整 `values.yaml` 中的配置
2. 配置適當的存儲類別
3. 設定防火牆規則開放 NodePort 端口
4. 配置監控和告警
5. 建立備份策略
6. 測試災難恢復流程
7. 考慮使用反向代理處理 SSL 終止

轉換已完成，可以開始在 Kubernetes 環境中部署 APIPark！
