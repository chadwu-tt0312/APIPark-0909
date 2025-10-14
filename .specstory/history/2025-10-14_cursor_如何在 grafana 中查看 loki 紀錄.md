# 如何在 grafana 中查看 loki 紀錄
_Exported on 2025/10/14 at 17:24:01 [GMT+8] from Cursor (1.7.46)_

---

**User**

grafana 要如何才能看到 loki 的紀錄?

---

**Cursor**

我來幫你了解如何在 Grafana 中查看 Loki 的日誌記錄。首先讓我查看一下你專案中的 Loki 相關配置。

根據我查看的配置，你的 APIPark 專案中已經設置了 Grafana 和 Loki 的整合。要在 Grafana 中查看 Loki 的日誌記錄，請按照以下步驟操作：

## 1. 確認服務運行狀態

首先確認 Loki 和 Grafana 服務是否正常運行：

### Docker Compose 環境：
```bash
docker ps | grep -E "loki|grafana"
```

### Kubernetes 環境：
```bash
kubectl get pods | grep -E "loki|grafana"
```

## 2. 訪問 Grafana

根據配置，Grafana 的訪問方式：

### Docker Compose 環境：
- URL: `http://localhost:3000`
- 預設已啟用匿名訪問，角色為 Admin

### Kubernetes 環境：
- URL: `http://<節點IP>:31300` (NodePort 配置)
- 或使用 port-forward: `kubectl port-forward svc/apipark-grafana 3000:3000`

## 3. 檢查 Loki 資料來源

Grafana 啟動時會自動配置 Loki 資料來源。根據配置檔內容：

- 資料來源名稱：`Loki`
- Loki URL：
  - Docker Compose: `http://apipark-loki:3100`
  - Kubernetes: `http://apipark-loki:3100`

## 4. 查詢 Loki 日誌

1. **進入 Grafana 後，點擊左側選單的「Explore」（探索）圖示**

2. **在頂部選擇「Loki」資料來源**

3. **使用 LogQL 查詢語言查詢日誌**，例如：
   ```
   {job="apipark"}
   ```
   或更具體的查詢：
   ```
   {container="apipark"} |= "error"
   ```

4. **調整時間範圍**：右上角可選擇查詢的時間範圍（最多 90 天，根據配置）

## 5. 建立 Dashboard

如果需要持續監控，可以：

1. 點擊「+」→「Create」→「Dashboard」
2. 添加新的 Panel
3. 選擇 Loki 資料來源
4. 設定查詢條件
5. 儲存 Dashboard

## 6. 常用 LogQL 查詢範例

```logql
# 查看所有日誌
{}

# 按標籤過濾
{app="apipark"}

# 搜尋包含特定文字的日誌
{app="apipark"} |= "error"

# 排除特定文字
{app="apipark"} != "debug"

# 使用正則表達式
{app="apipark"} |~ "error|warn"

# 解析 JSON 日誌
{app="apipark"} | json

# 統計錯誤數量
sum(rate({app="apipark"} |= "error" [5m]))
```

## 7. 疑難排解

如果看不到日誌，檢查：

1. **Loki 服務是否正常**：
   ```bash
   curl http://localhost:3100/ready
   ```

2. **應用程式是否正確發送日誌到 Loki**：
   檢查應用程式的日誌配置是否指向正確的 Loki 端點

3. **查看 Loki 的日誌**：
   ```bash
   docker logs apipark-loki
   # 或 Kubernetes
   kubectl logs -l app.kubernetes.io/component=loki
   ```

4. **在 Grafana 中測試資料來源**：
   - 設定 → Data Sources → Loki → Test

根據你的專案配置，Grafana 和 Loki 的整合應該已經自動完成。如果遇到問題，請提供具體的錯誤訊息，我可以協助進一步排查。

```shellscript
docker ps | grep -E "loki|grafana"
```

```shellscript
kubectl get pods | grep -E "loki|grafana"
```

```plaintext
   {job="apipark"}
```

```plaintext
   {container="apipark"} |= "error"
```

```plaintext
# 查看所有日誌
{}

# 按標籤過濾
{app="apipark"}

# 搜尋包含特定文字的日誌
{app="apipark"} |= "error"

# 排除特定文字
{app="apipark"} != "debug"

# 使用正則表達式
{app="apipark"} |~ "error|warn"

# 解析 JSON 日誌
{app="apipark"} | json

# 統計錯誤數量
sum(rate({app="apipark"} |= "error" [5m]))
```

```shellscript
   curl http://localhost:3100/ready
```

```shellscript
   docker logs apipark-loki
   # 或 Kubernetes
   kubectl logs -l app.kubernetes.io/component=loki
```

