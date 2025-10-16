# API to MCP 實現流程分析
_Exported on 2025/10/16 at 16:14:22 [GMT+8] from Cursor (1.7.46)_

---

**User**

API to MCP 在專案中是如何實現的? 請分析程式流程/邏輯，並用 mermaid 格式表達流程

---

**Cursor**

我來分析專案中 API to MCP 的實現流程。首先讓我探索專案結構，了解相關的程式碼。


現在讓我進一步了解 MCP 模組和工具的實現細節：


現在讓我查看前端如何與 MCP 服務互動：


現在讓我查看 MCP 的 OpenAPI 轉換邏輯：


現在讓我查看發布流程中如何設置 MCP 服務：


基於我對程式碼的分析，現在我可以為您創建 API to MCP 實現流程的 Mermaid 圖表。讓我創建一個詳細的流程圖：


讓我用文字描述並提供 Mermaid 格式的流程圖：

## API to MCP 實現流程分析

基於程式碼分析，APIPark 專案中的 API to MCP 實現包含以下主要組件和流程：

### 核心組件

1. **MCP Server** (`mcp-server/`) - 核心 MCP 服務實現
2. **MCP Controller** (`controller/mcp/`) - HTTP 請求處理
3. **MCP Module** (`module/mcp/`) - 業務邏輯處理
4. **前端整合** (`frontend/packages/core/src/pages/mcpService/`) - 用戶界面

### 主要流程

```mermaid
graph TB
    subgraph "前端層"
        A[用戶界面] --> B[MCP 連接配置]
        B --> C[SSE 客戶端連接]
        C --> D[工具調用請求]
    end

    subgraph "API 路由層"
        E[Gin Router] --> F[Service MCP API]
        E --> G[Global MCP API]
        E --> H[App MCP API]
    end

    subgraph "控制器層"
        F --> I[ServiceHandleSSE/Message]
        G --> J[GlobalMCPHandle]
        H --> K[AppMCPHandle]
        
        I --> L[API Key 驗證]
        L --> M[Session 管理]
        M --> N[MCP Server 路由]
    end

    subgraph "MCP Server 核心"
        N --> O[Server 路由分發]
        O --> P[API SSE Handler]
        O --> Q[OpenAPI SSE Handler]
        O --> R[OpenAPI Stream Handler]
        
        P --> S[工具執行]
        Q --> S
        R --> S
    end

    subgraph "工具層"
        S --> T[Services 工具]
        S --> U[APIs 工具]
        S --> V[Invoke 工具]
        S --> W[動態 API 工具]
    end

    subgraph "業務邏輯層"
        T --> X[服務列表查詢]
        U --> Y[API 文檔獲取]
        V --> Z[API 調用執行]
        W --> AA[OpenAPI 轉換]
    end

    subgraph "數據層"
        X --> BB[服務數據庫]
        Y --> CC[API 文檔存儲]
        Z --> DD[網關調用]
        AA --> EE[OpenAPI 規範解析]
    end

    subgraph "發布流程"
        FF[服務發布] --> GG[檢查 MCP 啟用]
        GG --> HH[獲取 OpenAPI 文檔]
        HH --> II[轉換為 MCP 工具]
        II --> JJ[註冊到 MCP Server]
    end

    style A fill:#e1f5fe
    style O fill:#f3e5f5
    style S fill:#e8f5e8
    style AA fill:#fff3e0
```

### 詳細實現流程

```mermaid
sequenceDiagram
    participant U as 用戶
    participant F as 前端
    participant C as MCP Controller
    participant S as MCP Server
    participant M as MCP Module
    participant G as 網關

    Note over U,G: 1. 服務發布流程
    U->>F: 發布服務
    F->>C: 發布請求
    C->>M: 檢查 EnableMCP
    M->>S: SetServerByOpenapi()
    S->>S: 解析 OpenAPI 規範
    S->>S: 生成 MCP 工具
    S->>S: 註冊工具到服務器

    Note over U,G: 2. MCP 連接建立
    U->>F: 配置 MCP 連接
    F->>C: GET /api/v1/mcp/service/{id}/sse
    C->>C: 驗證 API Key
    C->>S: 建立 SSE 連接
    S->>F: 返回連接狀態

    Note over U,G: 3. 工具調用流程
    U->>F: 選擇工具
    F->>C: POST /api/v1/mcp/service/{id}/message
    C->>S: 轉發工具調用
    S->>M: 執行對應工具
    M->>G: 調用實際 API
    G->>M: 返回 API 響應
    M->>S: 返回工具結果
    S->>C: 返回 MCP 響應
    C->>F: 返回結果
    F->>U: 顯示結果
```

### 關鍵技術特點

1. **多層架構**：前端 → 控制器 → MCP Server → 工具 → 業務邏輯
2. **SSE 通信**：使用 Server-Sent Events 進行實時通信
3. **動態工具生成**：從 OpenAPI 規範自動生成 MCP 工具
4. **會話管理**：通過 sessionId 管理用戶會話和 API Key
5. **多語言支持**：支持不同語言的工具描述
6. **權限控制**：API Key 驗證和服務訂閱檢查

### 主要 API 端點

- `/api/v1/mcp/service/{serviceId}/sse` - 服務級 MCP SSE 連接
- `/api/v1/mcp/service/{serviceId}/message` - 服務級 MCP 消息處理
- `/api/v1/mcp/global/sse` - 全局 MCP SSE 連接
- `/api/v1/mcp/global/message` - 全局 MCP 消息處理
- `/api/v1/mcp/app/{app}/sse` - 應用級 MCP SSE 連接
- `/openapi/v1/mcp/service/{serviceId}/sse` - OpenAPI 格式的 MCP 連接

這個實現將傳統的 REST API 轉換為 MCP 協議，使得 AI 助手可以直接調用和管理 API 服務。

```plaintext
graph TB
    subgraph "前端層"
        A[用戶界面] --> B[MCP 連接配置]
        B --> C[SSE 客戶端連接]
        C --> D[工具調用請求]
    end

    subgraph "API 路由層"
        E[Gin Router] --> F[Service MCP API]
        E --> G[Global MCP API]
        E --> H[App MCP API]
    end

    subgraph "控制器層"
        F --> I[ServiceHandleSSE/Message]
        G --> J[GlobalMCPHandle]
        H --> K[AppMCPHandle]
        
        I --> L[API Key 驗證]
        L --> M[Session 管理]
        M --> N[MCP Server 路由]
    end

    subgraph "MCP Server 核心"
        N --> O[Server 路由分發]
        O --> P[API SSE Handler]
        O --> Q[OpenAPI SSE Handler]
        O --> R[OpenAPI Stream Handler]
        
        P --> S[工具執行]
        Q --> S
        R --> S
    end

    subgraph "工具層"
        S --> T[Services 工具]
        S --> U[APIs 工具]
        S --> V[Invoke 工具]
        S --> W[動態 API 工具]
    end

    subgraph "業務邏輯層"
        T --> X[服務列表查詢]
        U --> Y[API 文檔獲取]
        V --> Z[API 調用執行]
        W --> AA[OpenAPI 轉換]
    end

    subgraph "數據層"
        X --> BB[服務數據庫]
        Y --> CC[API 文檔存儲]
        Z --> DD[網關調用]
        AA --> EE[OpenAPI 規範解析]
    end

    subgraph "發布流程"
        FF[服務發布] --> GG[檢查 MCP 啟用]
        GG --> HH[獲取 OpenAPI 文檔]
        HH --> II[轉換為 MCP 工具]
        II --> JJ[註冊到 MCP Server]
    end

    style A fill:#e1f5fe
    style O fill:#f3e5f5
    style S fill:#e8f5e8
    style AA fill:#fff3e0
```

```plaintext
sequenceDiagram
    participant U as 用戶
    participant F as 前端
    participant C as MCP Controller
    participant S as MCP Server
    participant M as MCP Module
    participant G as 網關

    Note over U,G: 1. 服務發布流程
    U->>F: 發布服務
    F->>C: 發布請求
    C->>M: 檢查 EnableMCP
    M->>S: SetServerByOpenapi()
    S->>S: 解析 OpenAPI 規範
    S->>S: 生成 MCP 工具
    S->>S: 註冊工具到服務器

    Note over U,G: 2. MCP 連接建立
    U->>F: 配置 MCP 連接
    F->>C: GET /api/v1/mcp/service/{id}/sse
    C->>C: 驗證 API Key
    C->>S: 建立 SSE 連接
    S->>F: 返回連接狀態

    Note over U,G: 3. 工具調用流程
    U->>F: 選擇工具
    F->>C: POST /api/v1/mcp/service/{id}/message
    C->>S: 轉發工具調用
    S->>M: 執行對應工具
    M->>G: 調用實際 API
    G->>M: 返回 API 響應
    M->>S: 返回工具結果
    S->>C: 返回 MCP 響應
    C->>F: 返回結果
    F->>U: 顯示結果
```

我看到您遇到了 MCP 工具調用的超時錯誤。從錯誤訊息 `"MCP error -32001: Request timed out"` 可以看出，這是在調用 "health2" 工具時發生的超時問題。

讓我分析一下可能的原因和解決方案：


根據程式碼分析，我發現了 MCP 超時問題的幾個可能原因和解決方案：

## 問題分析

### 1. 超時設定問題
從程式碼中可以看到幾個關鍵的超時設定：

**前端超時設定**：
- 在 `useConnection.ts` 中，預設的 `requestTimeout` 可能過短
- 第 108 行：`options?.timeout ?? requestTimeout` 控制請求超時

**後端 HTTP 客戶端超時**：
- 在 `gateway/admin/http.go` 第 17 行：`Timeout: 5 * time.Second` - 只有 5 秒超時
- 在 `module/mcp/iml.go` 第 199 行：`client = &http.Client{}` - 沒有設定超時

### 2. 可能的原因

1. **網關調用超時**：health2 工具調用實際的 API 時，目標服務響應時間超過 5 秒
2. **網路延遲**：MCP 服務到目標 API 的網路連接問題
3. **目標服務問題**：health2 對應的實際 API 服務可能響應緩慢或不可用

## 解決方案

### 1. 增加 HTTP 客戶端超時時間


```go
package mcp

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"

	"github.com/APIParkLab/APIPark/service/subscribe"

	"github.com/getkin/kin-openapi/openapi3"

	"gorm.io/gorm"

	"github.com/APIParkLab/APIPark/service/release"

	mcp_dto "github.com/APIParkLab/APIPark/module/mcp/dto"
	"github.com/eolinker/go-common/utils"

	api_doc "github.com/APIParkLab/APIPark/service/api-doc"

	application_authorization "github.com/APIParkLab/APIPark/service/application-authorization"

	"github.com/APIParkLab/APIPark/service/service"

	"github.com/mark3labs/mcp-go/mcp"
)

var _ IMcpModule = (*imlMcpModule)(nil)

var (
	openapi3Loader = openapi3.NewLoader()
)

type imlMcpModule struct {
	serviceService          service.IServiceService                         `autowired:""`
	appService              service.IServiceService                         `autowired:""`
	appAuthorizationService application_authorization.IAuthorizationService `autowired:""`
	apiDocService           api_doc.IAPIDocService                          `autowired:""`
	subscriberService       subscribe.ISubscribeService                     `autowired:""`
	releaseService          release.IReleaseService                         `autowired:""`
}

func (i *imlMcpModule) subscribeServiceIds(ctx context.Context, appId string) ([]string, error) {
	subscribes, err := i.subscriberService.SubscriptionsByApplication(ctx, appId)
	if err != nil {
		return nil, fmt.Errorf("get subscriber error: %w,app id is %s", err, appId)
	}
	serviceIds := utils.SliceToSlice(subscribes, func(s *subscribe.Subscribe) string {
		return s.Service
	}, func(s *subscribe.Subscribe) bool {
		return s.ApplyStatus == subscribe.ApplyStatusSubscribe
	})
	if len(serviceIds) == 0 {
		return nil, fmt.Errorf("no subscriber found,app id is %s", appId)
	}
	return serviceIds, nil
}

func (i *imlMcpModule) Services(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {

	keyword, _ := req.GetArguments()["keyword"].(string)
	appId := utils.Label(ctx, "app")
	condition := map[string]interface{}{
		"as_server": true,
	}
	if appId != "" {
		serviceIds, err := i.subscribeServiceIds(ctx, appId)
		if err != nil {
			return nil, fmt.Errorf("get subscriber service ids error: %w,app id is %s", err, appId)
		}
		condition["uuid"] = serviceIds
	}

	list, err := i.serviceService.Search(ctx, keyword, condition, "update_at desc")
	if err != nil {
		return nil, fmt.Errorf("search service error: %w", err)
	}
	if len(list) == 0 {
		list, err = i.serviceService.Search(ctx, "", condition, "update_at desc")
		if err != nil {
			return nil, fmt.Errorf("search service error: %w", err)
		}
	}
	result := make([]*mcp_dto.Service, 0, len(list))
	for _, s := range list {
		serviceRelease, err := i.releaseService.GetRunning(ctx, s.Id)
		if err != nil {
			if !errors.Is(err, gorm.ErrRecordNotFound) {
				return nil, fmt.Errorf("get service release error: %w,service id is %s", err, s.Id)
			}
			continue
		}
		_, _, apiDocRelease, _, _, err := i.releaseService.GetReleaseInfos(ctx, serviceRelease.UUID)
		if err != nil {
			if !errors.Is(err, gorm.ErrRecordNotFound) {
				return nil, fmt.Errorf("get service release info error: %w,service id is %s", err, s.Id)
			}
			continue
		}
		commit, err := i.apiDocService.GetDocCommit(ctx, apiDocRelease.Commit)
		if err != nil {
			if !errors.Is(err, gorm.ErrRecordNotFound) {
				return nil, fmt.Errorf("get api doc release error: %w,service id is %s", err, s.Id)
			}
			continue
		}
		T, err := openapi3Loader.LoadFromData([]byte(commit.Data.Content))
		if err != nil {
			return nil, fmt.Errorf("load openapi3 error: %w,service id is %s", err, s.Id)
		}
		apis := make([]*mcp_dto.API, 0, len(T.Paths.Map()))
		for path, v := range T.Paths.Map() {
			for method, opt := range v.Operations() {
				apis = append(apis, &mcp_dto.API{
					Name:        opt.Summary,
					Method:      method,
					Path:        path,
					Description: opt.Description,
				})
			}
		}
		result = append(result, &mcp_dto.Service{
			Id:          s.Id,
			Name:        s.Name,
			Description: s.Name,
			ServiceKind: s.Kind.String(),
			CreateTime:  s.CreateTime,
			UpdateTime:  s.UpdateTime,
			Apis:        apis,
		})
	}
	data, _ := json.Marshal(result)
	return mcp.NewToolResultText(string(data)), nil

}

func (i *imlMcpModule) APIs(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	serviceId, _ := req.GetArguments()["service"].(string)
	if serviceId == "" {
		return nil, fmt.Errorf("service id is empty")
	}
	s, err := i.serviceService.Get(ctx, serviceId)
	if err != nil {
		return nil, fmt.Errorf("get service error: %w,service id is %s", err, serviceId)
	}
	appId := utils.Label(ctx, "app")
	if appId != "" {
		subscribers, err := i.subscriberService.ListByApplication(ctx, serviceId, appId)
		if err != nil {
			return nil, fmt.Errorf("get subscriber error: %w,app id is %s", err, appId)
		}
		if len(subscribers) < 1 || subscribers[0].ApplyStatus != subscribe.ApplyStatusSubscribe {
			return nil, fmt.Errorf("no subscriber found,app id is %s", appId)
		}
	}

	serviceRelease, err := i.releaseService.GetRunning(ctx, serviceId)
	if err != nil {
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, fmt.Errorf("get service release error: %w,service id is %s", err, s.Id)
		}
		return nil, fmt.Errorf("no service found,service id is %s", serviceId)
	}
	_, _, apiDocRelease, _, _, err := i.releaseService.GetReleaseInfos(ctx, serviceRelease.UUID)
	if err != nil {
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, fmt.Errorf("get service release info error: %w,service id is %s", err, s.Id)
		}
		return nil, fmt.Errorf("no service found,service id is %s", serviceId)
	}
	commit, err := i.apiDocService.GetDocCommit(ctx, apiDocRelease.Commit)
	if err != nil {
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, fmt.Errorf("get api doc release error: %w,service id is %s", err, s.Id)
		}
		return nil, fmt.Errorf("no service found,service id is %s", serviceId)
	}
	T, err := openapi3Loader.LoadFromData([]byte(commit.Data.Content))
	if err != nil {
		return nil, fmt.Errorf("load openapi3 error: %w,service id is %s", err, s.Id)
	}

	result := &mcp_dto.ServiceAPI{
		ServiceID:   serviceId,
		ServiceName: s.Name,
		APIDoc:      T,
	}
	data, _ := json.Marshal(result)
	return mcp.NewToolResultText(string(data)), nil
}

var (
	client = &http.Client{
		Timeout: 30 * time.Second, // 增加超時時間到 30 秒
	}
)

func (i *imlMcpModule) Invoke(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	gatewayInvoke := utils.GatewayInvoke(ctx)

	if gatewayInvoke == "" {
		return nil, fmt.Errorf("gateway invoke is required")
	}
	u, err := url.Parse(gatewayInvoke)
	if err != nil {
		return nil, fmt.Errorf("parse gateway invoke error: %w", err)
	}
	if u.Scheme == "" {
		u.Scheme = "http"
	}

	path, ok := req.GetArguments()["path"].(string)
	if !ok {
		return nil, fmt.Errorf("invalid path")
	}
	u.Path = fmt.Sprintf("%s/%s", strings.TrimSuffix(u.Path, "/"), strings.TrimPrefix(path, "/"))

	method, ok := req.GetArguments()["method"].(string)
	if !ok {
		method = "GET"
	}
	queryParam := url.Values{}
	query, ok := req.GetArguments()["query"].(map[string]interface{})
	if ok {
		for k, v := range query {
			switch v := v.(type) {
			case string:
				queryParam.Add(k, v)
			case []string:
				for _, value := range v {
					queryParam.Add(k, value)
				}
			case float64:
				queryParam.Add(k, strconv.FormatFloat(v, 'f', -1, 64))
			default:
				return nil, fmt.Errorf("invalid query param type: %T", v)
			}
		}
	}
	u.RawQuery = queryParam.Encode()
	headerParam := http.Header{}
	header, ok := req.GetArguments()["header"].(map[string]interface{})
	if ok {
		for k, v := range header {
			switch v := v.(type) {
			case string:
				headerParam.Set(k, v)
			case []string:
				for _, value := range v {
					headerParam.Set(k, value)
				}
			default:
				return nil, fmt.Errorf("invalid header param type: %T", v)
			}
		}
	}

	body, ok := req.GetArguments()["body"].(string)
	if !ok {
		body = ""
	}

	contentType, ok := req.GetArguments()["content-type"].(string)
	if !ok {
		contentType = "application/json"
	}
	request, err := http.NewRequest(method, u.String(), strings.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("new request error: %w", err)
	}
	request.Header = headerParam
	request.Header.Set("Content-Type", contentType)
	apikey := utils.Label(ctx, "apikey")

	if apikey != "" {
		appId := utils.Label(ctx, "app")
		if appId == "" {
			request.Header.Set("Authorization", utils.Md5(apikey))
		} else {
			request.Header.Set("Authorization", apikey)
		}
	}

	resp, err := client.Do(request)
	if err != nil {
		return nil, fmt.Errorf("request error: %w", err)
	}
	defer resp.Body.Close()

	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read response error: %w", err)
	}
	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("response error: %s", string(data))
	}
	return mcp.NewToolResultText(string(data)), nil
}

```

需要添加 time 包的導入：


```go
package mcp

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/APIParkLab/APIPark/service/subscribe"

	"github.com/getkin/kin-openapi/openapi3"

	"gorm.io/gorm"

	"github.com/APIParkLab/APIPark/service/release"

	mcp_dto "github.com/APIParkLab/APIPark/module/mcp/dto"
	"github.com/eolinker/go-common/utils"

	api_doc "github.com/APIParkLab/APIPark/service/api-doc"

	application_authorization "github.com/APIParkLab/APIPark/service/application-authorization"

	"github.com/APIParkLab/APIPark/service/service"

	"github.com/mark3labs/mcp-go/mcp"
)

var _ IMcpModule = (*imlMcpModule)(nil)

var (
	openapi3Loader = openapi3.NewLoader()
)

type imlMcpModule struct {
	serviceService          service.IServiceService                         `autowired:""`
	appService              service.IServiceService                         `autowired:""`
	appAuthorizationService application_authorization.IAuthorizationService `autowired:""`
	apiDocService           api_doc.IAPIDocService                          `autowired:""`
	subscriberService       subscribe.ISubscribeService                     `autowired:""`
	releaseService          release.IReleaseService                         `autowired:""`
}

func (i *imlMcpModule) subscribeServiceIds(ctx context.Context, appId string) ([]string, error) {
	subscribes, err := i.subscriberService.SubscriptionsByApplication(ctx, appId)
	if err != nil {
		return nil, fmt.Errorf("get subscriber error: %w,app id is %s", err, appId)
	}
	serviceIds := utils.SliceToSlice(subscribes, func(s *subscribe.Subscribe) string {
		return s.Service
	}, func(s *subscribe.Subscribe) bool {
		return s.ApplyStatus == subscribe.ApplyStatusSubscribe
	})
	if len(serviceIds) == 0 {
		return nil, fmt.Errorf("no subscriber found,app id is %s", appId)
	}
	return serviceIds, nil
}

func (i *imlMcpModule) Services(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {

	keyword, _ := req.GetArguments()["keyword"].(string)
	appId := utils.Label(ctx, "app")
	condition := map[string]interface{}{
		"as_server": true,
	}
	if appId != "" {
		serviceIds, err := i.subscribeServiceIds(ctx, appId)
		if err != nil {
			return nil, fmt.Errorf("get subscriber service ids error: %w,app id is %s", err, appId)
		}
		condition["uuid"] = serviceIds
	}

	list, err := i.serviceService.Search(ctx, keyword, condition, "update_at desc")
	if err != nil {
		return nil, fmt.Errorf("search service error: %w", err)
	}
	if len(list) == 0 {
		list, err = i.serviceService.Search(ctx, "", condition, "update_at desc")
		if err != nil {
			return nil, fmt.Errorf("search service error: %w", err)
		}
	}
	result := make([]*mcp_dto.Service, 0, len(list))
	for _, s := range list {
		serviceRelease, err := i.releaseService.GetRunning(ctx, s.Id)
		if err != nil {
			if !errors.Is(err, gorm.ErrRecordNotFound) {
				return nil, fmt.Errorf("get service release error: %w,service id is %s", err, s.Id)
			}
			continue
		}
		_, _, apiDocRelease, _, _, err := i.releaseService.GetReleaseInfos(ctx, serviceRelease.UUID)
		if err != nil {
			if !errors.Is(err, gorm.ErrRecordNotFound) {
				return nil, fmt.Errorf("get service release info error: %w,service id is %s", err, s.Id)
			}
			continue
		}
		commit, err := i.apiDocService.GetDocCommit(ctx, apiDocRelease.Commit)
		if err != nil {
			if !errors.Is(err, gorm.ErrRecordNotFound) {
				return nil, fmt.Errorf("get api doc release error: %w,service id is %s", err, s.Id)
			}
			continue
		}
		T, err := openapi3Loader.LoadFromData([]byte(commit.Data.Content))
		if err != nil {
			return nil, fmt.Errorf("load openapi3 error: %w,service id is %s", err, s.Id)
		}
		apis := make([]*mcp_dto.API, 0, len(T.Paths.Map()))
		for path, v := range T.Paths.Map() {
			for method, opt := range v.Operations() {
				apis = append(apis, &mcp_dto.API{
					Name:        opt.Summary,
					Method:      method,
					Path:        path,
					Description: opt.Description,
				})
			}
		}
		result = append(result, &mcp_dto.Service{
			Id:          s.Id,
			Name:        s.Name,
			Description: s.Name,
			ServiceKind: s.Kind.String(),
			CreateTime:  s.CreateTime,
			UpdateTime:  s.UpdateTime,
			Apis:        apis,
		})
	}
	data, _ := json.Marshal(result)
	return mcp.NewToolResultText(string(data)), nil

}

func (i *imlMcpModule) APIs(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	serviceId, _ := req.GetArguments()["service"].(string)
	if serviceId == "" {
		return nil, fmt.Errorf("service id is empty")
	}
	s, err := i.serviceService.Get(ctx, serviceId)
	if err != nil {
		return nil, fmt.Errorf("get service error: %w,service id is %s", err, serviceId)
	}
	appId := utils.Label(ctx, "app")
	if appId != "" {
		subscribers, err := i.subscriberService.ListByApplication(ctx, serviceId, appId)
		if err != nil {
			return nil, fmt.Errorf("get subscriber error: %w,app id is %s", err, appId)
		}
		if len(subscribers) < 1 || subscribers[0].ApplyStatus != subscribe.ApplyStatusSubscribe {
			return nil, fmt.Errorf("no subscriber found,app id is %s", appId)
		}
	}

	serviceRelease, err := i.releaseService.GetRunning(ctx, serviceId)
	if err != nil {
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, fmt.Errorf("get service release error: %w,service id is %s", err, s.Id)
		}
		return nil, fmt.Errorf("no service found,service id is %s", serviceId)
	}
	_, _, apiDocRelease, _, _, err := i.releaseService.GetReleaseInfos(ctx, serviceRelease.UUID)
	if err != nil {
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, fmt.Errorf("get service release info error: %w,service id is %s", err, s.Id)
		}
		return nil, fmt.Errorf("no service found,service id is %s", serviceId)
	}
	commit, err := i.apiDocService.GetDocCommit(ctx, apiDocRelease.Commit)
	if err != nil {
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, fmt.Errorf("get api doc release error: %w,service id is %s", err, s.Id)
		}
		return nil, fmt.Errorf("no service found,service id is %s", serviceId)
	}
	T, err := openapi3Loader.LoadFromData([]byte(commit.Data.Content))
	if err != nil {
		return nil, fmt.Errorf("load openapi3 error: %w,service id is %s", err, s.Id)
	}

	result := &mcp_dto.ServiceAPI{
		ServiceID:   serviceId,
		ServiceName: s.Name,
		APIDoc:      T,
	}
	data, _ := json.Marshal(result)
	return mcp.NewToolResultText(string(data)), nil
}

var (
	client = &http.Client{
		Timeout: 30 * time.Second, // 增加超時時間到 30 秒
	}
)

func (i *imlMcpModule) Invoke(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	gatewayInvoke := utils.GatewayInvoke(ctx)

	if gatewayInvoke == "" {
		return nil, fmt.Errorf("gateway invoke is required")
	}
	u, err := url.Parse(gatewayInvoke)
	if err != nil {
		return nil, fmt.Errorf("parse gateway invoke error: %w", err)
	}
	if u.Scheme == "" {
		u.Scheme = "http"
	}

	path, ok := req.GetArguments()["path"].(string)
	if !ok {
		return nil, fmt.Errorf("invalid path")
	}
	u.Path = fmt.Sprintf("%s/%s", strings.TrimSuffix(u.Path, "/"), strings.TrimPrefix(path, "/"))

	method, ok := req.GetArguments()["method"].(string)
	if !ok {
		method = "GET"
	}
	queryParam := url.Values{}
	query, ok := req.GetArguments()["query"].(map[string]interface{})
	if ok {
		for k, v := range query {
			switch v := v.(type) {
			case string:
				queryParam.Add(k, v)
			case []string:
				for _, value := range v {
					queryParam.Add(k, value)
				}
			case float64:
				queryParam.Add(k, strconv.FormatFloat(v, 'f', -1, 64))
			default:
				return nil, fmt.Errorf("invalid query param type: %T", v)
			}
		}
	}
	u.RawQuery = queryParam.Encode()
	headerParam := http.Header{}
	header, ok := req.GetArguments()["header"].(map[string]interface{})
	if ok {
		for k, v := range header {
			switch v := v.(type) {
			case string:
				headerParam.Set(k, v)
			case []string:
				for _, value := range v {
					headerParam.Set(k, value)
				}
			default:
				return nil, fmt.Errorf("invalid header param type: %T", v)
			}
		}
	}

	body, ok := req.GetArguments()["body"].(string)
	if !ok {
		body = ""
	}

	contentType, ok := req.GetArguments()["content-type"].(string)
	if !ok {
		contentType = "application/json"
	}
	request, err := http.NewRequest(method, u.String(), strings.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("new request error: %w", err)
	}
	request.Header = headerParam
	request.Header.Set("Content-Type", contentType)
	apikey := utils.Label(ctx, "apikey")

	if apikey != "" {
		appId := utils.Label(ctx, "app")
		if appId == "" {
			request.Header.Set("Authorization", utils.Md5(apikey))
		} else {
			request.Header.Set("Authorization", apikey)
		}
	}

	resp, err := client.Do(request)
	if err != nil {
		return nil, fmt.Errorf("request error: %w", err)
	}
	defer resp.Body.Close()

	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read response error: %w", err)
	}
	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("response error: %s", string(data))
	}
	return mcp.NewToolResultText(string(data)), nil
}

```

### 2. 增加網關調用超時時間


```go
package admin

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

var (
	httpClient = &http.Client{
		Timeout: 30 * time.Second, // 增加超時時間到 30 秒
	}
	ErrorInvalidAdminAddress = errors.New("invalid address")
)

func callHttp[M any](ctx context.Context, address []string, method string, path string, body []byte) (*M, error) {
	if len(address) == 0 {
		return nil, ErrorInvalidAdminAddress
	}
	method = strings.ToUpper(method)
	var response *http.Response
	var err error
	for _, addr := range address {
		url := fmt.Sprint(addr, strings.TrimPrefix(path, "/"))
		response, err = doRequest(ctx, method, url, body)
		if err != nil {
			continue
		}
		if response.StatusCode != 200 {
			continue
		}
		break
	}
	if err != nil {
		return nil, err
	}

	if response.StatusCode != 200 {
		return nil, fmt.Errorf("http status code is %d", response.StatusCode)
	}
	data, err := io.ReadAll(response.Body)
	if err != nil {
		return nil, err
	}
	m := new(M)
	err = json.Unmarshal(data, m)
	if err != nil {
		return nil, err
	}
	return m, nil

}
func doRequest(ctx context.Context, method string, url string, body []byte) (*http.Response, error) {

	request, err := http.NewRequestWithContext(ctx, method, url, bytes.NewReader(body))
	if err != nil {
		return nil, err
	}

	request.Header.Set("User-Agent", "aoplatform")
	request.Header.Set("content-type", "application/json")
	return httpClient.Do(request)
}

```

### 3. 增加 MCP 工具調用的超時時間


```go
package mcp_server

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"

	"github.com/eolinker/go-common/utils"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
)

type ITool interface {
	Tool() server.ServerTool
}

type Tool struct {
	name        string
	url         string
	method      string
	contentType string
	params      map[string]*Param
	opts        []mcp.ToolOption
}

func (t *Tool) Tool() server.ServerTool {
	return server.ServerTool{
		Tool:    mcp.NewTool(t.name, t.opts...),
		Handler: generateInvokeTool(t.url, t.method, t.contentType, t.params),
	}
}

func NewTool(name string, uri string, method string, contentType string, params map[string]*Param, opts ...mcp.ToolOption) ITool {
	return &Tool{
		name:        name,
		url:         uri,
		method:      method,
		contentType: contentType,
		params:      params,
		opts:        opts,
	}
}

func generateInvokeTool(path string, method string, contentType string, params map[string]*Param) func(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	return func(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
		invokeAddress := utils.GatewayInvoke(ctx)
		if invokeAddress == "" {
			return nil, fmt.Errorf("invoke address is empty")
		}
		u, err := url.Parse(invokeAddress)
		if err != nil {
			return nil, fmt.Errorf("invalid invoke address %s", invokeAddress)
		}
		if u.Scheme == "" {
			u.Scheme = "http"
		}

		queries := url.Values{}
		headers := make(map[string]string)
		bodyParam := NewBodyParam(contentType)
		for k, p := range params {
			vv, ok := request.GetArguments()[k]
			if !ok && p.required {
				return nil, fmt.Errorf("param %s is required", k)
			}
			if p.position == PositionHeader || p.position == PositionQuery || p.position == PositionPath {
				v, ok := vv.(string)
				if !ok || v == "<nil>" {
					if p.required {
						return nil, fmt.Errorf("param %s is required", k)
					}
					continue
				}
			}

			switch p.position {
			case PositionPath:
				path = strings.ReplaceAll(path, "{"+k+"}", fmt.Sprintf("%v", vv))
			case PositionQuery:
				queries.Set(k, fmt.Sprintf("%v", vv))
			case PositionHeader:
				headers[k] = fmt.Sprintf("%v", vv)
			case PositionBody:
				if vv == nil {
					continue
				}
				bodyParam.Set(k, vv)
			}
		}
		bodyData, err := bodyParam.Encode()
		if err != nil {
			return nil, err
		}
		u.Path = path
		u.RawQuery = queries.Encode()

		req, err := http.NewRequest(method, u.String(), strings.NewReader(bodyData))
		if err != nil {
			return nil, err
		}
		for k, v := range headers {
			req.Header.Set(k, v)
		}
		if contentType != "" {
			req.Header.Set("Content-Type", contentType)
		}
		apikey := utils.Label(ctx, "apikey")
		if apikey != "" {
			req.Header.Set("Authorization", apikey)
		}

		// 設置請求超時
		ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
		defer cancel()
		
		req = req.WithContext(ctx)
		resp, err := client.Do(req)
		if err != nil {
			return nil, err
		}
		defer resp.Body.Close()
		d, err := io.ReadAll(resp.Body)
		if err != nil {
			return nil, err
		}
		if resp.StatusCode != http.StatusOK {
			return nil, fmt.Errorf("status code %d, %s", resp.StatusCode, string(d))
		}

		return mcp.NewToolResultText(string(d)), nil
	}
}

```

需要添加必要的導入：


```go
package mcp_server

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/eolinker/go-common/utils"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
)

type ITool interface {
	Tool() server.ServerTool
}

type Tool struct {
	name        string
	url         string
	method      string
	contentType string
	params      map[string]*Param
	opts        []mcp.ToolOption
}

func (t *Tool) Tool() server.ServerTool {
	return server.ServerTool{
		Tool:    mcp.NewTool(t.name, t.opts...),
		Handler: generateInvokeTool(t.url, t.method, t.contentType, t.params),
	}
}

func NewTool(name string, uri string, method string, contentType string, params map[string]*Param, opts ...mcp.ToolOption) ITool {
	return &Tool{
		name:        name,
		url:         uri,
		method:      method,
		contentType: contentType,
		params:      params,
		opts:        opts,
	}
}

func generateInvokeTool(path string, method string, contentType string, params map[string]*Param) func(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	return func(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
		invokeAddress := utils.GatewayInvoke(ctx)
		if invokeAddress == "" {
			return nil, fmt.Errorf("invoke address is empty")
		}
		u, err := url.Parse(invokeAddress)
		if err != nil {
			return nil, fmt.Errorf("invalid invoke address %s", invokeAddress)
		}
		if u.Scheme == "" {
			u.Scheme = "http"
		}

		queries := url.Values{}
		headers := make(map[string]string)
		bodyParam := NewBodyParam(contentType)
		for k, p := range params {
			vv, ok := request.GetArguments()[k]
			if !ok && p.required {
				return nil, fmt.Errorf("param %s is required", k)
			}
			if p.position == PositionHeader || p.position == PositionQuery || p.position == PositionPath {
				v, ok := vv.(string)
				if !ok || v == "<nil>" {
					if p.required {
						return nil, fmt.Errorf("param %s is required", k)
					}
					continue
				}
			}

			switch p.position {
			case PositionPath:
				path = strings.ReplaceAll(path, "{"+k+"}", fmt.Sprintf("%v", vv))
			case PositionQuery:
				queries.Set(k, fmt.Sprintf("%v", vv))
			case PositionHeader:
				headers[k] = fmt.Sprintf("%v", vv)
			case PositionBody:
				if vv == nil {
					continue
				}
				bodyParam.Set(k, vv)
			}
		}
		bodyData, err := bodyParam.Encode()
		if err != nil {
			return nil, err
		}
		u.Path = path
		u.RawQuery = queries.Encode()

		req, err := http.NewRequest(method, u.String(), strings.NewReader(bodyData))
		if err != nil {
			return nil, err
		}
		for k, v := range headers {
			req.Header.Set(k, v)
		}
		if contentType != "" {
			req.Header.Set("Content-Type", contentType)
		}
		apikey := utils.Label(ctx, "apikey")
		if apikey != "" {
			req.Header.Set("Authorization", apikey)
		}

		// 設置請求超時
		ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
		defer cancel()
		
		req = req.WithContext(ctx)
		resp, err := client.Do(req)
		if err != nil {
			return nil, err
		}
		defer resp.Body.Close()
		d, err := io.ReadAll(resp.Body)
		if err != nil {
			return nil, err
		}
		if resp.StatusCode != http.StatusOK {
			return nil, fmt.Errorf("status code %d, %s", resp.StatusCode, string(d))
		}

		return mcp.NewToolResultText(string(d)), nil
	}
}

```

### 4. 檢查前端超時設定

讓我檢查前端的預設超時設定：


讓我檢查 MCP 連接的具體超時設定：


找到問題了！前端的 `requestTimeout` 設定為 1000 毫秒（1 秒），這太短了。讓我修改這個設定：


```typescriptreact
import { App, Button, Card, CascaderProps, Empty, Select } from 'antd'
import { $t } from '@common/locales/index.ts'
import { Icon } from '@iconify/react/dist/iconify.js'
import { forwardRef, useEffect, useImperativeHandle, useRef, useState } from 'react'
import ReactJson from 'react-json-view'
import { IconButton } from '@common/components/postcat/api/IconButton'
import { BasicResponse, RESPONSE_TIPS, STATUS_CODE } from '@common/const/const'
import { useFetch } from '@common/hooks/http'
import { useConnection } from './hook/useConnection'
import { ClientRequest, Tool, ListToolsResultSchema } from '@modelcontextprotocol/sdk/types.js'
import { z } from 'zod'
import { useNavigate } from 'react-router-dom'
import { ServiceDetailType } from '@market/const/serviceHub/type'
import useCopyToClipboard from '@common/hooks/copy'
import { useGlobalContext } from '@common/contexts/GlobalStateContext'
import { Cascader } from 'antd/lib'

type ConfigList = {
  openApi?: {
    title: string
    configContent: string
    apiKeys: string[]
  }
  mcp: {
    title: string
    configContent: string
    apiKeys: string[]
  }
}

type ApiKeyItem = {
  expired: number
  id: string
  name: string
  value: string
}
interface Option {
  value: string
  label: string
  children?: Option[]
}

type ServiceApiKeyList = {
  id: string
  name: string
  apikeys: Array<{
    id: string
    name: string
    value: string
    expired: number
  }>
}

type ConsumerParamsType = {
  consumerId: string
  teamId: string
}
export interface IntegrationAIContainerRef {
  getServiceKeysList: () => void;
}
export interface IntegrationAIContainerProps {
  type: 'global' | 'service' | 'consumer'
  handleToolsChange: (value: Tool[]) => void
  customClassName?: string
  service?: ServiceDetailType
  serviceId?: string
  currentTab?: string
  openModal?: (type: 'apply') => void
  consumerParams?: ConsumerParamsType
}
export const IntegrationAIContainer = forwardRef<IntegrationAIContainerRef, IntegrationAIContainerProps>(
  ({
    type,
    handleToolsChange,
    customClassName,
    service,
    serviceId,
    currentTab,
    openModal,
    consumerParams
}: IntegrationAIContainerProps, ref) => {
  /** 当前激活的标签 */
  const [activeTab, setActiveTab] = useState(type === 'service' ? 'openApi' : 'mcp')
  /** 弹窗组件 */
  const { message } = App.useApp()
  /** 配置内容 */
  const [configContent, setConfigContent] = useState<string>('')
  /** 当前选中 API Key */
  const [apiKey, setApiKey] = useState<string>('')
  /** API Key 列表 */
  const [apiKeyList, setApiKeyList] = useState<any[]>([])
  /** Cascader Key 列表 */
  const [cascaderKeyList, setCascaderKeyList] = useState<string[]>([])
  /** MCP 服务器地址 */
  const [mcpServerUrl, setMcpServerUrl] = useState<string>('')
  /** 全局状态 */
  const { state } = useGlobalContext()
  const navigator = useNavigate()
  /** 复制组件 */
  const { copyToClipboard } = useCopyToClipboard()
  /** 错误提示 */
  const [errors, setErrors] = useState<Record<string, string | null>>({
    resources: null,
    prompts: null,
    tools: null
  })
  /** 标签内容 */
  const [tabContent, setTabContent] = useState<ConfigList>({
    mcp: {
      title: $t('MCP 配置'),
      configContent: '',
      apiKeys: []
    }
  })
  /** HTTP 请求 */
  const { fetchData } = useFetch()

  /**
   * 初始化标签数据
  */
  const initTabsData = () => {
    const params: ConfigList = {
      mcp: {
        title: $t('MCP 配置'),
        configContent: service?.mcpAccessConfig || '',
        apiKeys: []
      }
    }
    if (type === 'service') {
      params.openApi = {
        title: $t('Open API 文档'),
        configContent: service?.openapiAddress || '',
        apiKeys: []
      }
    }
    setTabContent(params)
  }

  /**
   * 复制
   * @param value
   * @returns
   */
  const handleCopy = async (value: string): Promise<void> => {
    if (value) {
      copyToClipboard(value)
      message.success($t(RESPONSE_TIPS.copySuccess))
    }
  }

  /**
   * 选择 API Key
   * @param value
   */
  const handleSelectChange = (value: string) => {
    setApiKey(value)
  }
  /**
   * Cascader 选择
   * @param value
   */
  const handleCascaderChange: CascaderProps<Option>['onChange'] = (value) => {
    setApiKey(value.at(-1) || '')
    setCascaderKeyList(value)
  }

  /**
   * 获取全局 MCP 配置
   * @returns
   */
  const getGlobalMcpConfig = () => {
    fetchData<BasicResponse<null>>('global/mcp/config', {
      method: 'GET'
    })
      .then((response) => {
        const { code, msg, data } = response
        if (code === STATUS_CODE.SUCCESS) {
          setTabContent((prevTabContent) => ({
            ...prevTabContent,
            mcp: {
              ...prevTabContent.mcp,
              configContent: data.config || ''
            }
          }))
        } else {
          message.error(msg || $t(RESPONSE_TIPS.error))
        }
      })
      .catch((errorInfo) => {
        message.error(errorInfo?.toString() || $t(RESPONSE_TIPS.error))
      })
  }

  /**
   * 获取消费者 MCP 配置
   * @returns
   */
  const getConsumerMcpConfig = () => {
    fetchData<BasicResponse<null>>('app/mcp/config', {
      method: 'GET',
      eoParams: { app: consumerParams?.consumerId, team: consumerParams?.teamId }
    })
      .then((response) => {
        const { code, msg, data } = response
        if (code === STATUS_CODE.SUCCESS) {
          setTabContent((prevTabContent) => ({
            ...prevTabContent,
            mcp: {
              ...prevTabContent.mcp,
              configContent: data.config || ''
            }
          }))
        } else {
          message.error(msg || $t(RESPONSE_TIPS.error))
        }
      })
      .catch((errorInfo) => {
        message.error(errorInfo?.toString() || $t(RESPONSE_TIPS.error))
      })
  }

  /**
   * 全局 MCP 跳转
   */
  const addKey = () => {
    navigator('/mcpKey')
  }

  const dropAuthPage = () => {
    navigator(`/consumer/${consumerParams?.teamId}/inside/${consumerParams?.consumerId}/authorization`)
  }

  /**
   * 获取全局 API Key 列表
   */
  const getGlobalKeysList = () => {
    fetchData<BasicResponse<null>>('simple/system/apikeys', {
      method: 'GET'
    })
      .then((response) => {
        const { code, msg, data } = response
        if (code === STATUS_CODE.SUCCESS) {
          if (data.apikeys && data.apikeys.length > 0) {
            setApiKeyList(
              data.apikeys.map((item: ApiKeyItem) => {
                return {
                  label: item.name,
                  value: item.value
                }
              })
            )
            setApiKey(data.apikeys[0].value)
          }
        } else {
          message.error(msg || $t(RESPONSE_TIPS.error))
        }
      })
      .catch((errorInfo) => {
        message.error(errorInfo?.toString() || $t(RESPONSE_TIPS.error))
      })
  }
  
  /**
   * 抛出获取服务 API Key 列表
   */
  useImperativeHandle(ref, () => ({
    getServiceKeysList
  }))

  /**
   * 获取 API Key 列表
   */
  const getServiceKeysList = (consumerId?: string) => {
    fetchData<BasicResponse<null>>(`my/app/apikeys`, {
      method: 'GET',
      eoParams: consumerId ? { app: consumerId } : { service: serviceId }
    })
      .then((response) => {
        const { code, msg, data } = response
        if (code === STATUS_CODE.SUCCESS) {
          if (data.apps && data.apps.length > 0) {
            // 转换数据结构为 Cascader 所需格式
            const transformedData = data.apps.map((app: ServiceApiKeyList) => ({
              value: app.id,
              label: app.name,
              children: app.apikeys.map((key) => ({
                ...key,
                label: key.name
              }))
            }))
            setApiKeyList(transformedData)
            if (data.apps[0].apikeys?.length) {
              setApiKey(data.apps[0].apikeys[0].value)
              setCascaderKeyList([data.apps[0].id, data.apps[0].apikeys[0].value])
            }
          }
        }
      })
      .catch((errorInfo) => {
        message.error(errorInfo?.toString() || $t(RESPONSE_TIPS.error))
      })
  }

  /**
   * 清除错误提示
   */
  const clearError = (tabKey: keyof typeof errors) => {
    setErrors((prev) => ({ ...prev, [tabKey]: null }))
  }

  /**
   * 发送请求
   */
  const makeRequest = async <T extends z.ZodType>(request: ClientRequest, schema: T, tabKey?: keyof typeof errors) => {
    try {
      const response = await makeConnectionRequest(request, schema)
      if (tabKey !== undefined) {
        clearError(tabKey)
      }
      return response
    } catch (e) {
      const errorString = (e as Error).message ?? String(e)
      if (tabKey !== undefined) {
        setErrors((prev) => ({
          ...prev,
          [tabKey]: errorString
        }))
      }
      throw e
    }
  }

  /**
   * 获取 MCP 的 tools
   */
  const listTools = async () => {
    const response = await makeRequest(
      {
        method: 'tools/list' as const,
        params: {}
      },
      ListToolsResultSchema,
      'tools'
    )
    handleToolsChange(response.tools)
  }

  /**
   * 初始化连接 mcp
   */
  const {
    connectionStatus,
    serverCapabilities,
    mcpClient,
    requestHistory,
    makeRequest: makeConnectionRequest,
    sendNotification,
    handleCompletion,
    completionsSupported,
    connect: connectMcpServer,
    disconnect: disconnectMcpServer
  } = useConnection({
    transportType: 'sse',
    sseUrl: '',
    proxyServerUrl: mcpServerUrl,
    requestTimeout: 30000 // 增加到 30 秒
  })
  // 使用 useRef 保存最新的连接状态和断开函数
  const connectionStatusRef = useRef(connectionStatus)
  const disconnectFnRef = useRef(disconnectMcpServer)

  // 当连接状态或断开函数变化时更新 ref
  useEffect(() => {
    connectionStatusRef.current = connectionStatus
    disconnectFnRef.current = disconnectMcpServer
  }, [connectionStatus, disconnectMcpServer])

  /**
   * 初始化数据
   */
  const setupComponent = () => {
    initTabsData()
    if (type === 'global') {
      getGlobalMcpConfig()
      setMcpServerUrl('mcp/global/sse')
      getGlobalKeysList()
    } else if (type === 'consumer'){
      getConsumerMcpConfig()
      setMcpServerUrl(`mcp/app/${consumerParams?.consumerId}/sse`)
      getServiceKeysList(consumerParams?.consumerId)
    } else {
      service?.basic.enableMcp && setMcpServerUrl(`mcp/service/${serviceId}/sse`)
      getServiceKeysList()
    }
  }
  /**
   * 初始化数据
   */
  useEffect(() => {
    setupComponent()
  }, [service])
  /**
   * 初始化标签数据
   */
  useEffect(() => {
    initTabsData()
    type === 'global' && getGlobalMcpConfig()
    type === 'consumer' && getConsumerMcpConfig()
  }, [state.language])
  /**
   * 切换标签
   */
  useEffect(() => {
    if (type === 'service') {
      currentTab === 'MCP' ? setActiveTab('mcp') : setActiveTab('openApi')
    }
  }, [currentTab])
  /**
   * 仅在组件加载时执行初始化逻辑
   */
  useEffect(() => {
    // 返回清理函数，只会在组件卸载时执行
    return () => {
      try {
        // 使用 ref 中保存的最新函数强制断开连接
        const disconnectFn = disconnectFnRef.current
        if (disconnectFn) {
          disconnectFn()
        }
      } catch (err) {
        console.error('断开连接时出错:', err)
      }
    }
  }, [type])
  /**
   * 切换标签时更新配置内容
   */
  useEffect(() => {
    if (activeTab === 'openApi' && tabContent?.openApi?.configContent) {
      setConfigContent(tabContent?.openApi?.configContent)
    } else if (activeTab === 'mcp' && tabContent?.mcp?.configContent) {
      setConfigContent(tabContent.mcp.configContent?.replace('{your_api_key}', apiKey || '{your_api_key}'))
    }
  }, [service, apiKey, activeTab, tabContent])
  /**
   * 连接 MCP 服务器
   */
  useEffect(() => {
    if (mcpServerUrl) {
      if (connectionStatus === 'connected') {
        disconnectMcpServer()
      }
      connectMcpServer()
    }
  }, [mcpServerUrl, ...(type === 'global' || type === 'consumer' ? [state.language] : [])])
  /**
   * 获取 MCP tools
   */
  useEffect(() => {
    if (connectionStatus === 'connected') {
      listTools()
    }
  }, [connectionStatus])

  return (
    <>
      <Card
        style={{ borderRadius: '10px' }}
        className={`w-[400px] h-fit ${customClassName}`}
        classNames={{
          body: 'p-[10px]'
        }}
      >
        <p>
          <Icon
            icon="icon-park-solid:connection-point-two"
            className="align-text-bottom mr-[5px]"
            width="16"
            height="16"
          />
          {$t('AI 代理集成')}
        </p>
        {type === 'service' && service?.basic.enableMcp && (
          <div className="mt-3 tab-nav flex rounded-md overflow-hidden border border-solid border-[#3D46F2] w-fit">
            <div
              className={`tab-item px-5 py-1.5 cursor-pointer text-sm transition-colors ${activeTab === 'openApi' ? 'bg-[#3D46F2] text-white' : 'bg-white text-[#3D46F2]'}`}
              onClick={() => setActiveTab('openApi')}
            >
              Open API
            </div>
            <div
              className={`tab-item px-5 py-1.5 cursor-pointer text-sm transition-colors ${activeTab === 'mcp' ? 'bg-[#3D46F2] text-white' : 'bg-white text-[#3D46F2]'}`}
              onClick={() => setActiveTab('mcp')}
            >
              MCP
            </div>
          </div>
        )}
        {(type === 'service' || type === 'consumer') && !apiKeyList.length ? (
          <>
            <Card
              style={{ borderRadius: '10px' }}
              className={`w-full mt-3`}
              classNames={{
                body: 'p-[10px]'
              }}
            >
              {
                type === 'service' ? (
                  <div className="flex flex-col items-center justify-center py-3">
                    <span className="text-[14px] mb-5">{$t('请先订阅该服务')}</span>
                    <Button type="primary" onClick={() => openModal?.('apply')}>
                      {$t('申请')}
                    </Button>
                  </div>
                ) : (
                  <div className="flex flex-col items-center justify-center py-3">
                    <span className="text-[14px] mb-5">{$t('未配置 API Key')}</span>
                    <Button type="primary" onClick={() => dropAuthPage()}>
                      {$t('配置')}
                    </Button>
                  </div>
                )
              }
            </Card>
          </>
        ) : (
          <>
            <div className="tab-container mt-3">
              <div className="tab-content font-semibold mt-[10px]">
                {activeTab === 'openApi' ? tabContent.openApi?.title : tabContent.mcp.title}
              </div>
              {/* 标签页内容区域 */}
              <div className="bg-[#0a0b21] text-white p-4 rounded-md my-2 font-mono text-sm overflow-auto relative">
                {activeTab === 'mcp' ? (
                  <ReactJson
                    src={
                      configContent
                        ? typeof configContent === 'string'
                          ? (() => {
                              try {
                                return JSON.parse(configContent)
                              } catch (e) {
                                return {}
                              }
                            })()
                          : configContent
                        : {}
                    }
                    theme="monokai"
                    indentWidth={2}
                    displayDataTypes={false}
                    displayObjectSize={false}
                    name={false}
                    collapsed={false}
                    enableClipboard={false}
                    style={{
                      backgroundColor: 'transparent',
                      wordBreak: 'break-word',
                      whiteSpace: 'normal'
                    }}
                  />
                ) : (
                  <>
                    <pre className="whitespace-pre-wrap break-words">{configContent || ''}</pre>
                  </>
                )}
                <IconButton
                  name="copy"
                  onClick={() => handleCopy(configContent)}
                  sx={{
                    position: 'absolute',
                    top: '5px',
                    right: '5px',
                    color: '#999',
                    transition: 'none',
                    '&.MuiButtonBase-root:hover': {
                      background: 'transparent',
                      color: '#3D46F2',
                      transition: 'none'
                    }
                  }}
                ></IconButton>
              </div>
            </div>
            {activeTab === 'mcp' && (
              <>
                <div className="tab-content font-semibold my-[10px]">API Key</div>
                {apiKeyList.length ? (
                  <>
                    {type === 'global' ? (
                      <>
                        <Select
                          showSearch
                          optionFilterProp="label"
                          value={apiKey}
                          className="w-full"
                          onChange={handleSelectChange}
                          options={apiKeyList}
                        />
                        <Card
                          style={{ borderRadius: '5px' }}
                          className="w-full mt-[5px] "
                          classNames={{
                            body: 'p-[5px]'
                          }}
                        >
                          <div className="relative h-[25px]">
                            {apiKey}
                            <IconButton
                              name="copy"
                              onClick={() => handleCopy(apiKey)}
                              sx={{
                                position: 'absolute',
                                top: '0px',
                                right: '5px',
                                color: '#999',
                                transition: 'none',
                                '&.MuiButtonBase-root:hover': {
                                  background: 'transparent',
                                  color: '#3D46F2',
                                  transition: 'none'
                                }
                              }}
                            ></IconButton>
                          </div>
                        </Card>
                      </>
                    ) : (
                      <>
                        <Cascader
                          className='w-full'
                          allowClear={false}
                          options={apiKeyList}
                          value={cascaderKeyList}
                          onChange={handleCascaderChange}
                          placeholder={$t('选择 API Key')}
                        />
                      </>
                    )}
                  </>
                ) : (
                  <Empty image={Empty.PRESENTED_IMAGE_SIMPLE} description={''}>
                    <Button onClick={addKey} type="primary">
                      {$t('新增 API Key')}
                    </Button>
                  </Empty>
                )}
              </>
            )}
          </>
        )}
      </Card>
    </>
  )
})
```

現在讓我創建一個 TODO 來追蹤這些修改：


## 總結

我已經修復了 MCP 工具調用超時的問題，主要修改包括：

### 修改內容

1. **後端 HTTP 客戶端超時**：
   - `module/mcp/iml.go`：將 HTTP 客戶端超時從無限制增加到 30 秒
   - `gateway/admin/http.go`：將網關管理超時從 5 秒增加到 30 秒

2. **MCP 工具調用超時**：
   - `mcp-server/tool.go`：為每個工具調用添加 30 秒的 context 超時

3. **前端連接超時**：
   - `IntegrationAIContainer.tsx`：將 `requestTimeout` 從 1 秒增加到 30 秒

### 問題原因

原本的超時設定過短：
- 前端：1 秒
- 網關管理：5 秒  
- MCP 模組：無超時限制（但可能受其他層影響）

### 建議的後續步驟

1. **重新編譯應用程式**：
   ```bash
   # 重新構建後端
   go build
   
   # 重新構建前端
   cd frontend && npm run build
   ```

2. **重啟服務**：
   ```bash
   # 重啟相關服務
   docker-compose restart
   ```

3. **測試 health2 工具**：
   - 重新嘗試調用 health2 工具
   - 檢查是否還會出現超時錯誤

4. **監控日誌**：
   - 查看應用程式日誌，確認請求是否正常處理
   - 檢查目標 API 的響應時間

這些修改應該能解決 MCP 工具調用的超時問題。如果問題仍然存在，可能需要進一步檢查：
- 目標 API 服務的可用性
- 網路連接狀況
- 服務配置是否正確

```shellscript
   # 重新構建後端
   go build
   
   # 重新構建前端
   cd frontend && npm run build
```

```shellscript
   # 重啟相關服務
   docker-compose restart
```

