# 分析 REST API 通訊流程與記錄
_Exported on 2025/10/14 at 17:23:04 [GMT+8] from Cursor (1.7.46)_

---

**User**

1. 請分析專案程式碼，找出 REST API 通訊的流程，並用 mermaid 格式繪出如何從外部接收 API request 一直到 API response 的相關流程。流程中不同元件(loki/apinto/etc)需要明確區分。
2. 流程分析完畢，接著分析如何記錄 API 通訊，如何記錄 requests
 

---

**Cursor**

我會分析 APIPark 專案的程式碼，了解 REST API 通訊流程以及如何記錄 API requests。

讓我先探索專案結構，了解主要元件和架構：

現在讓我深入了解 API request 的處理流程：

讓我查看 gateway 和 log driver 的整合：

現在讓我查看 log-driver 的實作：

現在讓我查看 API 如何透過 apinto 處理和記錄：

現在讓我查看系統如何配置 access log 輸出到 Loki：

現在讓我查看系統初始化時如何設定 Loki 作為日誌輸出：

讓我進一步查看系統如何初始化 Loki 作為日誌輸出：

現在讓我查看系統初始化流程：

現在讓我查看初始化程式碼，了解 Loki 如何被配置：

根據我的分析，現在我可以繪製 APIPark 的 REST API 通訊流程圖，並說明如何記錄 API 通訊。

## 1. REST API 通訊流程分析

根據程式碼分析，APIPark 的 REST API 通訊流程如下：

```mermaid
graph TB
    subgraph "外部客戶端"
        Client[API Client]
    end
    
    subgraph "APIPark Gateway Layer"
        Apinto[Apinto Gateway<br/>:8099/:9400/:9401]
        AccessLog[Access Log Plugin]
        Monitor[Monitor Plugin]
        ProxyRewrite[Proxy Rewrite Plugin]
        AppAuth[App Authentication Plugin]
        Strategy[Strategy Plugins<br/>限流/熔斷/快取/灰度]
    end
    
    subgraph "APIPark Core"
        Router[Router Controller]
        Service[Service Module]
        Auth[Authorization Module]
    end
    
    subgraph "Upstream Services"
        Backend[Backend Services]
    end
    
    subgraph "Log Collection"
        LogDriver[Log Driver Module]
        LokiDriver[Loki Driver]
    end
    
    subgraph "Storage"
        Loki[Loki<br/>:3100]
        InfluxDB[InfluxDB<br/>:8086]
        MySQL[MySQL<br/>:3306]
        Redis[Redis<br/>:6379]
    end
    
    subgraph "Monitoring"
        Grafana[Grafana<br/>:3000]
    end
    
    %% Request Flow
    Client -->|HTTP Request| Apinto
    Apinto --> AccessLog
    AccessLog --> Monitor
    Monitor --> AppAuth
    AppAuth -->|驗證| Auth
    AppAuth --> ProxyRewrite
    ProxyRewrite --> Strategy
    Strategy --> Router
    Router --> Service
    Service -->|轉發| Backend
    
    %% Response Flow
    Backend -->|Response| Service
    Service --> Router
    Router --> Strategy
    Strategy --> ProxyRewrite
    ProxyRewrite --> Apinto
    Apinto -->|HTTP Response| Client
    
    %% Logging Flow
    AccessLog -.->|記錄請求| LogDriver
    Monitor -.->|記錄指標| LogDriver
    LogDriver --> LokiDriver
    LokiDriver -->|推送日誌| Loki
    Monitor -.->|寫入指標| InfluxDB
    
    %% Data Storage
    Auth -.->|查詢授權| MySQL
    Strategy -.->|快取/狀態| Redis
    Service -.->|服務配置| MySQL
    
    %% Monitoring
    Loki -.->|查詢日誌| Grafana
    InfluxDB -.->|查詢指標| Grafana
    
    style Client fill:#e1f5fe
    style Apinto fill:#fff3e0
    style AccessLog fill:#f3e5f5
    style Monitor fill:#f3e5f5
    style ProxyRewrite fill:#f3e5f5
    style AppAuth fill:#f3e5f5
    style Strategy fill:#f3e5f5
    style Router fill:#e8f5e9
    style Service fill:#e8f5e9
    style Auth fill:#e8f5e9
    style Backend fill:#fce4ec
    style LogDriver fill:#fff9c4
    style LokiDriver fill:#fff9c4
    style Loki fill:#ffebee
    style InfluxDB fill:#ffebee
    style MySQL fill:#ffebee
    style Redis fill:#ffebee
    style Grafana fill:#e3f2fd
```

## 2. API 通訊記錄機制分析

### 2.1 記錄流程

APIPark 使用以下機制記錄 API 通訊：

#### **步驟 1：Apinto Gateway 接收請求**
- Apinto Gateway 在端口 8099 接收 API 請求
- 透過一系列插件處理請求

#### **步驟 2：Access Log 插件記錄**
- `access_log` 插件（全域啟用）攔截所有請求
- 記錄以下資訊：
  ```json
  {
    "msec": "時間戳記（毫秒）",
    "service": "服務名稱",
    "api": "API 路徑",
    "request_method": "HTTP 方法",
    "request_uri": "請求 URI",
    "request_header": "請求標頭",
    "request_body": "請求內容",
    "remote_addr": "客戶端 IP",
    "application": "應用程式 ID",
    "authorization": "授權資訊",
    "status": "回應狀態碼",
    "request_time": "請求處理時間",
    "response_body": "回應內容",
    "ai_provider": "AI 提供者（如適用）",
    "ai_model": "AI 模型（如適用）",
    "ai_model_input_token": "輸入 token 數",
    "ai_model_output_token": "輸出 token 數",
    "ai_model_total_token": "總 token 數"
  }
  ```

#### **步驟 3：Log Driver 處理**
- Log Driver 模組接收格式化的日誌資料
- 使用預設配置的 formatter 格式化日誌：
  ```go
  logFormatter = map[string]interface{}{
    "fields": []string{
      "$msec", "$service", "$provider", "$request_uri",
      "$remote_addr", "$request_body", "$api", "$status",
      "$request_time", "$application", "$strategy",
      "$request_id", "$authorization", "$response_body",
      // AI 相關欄位...
    }
  }
  ```

#### **步驟 4：Loki Driver 推送**
- Loki Driver 將日誌推送到 Loki 伺服器
- 配置：
  ```json
  {
    "url": "http://apipark-loki:3100",
    "headers": {
      "Content-Type": "application/json"
    }
  }
  ```

#### **步驟 5：Loki 儲存**
- Loki 接收並儲存日誌
- 保留期限：90 天
- 使用 TSDB 儲存引擎
- 檔案系統儲存在 `/tmp/loki/chunks`

### 2.2 系統初始化配置

系統啟動時自動配置 Loki 作為日誌輸出：

1. **Docker Compose 啟動 Loki 容器**
   - 自動生成 Loki 配置檔案
   - 監聽端口 3100

2. **APIPark 初始化**
   - 呼叫 `set_loki()` 函數設定 Loki 地址
   - API 端點：`/api/v1/log/loki`
   - 配置內容：`{"config":{"url":"http://apipark-loki:3100"}}`

3. **Gateway 配置同步**
   - Log Module 初始化時載入 Loki 驅動
   - 將配置推送到 Apinto Gateway
   - 設定 access_log 插件輸出到 Loki

### 2.3 日誌查詢與監控

1. **Grafana 整合**
   - Grafana 配置 Loki 作為資料來源
   - 可視化查詢 API 日誌
   - 端口：3000

2. **日誌查詢 API**
   - 透過 Loki Driver 提供查詢介面
   - 支援按時間範圍、服務、API 等條件過濾
   - 返回格式化的日誌記錄

3. **監控指標**
   - Monitor 插件同時記錄效能指標到 InfluxDB
   - 包含請求數、回應時間、錯誤率等指標

### 2.4 關鍵特性

- **即時記錄**：所有 API 請求都被即時記錄
- **結構化日誌**：使用 JSON 格式便於查詢分析
- **分散式追蹤**：透過 request_id 關聯請求鏈路
- **長期儲存**：90 天的日誌保留期
- **高效查詢**：Loki 提供高效的日誌查詢能力
- **可視化監控**：Grafana 提供豐富的視覺化介面

這個架構確保了所有經過 APIPark Gateway 的 API 通訊都被完整記錄，並提供了強大的查詢和分析能力。

```plaintext
graph TB
    subgraph "外部客戶端"
        Client[API Client]
    end
    
    subgraph "APIPark Gateway Layer"
        Apinto[Apinto Gateway<br/>:8099/:9400/:9401]
        AccessLog[Access Log Plugin]
        Monitor[Monitor Plugin]
        ProxyRewrite[Proxy Rewrite Plugin]
        AppAuth[App Authentication Plugin]
        Strategy[Strategy Plugins<br/>限流/熔斷/快取/灰度]
    end
    
    subgraph "APIPark Core"
        Router[Router Controller]
        Service[Service Module]
        Auth[Authorization Module]
    end
    
    subgraph "Upstream Services"
        Backend[Backend Services]
    end
    
    subgraph "Log Collection"
        LogDriver[Log Driver Module]
        LokiDriver[Loki Driver]
    end
    
    subgraph "Storage"
        Loki[Loki<br/>:3100]
        InfluxDB[InfluxDB<br/>:8086]
        MySQL[MySQL<br/>:3306]
        Redis[Redis<br/>:6379]
    end
    
    subgraph "Monitoring"
        Grafana[Grafana<br/>:3000]
    end
    
    %% Request Flow
    Client -->|HTTP Request| Apinto
    Apinto --> AccessLog
    AccessLog --> Monitor
    Monitor --> AppAuth
    AppAuth -->|驗證| Auth
    AppAuth --> ProxyRewrite
    ProxyRewrite --> Strategy
    Strategy --> Router
    Router --> Service
    Service -->|轉發| Backend
    
    %% Response Flow
    Backend -->|Response| Service
    Service --> Router
    Router --> Strategy
    Strategy --> ProxyRewrite
    ProxyRewrite --> Apinto
    Apinto -->|HTTP Response| Client
    
    %% Logging Flow
    AccessLog -.->|記錄請求| LogDriver
    Monitor -.->|記錄指標| LogDriver
    LogDriver --> LokiDriver
    LokiDriver -->|推送日誌| Loki
    Monitor -.->|寫入指標| InfluxDB
    
    %% Data Storage
    Auth -.->|查詢授權| MySQL
    Strategy -.->|快取/狀態| Redis
    Service -.->|服務配置| MySQL
    
    %% Monitoring
    Loki -.->|查詢日誌| Grafana
    InfluxDB -.->|查詢指標| Grafana
    
    style Client fill:#e1f5fe
    style Apinto fill:#fff3e0
    style AccessLog fill:#f3e5f5
    style Monitor fill:#f3e5f5
    style ProxyRewrite fill:#f3e5f5
    style AppAuth fill:#f3e5f5
    style Strategy fill:#f3e5f5
    style Router fill:#e8f5e9
    style Service fill:#e8f5e9
    style Auth fill:#e8f5e9
    style Backend fill:#fce4ec
    style LogDriver fill:#fff9c4
    style LokiDriver fill:#fff9c4
    style Loki fill:#ffebee
    style InfluxDB fill:#ffebee
    style MySQL fill:#ffebee
    style Redis fill:#ffebee
    style Grafana fill:#e3f2fd
```

```json
  {
    "msec": "時間戳記（毫秒）",
    "service": "服務名稱",
    "api": "API 路徑",
    "request_method": "HTTP 方法",
    "request_uri": "請求 URI",
    "request_header": "請求標頭",
    "request_body": "請求內容",
    "remote_addr": "客戶端 IP",
    "application": "應用程式 ID",
    "authorization": "授權資訊",
    "status": "回應狀態碼",
    "request_time": "請求處理時間",
    "response_body": "回應內容",
    "ai_provider": "AI 提供者（如適用）",
    "ai_model": "AI 模型（如適用）",
    "ai_model_input_token": "輸入 token 數",
    "ai_model_output_token": "輸出 token 數",
    "ai_model_total_token": "總 token 數"
  }
```

```go
  logFormatter = map[string]interface{}{
    "fields": []string{
      "$msec", "$service", "$provider", "$request_uri",
      "$remote_addr", "$request_body", "$api", "$status",
      "$request_time", "$application", "$strategy",
      "$request_id", "$authorization", "$response_body",
      // AI 相關欄位...
    }
  }
```

```json
  {
    "url": "http://apipark-loki:3100",
    "headers": {
      "Content-Type": "application/json"
    }
  }
```

---

**User**

分析如何記錄 API 通訊，如何記錄 requests。並指向對應程式碼

---

**Cursor**

我來詳細分析 APIPark 如何記錄 API 通訊和 requests，並指向對應的程式碼位置。

## API 通訊記錄機制詳細分析

### 1. Access Log 插件配置

**位置：** `/home/chad/APIPark-0909/gateway/apinto/plugin/apinto_plugin.yml:1-4`
```yaml
-
  id: eolinker.com:apinto:access_log
  name: access_log
  status: global  # 全域啟用，攔截所有請求
```

**位置：** `/home/chad/APIPark-0909/resources/plugin/plugin.yml:9-13`
```yaml
access_log:
  id: eolinker.com:apinto:access_log
  name: access_log
  status: global
```

### 2. 日誌格式化配置

**位置：** `/home/chad/APIPark-0909/module/log/iml.go:46-88`
```go
var logFormatter = map[string]interface{}{
    "fields": []string{
        "$msec",                    // 時間戳記（毫秒）
        "$service",                 // 服務名稱
        "$provider",                // 提供者
        "$scheme as request_scheme", // 請求協議
        "$url as request_uri",      // 請求 URI
        "$host as request_host",    // 請求主機
        "$header as request_header", // 請求標頭
        "$remote_addr",             // 遠端地址
        "$request_body",            // 請求內容
        "$proxy_body",              // 代理請求內容
        "$proxy_method",            // 代理方法
        "$proxy_scheme",            // 代理協議
        "$proxy_uri",               // 代理 URI
        "$api",                     // API 路徑
        "$proxy_host",              // 代理主機
        "$proxy_header",            // 代理標頭
        "$proxy_addr",              // 代理地址
        "$response_header",         // 回應標頭
        "$response_headers",        // 所有回應標頭
        "$status",                  // 狀態碼
        "$content_type",            // 內容類型
        "$proxy_status",            // 代理狀態碼
        "$request_time",            // 請求時間
        "$response_time",           // 回應時間
        "$node",                    // 節點
        "$cluster",                 // 叢集
        "$application",             // 應用程式
        "$src_ip",                  // 來源 IP
        "$block_name as strategy",  // 策略名稱
        "$request_id",              // 請求 ID（用於追蹤）
        "$request_method",          // HTTP 方法
        "$authorization",           // 授權資訊
        "$response_body",           // 回應內容
        "$proxy_response_body",     // 代理回應內容
        "$ai_provider",             // AI 提供者
        "$ai_model",                // AI 模型
        "$ai_model_input_token",    // AI 輸入 token
        "$ai_model_output_token",   // AI 輸出 token
        "$ai_model_total_token",    // AI 總 token
    },
}
```

### 3. Loki Driver 實作

**Loki Driver 註冊**
**位置：** `/home/chad/APIPark-0909/log-driver/loki/loki.go:19-21`
```go
func init() {
    log_driver.RegisterFactory("loki", &factory{})
}
```

**Loki Driver 建立**
**位置：** `/home/chad/APIPark-0909/log-driver/loki/loki.go:40-61`
```go
func NewDriver(config string) (*Driver, map[string]interface{}, error) {
    cfg := new(DriverConfig)
    err := json.Unmarshal([]byte(config), cfg)
    if err != nil {
        return nil, nil, err
    }
    // 驗證配置
    err = cfg.Check()
    if err != nil {
        return nil, nil, err
    }
    headers := map[string]string{}
    for _, h := range cfg.Header {
        headers[h.Key] = h.Value
    }
    return &Driver{
        url:     cfg.URL,  // Loki 伺服器地址
        headers: headers,   // HTTP 標頭
    }, map[string]interface{}{
        "url":     cfg.URL,
        "headers": headers,
    }, nil
}
```

### 4. 日誌資料結構

**位置：** `/home/chad/APIPark-0909/log-driver/loki/entity.go:63-64`
```go
type LogDetail struct {
    Api                string      `json:"api"`
    // ... 其他欄位定義在 entity.go 中
}
```

**日誌項目轉換**
**位置：** `/home/chad/APIPark-0909/log-driver/loki/loki.go:224-244`
```go
func ToLogItem(detail *LogDetail, msec int64) *log_driver.LogItem {
    return &log_driver.LogItem{
        ID:            detail.RequestId,
        Strategy:      detail.Strategy,
        Service:       detail.Provider,
        API:           detail.Api,
        Method:        detail.RequestMethod,
        Url:           detail.RequestUri,
        RemoteIP:      detail.SrcIp,
        Consumer:      detail.Application,
        Authorization: detail.Authorization,
        InputToken:    parseToInt64(detail.AIModelInputToken),
        OutputToken:   parseToInt64(detail.AIModelOutputToken),
        TotalToken:    parseToInt64(detail.AIModelTotalToken),
        AIProvider:    detail.AIProvider,
        AIModel:       detail.AIModel,
        StatusCode:    parseToInt64(detail.Status),
        ResponseTime:  parseToInt64(detail.RequestTime),
        Traffic:       int64(len(detail.ResponseBody) + len(detail.RequestBody)),
        RecordTime:    time.UnixMilli(msec),
    }
}
```

### 5. 系統初始化配置 Loki

**初始化腳本設定 Loki**
**位置：** `/home/chad/APIPark-0909/scripts/resource/init_config.sh:133-146`
```bash
set_loki() {
  # 設置 loki 地址
  body='{"config":{"url":"'"${LokiAddress}"'"}}'
  path="/api/v1/log/loki"
  response=$(request_apipark "$path" "$body")
  # 從響應中提取 code
  code=$(echo "${response}" | grep '^{.*}$' | sed 's/.*"code":\([0-9]*\).*/\1/')
  if [ "$code" -eq 0 ]; then
    echo_pass "Set loki successfully"
  else
    echo_fail "Set loki failed: ${response}"
    exit 1
  fi
}
```

### 6. Log Module 儲存配置

**位置：** `/home/chad/APIPark-0909/module/log/iml.go:90-159`
```go
func (i *imlLogModule) Save(ctx context.Context, driver string, input *log_dto.Save) error {
    factory, has := log_driver.GetFactory(driver)
    if !has {
        return errors.New("driver not found")
    }
    
    // ... 配置處理
    
    // 建立 driver 實例
    d, c, err := factory.Create(info.Config)
    if err != nil {
        return err
    }
    
    // 設定輸出屬性
    attr := make(map[string]interface{})
    attr["driver"] = driver
    attr["formatter"] = logFormatter  // 使用預定義的格式化器
    attr["labels"] = labels
    attr["method"] = "POST"
    attr["scopes"] = []string{"access_log"}
    attr["type"] = "json"
    
    // 推送配置到 Gateway
    err = dynamicClient.Online(txCtx, &gateway.DynamicRelease{
        BasicItem: &gateway.BasicItem{
            ID:          driver,
            Description: "collect access log",
            Version:     time.Now().Format("20060102150405"),
            Resource:    gateway.ProfessionOutput,
        },
        Attr: attr,
    })
    
    // 設定 driver
    log_driver.SetDriver(driver, d)
    
    // ... 啟動排程
}
```

### 7. Gateway 初始化時載入日誌配置

**位置：** `/home/chad/APIPark-0909/module/log/iml.go:197-250`
```go
func (i *imlLogModule) initGateway(ctx context.Context, clusterId string, clientDriver gateway.IClientDriver) error {
    drivers := log_driver.Drivers()
    if len(drivers) < 1 {
        return nil
    }

    for _, driver := range drivers {
        factory, has := log_driver.GetFactory(driver)
        if !has {
            log_print.Errorf("driver %s not found", driver)
            continue
        }
        
        // 取得日誌來源配置
        info, err := i.service.GetLogSource(ctx, driver)
        if err != nil {
            log_print.Errorf("get log source %s error: %s", driver, err)
            continue
        }
        
        // 建立 driver
        d, c, err := factory.Create(info.Config)
        if err != nil {
            log_print.Errorf("create driver %s error: %s,config: %s", driver, err, info.Config)
            continue
        }
        
        log_driver.SetDriver(driver, d)
        
        // 取得動態客戶端
        dynamicClient, err := clientDriver.Dynamic(driver)
        if err != nil {
            log_print.Errorf("get dynamic client %s error: %s", driver, err)
            continue
        }
        
        // 設定屬性
        attr := make(map[string]interface{})
        attr["driver"] = driver
        attr["formatter"] = logFormatter
        attr["labels"] = labels
        attr["method"] = "POST"
        for k, v := range c {
            attr[k] = v
        }
        
        // 上線配置
        err = dynamicClient.Online(ctx, &gateway.DynamicRelease{
            BasicItem: &gateway.BasicItem{
                ID:          driver,
                Description: "collect access log",
                Version:     time.Now().Format("20060102150405"),
                Resource:    gateway.ProfessionOutput,
            },
            Attr: attr,
        })
    }
    
    return nil
}
```

### 8. 發送日誌到 Loki

**位置：** `/home/chad/APIPark-0909/log-driver/loki/loki.go:338-372`
```go
func send[T any](method string, uri string, headers map[string]string, queries url.Values, body string) ([]*T, error) {
    if queries != nil && len(queries) > 0 {
        uri = fmt.Sprintf("%s?%s", uri, queries.Encode())
    }
    
    // 建立 HTTP 請求
    req, err := http.NewRequest(method, uri, strings.NewReader(body))
    if err != nil {
        return nil, fmt.Errorf("failed to create request: %w,uri is %s", err, uri)
    }
    
    // 設定標頭
    for key, value := range headers {
        req.Header.Set(key, value)
    }
    
    log.DebugF("do request: %s", uri)
    doRequestTime := time.Now()
    
    // 發送請求
    resp, err := client.Do(req)
    if err != nil {
        return nil, fmt.Errorf("failed to send request: %w", err)
    }
    log.DebugF("do request spend time: %v", time.Now().Sub(doRequestTime))
    defer resp.Body.Close()
    
    // 讀取回應
    respData, err := io.ReadAll(resp.Body)
    if err != nil {
        return nil, fmt.Errorf("failed to read response: %w", err)
    }
    
    // 處理錯誤狀態碼
    if resp.StatusCode > 399 {
        return nil, fmt.Errorf("failed to send request: %s,body is %s", resp.Status, string(respData))
    }
    
    // 解析回應
    result := new(Response[T])
    err = json.Unmarshal(respData, result)
    if err != nil {
        return nil, fmt.Errorf("failed to decode response: %w,body is %s", err, string(respData))
    }
    return result.Data.Result, nil
}
```

### 9. 日誌查詢實作

**位置：** `/home/chad/APIPark-0909/log-driver/loki/loki.go:63-222`
```go
func (d *Driver) LogInfo(clusterId string, id string) (*log_driver.LogItem, error) {
    // 查詢特定請求 ID 的日誌
    // ... 實作細節
}

func (d *Driver) Logs(clusterId string, conditions map[string]string, start time.Time, end time.Time, limit int, offset int64) ([]*log_driver.LogItem, int64, error) {
    // 根據條件查詢日誌列表
    // ... 實作細節
}
```

## 總結

APIPark 的 API 通訊記錄機制：

1. **全域攔截**：透過 `access_log` 插件全域攔截所有 API 請求
2. **結構化記錄**：使用預定義的 formatter 記錄完整的請求/回應資訊
3. **即時推送**：透過 Loki Driver 即時推送日誌到 Loki 伺服器
4. **持久儲存**：Loki 提供 90 天的日誌保留期
5. **高效查詢**：支援按多種條件查詢歷史日誌
6. **可視化監控**：整合 Grafana 提供視覺化介面

每個請求都會被完整記錄，包含請求內容、回應內容、處理時間、狀態碼等關鍵資訊，並透過 request_id 實現請求追蹤。

```yaml
-
  id: eolinker.com:apinto:access_log
  name: access_log
  status: global  # 全域啟用，攔截所有請求
```

```yaml
access_log:
  id: eolinker.com:apinto:access_log
  name: access_log
  status: global
```

```go
var logFormatter = map[string]interface{}{
    "fields": []string{
        "$msec",                    // 時間戳記（毫秒）
        "$service",                 // 服務名稱
        "$provider",                // 提供者
        "$scheme as request_scheme", // 請求協議
        "$url as request_uri",      // 請求 URI
        "$host as request_host",    // 請求主機
        "$header as request_header", // 請求標頭
        "$remote_addr",             // 遠端地址
        "$request_body",            // 請求內容
        "$proxy_body",              // 代理請求內容
        "$proxy_method",            // 代理方法
        "$proxy_scheme",            // 代理協議
        "$proxy_uri",               // 代理 URI
        "$api",                     // API 路徑
        "$proxy_host",              // 代理主機
        "$proxy_header",            // 代理標頭
        "$proxy_addr",              // 代理地址
        "$response_header",         // 回應標頭
        "$response_headers",        // 所有回應標頭
        "$status",                  // 狀態碼
        "$content_type",            // 內容類型
        "$proxy_status",            // 代理狀態碼
        "$request_time",            // 請求時間
        "$response_time",           // 回應時間
        "$node",                    // 節點
        "$cluster",                 // 叢集
        "$application",             // 應用程式
        "$src_ip",                  // 來源 IP
        "$block_name as strategy",  // 策略名稱
        "$request_id",              // 請求 ID（用於追蹤）
        "$request_method",          // HTTP 方法
        "$authorization",           // 授權資訊
        "$response_body",           // 回應內容
        "$proxy_response_body",     // 代理回應內容
        "$ai_provider",             // AI 提供者
        "$ai_model",                // AI 模型
        "$ai_model_input_token",    // AI 輸入 token
        "$ai_model_output_token",   // AI 輸出 token
        "$ai_model_total_token",    // AI 總 token
    },
}
```

```go
func init() {
    log_driver.RegisterFactory("loki", &factory{})
}
```

```go
func NewDriver(config string) (*Driver, map[string]interface{}, error) {
    cfg := new(DriverConfig)
    err := json.Unmarshal([]byte(config), cfg)
    if err != nil {
        return nil, nil, err
    }
    // 驗證配置
    err = cfg.Check()
    if err != nil {
        return nil, nil, err
    }
    headers := map[string]string{}
    for _, h := range cfg.Header {
        headers[h.Key] = h.Value
    }
    return &Driver{
        url:     cfg.URL,  // Loki 伺服器地址
        headers: headers,   // HTTP 標頭
    }, map[string]interface{}{
        "url":     cfg.URL,
        "headers": headers,
    }, nil
}
```

```go
type LogDetail struct {
    Api                string      `json:"api"`
    // ... 其他欄位定義在 entity.go 中
}
```

```go
func ToLogItem(detail *LogDetail, msec int64) *log_driver.LogItem {
    return &log_driver.LogItem{
        ID:            detail.RequestId,
        Strategy:      detail.Strategy,
        Service:       detail.Provider,
        API:           detail.Api,
        Method:        detail.RequestMethod,
        Url:           detail.RequestUri,
        RemoteIP:      detail.SrcIp,
        Consumer:      detail.Application,
        Authorization: detail.Authorization,
        InputToken:    parseToInt64(detail.AIModelInputToken),
        OutputToken:   parseToInt64(detail.AIModelOutputToken),
        TotalToken:    parseToInt64(detail.AIModelTotalToken),
        AIProvider:    detail.AIProvider,
        AIModel:       detail.AIModel,
        StatusCode:    parseToInt64(detail.Status),
        ResponseTime:  parseToInt64(detail.RequestTime),
        Traffic:       int64(len(detail.ResponseBody) + len(detail.RequestBody)),
        RecordTime:    time.UnixMilli(msec),
    }
}
```

```shellscript
set_loki() {
  # 設置 loki 地址
  body='{"config":{"url":"'"${LokiAddress}"'"}}'
  path="/api/v1/log/loki"
  response=$(request_apipark "$path" "$body")
  # 從響應中提取 code
  code=$(echo "${response}" | grep '^{.*}$' | sed 's/.*"code":\([0-9]*\).*/\1/')
  if [ "$code" -eq 0 ]; then
    echo_pass "Set loki successfully"
  else
    echo_fail "Set loki failed: ${response}"
    exit 1
  fi
}
```

```go
func (i *imlLogModule) Save(ctx context.Context, driver string, input *log_dto.Save) error {
    factory, has := log_driver.GetFactory(driver)
    if !has {
        return errors.New("driver not found")
    }
    
    // ... 配置處理
    
    // 建立 driver 實例
    d, c, err := factory.Create(info.Config)
    if err != nil {
        return err
    }
    
    // 設定輸出屬性
    attr := make(map[string]interface{})
    attr["driver"] = driver
    attr["formatter"] = logFormatter  // 使用預定義的格式化器
    attr["labels"] = labels
    attr["method"] = "POST"
    attr["scopes"] = []string{"access_log"}
    attr["type"] = "json"
    
    // 推送配置到 Gateway
    err = dynamicClient.Online(txCtx, &gateway.DynamicRelease{
        BasicItem: &gateway.BasicItem{
            ID:          driver,
            Description: "collect access log",
            Version:     time.Now().Format("20060102150405"),
            Resource:    gateway.ProfessionOutput,
        },
        Attr: attr,
    })
    
    // 設定 driver
    log_driver.SetDriver(driver, d)
    
    // ... 啟動排程
}
```

```go
func (i *imlLogModule) initGateway(ctx context.Context, clusterId string, clientDriver gateway.IClientDriver) error {
    drivers := log_driver.Drivers()
    if len(drivers) < 1 {
        return nil
    }

    for _, driver := range drivers {
        factory, has := log_driver.GetFactory(driver)
        if !has {
            log_print.Errorf("driver %s not found", driver)
            continue
        }
        
        // 取得日誌來源配置
        info, err := i.service.GetLogSource(ctx, driver)
        if err != nil {
            log_print.Errorf("get log source %s error: %s", driver, err)
            continue
        }
        
        // 建立 driver
        d, c, err := factory.Create(info.Config)
        if err != nil {
            log_print.Errorf("create driver %s error: %s,config: %s", driver, err, info.Config)
            continue
        }
        
        log_driver.SetDriver(driver, d)
        
        // 取得動態客戶端
        dynamicClient, err := clientDriver.Dynamic(driver)
        if err != nil {
            log_print.Errorf("get dynamic client %s error: %s", driver, err)
            continue
        }
        
        // 設定屬性
        attr := make(map[string]interface{})
        attr["driver"] = driver
        attr["formatter"] = logFormatter
        attr["labels"] = labels
        attr["method"] = "POST"
        for k, v := range c {
            attr[k] = v
        }
        
        // 上線配置
        err = dynamicClient.Online(ctx, &gateway.DynamicRelease{
            BasicItem: &gateway.BasicItem{
                ID:          driver,
                Description: "collect access log",
                Version:     time.Now().Format("20060102150405"),
                Resource:    gateway.ProfessionOutput,
            },
            Attr: attr,
        })
    }
    
    return nil
}
```

```go
func send[T any](method string, uri string, headers map[string]string, queries url.Values, body string) ([]*T, error) {
    if queries != nil && len(queries) > 0 {
        uri = fmt.Sprintf("%s?%s", uri, queries.Encode())
    }
    
    // 建立 HTTP 請求
    req, err := http.NewRequest(method, uri, strings.NewReader(body))
    if err != nil {
        return nil, fmt.Errorf("failed to create request: %w,uri is %s", err, uri)
    }
    
    // 設定標頭
    for key, value := range headers {
        req.Header.Set(key, value)
    }
    
    log.DebugF("do request: %s", uri)
    doRequestTime := time.Now()
    
    // 發送請求
    resp, err := client.Do(req)
    if err != nil {
        return nil, fmt.Errorf("failed to send request: %w", err)
    }
    log.DebugF("do request spend time: %v", time.Now().Sub(doRequestTime))
    defer resp.Body.Close()
    
    // 讀取回應
    respData, err := io.ReadAll(resp.Body)
    if err != nil {
        return nil, fmt.Errorf("failed to read response: %w", err)
    }
    
    // 處理錯誤狀態碼
    if resp.StatusCode > 399 {
        return nil, fmt.Errorf("failed to send request: %s,body is %s", resp.Status, string(respData))
    }
    
    // 解析回應
    result := new(Response[T])
    err = json.Unmarshal(respData, result)
    if err != nil {
        return nil, fmt.Errorf("failed to decode response: %w,body is %s", err, string(respData))
    }
    return result.Data.Result, nil
}
```

```go
func (d *Driver) LogInfo(clusterId string, id string) (*log_driver.LogItem, error) {
    // 查詢特定請求 ID 的日誌
    // ... 實作細節
}

func (d *Driver) Logs(clusterId string, conditions map[string]string, start time.Time, end time.Time, limit int, offset int64) ([]*log_driver.LogItem, int64, error) {
    // 根據條件查詢日誌列表
    // ... 實作細節
}
```

---

**User**

INSERT INTO `log_record` (`uuid`,`driver`,`service`,`api`,`strategy`,`method`,`url`,`remote_ip`,`consumer`,`authorization`,`input_token`,`output_token`,`total_token`,`ai_provider`,`ai_model`,`status_code`,`response_time`,`traffic`,`record_time`) VALUES ('abcb664d-7b73-4243-b94a-7945dbdc3dca','loki','a00ca1fc-c8a5-49a7-968c-3f7be172a519','8c3786b2-1c7c-4827-b053-e800ad2d00b7','','GET','http://192.168.31.180:31899/4e5fdf32/health2','127.0.0.1','c58f4e79-4da9-4828-b9e6-9ebf8a8a530b','2ad41626-744f-4cb6-aa01-572176d07c87',0,0,0,'','',200,4,46,'2025-10-14 15:40:07.136')
程式在哪裡對 log_record 做寫入?

---

**Cursor**

我來幫您找出程式碼中對 `log_record` 資料表進行寫入的位置。

現在讓我查找實際進行寫入操作的程式碼：

現在讓我查看實際的寫入操作：

現在讓我查看是誰呼叫 `InsertLog` 函數：

讓我查看 module/log/iml.go 中如何呼叫 InsertLog：

現在讓我查看 `scheduleUpdateLogRecord` 函數，了解定時任務如何運作：

現在讓我查看 Loki driver 如何從 Loki 取得日誌記錄：

## 完整的 log_record 寫入流程

根據程式碼分析，`log_record` 資料表的寫入流程如下：

### 1. 資料表定義
**位置：** `/home/chad/APIPark-0909/stores/log-source/model.go:26-55`
```go
type LogRecord struct {
    Id            int64     `gorm:"column:id;..."`
    UUID          string    `gorm:"column:uuid;..."`  // 請求唯一ID
    Driver        string    `gorm:"column:driver;..."` // 日誌驅動(loki)
    Service       string    `gorm:"column:service;..."` // 服務ID
    API           string    `gorm:"column:api;..."`     // API ID
    Strategy      string    `gorm:"column:strategy;..."` // 策略ID
    Method        string    `gorm:"column:method;..."`   // HTTP方法
    Url           string    `gorm:"column:url;..."`      // 請求URL
    RemoteIP      string    `gorm:"column:remote_ip;..."` // 客戶端IP
    Consumer      string    `gorm:"column:consumer;..."`  // 消費者ID
    Authorization string    `gorm:"column:authorization;..."` // 授權ID
    // ... AI相關欄位
    StatusCode    int64     `gorm:"column:status_code;..."` // 狀態碼
    ResponseTime  int64     `gorm:"column:response_time;..."` // 回應時間
    Traffic       int64     `gorm:"column:traffic;..."`    // 流量
    RecordTime    time.Time `gorm:"column:record_time;..."` // 記錄時間
}

func (c *LogRecord) TableName() string {
    return "log_record"
}
```

### 2. 寫入函數
**位置：** `/home/chad/APIPark-0909/service/log/iml.go:64-97`
```go
func (i *imlLogService) InsertLog(ctx context.Context, driver string, input *InsertLog) error {
    // 判斷日誌是否已存在，若已存在，則不插入（避免重複）
    _, err := i.logRecordStore.First(ctx, map[string]interface{}{"uuid": input.ID})
    if err != nil {
        if !errors.Is(err, gorm.ErrRecordNotFound) {
            log_print.Errorf("get log record %s error: %s", input.ID, err)
            return err
        }
        // 執行實際的資料庫插入操作
        return i.logRecordStore.Insert(ctx, &log_source.LogRecord{
            UUID:          input.ID,
            Driver:        input.Driver,
            Service:       input.Service,
            API:           input.API,
            Strategy:      input.Strategy,
            Method:        input.Method,
            Url:           input.Url,
            RemoteIP:      input.RemoteIP,
            Consumer:      input.Consumer,
            Authorization: input.Authorization,
            InputToken:    input.InputToken,
            OutputToken:   input.OutputToken,
            TotalToken:    input.TotalToken,
            AIProvider:    input.AIProvider,
            AIModel:       input.AIModel,
            StatusCode:    input.StatusCode,
            ResponseTime:  input.ResponseTime,
            Traffic:       input.Traffic,
            RecordTime:    input.RecordTime,
        })
    }
    return nil
}
```

### 3. 定時同步機制
**位置：** `/home/chad/APIPark-0909/module/log/iml.go:260-357`

系統使用兩個 goroutine 進行日誌同步：

#### 3.1 歷史日誌同步 (每分鐘執行)
```go
func (i *imlLogModule) scheduleUpdateLogRecord(ctx context.Context) {
    // 取得 Loki driver
    driver, has := log_driver.GetDriver("loki")
    
    // 計算時間範圍（預設從 7 天前開始）
    now := time.Now()
    before90Days := now.Add(-7 * 24 * time.Hour)
    
    // 歷史日誌同步 goroutine
    go func() {
        ticket := time.NewTicker(1 * time.Minute) // 每分鐘執行
        for {
            select {
            case <-ticket.C:
                // 批次處理：每次處理一天的日誌
                if now.Sub(beginTime) > oneDay {
                    endTime := beginTime.Add(oneDay)
                    err = i.updateLogRecord(ctx, driver, beginTime, endTime)
                    // 更新最後拉取時間
                    i.service.UpdateLogSource(ctx, "loki", &log.Save{
                        LastPullTime: &endTime,
                    })
                    beginTime = endTime
                }
            }
        }
    }()
```

#### 3.2 即時日誌同步 (每10秒執行)
```go
    // 即時日誌同步 goroutine
    go func() {
        ticket := time.NewTicker(10 * time.Second) // 每10秒執行
        for {
            select {
            case <-ticket.C:
                end := time.Now()
                start := end.Add(-1 * time.Minute) // 取最近1分鐘的日誌
                err = i.updateLogRecord(ctx, driver, start, end)
                if historyFinish {
                    // 更新最後拉取時間
                    i.service.UpdateLogSource(ctx, "loki", &log.Save{
                        LastPullTime: &end,
                    })
                }
            }
        }
    }()
```

### 4. 實際同步邏輯
**位置：** `/home/chad/APIPark-0909/module/log/iml.go:361-399`
```go
func (i *imlLogModule) updateLogRecord(ctx context.Context, driver log_driver.ILogDriver, start, end time.Time) error {
    // 從 Loki 取得日誌記錄
    logs, err := driver.LogRecords(c.Cluster, start, end)
    if err != nil {
        return fmt.Errorf("get log records error: %s", err)
    }
    
    // 逐筆插入到資料庫
    for _, l := range logs {
        err = i.service.InsertLog(ctx, "loki", &log.InsertLog{
            ID:            l.ID,  // 對應 UUID 欄位
            Driver:        "loki",
            Strategy:      l.Strategy,
            API:           l.API,
            Service:       l.Service,
            Method:        l.Method,
            Url:           l.Url,
            RemoteIP:      l.RemoteIP,
            Consumer:      l.Consumer,
            Authorization: l.Authorization,
            // ... 其他欄位
            RecordTime:    l.RecordTime,
        })
        if err != nil {
            eosc_log.Errorf("insert log record error: %s,log id: %s", err, l.ID)
            continue // 錯誤時繼續處理下一筆
        }
    }
    return nil
}
```

### 5. 從 Loki 查詢日誌
**位置：** `/home/chad/APIPark-0909/log-driver/loki/loki.go:161-177`
```go
func (d *Driver) LogRecords(clusterId string, start time.Time, end time.Time) ([]*log_driver.LogItem, error) {
    queries := url.Values{}
    // 構建 LogQL 查詢語句
    queries.Set("query", fmt.Sprintf("{cluster=\"%s\"} | json", clusterId))
    queries.Set("direction", "backward")
    queries.Set("start", strconv.FormatInt(start.UnixNano(), 10))
    queries.Set("end", strconv.FormatInt(end.UnixNano(), 10))
    
    // 向 Loki 發送查詢請求
    logs, err := d.recuseLogs(queries, end, 1)
    if err != nil {
        return nil, err
    }
    return logs, nil
}
```

## 總結

`log_record` 資料表的寫入流程：

1. **Apinto Gateway** 透過 `access_log` 插件即時將 API 日誌推送到 **Loki**
2. **定時任務**（每10秒）從 Loki 拉取最近1分鐘的日誌
3. **`updateLogRecord`** 函數呼叫 Loki Driver 的 `LogRecords` 方法查詢日誌
4. **`InsertLog`** 函數檢查 UUID 避免重複，然後插入到 MySQL 的 `log_record` 表
5. 系統同時運行**歷史日誌同步**（補齊過去7天）和**即時日誌同步**（最新日誌）

這種設計實現了：
- **即時性**：API 日誌先存到 Loki（高效能時序資料庫）
- **持久性**：定期同步到 MySQL 進行長期儲存
- **去重機制**：透過 UUID 檢查避免重複寫入
- **容錯性**：單筆錯誤不影響其他日誌的處理

```go
type LogRecord struct {
    Id            int64     `gorm:"column:id;..."`
    UUID          string    `gorm:"column:uuid;..."`  // 請求唯一ID
    Driver        string    `gorm:"column:driver;..."` // 日誌驅動(loki)
    Service       string    `gorm:"column:service;..."` // 服務ID
    API           string    `gorm:"column:api;..."`     // API ID
    Strategy      string    `gorm:"column:strategy;..."` // 策略ID
    Method        string    `gorm:"column:method;..."`   // HTTP方法
    Url           string    `gorm:"column:url;..."`      // 請求URL
    RemoteIP      string    `gorm:"column:remote_ip;..."` // 客戶端IP
    Consumer      string    `gorm:"column:consumer;..."`  // 消費者ID
    Authorization string    `gorm:"column:authorization;..."` // 授權ID
    // ... AI相關欄位
    StatusCode    int64     `gorm:"column:status_code;..."` // 狀態碼
    ResponseTime  int64     `gorm:"column:response_time;..."` // 回應時間
    Traffic       int64     `gorm:"column:traffic;..."`    // 流量
    RecordTime    time.Time `gorm:"column:record_time;..."` // 記錄時間
}

func (c *LogRecord) TableName() string {
    return "log_record"
}
```

```go
func (i *imlLogService) InsertLog(ctx context.Context, driver string, input *InsertLog) error {
    // 判斷日誌是否已存在，若已存在，則不插入（避免重複）
    _, err := i.logRecordStore.First(ctx, map[string]interface{}{"uuid": input.ID})
    if err != nil {
        if !errors.Is(err, gorm.ErrRecordNotFound) {
            log_print.Errorf("get log record %s error: %s", input.ID, err)
            return err
        }
        // 執行實際的資料庫插入操作
        return i.logRecordStore.Insert(ctx, &log_source.LogRecord{
            UUID:          input.ID,
            Driver:        input.Driver,
            Service:       input.Service,
            API:           input.API,
            Strategy:      input.Strategy,
            Method:        input.Method,
            Url:           input.Url,
            RemoteIP:      input.RemoteIP,
            Consumer:      input.Consumer,
            Authorization: input.Authorization,
            InputToken:    input.InputToken,
            OutputToken:   input.OutputToken,
            TotalToken:    input.TotalToken,
            AIProvider:    input.AIProvider,
            AIModel:       input.AIModel,
            StatusCode:    input.StatusCode,
            ResponseTime:  input.ResponseTime,
            Traffic:       input.Traffic,
            RecordTime:    input.RecordTime,
        })
    }
    return nil
}
```

```go
func (i *imlLogModule) scheduleUpdateLogRecord(ctx context.Context) {
    // 取得 Loki driver
    driver, has := log_driver.GetDriver("loki")
    
    // 計算時間範圍（預設從 7 天前開始）
    now := time.Now()
    before90Days := now.Add(-7 * 24 * time.Hour)
    
    // 歷史日誌同步 goroutine
    go func() {
        ticket := time.NewTicker(1 * time.Minute) // 每分鐘執行
        for {
            select {
            case <-ticket.C:
                // 批次處理：每次處理一天的日誌
                if now.Sub(beginTime) > oneDay {
                    endTime := beginTime.Add(oneDay)
                    err = i.updateLogRecord(ctx, driver, beginTime, endTime)
                    // 更新最後拉取時間
                    i.service.UpdateLogSource(ctx, "loki", &log.Save{
                        LastPullTime: &endTime,
                    })
                    beginTime = endTime
                }
            }
        }
    }()
```

```go
    // 即時日誌同步 goroutine
    go func() {
        ticket := time.NewTicker(10 * time.Second) // 每10秒執行
        for {
            select {
            case <-ticket.C:
                end := time.Now()
                start := end.Add(-1 * time.Minute) // 取最近1分鐘的日誌
                err = i.updateLogRecord(ctx, driver, start, end)
                if historyFinish {
                    // 更新最後拉取時間
                    i.service.UpdateLogSource(ctx, "loki", &log.Save{
                        LastPullTime: &end,
                    })
                }
            }
        }
    }()
```

```go
func (i *imlLogModule) updateLogRecord(ctx context.Context, driver log_driver.ILogDriver, start, end time.Time) error {
    // 從 Loki 取得日誌記錄
    logs, err := driver.LogRecords(c.Cluster, start, end)
    if err != nil {
        return fmt.Errorf("get log records error: %s", err)
    }
    
    // 逐筆插入到資料庫
    for _, l := range logs {
        err = i.service.InsertLog(ctx, "loki", &log.InsertLog{
            ID:            l.ID,  // 對應 UUID 欄位
            Driver:        "loki",
            Strategy:      l.Strategy,
            API:           l.API,
            Service:       l.Service,
            Method:        l.Method,
            Url:           l.Url,
            RemoteIP:      l.RemoteIP,
            Consumer:      l.Consumer,
            Authorization: l.Authorization,
            // ... 其他欄位
            RecordTime:    l.RecordTime,
        })
        if err != nil {
            eosc_log.Errorf("insert log record error: %s,log id: %s", err, l.ID)
            continue // 錯誤時繼續處理下一筆
        }
    }
    return nil
}
```

```go
func (d *Driver) LogRecords(clusterId string, start time.Time, end time.Time) ([]*log_driver.LogItem, error) {
    queries := url.Values{}
    // 構建 LogQL 查詢語句
    queries.Set("query", fmt.Sprintf("{cluster=\"%s\"} | json", clusterId))
    queries.Set("direction", "backward")
    queries.Set("start", strconv.FormatInt(start.UnixNano(), 10))
    queries.Set("end", strconv.FormatInt(end.UnixNano(), 10))
    
    // 向 Loki 發送查詢請求
    logs, err := d.recuseLogs(queries, end, 1)
    if err != nil {
        return nil, err
    }
    return logs, nil
}
```

