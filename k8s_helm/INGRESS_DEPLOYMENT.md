# APIPark Ingress 部署指南

## 概述

已將 APIPark 從 NodePort 模式改為 Ingress 模式，提供更靈活的流量管理和更好的安全性。

## 主要變更

### 1. 服務類型變更
- **APIPark 主應用程式**: NodePort (31288) → ClusterIP (8288)
- **Apinto Gateway**: NodePort (31899) → ClusterIP (8099)  

### 2. 新增 Ingress 配置
- 域名: `apipark.local`
- 路徑配置:
  - `/` → APIPark 主應用程式 (port 8288)
  - `/api` → Apinto Gateway (port 8099)

## 部署步驟

### 1. 安裝 Nginx Ingress Controller
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.3/deploy/static/provider/cloud/deploy.yaml
```

### 2. 部署 APIPark
```bash
cd /home/chad/APIPark-0909/k8s_helm
helm install apipark ./apipark
```

### 3. 配置本地 DNS
在 `/etc/hosts` (Linux/Mac) 或 `C:\Windows\System32\drivers\etc\hosts` (Windows) 中新增：
```
<INGRESS_IP> apipark.local
```

### 4. 取得 Ingress IP
```bash
kubectl get ingress apipark
```

## 訪問方式

- **APIPark 主應用程式**: http://apipark.local/
- **Apinto API Gateway**: http://apipark.local/api

## 配置自訂

### 修改域名
編輯 `apipark/values.yaml`:
```yaml
ingress:
  hosts:
    - host: your-domain.com  # 修改為您的域名
```

### 修改路徑
編輯 `apipark/values.yaml`:
```yaml
ingress:
  hosts:
    - host: apipark.local
      paths:
        - path: /your-path
          pathType: Prefix
          service:
            name: apipark
            port: 8288
```

### 啟用 HTTPS
編輯 `apipark/values.yaml`:
```yaml
ingress:
  tls:
    - secretName: apipark-tls
      hosts:
        - apipark.local
```

## 故障排除

### 檢查 Ingress Controller
```bash
kubectl get pods -n ingress-nginx
```

### 檢查 Ingress 狀態
```bash
kubectl describe ingress apipark
```

### 檢查服務狀態
```bash
kubectl get svc
```

## 注意事項

1. 確保 Ingress Controller 已正確安裝並運行
2. 確保 DNS 解析正確配置
3. MySQL 通過 Ingress 訪問可能需要額外的資料庫代理配置
4. 管理員密碼仍為: `aToh0eag`
