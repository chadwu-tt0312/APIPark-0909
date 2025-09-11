# Find code for API settings
_Exported on 2025/9/9 at 17:32:38 [GMT+8] from Cursor (1.5.11)_

---

**User**

+ API 路由/API 設置
	+ 請求路徑
		+ `/e72569cf/health`
	+ 轉發上游路徑
		+ `/api/v1/health`
+ 上游
	+ 地址(IP 端口或域名)
		+ `192.168.31.180:5678`
	+ 轉發 Host
		+ `透傳客戶端請求Host`
+ 發布/新建版本
	+ 版本號
		+ `v1`
+ 設置
	+ 服務名稱
		+ `Health Restful Service`
	+ MCP
		+ `開啟`
---
上面的設置，請找出每個設定對應的程式碼。例如: 請求路徑=QuickCreateRestfulService() 裡的 `Path:        path + "*"`
		

---

**Cursor**

我來幫您找出這些 API 設置對應的程式碼。首先讓我查看相關的檔案來了解程式結構。


現在讓我搜尋更多相關的程式碼來找出每個設定對應的程式碼位置：


現在讓我搜尋更多關於路由和轉發路徑的程式碼：


基於我對程式碼的分析，我現在可以為您提供每個 API 設置對應的程式碼位置：

## API 設置對應的程式碼位置

### 1. **請求路徑** - `/e72569cf/health`
**對應程式碼：**
```go
// controller/service/iml.go:365
Path: path + "*"
```
- 在 `QuickCreateRestfulService()` 函數中，第 365 行
- 實際路徑由 `prefix` 變數組成，格式為 `/{prefix}/*`

### 2. **轉發上游路徑** - `/api/v1/health`
**對應程式碼：**
```go
// controller/service/iml.go:370
Proxy: &router_dto.InputProxy{
    Path:    path,  // 這裡是轉發路徑
    Timeout: 30000,
    Retry:   0,
}
```
- 在 `QuickCreateRestfulService()` 函數中，第 370 行
- `path` 變數在第 361 行定義：`path := prefix + "/"`

### 3. **上游地址** - `192.168.31.180:5678`
**對應程式碼：**
```go
// module/upstream/dto/output.go:28-30
type NodeConfig struct {
    Address string `json:"address"`  // 這裡存儲上游地址
    Weight  int    `json:"weight"`
}
```
- 上游節點配置在 `NodeConfig` 結構體中
- 實際配置會通過上游管理模組設定

### 4. **轉發 Host** - `透傳客戶端請求Host`
**對應程式碼：**
```go
// module/upstream/dto/output.go:22
PassHost string `json:"pass_host"`
```
- 在 `Upstream` 結構體中定義
- 控制是否透傳客戶端請求的 Host 標頭

### 5. **版本號** - `v1`
**對應程式碼：**
```go
// gateway/apinto/entity/service.go:27
Version: version,
```
- 在 `ToService()` 函數中設定服務版本
- 版本資訊會傳遞到網關實體中

### 6. **服務名稱** - `Health Restful Service`
**對應程式碼：**
```go
// controller/service/iml.go:342
Name: "Restful Service By Swagger",
```
- 在 `QuickCreateRestfulService()` 函數中設定
- 實際會根據上傳的 Swagger 文件動態生成

### 7. **MCP 設定** - `開啟`
**對應程式碼：**
```go
// stores/service/model.go:27
EnableMCP bool `gorm:"type:tinyint(1);not null;column:enable_mcp;comment:是否启用MCP"`
```
- 在資料庫模型中定義
- 在 `service/service/model.go:125` 的 `Service` 結構體中也有對應欄位

**MCP 相關處理程式碼：**
```go
// module/service/iml.go:885-898
if input.EnableMCP != nil {
    if *input.EnableMCP {
        name := info.Name
        if input.Name != nil {
            name = *input.Name
        }
        err = i.updateMCPServer(ctx, id, name, "1.0")
        if err != nil {
            return err
        }
    } else {
        i.deleteMCPServer(ctx, id)
    }
}
```

### 總結
這些設定主要分布在以下幾個關鍵檔案中：
- **路由設定**：`controller/service/iml.go` 的 `QuickCreateRestfulService()` 函數
- **上游設定**：`module/upstream/dto/output.go` 和相關模組
- **服務設定**：`stores/service/model.go` 和 `service/service/model.go`
- **MCP 設定**：`module/service/iml.go` 的編輯服務函數中

```go
// controller/service/iml.go:365
Path: path + "*"
```

```go
// controller/service/iml.go:370
Proxy: &router_dto.InputProxy{
    Path:    path,  // 這裡是轉發路徑
    Timeout: 30000,
    Retry:   0,
}
```

```go
// module/upstream/dto/output.go:28-30
type NodeConfig struct {
    Address string `json:"address"`  // 這裡存儲上游地址
    Weight  int    `json:"weight"`
}
```

```go
// module/upstream/dto/output.go:22
PassHost string `json:"pass_host"`
```

```go
// gateway/apinto/entity/service.go:27
Version: version,
```

```go
// controller/service/iml.go:342
Name: "Restful Service By Swagger",
```

```go
// stores/service/model.go:27
EnableMCP bool `gorm:"type:tinyint(1);not null;column:enable_mcp;comment:是否启用MCP"`
```

```go
// module/service/iml.go:885-898
if input.EnableMCP != nil {
    if *input.EnableMCP {
        name := info.Name
        if input.Name != nil {
            name = *input.Name
        }
        err = i.updateMCPServer(ctx, id, name, "1.0")
        if err != nil {
            return err
        }
    } else {
        i.deleteMCPServer(ctx, id)
    }
}
```

---

**User**

+ API 路由/API 設置
	+ 請求路徑
		+ `/e72569cf/health`
	+ 轉發上游路徑
		+ `/api/v1/health`
+ 上游
	+ 地址(IP 端口或域名)
		+ `192.168.31.180:5678`
	+ 轉發 Host
		+ `透傳客戶端請求Host`
+ 設置
	+ 服務名稱
		+ `Health Restful Service`
	+ MCP
		+ `開啟`
--- api_doc-health.yaml
openapi: 3.0.0
info:
  title: Health Restful Service
  version: 1.0.0
  description: 健康檢查 API 文件

servers:
  - url: http://192.168.31.180:5678/api/v1/health

paths:
  /health:
    get:
      summary: health
      description: 取得健康檢查資訊
      tags:
        - health
      responses:
        "200":
          description: 成功取得健康檢查資訊
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/HealthResponse"
components:
  schemas:
    HealthResponse:
      type: object
      properties:
        status:
          type: string
          example: ok
        message:
          type: string
          example: Service is healthy

---
請分析如何根據下列要求修改程式，並與我討論確認後再開始實作
- 請求路徑: /{prefix}/{VAR1}
  - VAR1 讀取 yaml 檔中的 paths 下的 summary 欄位內容
- 轉發上游路徑: {VAR2}  
  - VAR2 讀取 yaml 檔中的 servers 下的 url 欄位內的 path 部分(`/api/v1/health`)
- 上游地址: {VAR3}
  - VAR3 讀取 yaml 檔中的 servers 下的 url 欄位內的 IP+Port 部分(`192.168.31.180:5678`)
- 轉發 Host: {VAR4}
  - VAR4 預設選擇使用 `Pass-through Client Request Host`
- 服務名稱: {VAR5}
  - VAR5 讀取 yaml 檔中的 info 下的 title 欄位內容
- EnableMCP: {VAR6}
  - VAR6 預設值=1

---

**Cursor**

我來分析您的需求並與您討論修改方案。

## 需求分析

您希望修改 `QuickCreateRestfulService()` 函數，讓它能夠從上傳的 OpenAPI YAML 文件中動態讀取配置資訊，而不是使用硬編碼的值。

## 修改方案討論

### 1. **請求路徑生成邏輯**
```go
// 目前：path := prefix + "/"
// 修改後：需要解析 yaml 中的 paths，提取 summary 作為 VAR1
// 格式：/{prefix}/{summary}
```

**問題：** 如果 yaml 中有多個 paths，應該如何處理？
- 選取第一個 path？
- 還是需要讓用戶選擇？

### 2. **轉發上游路徑**
```go
// 目前：path (即 prefix + "/")
// 修改後：從 servers[0].url 中提取路徑部分
// 例如：http://192.168.31.180:5678/api/v1/health -> /api/v1/health
```

### 3. **上游地址**
```go
// 目前：沒有設定上游地址
// 修改後：從 servers[0].url 中提取 host:port
// 例如：http://192.168.31.180:5678/api/v1/health -> 192.168.31.180:5678
```

### 4. **轉發 Host 設定**
```go
// 目前：沒有明確設定
// 修改後：預設使用 "pass" (透傳客戶端請求Host)
```

### 5. **服務名稱**
```go
// 目前：Name: "Restful Service By Swagger"
// 修改後：從 info.title 讀取
```

### 6. **MCP 設定**
```go
// 目前：沒有設定 EnableMCP
// 修改後：預設設為 true
```

## 實作步驟

我建議按以下步驟進行：

1. **建立 YAML 解析函數**：解析 OpenAPI 文件並提取所需資訊
2. **修改 QuickCreateRestfulService 函數**：使用解析出的資訊替代硬編碼值
3. **建立上游配置**：根據解析的資訊建立對應的上游配置
4. **更新路由配置**：使用動態路徑和轉發設定

## 需要確認的問題

1. **多個 paths 處理**：如果 yaml 中有多個 API 路徑，您希望：
   - 只處理第一個？
   - 為每個 path 建立獨立的路由？
   - 讓用戶選擇？

2. **錯誤處理**：如果 yaml 格式不正確或缺少必要欄位，應該如何處理？

3. **向後相容性**：是否需要保持對現有功能的支援？

4. **上游配置**：是否需要為每個服務建立獨立的上游配置，還是可以共用？

請確認這些問題，我就可以開始實作修改方案。

```go
// 目前：path := prefix + "/"
// 修改後：需要解析 yaml 中的 paths，提取 summary 作為 VAR1
// 格式：/{prefix}/{summary}
```

```go
// 目前：path (即 prefix + "/")
// 修改後：從 servers[0].url 中提取路徑部分
// 例如：http://192.168.31.180:5678/api/v1/health -> /api/v1/health
```

```go
// 目前：沒有設定上游地址
// 修改後：從 servers[0].url 中提取 host:port
// 例如：http://192.168.31.180:5678/api/v1/health -> 192.168.31.180:5678
```

```go
// 目前：沒有明確設定
// 修改後：預設使用 "pass" (透傳客戶端請求Host)
```

```go
// 目前：Name: "Restful Service By Swagger"
// 修改後：從 info.title 讀取
```

```go
// 目前：沒有設定 EnableMCP
// 修改後：預設設為 true
```

---

**User**

1. 如果 yaml 中有多個 API 路徑，只處理第一個
2. 如果 yaml 格式不正確或缺少必要欄位時，此次建立服務失敗。並要求修改 yaml 
3. 只有透過主頁使用"添加 REST 服務"時才應用這次的修改，其他保持不變
4. 每個服務建立獨立的上游配置


---

**Cursor**

好的，根據您的確認，我來實作修改方案。讓我先查看相關的程式碼結構，然後開始實作。


現在我來建立 TODO 清單並開始實作修改：


現在開始實作。首先建立 YAML 解析函數：


```go
package service

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/APIParkLab/APIPark/module/monitor"
	monitor_dto "github.com/APIParkLab/APIPark/module/monitor/dto"

	ai_provider_local "github.com/APIParkLab/APIPark/ai-provider/local"

	subscribe_dto "github.com/APIParkLab/APIPark/module/subscribe/dto"

	"github.com/APIParkLab/APIPark/module/subscribe"

	ai_local "github.com/APIParkLab/APIPark/module/ai-local"

	ai_dto "github.com/APIParkLab/APIPark/module/ai/dto"

	api_doc_dto "github.com/APIParkLab/APIPark/module/api-doc/dto"

	"github.com/APIParkLab/APIPark/module/catalogue"

	"github.com/APIParkLab/APIPark/module/team"

	"github.com/eolinker/go-common/pm3"

	"github.com/APIParkLab/APIPark/module/system"

	"github.com/getkin/kin-openapi/openapi3"

	api_doc "github.com/APIParkLab/APIPark/module/api-doc"

	"github.com/eolinker/eosc/log"

	application_authorization "github.com/APIParkLab/APIPark/module/application-authorization"
	application_authorization_dto "github.com/APIParkLab/APIPark/module/application-authorization/dto"

	"github.com/APIParkLab/APIPark/model/plugin_model"
	"github.com/APIParkLab/APIPark/service/api"

	router_dto "github.com/APIParkLab/APIPark/module/router/dto"

	model_runtime "github.com/APIParkLab/APIPark/ai-provider/model-runtime"
	"github.com/APIParkLab/APIPark/module/ai"
	ai_api "github.com/APIParkLab/APIPark/module/ai-api"
	ai_api_dto "github.com/APIParkLab/APIPark/module/ai-api/dto"
	"github.com/APIParkLab/APIPark/module/router"
	"github.com/APIParkLab/APIPark/module/service"
	service_dto "github.com/APIParkLab/APIPark/module/service/dto"
	"github.com/APIParkLab/APIPark/module/upstream"
	upstream_dto "github.com/APIParkLab/APIPark/module/upstream/dto"
	"github.com/eolinker/go-common/store"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

var (
	_ IServiceController = (*imlServiceController)(nil)

	_ IAppController = (*imlAppController)(nil)
)

type imlServiceController struct {
	module              service.IServiceModule          `autowired:""`
	docModule           service.IServiceDocModule       `autowired:""`
	subscribeModule     subscribe.ISubscribeModule      `autowired:""`
	aiAPIModule         ai_api.IAPIModule               `autowired:""`
	routerModule        router.IRouterModule            `autowired:""`
	apiDocModule        api_doc.IAPIDocModule           `autowired:""`
	providerModule      ai.IProviderModule              `autowired:""`
	aiLocalModel        ai_local.ILocalModelModule      `autowired:""`
	appModule           service.IAppModule              `autowired:""`
	upstreamModule      upstream.IUpstreamModule        `autowired:""`
	settingModule       system.ISettingModule           `autowired:""`
	teamModule          team.ITeamModule                `autowired:""`
	catalogueModule     catalogue.ICatalogueModule      `autowired:""`
	monitorModule       monitor.IMonitorStatisticModule `autowired:""`
	monitorConfigModule monitor.IMonitorConfigModule    `autowired:""`
	transaction         store.ITransaction              `autowired:""`
}

func (i *imlServiceController) RestLogInfo(ctx *gin.Context, serviceId string, logId string) (*service_dto.RestLogInfo, error) {
	return i.module.RestLogInfo(ctx, serviceId, logId)
}

func (i *imlServiceController) AILogInfo(ctx *gin.Context, serviceId string, logId string) (*service_dto.AILogInfo, error) {
	return i.module.AILogInfo(ctx, serviceId, logId)
}

func (i *imlServiceController) AILogs(ctx *gin.Context, serviceId string, start string, end string, page string, size string) ([]*service_dto.AILogItem, int64, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, 0, err
	}
	if serviceId == "" {
		return nil, 0, fmt.Errorf("service id is empty")
	}
	if page == "" {
		page = "1"
	}
	if size == "" {
		size = "20"
	}
	p, err := strconv.Atoi(page)
	if err != nil {
		return nil, 0, err
	}
	ps, err := strconv.Atoi(size)
	if err != nil {
		return nil, 0, err
	}

	return i.module.AILogs(ctx, serviceId, s, e, p, ps)
}

func (i *imlServiceController) RestLogs(ctx *gin.Context, serviceId string, start string, end string, page string, size string) ([]*service_dto.RestLogItem, int64, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, 0, err
	}
	if serviceId == "" {
		return nil, 0, fmt.Errorf("service id is empty")
	}
	if page == "" {
		page = "1"
	}
	if size == "" {
		size = "20"
	}
	p, err := strconv.Atoi(page)
	if err != nil {
		return nil, 0, err
	}
	ps, err := strconv.Atoi(size)
	if err != nil {
		return nil, 0, err
	}

	return i.module.RestLogs(ctx, serviceId, s, e, p, ps)
}

func (i *imlServiceController) ServiceOverview(ctx *gin.Context, serviceId string) (*service_dto.Overview, error) {
	o, err := i.module.ServiceOverview(ctx, serviceId)
	if err != nil {
		return nil, err
	}
	cfg, err := i.monitorConfigModule.GetMonitorConfig(ctx)
	if err != nil {
		return nil, err
	}
	if len(cfg.Config) < 1 {
		return o, nil
	}
	statistics, err := i.monitorModule.ProviderStatistics(ctx, &monitor_dto.StatisticInput{
		Services: []string{serviceId},
		CommonInput: &monitor_dto.CommonInput{
			Start: time.Now().Add(-24 * 30 * time.Hour).Unix(),
			End:   time.Now().Unix(),
		},
	})
	if err != nil {
		return nil, err
	}
	if len(statistics) < 1 {
		return o, nil
	}
	o.InvokeNum = statistics[0].RequestTotal
	return o, nil
}

func (i *imlServiceController) AIChartOverview(ctx *gin.Context, serviceId string, start string, end string) (*monitor_dto.ServiceChartAIOverview, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, err
	}
	if serviceId == "" {
		return nil, fmt.Errorf("service is required")
	}
	so, err := i.module.ServiceOverview(ctx, serviceId)
	if err != nil {
		return nil, err
	}
	result := &monitor_dto.ServiceChartAIOverview{
		EnableMCP:     so.EnableMCP,
		SubscriberNum: so.SubscriberNum,
		APINum:        so.APINum,
		ServiceKind:   so.ServiceKind,
	}
	cfg, err := i.monitorConfigModule.GetMonitorConfig(ctx)
	if err != nil {
		return nil, err
	}
	if len(cfg.Config) < 1 {
		return result, nil
	}

	o, err := i.monitorModule.AIChartOverview(ctx, serviceId, s, e)
	if err != nil {
		return nil, err
	}

	result.AvailableMonitor = true
	result.ChartAIOverview = o
	return result, nil
}

func (i *imlServiceController) RestChartOverview(ctx *gin.Context, serviceId string, start string, end string) (*monitor_dto.ServiceChartRestOverview, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, err
	}
	if serviceId == "" {
		return nil, fmt.Errorf("service is required")
	}
	so, err := i.module.ServiceOverview(ctx, serviceId)
	if err != nil {
		return nil, err
	}
	result := &monitor_dto.ServiceChartRestOverview{
		EnableMCP:     so.EnableMCP,
		SubscriberNum: so.SubscriberNum,
		APINum:        so.APINum,
		ServiceKind:   so.ServiceKind,
	}
	cfg, err := i.monitorConfigModule.GetMonitorConfig(ctx)
	if err != nil {
		return nil, err
	}
	if len(cfg.Config) < 1 {
		return result, nil
	}
	o, err := i.monitorModule.RestChartOverview(ctx, serviceId, s, e)
	if err != nil {
		return nil, err
	}
	result.AvailableMonitor = true
	result.ChartRestOverview = o
	return result, nil
}

func formatTime(start string, end string) (int64, int64, error) {
	s, err := strconv.ParseInt(start, 10, 64)
	if err != nil {
		return 0, 0, fmt.Errorf("parse start time %s error: %w", start, err)
	}
	e, err := strconv.ParseInt(end, 10, 64)
	if err != nil {
		return 0, 0, fmt.Errorf("parse end time %s error: %w", end, err)
	}
	return s, e, nil
}

func (i *imlServiceController) Top10(ctx *gin.Context, serviceId string, start string, end string) ([]*monitor_dto.TopN, []*monitor_dto.TopN, error) {
	if serviceId == "" {
		return nil, nil, fmt.Errorf("serviceId is required")
	}
	info, err := i.module.Get(ctx, serviceId)
	if err != nil {
		return nil, nil, err
	}

	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, nil, err
	}

	return i.monitorModule.Top(ctx, serviceId, s, e, 10, info.ServiceKind)
}

func (i *imlServiceController) QuickCreateAIService(ctx *gin.Context, input *service_dto.QuickCreateAIService) error {
	return i.transaction.Transaction(ctx, func(txCtx context.Context) error {
		enable := true
		err := i.providerModule.UpdateProviderConfig(ctx, input.Provider, &ai_dto.UpdateConfig{
			Config: input.Config,
			Enable: &enable,
		})
		if err != nil {
			return err
		}
		p, err := i.providerModule.Provider(ctx, input.Provider)
		if err != nil {
			return err
		}
		id := uuid.NewString()
		prefix := fmt.Sprintf("/%s", id[:8])
		catalogueInfo, err := i.catalogueModule.DefaultCatalogue(ctx)
		if err != nil {
			return err
		}
		_, err = i.createAIService(ctx, input.Team, &service_dto.CreateService{
			Id:           uuid.NewString(),
			Name:         input.Provider + " AI Service",
			Prefix:       prefix,
			Description:  "Quick create by AI provider",
			ServiceType:  "public",
			State:        "normal",
			Catalogue:    catalogueInfo.Id,
			ApprovalType: "auto",
			Provider:     &input.Provider,
			Model:        &p.DefaultLLM,
			Kind:         "ai",
		})
		return err
	})
}

func (i *imlServiceController) QuickCreateRestfulService(ctx *gin.Context) error {
	fileHeader, err := ctx.FormFile("file")
	if err != nil {
		return err
	}
	file, err := fileHeader.Open()
	if err != nil {
		return err
	}
	content, err := io.ReadAll(file)
	if err != nil {
		return err
	}
	typ := ctx.PostForm("type")
	switch typ {
	case "swagger", "":
	default:
		return fmt.Errorf("type %s not support", typ)
	}

	return i.transaction.Transaction(ctx, func(txCtx context.Context) error {
		teamId := ctx.PostForm("team")
		id := uuid.NewString()
		prefix := fmt.Sprintf("/%s", id[:8])
		catalogueInfo, err := i.catalogueModule.DefaultCatalogue(ctx)
		if err != nil {
			return err
		}
		s, err := i.module.Create(ctx, teamId, &service_dto.CreateService{
			Id:           uuid.NewString(),
			Name:         "Restful Service By Swagger",
			Prefix:       prefix,
			Description:  "Auto create by upload swagger",
			ServiceType:  "public",
			State:        "normal",
			Catalogue:    catalogueInfo.Id,
			ApprovalType: "auto",
			Kind:         "rest",
		})
		if err != nil {
			return err
		}
		_, err = i.apiDocModule.UpdateDoc(ctx, s.Id, &api_doc_dto.UpdateDoc{
			Id:      s.Id,
			Content: string(content),
		})
		if err != nil {
			return err
		}
		path := prefix + "/"
		_, err = i.routerModule.Create(ctx, s.Id, &router_dto.Create{
			Id:          uuid.NewString(),
			Name:        "",
			Path:        path + "*",
			Methods:     []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodPatch, http.MethodOptions},
			Description: "auto create by create service",
			Protocols:   []string{"http", "https"},
			Proxy: &router_dto.InputProxy{
				Path:    path,
				Timeout: 30000,
				Retry:   0,
			},
			Disable: false,
		})
		if err != nil {
			return err
		}
		apps, err := i.appModule.Search(ctx, teamId, "")
		if err != nil {
			return err
		}
		for _, app := range apps {
			i.subscribeModule.AddSubscriber(ctx, id, &subscribe_dto.AddSubscriber{
				Application: app.Id,
			})
		}

		return nil
	})
}

var (
	loader = openapi3.NewLoader()
)

func (i *imlServiceController) swagger(ctx *gin.Context, id string) (*openapi3.T, error) {
	doc, err := i.apiDocModule.GetDoc(ctx, id)
	if err != nil {
		return nil, err
	}
	tmp, err := loader.LoadFromData([]byte(doc.Content))
	if err != nil {
		return nil, err
	}
	cfg := i.settingModule.Get(ctx)

	tmp.AddServer(&openapi3.Server{
		URL: cfg.InvokeAddress,
	})
	return tmp, nil
}

func (i *imlServiceController) ExportSwagger(ctx *gin.Context) {
	id, has := ctx.Params.Get("id")
	if !has {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: fmt.Sprintf("id is required"),
		})
		return
	}
	s, err := i.module.Get(ctx, id)
	if err != nil {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: err.Error(),
		})
		return
	}
	tmp, err := i.swagger(ctx, id)
	if err != nil {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: err.Error(),
		})
		return
	}

	data, _ := tmp.MarshalJSON()
	ctx.Status(200)
	// 设置响应头
	ctx.Header("Content-Disposition", fmt.Sprintf("attachment; filename=%s.json", strings.Replace(s.Name, " ", "_", -1)))
	ctx.Header("Content-Type", "application/octet-stream")
	ctx.Header("Content-Transfer-Encoding", "binary")
	ctx.Writer.Write(data)
	return
}

func (i *imlServiceController) Swagger(ctx *gin.Context) {
	id, has := ctx.Params.Get("id")
	if !has {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: fmt.Sprintf("id is required"),
		})
		return
	}
	tmp, err := i.swagger(ctx, id)
	if err != nil {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: err.Error(),
		})
		return
	}
	ctx.JSON(200, tmp)
	return
}

func (i *imlServiceController) Simple(ctx *gin.Context) ([]*service_dto.SimpleServiceItem, error) {
	return i.module.Simple(ctx)
}

func (i *imlServiceController) MySimple(ctx *gin.Context) ([]*service_dto.SimpleServiceItem, error) {
	return i.module.MySimple(ctx)
}

func (i *imlServiceController) editAIService(ctx *gin.Context, id string, input *service_dto.EditService) (*service_dto.Service, error) {

	if input.Provider == nil {
		return nil, fmt.Errorf("provider is required")
	}
	if *input.Provider != ai_provider_local.ProviderLocal {
		_, has := model_runtime.GetProvider(*input.Provider)
		if !has {
			return nil, fmt.Errorf("provider not found")
		}
	}

	info, err := i.module.Edit(ctx, id, input)
	if err != nil {
		return nil, err
	}
	//_, err = i.upstreamModule.Save(ctx, id, newAIUpstream(id, *input.Provider, p.URI()))

	return info, nil
}

func (i *imlServiceController) createAIService(ctx *gin.Context, teamID string, input *service_dto.CreateService) (*service_dto.Service, error) {
	if input.Provider == nil {
		return nil, fmt.Errorf("provider is required")
	}

	if input.Id == "" {
		input.Id = uuid.New().String()
	}
	if input.Prefix == "" {
		if len(input.Id) < 9 {
			input.Prefix = input.Id
		} else {
			input.Prefix = input.Id[:8]
		}
	}
	modelId := ""
	modelCfg := ""
	modelType := "online"
	if *input.Provider == ai_provider_local.ProviderLocal {
		modelType = "local"
		list, err := i.aiLocalModel.SimpleList(ctx)
		if err != nil {
			return nil, err
		}
		if len(list) == 0 {
			return nil, fmt.Errorf("no local model")
		}
		modelId = list[0].Id
		modelCfg = ai_provider_local.LocalConfig
	} else {
		pv, err := i.providerModule.Provider(ctx, *input.Provider)
		if err != nil {
			return nil, err
		}
		p, has := model_runtime.GetProvider(*input.Provider)
		if !has {
			return nil, fmt.Errorf("provider not found")
		}
		m, has := p.GetModel(pv.DefaultLLM)
		if !has {
			return nil, fmt.Errorf("model %s not found", pv.DefaultLLM)
		}
		//modelId = m.ID()
		modelId = m.Name()
		modelCfg = m.DefaultConfig()

	}

	var info *service_dto.Service
	err := i.transaction.Transaction(ctx, func(txCtx context.Context) error {
		var err error
		info, err = i.module.Create(ctx, teamID, input)
		if err != nil {
			return err
		}
		prefix := strings.Replace(input.Prefix, ":", "_", -1)
		path := fmt.Sprintf("/%s/chat/completions", strings.Trim(prefix, "/"))
		timeout := 300000
		retry := 0
		aiPrompt := &ai_api_dto.AiPrompt{
			Variables: []*ai_api_dto.AiPromptVariable{},
			Prompt:    "",
		}
		aiModel := &ai_api_dto.AiModel{
			Id:       modelId,
			Config:   modelCfg,
			Provider: *input.Provider,
			Type:     modelType,
		}
		name := "Demo AI API "
		description := "This is a demo that shows you how to use a Chat API."
		apiId := uuid.New().String()
		err = i.aiAPIModule.Create(
			ctx,
			info.Id,
			&ai_api_dto.CreateAPI{
				Id:          apiId,
				Name:        name,
				Path:        path,
				Description: description,
				Disable:     false,
				AiPrompt:    aiPrompt,
				AiModel:     aiModel,
				Timeout:     timeout,
				Retry:       retry,
			},
		)
		if err != nil {
			return err
		}
		plugins := make(map[string]api.PluginSetting)
		plugins["ai_prompt"] = api.PluginSetting{
			Config: plugin_model.ConfigType{
				"prompt":    aiPrompt.Prompt,
				"variables": aiPrompt.Variables,
			},
		}
		plugins["ai_formatter"] = api.PluginSetting{
			Config: plugin_model.ConfigType{
				"model":    aiModel.Id,
				"provider": fmt.Sprintf("%s@ai-provider", info.Provider.Id),
				"config":   aiModel.Config,
			},
		}
		_, err = i.routerModule.Create(ctx, info.Id, &router_dto.Create{
			Id:   apiId,
			Name: name,
			Path: path,
			Methods: []string{
				http.MethodPost,
			},
			Description: description,
			Protocols:   []string{"http", "https"},
			MatchRules:  nil,
			Proxy: &router_dto.InputProxy{
				Path:    path,
				Timeout: timeout,
				Retry:   retry,
				Plugins: plugins,
			},
			Disable:  false,
			Upstream: info.Provider.Id,
		})
		if err != nil {
			return err
		}
		apps, err := i.appModule.Search(ctx, info.Team.Id, "")
		if err != nil {
			return err
		}
		for _, app := range apps {
			i.subscribeModule.AddSubscriber(ctx, info.Id, &subscribe_dto.AddSubscriber{
				Application: app.Id,
			})
		}

		return i.docModule.SaveServiceDoc(ctx, info.Id, &service_dto.SaveServiceDoc{
			Doc: "",
		})
	})

	return info, err
}

func (i *imlServiceController) SearchMyServices(ctx *gin.Context, teamId string, keyword string) ([]*service_dto.ServiceItem, error) {
	return i.module.SearchMyServices(ctx, teamId, keyword)
}

func (i *imlServiceController) Get(ctx *gin.Context, id string) (*service_dto.Service, error) {
	now := time.Now()
	defer func() {
		log.Infof("get service %s cost %d ms", id, time.Since(now).Milliseconds())
	}()
	return i.module.Get(ctx, id)
}

func (i *imlServiceController) Search(ctx *gin.Context, teamIDs string, keyword string) ([]*service_dto.ServiceItem, error) {
	return i.module.Search(ctx, teamIDs, keyword)
}

func (i *imlServiceController) Create(ctx *gin.Context, teamID string, input *service_dto.CreateService) (*service_dto.Service, error) {
	if input.Kind == "ai" {
		return i.createAIService(ctx, teamID, input)
	}
	var err error
	var info *service_dto.Service
	err = i.transaction.Transaction(ctx, func(ctx context.Context) error {
		info, err = i.module.Create(ctx, teamID, input)
		if err != nil {
			return err
		}
		path := fmt.Sprintf("/%s/", strings.Trim(input.Prefix, "/"))
		_, err = i.routerModule.Create(ctx, info.Id, &router_dto.Create{
			Id:          uuid.New().String(),
			Name:        "",
			Path:        path + "*",
			Methods:     []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodPatch, http.MethodOptions},
			Description: "auto create by create service",
			Protocols:   []string{"http", "https"},
			MatchRules:  nil,
			Upstream:    "",
			Proxy: &router_dto.InputProxy{
				Path:    path,
				Timeout: 30000,
				Retry:   0,
			},
			Disable: false,
		})
		apps, err := i.appModule.Search(ctx, teamID, "")
		if err != nil {
			return err
		}
		for _, app := range apps {
			i.subscribeModule.AddSubscriber(ctx, info.Id, &subscribe_dto.AddSubscriber{
				Application: app.Id,
			})
		}
		return err
	})
	return info, err
}

func (i *imlServiceController) Edit(ctx *gin.Context, id string, input *service_dto.EditService) (*service_dto.Service, error) {
	info, err := i.Get(ctx, id)
	if err != nil {
		return nil, err
	}
	if info.ServiceKind == "ai" {
		return i.editAIService(ctx, id, input)
	}
	return i.module.Edit(ctx, id, input)
}

func (i *imlServiceController) Delete(ctx *gin.Context, id string) error {
	return i.module.Delete(ctx, id)
}

func (i *imlServiceController) ServiceDoc(ctx *gin.Context, id string) (*service_dto.ServiceDoc, error) {
	return i.docModule.ServiceDoc(ctx, id)
}

func (i *imlServiceController) SaveServiceDoc(ctx *gin.Context, id string, input *service_dto.SaveServiceDoc) error {
	return i.docModule.SaveServiceDoc(ctx, id, input)
}

type imlAppController struct {
	module     service.IAppModule                             `autowired:""`
	authModule application_authorization.IAuthorizationModule `autowired:""`
}

func (i *imlAppController) SearchCanSubscribe(ctx *gin.Context, serviceId string) ([]*service_dto.SubscribeAppItem, error) {
	items, _, err := i.module.SearchCanSubscribe(ctx, serviceId)
	return items, err
}

func (i *imlAppController) Search(ctx *gin.Context, teamId string, keyword string) ([]*service_dto.AppItem, error) {
	return i.module.Search(ctx, teamId, keyword)
}

func (i *imlAppController) CreateApp(ctx *gin.Context, teamID string, input *service_dto.CreateApp) (*service_dto.App, error) {
	app, err := i.module.CreateApp(ctx, teamID, input)
	if err != nil {
		return nil, err
	}
	_, err = i.authModule.AddAuthorization(ctx, app.Id, &application_authorization_dto.CreateAuthorization{
		Name:       "Default API Key",
		Driver:     "apikey",
		Position:   "Header",
		TokenName:  "Authorization",
		ExpireTime: 0,
		Config: map[string]interface{}{
			"apikey": uuid.New().String(),
		},
	})
	if err != nil {
		i.module.DeleteApp(ctx, app.Id)
		return nil, err
	}
	return app, nil
}
func (i *imlAppController) UpdateApp(ctx *gin.Context, appId string, input *service_dto.UpdateApp) (*service_dto.App, error) {
	return i.module.UpdateApp(ctx, appId, input)
}

func (i *imlAppController) SearchMyApps(ctx *gin.Context, teamId string, keyword string) ([]*service_dto.AppItem, error) {
	return i.module.SearchMyApps(ctx, teamId, keyword)
}

func (i *imlAppController) SimpleApps(ctx *gin.Context, keyword string) ([]*service_dto.SimpleAppItem, error) {
	return i.module.SimpleApps(ctx, keyword)
}

func (i *imlAppController) MySimpleApps(ctx *gin.Context, keyword string) ([]*service_dto.SimpleAppItem, error) {
	return i.module.MySimpleApps(ctx, keyword)
}

func (i *imlAppController) GetApp(ctx *gin.Context, appId string) (*service_dto.App, error) {
	return i.module.GetApp(ctx, appId)
}

func (i *imlAppController) DeleteApp(ctx *gin.Context, appId string) error {
	return i.module.DeleteApp(ctx, appId)
}

//func newAIUpstream(id string, provider string, uri model_runtime.IProviderURI) *upstream_dto.Upstream {
//	return &upstream_dto.Upstream{
//		Type:            "http",
//		Balance:         "round-robin",
//		Timeout:         300000,
//		Retry:           0,
//		Remark:          fmt.Sprintf("auto create by ai service %s,provider is %s", id, provider),
//		LimitPeerSecond: 0,
//		ProxyHeaders:    nil,
//		Scheme:          uri.Scheme(),
//		PassHost:        "node",
//		Nodes: []*upstream_dto.NodeConfig{
//			{
//				Address: uri.Host(),
//				Weight:  100,
//			},
//		},
//	}
//}

```

現在在 `QuickCreateRestfulService` 函數之前添加 YAML 解析函數：


```go
package service

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/APIParkLab/APIPark/module/monitor"
	monitor_dto "github.com/APIParkLab/APIPark/module/monitor/dto"

	ai_provider_local "github.com/APIParkLab/APIPark/ai-provider/local"

	subscribe_dto "github.com/APIParkLab/APIPark/module/subscribe/dto"

	"github.com/APIParkLab/APIPark/module/subscribe"

	ai_local "github.com/APIParkLab/APIPark/module/ai-local"

	ai_dto "github.com/APIParkLab/APIPark/module/ai/dto"

	api_doc_dto "github.com/APIParkLab/APIPark/module/api-doc/dto"

	"github.com/APIParkLab/APIPark/module/catalogue"

	"github.com/APIParkLab/APIPark/module/team"

	"github.com/eolinker/go-common/pm3"

	"github.com/APIParkLab/APIPark/module/system"

	"github.com/getkin/kin-openapi/openapi3"

	api_doc "github.com/APIParkLab/APIPark/module/api-doc"

	"github.com/eolinker/eosc/log"

	application_authorization "github.com/APIParkLab/APIPark/module/application-authorization"
	application_authorization_dto "github.com/APIParkLab/APIPark/module/application-authorization/dto"

	"github.com/APIParkLab/APIPark/model/plugin_model"
	"github.com/APIParkLab/APIPark/service/api"

	router_dto "github.com/APIParkLab/APIPark/module/router/dto"

	model_runtime "github.com/APIParkLab/APIPark/ai-provider/model-runtime"
	"github.com/APIParkLab/APIPark/module/ai"
	ai_api "github.com/APIParkLab/APIPark/module/ai-api"
	ai_api_dto "github.com/APIParkLab/APIPark/module/ai-api/dto"
	"github.com/APIParkLab/APIPark/module/router"
	"github.com/APIParkLab/APIPark/module/service"
	service_dto "github.com/APIParkLab/APIPark/module/service/dto"
	"github.com/APIParkLab/APIPark/module/upstream"
	upstream_dto "github.com/APIParkLab/APIPark/module/upstream/dto"
	"github.com/eolinker/go-common/store"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

var (
	_ IServiceController = (*imlServiceController)(nil)

	_ IAppController = (*imlAppController)(nil)
)

type imlServiceController struct {
	module              service.IServiceModule          `autowired:""`
	docModule           service.IServiceDocModule       `autowired:""`
	subscribeModule     subscribe.ISubscribeModule      `autowired:""`
	aiAPIModule         ai_api.IAPIModule               `autowired:""`
	routerModule        router.IRouterModule            `autowired:""`
	apiDocModule        api_doc.IAPIDocModule           `autowired:""`
	providerModule      ai.IProviderModule              `autowired:""`
	aiLocalModel        ai_local.ILocalModelModule      `autowired:""`
	appModule           service.IAppModule              `autowired:""`
	upstreamModule      upstream.IUpstreamModule        `autowired:""`
	settingModule       system.ISettingModule           `autowired:""`
	teamModule          team.ITeamModule                `autowired:""`
	catalogueModule     catalogue.ICatalogueModule      `autowired:""`
	monitorModule       monitor.IMonitorStatisticModule `autowired:""`
	monitorConfigModule monitor.IMonitorConfigModule    `autowired:""`
	transaction         store.ITransaction              `autowired:""`
}

func (i *imlServiceController) RestLogInfo(ctx *gin.Context, serviceId string, logId string) (*service_dto.RestLogInfo, error) {
	return i.module.RestLogInfo(ctx, serviceId, logId)
}

func (i *imlServiceController) AILogInfo(ctx *gin.Context, serviceId string, logId string) (*service_dto.AILogInfo, error) {
	return i.module.AILogInfo(ctx, serviceId, logId)
}

func (i *imlServiceController) AILogs(ctx *gin.Context, serviceId string, start string, end string, page string, size string) ([]*service_dto.AILogItem, int64, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, 0, err
	}
	if serviceId == "" {
		return nil, 0, fmt.Errorf("service id is empty")
	}
	if page == "" {
		page = "1"
	}
	if size == "" {
		size = "20"
	}
	p, err := strconv.Atoi(page)
	if err != nil {
		return nil, 0, err
	}
	ps, err := strconv.Atoi(size)
	if err != nil {
		return nil, 0, err
	}

	return i.module.AILogs(ctx, serviceId, s, e, p, ps)
}

func (i *imlServiceController) RestLogs(ctx *gin.Context, serviceId string, start string, end string, page string, size string) ([]*service_dto.RestLogItem, int64, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, 0, err
	}
	if serviceId == "" {
		return nil, 0, fmt.Errorf("service id is empty")
	}
	if page == "" {
		page = "1"
	}
	if size == "" {
		size = "20"
	}
	p, err := strconv.Atoi(page)
	if err != nil {
		return nil, 0, err
	}
	ps, err := strconv.Atoi(size)
	if err != nil {
		return nil, 0, err
	}

	return i.module.RestLogs(ctx, serviceId, s, e, p, ps)
}

func (i *imlServiceController) ServiceOverview(ctx *gin.Context, serviceId string) (*service_dto.Overview, error) {
	o, err := i.module.ServiceOverview(ctx, serviceId)
	if err != nil {
		return nil, err
	}
	cfg, err := i.monitorConfigModule.GetMonitorConfig(ctx)
	if err != nil {
		return nil, err
	}
	if len(cfg.Config) < 1 {
		return o, nil
	}
	statistics, err := i.monitorModule.ProviderStatistics(ctx, &monitor_dto.StatisticInput{
		Services: []string{serviceId},
		CommonInput: &monitor_dto.CommonInput{
			Start: time.Now().Add(-24 * 30 * time.Hour).Unix(),
			End:   time.Now().Unix(),
		},
	})
	if err != nil {
		return nil, err
	}
	if len(statistics) < 1 {
		return o, nil
	}
	o.InvokeNum = statistics[0].RequestTotal
	return o, nil
}

func (i *imlServiceController) AIChartOverview(ctx *gin.Context, serviceId string, start string, end string) (*monitor_dto.ServiceChartAIOverview, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, err
	}
	if serviceId == "" {
		return nil, fmt.Errorf("service is required")
	}
	so, err := i.module.ServiceOverview(ctx, serviceId)
	if err != nil {
		return nil, err
	}
	result := &monitor_dto.ServiceChartAIOverview{
		EnableMCP:     so.EnableMCP,
		SubscriberNum: so.SubscriberNum,
		APINum:        so.APINum,
		ServiceKind:   so.ServiceKind,
	}
	cfg, err := i.monitorConfigModule.GetMonitorConfig(ctx)
	if err != nil {
		return nil, err
	}
	if len(cfg.Config) < 1 {
		return result, nil
	}

	o, err := i.monitorModule.AIChartOverview(ctx, serviceId, s, e)
	if err != nil {
		return nil, err
	}

	result.AvailableMonitor = true
	result.ChartAIOverview = o
	return result, nil
}

func (i *imlServiceController) RestChartOverview(ctx *gin.Context, serviceId string, start string, end string) (*monitor_dto.ServiceChartRestOverview, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, err
	}
	if serviceId == "" {
		return nil, fmt.Errorf("service is required")
	}
	so, err := i.module.ServiceOverview(ctx, serviceId)
	if err != nil {
		return nil, err
	}
	result := &monitor_dto.ServiceChartRestOverview{
		EnableMCP:     so.EnableMCP,
		SubscriberNum: so.SubscriberNum,
		APINum:        so.APINum,
		ServiceKind:   so.ServiceKind,
	}
	cfg, err := i.monitorConfigModule.GetMonitorConfig(ctx)
	if err != nil {
		return nil, err
	}
	if len(cfg.Config) < 1 {
		return result, nil
	}
	o, err := i.monitorModule.RestChartOverview(ctx, serviceId, s, e)
	if err != nil {
		return nil, err
	}
	result.AvailableMonitor = true
	result.ChartRestOverview = o
	return result, nil
}

func formatTime(start string, end string) (int64, int64, error) {
	s, err := strconv.ParseInt(start, 10, 64)
	if err != nil {
		return 0, 0, fmt.Errorf("parse start time %s error: %w", start, err)
	}
	e, err := strconv.ParseInt(end, 10, 64)
	if err != nil {
		return 0, 0, fmt.Errorf("parse end time %s error: %w", end, err)
	}
	return s, e, nil
}

func (i *imlServiceController) Top10(ctx *gin.Context, serviceId string, start string, end string) ([]*monitor_dto.TopN, []*monitor_dto.TopN, error) {
	if serviceId == "" {
		return nil, nil, fmt.Errorf("serviceId is required")
	}
	info, err := i.module.Get(ctx, serviceId)
	if err != nil {
		return nil, nil, err
	}

	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, nil, err
	}

	return i.monitorModule.Top(ctx, serviceId, s, e, 10, info.ServiceKind)
}

func (i *imlServiceController) QuickCreateAIService(ctx *gin.Context, input *service_dto.QuickCreateAIService) error {
	return i.transaction.Transaction(ctx, func(txCtx context.Context) error {
		enable := true
		err := i.providerModule.UpdateProviderConfig(ctx, input.Provider, &ai_dto.UpdateConfig{
			Config: input.Config,
			Enable: &enable,
		})
		if err != nil {
			return err
		}
		p, err := i.providerModule.Provider(ctx, input.Provider)
		if err != nil {
			return err
		}
		id := uuid.NewString()
		prefix := fmt.Sprintf("/%s", id[:8])
		catalogueInfo, err := i.catalogueModule.DefaultCatalogue(ctx)
		if err != nil {
			return err
		}
		_, err = i.createAIService(ctx, input.Team, &service_dto.CreateService{
			Id:           uuid.NewString(),
			Name:         input.Provider + " AI Service",
			Prefix:       prefix,
			Description:  "Quick create by AI provider",
			ServiceType:  "public",
			State:        "normal",
			Catalogue:    catalogueInfo.Id,
			ApprovalType: "auto",
			Provider:     &input.Provider,
			Model:        &p.DefaultLLM,
			Kind:         "ai",
		})
		return err
	})
}

// OpenAPIConfig 從 OpenAPI YAML 文件中解析的配置資訊
type OpenAPIConfig struct {
	ServiceName    string // info.title
	FirstPath      string // 第一個 path 的 key
	FirstSummary   string // 第一個 path 的 summary
	ServerURL      string // servers[0].url
	ServerHost     string // 從 server URL 提取的 host:port
	ServerPath     string // 從 server URL 提取的 path
}

// parseOpenAPIConfig 解析 OpenAPI YAML 文件並提取所需配置
func parseOpenAPIConfig(content []byte) (*OpenAPIConfig, error) {
	// 使用現有的 openapi3 loader 解析文件
	doc, err := loader.LoadFromData(content)
	if err != nil {
		return nil, fmt.Errorf("failed to parse OpenAPI document: %w", err)
	}

	config := &OpenAPIConfig{}

	// 提取服務名稱 (info.title)
	if doc.Info == nil || doc.Info.Title == "" {
		return nil, fmt.Errorf("OpenAPI document missing required field: info.title")
	}
	config.ServiceName = doc.Info.Title

	// 提取第一個 path 和其 summary
	if doc.Paths == nil || len(doc.Paths.Map()) == 0 {
		return nil, fmt.Errorf("OpenAPI document missing required field: paths")
	}
	
	// 取得第一個 path
	for pathKey, pathItem := range doc.Paths.Map() {
		config.FirstPath = pathKey
		
		// 取得第一個 operation 的 summary
		if pathItem.Get != nil && pathItem.Get.Summary != "" {
			config.FirstSummary = pathItem.Get.Summary
			break
		}
		if pathItem.Post != nil && pathItem.Post.Summary != "" {
			config.FirstSummary = pathItem.Post.Summary
			break
		}
		if pathItem.Put != nil && pathItem.Put.Summary != "" {
			config.FirstSummary = pathItem.Put.Summary
			break
		}
		if pathItem.Delete != nil && pathItem.Delete.Summary != "" {
			config.FirstSummary = pathItem.Delete.Summary
			break
		}
		if pathItem.Patch != nil && pathItem.Patch.Summary != "" {
			config.FirstSummary = pathItem.Patch.Summary
			break
		}
		// 如果沒有找到 summary，使用 path 作為預設值
		if config.FirstSummary == "" {
			config.FirstSummary = strings.TrimPrefix(pathKey, "/")
		}
		break
	}

	// 提取 server URL
	if doc.Servers == nil || len(doc.Servers) == 0 {
		return nil, fmt.Errorf("OpenAPI document missing required field: servers")
	}
	config.ServerURL = doc.Servers[0].URL

	// 解析 server URL 提取 host:port 和 path
	parsedURL, err := url.Parse(config.ServerURL)
	if err != nil {
		return nil, fmt.Errorf("failed to parse server URL: %w", err)
	}
	
	config.ServerHost = parsedURL.Host
	config.ServerPath = parsedURL.Path

	// 驗證必要欄位
	if config.ServerHost == "" {
		return nil, fmt.Errorf("server URL missing host:port information")
	}
	if config.ServerPath == "" {
		return nil, fmt.Errorf("server URL missing path information")
	}

	return config, nil
}

func (i *imlServiceController) QuickCreateRestfulService(ctx *gin.Context) error {
	fileHeader, err := ctx.FormFile("file")
	if err != nil {
		return err
	}
	file, err := fileHeader.Open()
	if err != nil {
		return err
	}
	content, err := io.ReadAll(file)
	if err != nil {
		return err
	}
	typ := ctx.PostForm("type")
	switch typ {
	case "swagger", "":
	default:
		return fmt.Errorf("type %s not support", typ)
	}

	return i.transaction.Transaction(ctx, func(txCtx context.Context) error {
		teamId := ctx.PostForm("team")
		id := uuid.NewString()
		prefix := fmt.Sprintf("/%s", id[:8])
		catalogueInfo, err := i.catalogueModule.DefaultCatalogue(ctx)
		if err != nil {
			return err
		}
		s, err := i.module.Create(ctx, teamId, &service_dto.CreateService{
			Id:           uuid.NewString(),
			Name:         "Restful Service By Swagger",
			Prefix:       prefix,
			Description:  "Auto create by upload swagger",
			ServiceType:  "public",
			State:        "normal",
			Catalogue:    catalogueInfo.Id,
			ApprovalType: "auto",
			Kind:         "rest",
		})
		if err != nil {
			return err
		}
		_, err = i.apiDocModule.UpdateDoc(ctx, s.Id, &api_doc_dto.UpdateDoc{
			Id:      s.Id,
			Content: string(content),
		})
		if err != nil {
			return err
		}
		path := prefix + "/"
		_, err = i.routerModule.Create(ctx, s.Id, &router_dto.Create{
			Id:          uuid.NewString(),
			Name:        "",
			Path:        path + "*",
			Methods:     []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodPatch, http.MethodOptions},
			Description: "auto create by create service",
			Protocols:   []string{"http", "https"},
			Proxy: &router_dto.InputProxy{
				Path:    path,
				Timeout: 30000,
				Retry:   0,
			},
			Disable: false,
		})
		if err != nil {
			return err
		}
		apps, err := i.appModule.Search(ctx, teamId, "")
		if err != nil {
			return err
		}
		for _, app := range apps {
			i.subscribeModule.AddSubscriber(ctx, id, &subscribe_dto.AddSubscriber{
				Application: app.Id,
			})
		}

		return nil
	})
}

var (
	loader = openapi3.NewLoader()
)

func (i *imlServiceController) swagger(ctx *gin.Context, id string) (*openapi3.T, error) {
	doc, err := i.apiDocModule.GetDoc(ctx, id)
	if err != nil {
		return nil, err
	}
	tmp, err := loader.LoadFromData([]byte(doc.Content))
	if err != nil {
		return nil, err
	}
	cfg := i.settingModule.Get(ctx)

	tmp.AddServer(&openapi3.Server{
		URL: cfg.InvokeAddress,
	})
	return tmp, nil
}

func (i *imlServiceController) ExportSwagger(ctx *gin.Context) {
	id, has := ctx.Params.Get("id")
	if !has {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: fmt.Sprintf("id is required"),
		})
		return
	}
	s, err := i.module.Get(ctx, id)
	if err != nil {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: err.Error(),
		})
		return
	}
	tmp, err := i.swagger(ctx, id)
	if err != nil {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: err.Error(),
		})
		return
	}

	data, _ := tmp.MarshalJSON()
	ctx.Status(200)
	// 设置响应头
	ctx.Header("Content-Disposition", fmt.Sprintf("attachment; filename=%s.json", strings.Replace(s.Name, " ", "_", -1)))
	ctx.Header("Content-Type", "application/octet-stream")
	ctx.Header("Content-Transfer-Encoding", "binary")
	ctx.Writer.Write(data)
	return
}

func (i *imlServiceController) Swagger(ctx *gin.Context) {
	id, has := ctx.Params.Get("id")
	if !has {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: fmt.Sprintf("id is required"),
		})
		return
	}
	tmp, err := i.swagger(ctx, id)
	if err != nil {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: err.Error(),
		})
		return
	}
	ctx.JSON(200, tmp)
	return
}

func (i *imlServiceController) Simple(ctx *gin.Context) ([]*service_dto.SimpleServiceItem, error) {
	return i.module.Simple(ctx)
}

func (i *imlServiceController) MySimple(ctx *gin.Context) ([]*service_dto.SimpleServiceItem, error) {
	return i.module.MySimple(ctx)
}

func (i *imlServiceController) editAIService(ctx *gin.Context, id string, input *service_dto.EditService) (*service_dto.Service, error) {

	if input.Provider == nil {
		return nil, fmt.Errorf("provider is required")
	}
	if *input.Provider != ai_provider_local.ProviderLocal {
		_, has := model_runtime.GetProvider(*input.Provider)
		if !has {
			return nil, fmt.Errorf("provider not found")
		}
	}

	info, err := i.module.Edit(ctx, id, input)
	if err != nil {
		return nil, err
	}
	//_, err = i.upstreamModule.Save(ctx, id, newAIUpstream(id, *input.Provider, p.URI()))

	return info, nil
}

func (i *imlServiceController) createAIService(ctx *gin.Context, teamID string, input *service_dto.CreateService) (*service_dto.Service, error) {
	if input.Provider == nil {
		return nil, fmt.Errorf("provider is required")
	}

	if input.Id == "" {
		input.Id = uuid.New().String()
	}
	if input.Prefix == "" {
		if len(input.Id) < 9 {
			input.Prefix = input.Id
		} else {
			input.Prefix = input.Id[:8]
		}
	}
	modelId := ""
	modelCfg := ""
	modelType := "online"
	if *input.Provider == ai_provider_local.ProviderLocal {
		modelType = "local"
		list, err := i.aiLocalModel.SimpleList(ctx)
		if err != nil {
			return nil, err
		}
		if len(list) == 0 {
			return nil, fmt.Errorf("no local model")
		}
		modelId = list[0].Id
		modelCfg = ai_provider_local.LocalConfig
	} else {
		pv, err := i.providerModule.Provider(ctx, *input.Provider)
		if err != nil {
			return nil, err
		}
		p, has := model_runtime.GetProvider(*input.Provider)
		if !has {
			return nil, fmt.Errorf("provider not found")
		}
		m, has := p.GetModel(pv.DefaultLLM)
		if !has {
			return nil, fmt.Errorf("model %s not found", pv.DefaultLLM)
		}
		//modelId = m.ID()
		modelId = m.Name()
		modelCfg = m.DefaultConfig()

	}

	var info *service_dto.Service
	err := i.transaction.Transaction(ctx, func(txCtx context.Context) error {
		var err error
		info, err = i.module.Create(ctx, teamID, input)
		if err != nil {
			return err
		}
		prefix := strings.Replace(input.Prefix, ":", "_", -1)
		path := fmt.Sprintf("/%s/chat/completions", strings.Trim(prefix, "/"))
		timeout := 300000
		retry := 0
		aiPrompt := &ai_api_dto.AiPrompt{
			Variables: []*ai_api_dto.AiPromptVariable{},
			Prompt:    "",
		}
		aiModel := &ai_api_dto.AiModel{
			Id:       modelId,
			Config:   modelCfg,
			Provider: *input.Provider,
			Type:     modelType,
		}
		name := "Demo AI API "
		description := "This is a demo that shows you how to use a Chat API."
		apiId := uuid.New().String()
		err = i.aiAPIModule.Create(
			ctx,
			info.Id,
			&ai_api_dto.CreateAPI{
				Id:          apiId,
				Name:        name,
				Path:        path,
				Description: description,
				Disable:     false,
				AiPrompt:    aiPrompt,
				AiModel:     aiModel,
				Timeout:     timeout,
				Retry:       retry,
			},
		)
		if err != nil {
			return err
		}
		plugins := make(map[string]api.PluginSetting)
		plugins["ai_prompt"] = api.PluginSetting{
			Config: plugin_model.ConfigType{
				"prompt":    aiPrompt.Prompt,
				"variables": aiPrompt.Variables,
			},
		}
		plugins["ai_formatter"] = api.PluginSetting{
			Config: plugin_model.ConfigType{
				"model":    aiModel.Id,
				"provider": fmt.Sprintf("%s@ai-provider", info.Provider.Id),
				"config":   aiModel.Config,
			},
		}
		_, err = i.routerModule.Create(ctx, info.Id, &router_dto.Create{
			Id:   apiId,
			Name: name,
			Path: path,
			Methods: []string{
				http.MethodPost,
			},
			Description: description,
			Protocols:   []string{"http", "https"},
			MatchRules:  nil,
			Proxy: &router_dto.InputProxy{
				Path:    path,
				Timeout: timeout,
				Retry:   retry,
				Plugins: plugins,
			},
			Disable:  false,
			Upstream: info.Provider.Id,
		})
		if err != nil {
			return err
		}
		apps, err := i.appModule.Search(ctx, info.Team.Id, "")
		if err != nil {
			return err
		}
		for _, app := range apps {
			i.subscribeModule.AddSubscriber(ctx, info.Id, &subscribe_dto.AddSubscriber{
				Application: app.Id,
			})
		}

		return i.docModule.SaveServiceDoc(ctx, info.Id, &service_dto.SaveServiceDoc{
			Doc: "",
		})
	})

	return info, err
}

func (i *imlServiceController) SearchMyServices(ctx *gin.Context, teamId string, keyword string) ([]*service_dto.ServiceItem, error) {
	return i.module.SearchMyServices(ctx, teamId, keyword)
}

func (i *imlServiceController) Get(ctx *gin.Context, id string) (*service_dto.Service, error) {
	now := time.Now()
	defer func() {
		log.Infof("get service %s cost %d ms", id, time.Since(now).Milliseconds())
	}()
	return i.module.Get(ctx, id)
}

func (i *imlServiceController) Search(ctx *gin.Context, teamIDs string, keyword string) ([]*service_dto.ServiceItem, error) {
	return i.module.Search(ctx, teamIDs, keyword)
}

func (i *imlServiceController) Create(ctx *gin.Context, teamID string, input *service_dto.CreateService) (*service_dto.Service, error) {
	if input.Kind == "ai" {
		return i.createAIService(ctx, teamID, input)
	}
	var err error
	var info *service_dto.Service
	err = i.transaction.Transaction(ctx, func(ctx context.Context) error {
		info, err = i.module.Create(ctx, teamID, input)
		if err != nil {
			return err
		}
		path := fmt.Sprintf("/%s/", strings.Trim(input.Prefix, "/"))
		_, err = i.routerModule.Create(ctx, info.Id, &router_dto.Create{
			Id:          uuid.New().String(),
			Name:        "",
			Path:        path + "*",
			Methods:     []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodPatch, http.MethodOptions},
			Description: "auto create by create service",
			Protocols:   []string{"http", "https"},
			MatchRules:  nil,
			Upstream:    "",
			Proxy: &router_dto.InputProxy{
				Path:    path,
				Timeout: 30000,
				Retry:   0,
			},
			Disable: false,
		})
		apps, err := i.appModule.Search(ctx, teamID, "")
		if err != nil {
			return err
		}
		for _, app := range apps {
			i.subscribeModule.AddSubscriber(ctx, info.Id, &subscribe_dto.AddSubscriber{
				Application: app.Id,
			})
		}
		return err
	})
	return info, err
}

func (i *imlServiceController) Edit(ctx *gin.Context, id string, input *service_dto.EditService) (*service_dto.Service, error) {
	info, err := i.Get(ctx, id)
	if err != nil {
		return nil, err
	}
	if info.ServiceKind == "ai" {
		return i.editAIService(ctx, id, input)
	}
	return i.module.Edit(ctx, id, input)
}

func (i *imlServiceController) Delete(ctx *gin.Context, id string) error {
	return i.module.Delete(ctx, id)
}

func (i *imlServiceController) ServiceDoc(ctx *gin.Context, id string) (*service_dto.ServiceDoc, error) {
	return i.docModule.ServiceDoc(ctx, id)
}

func (i *imlServiceController) SaveServiceDoc(ctx *gin.Context, id string, input *service_dto.SaveServiceDoc) error {
	return i.docModule.SaveServiceDoc(ctx, id, input)
}

type imlAppController struct {
	module     service.IAppModule                             `autowired:""`
	authModule application_authorization.IAuthorizationModule `autowired:""`
}

func (i *imlAppController) SearchCanSubscribe(ctx *gin.Context, serviceId string) ([]*service_dto.SubscribeAppItem, error) {
	items, _, err := i.module.SearchCanSubscribe(ctx, serviceId)
	return items, err
}

func (i *imlAppController) Search(ctx *gin.Context, teamId string, keyword string) ([]*service_dto.AppItem, error) {
	return i.module.Search(ctx, teamId, keyword)
}

func (i *imlAppController) CreateApp(ctx *gin.Context, teamID string, input *service_dto.CreateApp) (*service_dto.App, error) {
	app, err := i.module.CreateApp(ctx, teamID, input)
	if err != nil {
		return nil, err
	}
	_, err = i.authModule.AddAuthorization(ctx, app.Id, &application_authorization_dto.CreateAuthorization{
		Name:       "Default API Key",
		Driver:     "apikey",
		Position:   "Header",
		TokenName:  "Authorization",
		ExpireTime: 0,
		Config: map[string]interface{}{
			"apikey": uuid.New().String(),
		},
	})
	if err != nil {
		i.module.DeleteApp(ctx, app.Id)
		return nil, err
	}
	return app, nil
}
func (i *imlAppController) UpdateApp(ctx *gin.Context, appId string, input *service_dto.UpdateApp) (*service_dto.App, error) {
	return i.module.UpdateApp(ctx, appId, input)
}

func (i *imlAppController) SearchMyApps(ctx *gin.Context, teamId string, keyword string) ([]*service_dto.AppItem, error) {
	return i.module.SearchMyApps(ctx, teamId, keyword)
}

func (i *imlAppController) SimpleApps(ctx *gin.Context, keyword string) ([]*service_dto.SimpleAppItem, error) {
	return i.module.SimpleApps(ctx, keyword)
}

func (i *imlAppController) MySimpleApps(ctx *gin.Context, keyword string) ([]*service_dto.SimpleAppItem, error) {
	return i.module.MySimpleApps(ctx, keyword)
}

func (i *imlAppController) GetApp(ctx *gin.Context, appId string) (*service_dto.App, error) {
	return i.module.GetApp(ctx, appId)
}

func (i *imlAppController) DeleteApp(ctx *gin.Context, appId string) error {
	return i.module.DeleteApp(ctx, appId)
}

//func newAIUpstream(id string, provider string, uri model_runtime.IProviderURI) *upstream_dto.Upstream {
//	return &upstream_dto.Upstream{
//		Type:            "http",
//		Balance:         "round-robin",
//		Timeout:         300000,
//		Retry:           0,
//		Remark:          fmt.Sprintf("auto create by ai service %s,provider is %s", id, provider),
//		LimitPeerSecond: 0,
//		ProxyHeaders:    nil,
//		Scheme:          uri.Scheme(),
//		PassHost:        "node",
//		Nodes: []*upstream_dto.NodeConfig{
//			{
//				Address: uri.Host(),
//				Weight:  100,
//			},
//		},
//	}
//}

```

現在修改 `QuickCreateRestfulService` 函數來使用動態配置：


```go
package service

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/APIParkLab/APIPark/module/monitor"
	monitor_dto "github.com/APIParkLab/APIPark/module/monitor/dto"

	ai_provider_local "github.com/APIParkLab/APIPark/ai-provider/local"

	subscribe_dto "github.com/APIParkLab/APIPark/module/subscribe/dto"

	"github.com/APIParkLab/APIPark/module/subscribe"

	ai_local "github.com/APIParkLab/APIPark/module/ai-local"

	ai_dto "github.com/APIParkLab/APIPark/module/ai/dto"

	api_doc_dto "github.com/APIParkLab/APIPark/module/api-doc/dto"

	"github.com/APIParkLab/APIPark/module/catalogue"

	"github.com/APIParkLab/APIPark/module/team"

	"github.com/eolinker/go-common/pm3"

	"github.com/APIParkLab/APIPark/module/system"

	"github.com/getkin/kin-openapi/openapi3"

	api_doc "github.com/APIParkLab/APIPark/module/api-doc"

	"github.com/eolinker/eosc/log"

	application_authorization "github.com/APIParkLab/APIPark/module/application-authorization"
	application_authorization_dto "github.com/APIParkLab/APIPark/module/application-authorization/dto"

	"github.com/APIParkLab/APIPark/model/plugin_model"
	"github.com/APIParkLab/APIPark/service/api"

	router_dto "github.com/APIParkLab/APIPark/module/router/dto"

	model_runtime "github.com/APIParkLab/APIPark/ai-provider/model-runtime"
	"github.com/APIParkLab/APIPark/module/ai"
	ai_api "github.com/APIParkLab/APIPark/module/ai-api"
	ai_api_dto "github.com/APIParkLab/APIPark/module/ai-api/dto"
	"github.com/APIParkLab/APIPark/module/router"
	"github.com/APIParkLab/APIPark/module/service"
	service_dto "github.com/APIParkLab/APIPark/module/service/dto"
	"github.com/APIParkLab/APIPark/module/upstream"
	upstream_dto "github.com/APIParkLab/APIPark/module/upstream/dto"
	"github.com/eolinker/go-common/store"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

var (
	_ IServiceController = (*imlServiceController)(nil)

	_ IAppController = (*imlAppController)(nil)
)

type imlServiceController struct {
	module              service.IServiceModule          `autowired:""`
	docModule           service.IServiceDocModule       `autowired:""`
	subscribeModule     subscribe.ISubscribeModule      `autowired:""`
	aiAPIModule         ai_api.IAPIModule               `autowired:""`
	routerModule        router.IRouterModule            `autowired:""`
	apiDocModule        api_doc.IAPIDocModule           `autowired:""`
	providerModule      ai.IProviderModule              `autowired:""`
	aiLocalModel        ai_local.ILocalModelModule      `autowired:""`
	appModule           service.IAppModule              `autowired:""`
	upstreamModule      upstream.IUpstreamModule        `autowired:""`
	settingModule       system.ISettingModule           `autowired:""`
	teamModule          team.ITeamModule                `autowired:""`
	catalogueModule     catalogue.ICatalogueModule      `autowired:""`
	monitorModule       monitor.IMonitorStatisticModule `autowired:""`
	monitorConfigModule monitor.IMonitorConfigModule    `autowired:""`
	transaction         store.ITransaction              `autowired:""`
}

func (i *imlServiceController) RestLogInfo(ctx *gin.Context, serviceId string, logId string) (*service_dto.RestLogInfo, error) {
	return i.module.RestLogInfo(ctx, serviceId, logId)
}

func (i *imlServiceController) AILogInfo(ctx *gin.Context, serviceId string, logId string) (*service_dto.AILogInfo, error) {
	return i.module.AILogInfo(ctx, serviceId, logId)
}

func (i *imlServiceController) AILogs(ctx *gin.Context, serviceId string, start string, end string, page string, size string) ([]*service_dto.AILogItem, int64, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, 0, err
	}
	if serviceId == "" {
		return nil, 0, fmt.Errorf("service id is empty")
	}
	if page == "" {
		page = "1"
	}
	if size == "" {
		size = "20"
	}
	p, err := strconv.Atoi(page)
	if err != nil {
		return nil, 0, err
	}
	ps, err := strconv.Atoi(size)
	if err != nil {
		return nil, 0, err
	}

	return i.module.AILogs(ctx, serviceId, s, e, p, ps)
}

func (i *imlServiceController) RestLogs(ctx *gin.Context, serviceId string, start string, end string, page string, size string) ([]*service_dto.RestLogItem, int64, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, 0, err
	}
	if serviceId == "" {
		return nil, 0, fmt.Errorf("service id is empty")
	}
	if page == "" {
		page = "1"
	}
	if size == "" {
		size = "20"
	}
	p, err := strconv.Atoi(page)
	if err != nil {
		return nil, 0, err
	}
	ps, err := strconv.Atoi(size)
	if err != nil {
		return nil, 0, err
	}

	return i.module.RestLogs(ctx, serviceId, s, e, p, ps)
}

func (i *imlServiceController) ServiceOverview(ctx *gin.Context, serviceId string) (*service_dto.Overview, error) {
	o, err := i.module.ServiceOverview(ctx, serviceId)
	if err != nil {
		return nil, err
	}
	cfg, err := i.monitorConfigModule.GetMonitorConfig(ctx)
	if err != nil {
		return nil, err
	}
	if len(cfg.Config) < 1 {
		return o, nil
	}
	statistics, err := i.monitorModule.ProviderStatistics(ctx, &monitor_dto.StatisticInput{
		Services: []string{serviceId},
		CommonInput: &monitor_dto.CommonInput{
			Start: time.Now().Add(-24 * 30 * time.Hour).Unix(),
			End:   time.Now().Unix(),
		},
	})
	if err != nil {
		return nil, err
	}
	if len(statistics) < 1 {
		return o, nil
	}
	o.InvokeNum = statistics[0].RequestTotal
	return o, nil
}

func (i *imlServiceController) AIChartOverview(ctx *gin.Context, serviceId string, start string, end string) (*monitor_dto.ServiceChartAIOverview, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, err
	}
	if serviceId == "" {
		return nil, fmt.Errorf("service is required")
	}
	so, err := i.module.ServiceOverview(ctx, serviceId)
	if err != nil {
		return nil, err
	}
	result := &monitor_dto.ServiceChartAIOverview{
		EnableMCP:     so.EnableMCP,
		SubscriberNum: so.SubscriberNum,
		APINum:        so.APINum,
		ServiceKind:   so.ServiceKind,
	}
	cfg, err := i.monitorConfigModule.GetMonitorConfig(ctx)
	if err != nil {
		return nil, err
	}
	if len(cfg.Config) < 1 {
		return result, nil
	}

	o, err := i.monitorModule.AIChartOverview(ctx, serviceId, s, e)
	if err != nil {
		return nil, err
	}

	result.AvailableMonitor = true
	result.ChartAIOverview = o
	return result, nil
}

func (i *imlServiceController) RestChartOverview(ctx *gin.Context, serviceId string, start string, end string) (*monitor_dto.ServiceChartRestOverview, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, err
	}
	if serviceId == "" {
		return nil, fmt.Errorf("service is required")
	}
	so, err := i.module.ServiceOverview(ctx, serviceId)
	if err != nil {
		return nil, err
	}
	result := &monitor_dto.ServiceChartRestOverview{
		EnableMCP:     so.EnableMCP,
		SubscriberNum: so.SubscriberNum,
		APINum:        so.APINum,
		ServiceKind:   so.ServiceKind,
	}
	cfg, err := i.monitorConfigModule.GetMonitorConfig(ctx)
	if err != nil {
		return nil, err
	}
	if len(cfg.Config) < 1 {
		return result, nil
	}
	o, err := i.monitorModule.RestChartOverview(ctx, serviceId, s, e)
	if err != nil {
		return nil, err
	}
	result.AvailableMonitor = true
	result.ChartRestOverview = o
	return result, nil
}

func formatTime(start string, end string) (int64, int64, error) {
	s, err := strconv.ParseInt(start, 10, 64)
	if err != nil {
		return 0, 0, fmt.Errorf("parse start time %s error: %w", start, err)
	}
	e, err := strconv.ParseInt(end, 10, 64)
	if err != nil {
		return 0, 0, fmt.Errorf("parse end time %s error: %w", end, err)
	}
	return s, e, nil
}

func (i *imlServiceController) Top10(ctx *gin.Context, serviceId string, start string, end string) ([]*monitor_dto.TopN, []*monitor_dto.TopN, error) {
	if serviceId == "" {
		return nil, nil, fmt.Errorf("serviceId is required")
	}
	info, err := i.module.Get(ctx, serviceId)
	if err != nil {
		return nil, nil, err
	}

	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, nil, err
	}

	return i.monitorModule.Top(ctx, serviceId, s, e, 10, info.ServiceKind)
}

func (i *imlServiceController) QuickCreateAIService(ctx *gin.Context, input *service_dto.QuickCreateAIService) error {
	return i.transaction.Transaction(ctx, func(txCtx context.Context) error {
		enable := true
		err := i.providerModule.UpdateProviderConfig(ctx, input.Provider, &ai_dto.UpdateConfig{
			Config: input.Config,
			Enable: &enable,
		})
		if err != nil {
			return err
		}
		p, err := i.providerModule.Provider(ctx, input.Provider)
		if err != nil {
			return err
		}
		id := uuid.NewString()
		prefix := fmt.Sprintf("/%s", id[:8])
		catalogueInfo, err := i.catalogueModule.DefaultCatalogue(ctx)
		if err != nil {
			return err
		}
		_, err = i.createAIService(ctx, input.Team, &service_dto.CreateService{
			Id:           uuid.NewString(),
			Name:         input.Provider + " AI Service",
			Prefix:       prefix,
			Description:  "Quick create by AI provider",
			ServiceType:  "public",
			State:        "normal",
			Catalogue:    catalogueInfo.Id,
			ApprovalType: "auto",
			Provider:     &input.Provider,
			Model:        &p.DefaultLLM,
			Kind:         "ai",
		})
		return err
	})
}

// OpenAPIConfig 從 OpenAPI YAML 文件中解析的配置資訊
type OpenAPIConfig struct {
	ServiceName    string // info.title
	FirstPath      string // 第一個 path 的 key
	FirstSummary   string // 第一個 path 的 summary
	ServerURL      string // servers[0].url
	ServerHost     string // 從 server URL 提取的 host:port
	ServerPath     string // 從 server URL 提取的 path
}

// parseOpenAPIConfig 解析 OpenAPI YAML 文件並提取所需配置
func parseOpenAPIConfig(content []byte) (*OpenAPIConfig, error) {
	// 使用現有的 openapi3 loader 解析文件
	doc, err := loader.LoadFromData(content)
	if err != nil {
		return nil, fmt.Errorf("failed to parse OpenAPI document: %w", err)
	}

	config := &OpenAPIConfig{}

	// 提取服務名稱 (info.title)
	if doc.Info == nil || doc.Info.Title == "" {
		return nil, fmt.Errorf("OpenAPI document missing required field: info.title")
	}
	config.ServiceName = doc.Info.Title

	// 提取第一個 path 和其 summary
	if doc.Paths == nil || len(doc.Paths.Map()) == 0 {
		return nil, fmt.Errorf("OpenAPI document missing required field: paths")
	}
	
	// 取得第一個 path
	for pathKey, pathItem := range doc.Paths.Map() {
		config.FirstPath = pathKey
		
		// 取得第一個 operation 的 summary
		if pathItem.Get != nil && pathItem.Get.Summary != "" {
			config.FirstSummary = pathItem.Get.Summary
			break
		}
		if pathItem.Post != nil && pathItem.Post.Summary != "" {
			config.FirstSummary = pathItem.Post.Summary
			break
		}
		if pathItem.Put != nil && pathItem.Put.Summary != "" {
			config.FirstSummary = pathItem.Put.Summary
			break
		}
		if pathItem.Delete != nil && pathItem.Delete.Summary != "" {
			config.FirstSummary = pathItem.Delete.Summary
			break
		}
		if pathItem.Patch != nil && pathItem.Patch.Summary != "" {
			config.FirstSummary = pathItem.Patch.Summary
			break
		}
		// 如果沒有找到 summary，使用 path 作為預設值
		if config.FirstSummary == "" {
			config.FirstSummary = strings.TrimPrefix(pathKey, "/")
		}
		break
	}

	// 提取 server URL
	if doc.Servers == nil || len(doc.Servers) == 0 {
		return nil, fmt.Errorf("OpenAPI document missing required field: servers")
	}
	config.ServerURL = doc.Servers[0].URL

	// 解析 server URL 提取 host:port 和 path
	parsedURL, err := url.Parse(config.ServerURL)
	if err != nil {
		return nil, fmt.Errorf("failed to parse server URL: %w", err)
	}
	
	config.ServerHost = parsedURL.Host
	config.ServerPath = parsedURL.Path

	// 驗證必要欄位
	if config.ServerHost == "" {
		return nil, fmt.Errorf("server URL missing host:port information")
	}
	if config.ServerPath == "" {
		return nil, fmt.Errorf("server URL missing path information")
	}

	return config, nil
}

func (i *imlServiceController) QuickCreateRestfulService(ctx *gin.Context) error {
	fileHeader, err := ctx.FormFile("file")
	if err != nil {
		return err
	}
	file, err := fileHeader.Open()
	if err != nil {
		return err
	}
	content, err := io.ReadAll(file)
	if err != nil {
		return err
	}
	typ := ctx.PostForm("type")
	switch typ {
	case "swagger", "":
	default:
		return fmt.Errorf("type %s not support", typ)
	}

	// 解析 OpenAPI 配置
	openAPIConfig, err := parseOpenAPIConfig(content)
	if err != nil {
		return fmt.Errorf("failed to parse OpenAPI configuration: %w", err)
	}

	return i.transaction.Transaction(ctx, func(txCtx context.Context) error {
		teamId := ctx.PostForm("team")
		id := uuid.NewString()
		prefix := fmt.Sprintf("/%s", id[:8])
		catalogueInfo, err := i.catalogueModule.DefaultCatalogue(ctx)
		if err != nil {
			return err
		}

		// 使用動態服務名稱
		s, err := i.module.Create(ctx, teamId, &service_dto.CreateService{
			Id:           uuid.NewString(),
			Name:         openAPIConfig.ServiceName, // VAR5: 從 info.title 讀取
			Prefix:       prefix,
			Description:  "Auto create by upload swagger",
			ServiceType:  "public",
			State:        "normal",
			Catalogue:    catalogueInfo.Id,
			ApprovalType: "auto",
			Kind:         "rest",
			EnableMCP:    true, // VAR6: 預設值=1 (true)
		})
		if err != nil {
			return err
		}

		// 建立上游配置
		upstreamId := uuid.NewString()
		_, err = i.upstreamModule.Save(ctx, s.Id, &upstream_dto.Upstream{
			Type:            "http",
			Balance:         "round-robin",
			Timeout:         30000,
			Retry:           0,
			Remark:          fmt.Sprintf("Auto create for service %s", s.Id),
			LimitPeerSecond: 0,
			ProxyHeaders:    []*upstream_dto.ProxyHeader{},
			Scheme:          "http",
			PassHost:        "pass", // VAR4: 透傳客戶端請求Host
			UpstreamHost:    "",
			Nodes: []*upstream_dto.NodeConfig{
				{
					Address: openAPIConfig.ServerHost, // VAR3: 從 servers[0].url 提取 host:port
					Weight:  100,
				},
			},
			Discover: &upstream_dto.DiscoverConfig{
				Discover: "",
				Service:  "",
			},
		})
		if err != nil {
			return err
		}

		_, err = i.apiDocModule.UpdateDoc(ctx, s.Id, &api_doc_dto.UpdateDoc{
			Id:      s.Id,
			Content: string(content),
		})
		if err != nil {
			return err
		}

		// 使用動態路徑配置
		// VAR1: 請求路徑 = /{prefix}/{summary}
		requestPath := fmt.Sprintf("/%s/%s", strings.TrimPrefix(prefix, "/"), openAPIConfig.FirstSummary)
		// VAR2: 轉發上游路徑 = 從 servers[0].url 提取的 path
		proxyPath := openAPIConfig.ServerPath

		_, err = i.routerModule.Create(ctx, s.Id, &router_dto.Create{
			Id:          uuid.NewString(),
			Name:        "",
			Path:        requestPath, // VAR1: /{prefix}/{summary}
			Methods:     []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodPatch, http.MethodOptions},
			Description: "auto create by create service",
			Protocols:   []string{"http", "https"},
			Upstream:    upstreamId,
			Proxy: &router_dto.InputProxy{
				Path:    proxyPath, // VAR2: 從 servers[0].url 提取的 path
				Timeout: 30000,
				Retry:   0,
			},
			Disable: false,
		})
		if err != nil {
			return err
		}

		apps, err := i.appModule.Search(ctx, teamId, "")
		if err != nil {
			return err
		}
		for _, app := range apps {
			i.subscribeModule.AddSubscriber(ctx, s.Id, &subscribe_dto.AddSubscriber{
				Application: app.Id,
			})
		}

		return nil
	})
}

var (
	loader = openapi3.NewLoader()
)

func (i *imlServiceController) swagger(ctx *gin.Context, id string) (*openapi3.T, error) {
	doc, err := i.apiDocModule.GetDoc(ctx, id)
	if err != nil {
		return nil, err
	}
	tmp, err := loader.LoadFromData([]byte(doc.Content))
	if err != nil {
		return nil, err
	}
	cfg := i.settingModule.Get(ctx)

	tmp.AddServer(&openapi3.Server{
		URL: cfg.InvokeAddress,
	})
	return tmp, nil
}

func (i *imlServiceController) ExportSwagger(ctx *gin.Context) {
	id, has := ctx.Params.Get("id")
	if !has {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: fmt.Sprintf("id is required"),
		})
		return
	}
	s, err := i.module.Get(ctx, id)
	if err != nil {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: err.Error(),
		})
		return
	}
	tmp, err := i.swagger(ctx, id)
	if err != nil {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: err.Error(),
		})
		return
	}

	data, _ := tmp.MarshalJSON()
	ctx.Status(200)
	// 设置响应头
	ctx.Header("Content-Disposition", fmt.Sprintf("attachment; filename=%s.json", strings.Replace(s.Name, " ", "_", -1)))
	ctx.Header("Content-Type", "application/octet-stream")
	ctx.Header("Content-Transfer-Encoding", "binary")
	ctx.Writer.Write(data)
	return
}

func (i *imlServiceController) Swagger(ctx *gin.Context) {
	id, has := ctx.Params.Get("id")
	if !has {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: fmt.Sprintf("id is required"),
		})
		return
	}
	tmp, err := i.swagger(ctx, id)
	if err != nil {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: err.Error(),
		})
		return
	}
	ctx.JSON(200, tmp)
	return
}

func (i *imlServiceController) Simple(ctx *gin.Context) ([]*service_dto.SimpleServiceItem, error) {
	return i.module.Simple(ctx)
}

func (i *imlServiceController) MySimple(ctx *gin.Context) ([]*service_dto.SimpleServiceItem, error) {
	return i.module.MySimple(ctx)
}

func (i *imlServiceController) editAIService(ctx *gin.Context, id string, input *service_dto.EditService) (*service_dto.Service, error) {

	if input.Provider == nil {
		return nil, fmt.Errorf("provider is required")
	}
	if *input.Provider != ai_provider_local.ProviderLocal {
		_, has := model_runtime.GetProvider(*input.Provider)
		if !has {
			return nil, fmt.Errorf("provider not found")
		}
	}

	info, err := i.module.Edit(ctx, id, input)
	if err != nil {
		return nil, err
	}
	//_, err = i.upstreamModule.Save(ctx, id, newAIUpstream(id, *input.Provider, p.URI()))

	return info, nil
}

func (i *imlServiceController) createAIService(ctx *gin.Context, teamID string, input *service_dto.CreateService) (*service_dto.Service, error) {
	if input.Provider == nil {
		return nil, fmt.Errorf("provider is required")
	}

	if input.Id == "" {
		input.Id = uuid.New().String()
	}
	if input.Prefix == "" {
		if len(input.Id) < 9 {
			input.Prefix = input.Id
		} else {
			input.Prefix = input.Id[:8]
		}
	}
	modelId := ""
	modelCfg := ""
	modelType := "online"
	if *input.Provider == ai_provider_local.ProviderLocal {
		modelType = "local"
		list, err := i.aiLocalModel.SimpleList(ctx)
		if err != nil {
			return nil, err
		}
		if len(list) == 0 {
			return nil, fmt.Errorf("no local model")
		}
		modelId = list[0].Id
		modelCfg = ai_provider_local.LocalConfig
	} else {
		pv, err := i.providerModule.Provider(ctx, *input.Provider)
		if err != nil {
			return nil, err
		}
		p, has := model_runtime.GetProvider(*input.Provider)
		if !has {
			return nil, fmt.Errorf("provider not found")
		}
		m, has := p.GetModel(pv.DefaultLLM)
		if !has {
			return nil, fmt.Errorf("model %s not found", pv.DefaultLLM)
		}
		//modelId = m.ID()
		modelId = m.Name()
		modelCfg = m.DefaultConfig()

	}

	var info *service_dto.Service
	err := i.transaction.Transaction(ctx, func(txCtx context.Context) error {
		var err error
		info, err = i.module.Create(ctx, teamID, input)
		if err != nil {
			return err
		}
		prefix := strings.Replace(input.Prefix, ":", "_", -1)
		path := fmt.Sprintf("/%s/chat/completions", strings.Trim(prefix, "/"))
		timeout := 300000
		retry := 0
		aiPrompt := &ai_api_dto.AiPrompt{
			Variables: []*ai_api_dto.AiPromptVariable{},
			Prompt:    "",
		}
		aiModel := &ai_api_dto.AiModel{
			Id:       modelId,
			Config:   modelCfg,
			Provider: *input.Provider,
			Type:     modelType,
		}
		name := "Demo AI API "
		description := "This is a demo that shows you how to use a Chat API."
		apiId := uuid.New().String()
		err = i.aiAPIModule.Create(
			ctx,
			info.Id,
			&ai_api_dto.CreateAPI{
				Id:          apiId,
				Name:        name,
				Path:        path,
				Description: description,
				Disable:     false,
				AiPrompt:    aiPrompt,
				AiModel:     aiModel,
				Timeout:     timeout,
				Retry:       retry,
			},
		)
		if err != nil {
			return err
		}
		plugins := make(map[string]api.PluginSetting)
		plugins["ai_prompt"] = api.PluginSetting{
			Config: plugin_model.ConfigType{
				"prompt":    aiPrompt.Prompt,
				"variables": aiPrompt.Variables,
			},
		}
		plugins["ai_formatter"] = api.PluginSetting{
			Config: plugin_model.ConfigType{
				"model":    aiModel.Id,
				"provider": fmt.Sprintf("%s@ai-provider", info.Provider.Id),
				"config":   aiModel.Config,
			},
		}
		_, err = i.routerModule.Create(ctx, info.Id, &router_dto.Create{
			Id:   apiId,
			Name: name,
			Path: path,
			Methods: []string{
				http.MethodPost,
			},
			Description: description,
			Protocols:   []string{"http", "https"},
			MatchRules:  nil,
			Proxy: &router_dto.InputProxy{
				Path:    path,
				Timeout: timeout,
				Retry:   retry,
				Plugins: plugins,
			},
			Disable:  false,
			Upstream: info.Provider.Id,
		})
		if err != nil {
			return err
		}
		apps, err := i.appModule.Search(ctx, info.Team.Id, "")
		if err != nil {
			return err
		}
		for _, app := range apps {
			i.subscribeModule.AddSubscriber(ctx, info.Id, &subscribe_dto.AddSubscriber{
				Application: app.Id,
			})
		}

		return i.docModule.SaveServiceDoc(ctx, info.Id, &service_dto.SaveServiceDoc{
			Doc: "",
		})
	})

	return info, err
}

func (i *imlServiceController) SearchMyServices(ctx *gin.Context, teamId string, keyword string) ([]*service_dto.ServiceItem, error) {
	return i.module.SearchMyServices(ctx, teamId, keyword)
}

func (i *imlServiceController) Get(ctx *gin.Context, id string) (*service_dto.Service, error) {
	now := time.Now()
	defer func() {
		log.Infof("get service %s cost %d ms", id, time.Since(now).Milliseconds())
	}()
	return i.module.Get(ctx, id)
}

func (i *imlServiceController) Search(ctx *gin.Context, teamIDs string, keyword string) ([]*service_dto.ServiceItem, error) {
	return i.module.Search(ctx, teamIDs, keyword)
}

func (i *imlServiceController) Create(ctx *gin.Context, teamID string, input *service_dto.CreateService) (*service_dto.Service, error) {
	if input.Kind == "ai" {
		return i.createAIService(ctx, teamID, input)
	}
	var err error
	var info *service_dto.Service
	err = i.transaction.Transaction(ctx, func(ctx context.Context) error {
		info, err = i.module.Create(ctx, teamID, input)
		if err != nil {
			return err
		}
		path := fmt.Sprintf("/%s/", strings.Trim(input.Prefix, "/"))
		_, err = i.routerModule.Create(ctx, info.Id, &router_dto.Create{
			Id:          uuid.New().String(),
			Name:        "",
			Path:        path + "*",
			Methods:     []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodPatch, http.MethodOptions},
			Description: "auto create by create service",
			Protocols:   []string{"http", "https"},
			MatchRules:  nil,
			Upstream:    "",
			Proxy: &router_dto.InputProxy{
				Path:    path,
				Timeout: 30000,
				Retry:   0,
			},
			Disable: false,
		})
		apps, err := i.appModule.Search(ctx, teamID, "")
		if err != nil {
			return err
		}
		for _, app := range apps {
			i.subscribeModule.AddSubscriber(ctx, info.Id, &subscribe_dto.AddSubscriber{
				Application: app.Id,
			})
		}
		return err
	})
	return info, err
}

func (i *imlServiceController) Edit(ctx *gin.Context, id string, input *service_dto.EditService) (*service_dto.Service, error) {
	info, err := i.Get(ctx, id)
	if err != nil {
		return nil, err
	}
	if info.ServiceKind == "ai" {
		return i.editAIService(ctx, id, input)
	}
	return i.module.Edit(ctx, id, input)
}

func (i *imlServiceController) Delete(ctx *gin.Context, id string) error {
	return i.module.Delete(ctx, id)
}

func (i *imlServiceController) ServiceDoc(ctx *gin.Context, id string) (*service_dto.ServiceDoc, error) {
	return i.docModule.ServiceDoc(ctx, id)
}

func (i *imlServiceController) SaveServiceDoc(ctx *gin.Context, id string, input *service_dto.SaveServiceDoc) error {
	return i.docModule.SaveServiceDoc(ctx, id, input)
}

type imlAppController struct {
	module     service.IAppModule                             `autowired:""`
	authModule application_authorization.IAuthorizationModule `autowired:""`
}

func (i *imlAppController) SearchCanSubscribe(ctx *gin.Context, serviceId string) ([]*service_dto.SubscribeAppItem, error) {
	items, _, err := i.module.SearchCanSubscribe(ctx, serviceId)
	return items, err
}

func (i *imlAppController) Search(ctx *gin.Context, teamId string, keyword string) ([]*service_dto.AppItem, error) {
	return i.module.Search(ctx, teamId, keyword)
}

func (i *imlAppController) CreateApp(ctx *gin.Context, teamID string, input *service_dto.CreateApp) (*service_dto.App, error) {
	app, err := i.module.CreateApp(ctx, teamID, input)
	if err != nil {
		return nil, err
	}
	_, err = i.authModule.AddAuthorization(ctx, app.Id, &application_authorization_dto.CreateAuthorization{
		Name:       "Default API Key",
		Driver:     "apikey",
		Position:   "Header",
		TokenName:  "Authorization",
		ExpireTime: 0,
		Config: map[string]interface{}{
			"apikey": uuid.New().String(),
		},
	})
	if err != nil {
		i.module.DeleteApp(ctx, app.Id)
		return nil, err
	}
	return app, nil
}
func (i *imlAppController) UpdateApp(ctx *gin.Context, appId string, input *service_dto.UpdateApp) (*service_dto.App, error) {
	return i.module.UpdateApp(ctx, appId, input)
}

func (i *imlAppController) SearchMyApps(ctx *gin.Context, teamId string, keyword string) ([]*service_dto.AppItem, error) {
	return i.module.SearchMyApps(ctx, teamId, keyword)
}

func (i *imlAppController) SimpleApps(ctx *gin.Context, keyword string) ([]*service_dto.SimpleAppItem, error) {
	return i.module.SimpleApps(ctx, keyword)
}

func (i *imlAppController) MySimpleApps(ctx *gin.Context, keyword string) ([]*service_dto.SimpleAppItem, error) {
	return i.module.MySimpleApps(ctx, keyword)
}

func (i *imlAppController) GetApp(ctx *gin.Context, appId string) (*service_dto.App, error) {
	return i.module.GetApp(ctx, appId)
}

func (i *imlAppController) DeleteApp(ctx *gin.Context, appId string) error {
	return i.module.DeleteApp(ctx, appId)
}

//func newAIUpstream(id string, provider string, uri model_runtime.IProviderURI) *upstream_dto.Upstream {
//	return &upstream_dto.Upstream{
//		Type:            "http",
//		Balance:         "round-robin",
//		Timeout:         300000,
//		Retry:           0,
//		Remark:          fmt.Sprintf("auto create by ai service %s,provider is %s", id, provider),
//		LimitPeerSecond: 0,
//		ProxyHeaders:    nil,
//		Scheme:          uri.Scheme(),
//		PassHost:        "node",
//		Nodes: []*upstream_dto.NodeConfig{
//			{
//				Address: uri.Host(),
//				Weight:  100,
//			},
//		},
//	}
//}

```

現在更新 TODO 狀態並檢查是否有編譯錯誤：


讓我檢查是否有編譯錯誤：


---

**User**

繼續

---

**Cursor**

好的，讓我繼續檢查編譯錯誤並完成實作。


讓我檢查程式碼中可能的問題。我注意到在 `upstreamModule.Save` 的調用中可能有問題，讓我檢查正確的 API：


我看到問題了。`upstreamModule.Save` 方法需要的是 `upstream_dto.UpstreamConfig` 類型，而不是 `upstream_dto.Upstream`。讓我修正這個問題：


```go
package service

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/APIParkLab/APIPark/module/monitor"
	monitor_dto "github.com/APIParkLab/APIPark/module/monitor/dto"

	ai_provider_local "github.com/APIParkLab/APIPark/ai-provider/local"

	subscribe_dto "github.com/APIParkLab/APIPark/module/subscribe/dto"

	"github.com/APIParkLab/APIPark/module/subscribe"

	ai_local "github.com/APIParkLab/APIPark/module/ai-local"

	ai_dto "github.com/APIParkLab/APIPark/module/ai/dto"

	api_doc_dto "github.com/APIParkLab/APIPark/module/api-doc/dto"

	"github.com/APIParkLab/APIPark/module/catalogue"

	"github.com/APIParkLab/APIPark/module/team"

	"github.com/eolinker/go-common/pm3"

	"github.com/APIParkLab/APIPark/module/system"

	"github.com/getkin/kin-openapi/openapi3"

	api_doc "github.com/APIParkLab/APIPark/module/api-doc"

	"github.com/eolinker/eosc/log"

	application_authorization "github.com/APIParkLab/APIPark/module/application-authorization"
	application_authorization_dto "github.com/APIParkLab/APIPark/module/application-authorization/dto"

	"github.com/APIParkLab/APIPark/model/plugin_model"
	"github.com/APIParkLab/APIPark/service/api"

	router_dto "github.com/APIParkLab/APIPark/module/router/dto"

	model_runtime "github.com/APIParkLab/APIPark/ai-provider/model-runtime"
	"github.com/APIParkLab/APIPark/module/ai"
	ai_api "github.com/APIParkLab/APIPark/module/ai-api"
	ai_api_dto "github.com/APIParkLab/APIPark/module/ai-api/dto"
	"github.com/APIParkLab/APIPark/module/router"
	"github.com/APIParkLab/APIPark/module/service"
	service_dto "github.com/APIParkLab/APIPark/module/service/dto"
	"github.com/APIParkLab/APIPark/module/upstream"
	upstream_dto "github.com/APIParkLab/APIPark/module/upstream/dto"
	"github.com/eolinker/go-common/store"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

var (
	_ IServiceController = (*imlServiceController)(nil)

	_ IAppController = (*imlAppController)(nil)
)

type imlServiceController struct {
	module              service.IServiceModule          `autowired:""`
	docModule           service.IServiceDocModule       `autowired:""`
	subscribeModule     subscribe.ISubscribeModule      `autowired:""`
	aiAPIModule         ai_api.IAPIModule               `autowired:""`
	routerModule        router.IRouterModule            `autowired:""`
	apiDocModule        api_doc.IAPIDocModule           `autowired:""`
	providerModule      ai.IProviderModule              `autowired:""`
	aiLocalModel        ai_local.ILocalModelModule      `autowired:""`
	appModule           service.IAppModule              `autowired:""`
	upstreamModule      upstream.IUpstreamModule        `autowired:""`
	settingModule       system.ISettingModule           `autowired:""`
	teamModule          team.ITeamModule                `autowired:""`
	catalogueModule     catalogue.ICatalogueModule      `autowired:""`
	monitorModule       monitor.IMonitorStatisticModule `autowired:""`
	monitorConfigModule monitor.IMonitorConfigModule    `autowired:""`
	transaction         store.ITransaction              `autowired:""`
}

func (i *imlServiceController) RestLogInfo(ctx *gin.Context, serviceId string, logId string) (*service_dto.RestLogInfo, error) {
	return i.module.RestLogInfo(ctx, serviceId, logId)
}

func (i *imlServiceController) AILogInfo(ctx *gin.Context, serviceId string, logId string) (*service_dto.AILogInfo, error) {
	return i.module.AILogInfo(ctx, serviceId, logId)
}

func (i *imlServiceController) AILogs(ctx *gin.Context, serviceId string, start string, end string, page string, size string) ([]*service_dto.AILogItem, int64, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, 0, err
	}
	if serviceId == "" {
		return nil, 0, fmt.Errorf("service id is empty")
	}
	if page == "" {
		page = "1"
	}
	if size == "" {
		size = "20"
	}
	p, err := strconv.Atoi(page)
	if err != nil {
		return nil, 0, err
	}
	ps, err := strconv.Atoi(size)
	if err != nil {
		return nil, 0, err
	}

	return i.module.AILogs(ctx, serviceId, s, e, p, ps)
}

func (i *imlServiceController) RestLogs(ctx *gin.Context, serviceId string, start string, end string, page string, size string) ([]*service_dto.RestLogItem, int64, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, 0, err
	}
	if serviceId == "" {
		return nil, 0, fmt.Errorf("service id is empty")
	}
	if page == "" {
		page = "1"
	}
	if size == "" {
		size = "20"
	}
	p, err := strconv.Atoi(page)
	if err != nil {
		return nil, 0, err
	}
	ps, err := strconv.Atoi(size)
	if err != nil {
		return nil, 0, err
	}

	return i.module.RestLogs(ctx, serviceId, s, e, p, ps)
}

func (i *imlServiceController) ServiceOverview(ctx *gin.Context, serviceId string) (*service_dto.Overview, error) {
	o, err := i.module.ServiceOverview(ctx, serviceId)
	if err != nil {
		return nil, err
	}
	cfg, err := i.monitorConfigModule.GetMonitorConfig(ctx)
	if err != nil {
		return nil, err
	}
	if len(cfg.Config) < 1 {
		return o, nil
	}
	statistics, err := i.monitorModule.ProviderStatistics(ctx, &monitor_dto.StatisticInput{
		Services: []string{serviceId},
		CommonInput: &monitor_dto.CommonInput{
			Start: time.Now().Add(-24 * 30 * time.Hour).Unix(),
			End:   time.Now().Unix(),
		},
	})
	if err != nil {
		return nil, err
	}
	if len(statistics) < 1 {
		return o, nil
	}
	o.InvokeNum = statistics[0].RequestTotal
	return o, nil
}

func (i *imlServiceController) AIChartOverview(ctx *gin.Context, serviceId string, start string, end string) (*monitor_dto.ServiceChartAIOverview, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, err
	}
	if serviceId == "" {
		return nil, fmt.Errorf("service is required")
	}
	so, err := i.module.ServiceOverview(ctx, serviceId)
	if err != nil {
		return nil, err
	}
	result := &monitor_dto.ServiceChartAIOverview{
		EnableMCP:     so.EnableMCP,
		SubscriberNum: so.SubscriberNum,
		APINum:        so.APINum,
		ServiceKind:   so.ServiceKind,
	}
	cfg, err := i.monitorConfigModule.GetMonitorConfig(ctx)
	if err != nil {
		return nil, err
	}
	if len(cfg.Config) < 1 {
		return result, nil
	}

	o, err := i.monitorModule.AIChartOverview(ctx, serviceId, s, e)
	if err != nil {
		return nil, err
	}

	result.AvailableMonitor = true
	result.ChartAIOverview = o
	return result, nil
}

func (i *imlServiceController) RestChartOverview(ctx *gin.Context, serviceId string, start string, end string) (*monitor_dto.ServiceChartRestOverview, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, err
	}
	if serviceId == "" {
		return nil, fmt.Errorf("service is required")
	}
	so, err := i.module.ServiceOverview(ctx, serviceId)
	if err != nil {
		return nil, err
	}
	result := &monitor_dto.ServiceChartRestOverview{
		EnableMCP:     so.EnableMCP,
		SubscriberNum: so.SubscriberNum,
		APINum:        so.APINum,
		ServiceKind:   so.ServiceKind,
	}
	cfg, err := i.monitorConfigModule.GetMonitorConfig(ctx)
	if err != nil {
		return nil, err
	}
	if len(cfg.Config) < 1 {
		return result, nil
	}
	o, err := i.monitorModule.RestChartOverview(ctx, serviceId, s, e)
	if err != nil {
		return nil, err
	}
	result.AvailableMonitor = true
	result.ChartRestOverview = o
	return result, nil
}

func formatTime(start string, end string) (int64, int64, error) {
	s, err := strconv.ParseInt(start, 10, 64)
	if err != nil {
		return 0, 0, fmt.Errorf("parse start time %s error: %w", start, err)
	}
	e, err := strconv.ParseInt(end, 10, 64)
	if err != nil {
		return 0, 0, fmt.Errorf("parse end time %s error: %w", end, err)
	}
	return s, e, nil
}

func (i *imlServiceController) Top10(ctx *gin.Context, serviceId string, start string, end string) ([]*monitor_dto.TopN, []*monitor_dto.TopN, error) {
	if serviceId == "" {
		return nil, nil, fmt.Errorf("serviceId is required")
	}
	info, err := i.module.Get(ctx, serviceId)
	if err != nil {
		return nil, nil, err
	}

	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, nil, err
	}

	return i.monitorModule.Top(ctx, serviceId, s, e, 10, info.ServiceKind)
}

func (i *imlServiceController) QuickCreateAIService(ctx *gin.Context, input *service_dto.QuickCreateAIService) error {
	return i.transaction.Transaction(ctx, func(txCtx context.Context) error {
		enable := true
		err := i.providerModule.UpdateProviderConfig(ctx, input.Provider, &ai_dto.UpdateConfig{
			Config: input.Config,
			Enable: &enable,
		})
		if err != nil {
			return err
		}
		p, err := i.providerModule.Provider(ctx, input.Provider)
		if err != nil {
			return err
		}
		id := uuid.NewString()
		prefix := fmt.Sprintf("/%s", id[:8])
		catalogueInfo, err := i.catalogueModule.DefaultCatalogue(ctx)
		if err != nil {
			return err
		}
		_, err = i.createAIService(ctx, input.Team, &service_dto.CreateService{
			Id:           uuid.NewString(),
			Name:         input.Provider + " AI Service",
			Prefix:       prefix,
			Description:  "Quick create by AI provider",
			ServiceType:  "public",
			State:        "normal",
			Catalogue:    catalogueInfo.Id,
			ApprovalType: "auto",
			Provider:     &input.Provider,
			Model:        &p.DefaultLLM,
			Kind:         "ai",
		})
		return err
	})
}

// OpenAPIConfig 從 OpenAPI YAML 文件中解析的配置資訊
type OpenAPIConfig struct {
	ServiceName    string // info.title
	FirstPath      string // 第一個 path 的 key
	FirstSummary   string // 第一個 path 的 summary
	ServerURL      string // servers[0].url
	ServerHost     string // 從 server URL 提取的 host:port
	ServerPath     string // 從 server URL 提取的 path
}

// parseOpenAPIConfig 解析 OpenAPI YAML 文件並提取所需配置
func parseOpenAPIConfig(content []byte) (*OpenAPIConfig, error) {
	// 使用現有的 openapi3 loader 解析文件
	doc, err := loader.LoadFromData(content)
	if err != nil {
		return nil, fmt.Errorf("failed to parse OpenAPI document: %w", err)
	}

	config := &OpenAPIConfig{}

	// 提取服務名稱 (info.title)
	if doc.Info == nil || doc.Info.Title == "" {
		return nil, fmt.Errorf("OpenAPI document missing required field: info.title")
	}
	config.ServiceName = doc.Info.Title

	// 提取第一個 path 和其 summary
	if doc.Paths == nil || len(doc.Paths.Map()) == 0 {
		return nil, fmt.Errorf("OpenAPI document missing required field: paths")
	}
	
	// 取得第一個 path
	for pathKey, pathItem := range doc.Paths.Map() {
		config.FirstPath = pathKey
		
		// 取得第一個 operation 的 summary
		if pathItem.Get != nil && pathItem.Get.Summary != "" {
			config.FirstSummary = pathItem.Get.Summary
			break
		}
		if pathItem.Post != nil && pathItem.Post.Summary != "" {
			config.FirstSummary = pathItem.Post.Summary
			break
		}
		if pathItem.Put != nil && pathItem.Put.Summary != "" {
			config.FirstSummary = pathItem.Put.Summary
			break
		}
		if pathItem.Delete != nil && pathItem.Delete.Summary != "" {
			config.FirstSummary = pathItem.Delete.Summary
			break
		}
		if pathItem.Patch != nil && pathItem.Patch.Summary != "" {
			config.FirstSummary = pathItem.Patch.Summary
			break
		}
		// 如果沒有找到 summary，使用 path 作為預設值
		if config.FirstSummary == "" {
			config.FirstSummary = strings.TrimPrefix(pathKey, "/")
		}
		break
	}

	// 提取 server URL
	if doc.Servers == nil || len(doc.Servers) == 0 {
		return nil, fmt.Errorf("OpenAPI document missing required field: servers")
	}
	config.ServerURL = doc.Servers[0].URL

	// 解析 server URL 提取 host:port 和 path
	parsedURL, err := url.Parse(config.ServerURL)
	if err != nil {
		return nil, fmt.Errorf("failed to parse server URL: %w", err)
	}
	
	config.ServerHost = parsedURL.Host
	config.ServerPath = parsedURL.Path

	// 驗證必要欄位
	if config.ServerHost == "" {
		return nil, fmt.Errorf("server URL missing host:port information")
	}
	if config.ServerPath == "" {
		return nil, fmt.Errorf("server URL missing path information")
	}

	return config, nil
}

func (i *imlServiceController) QuickCreateRestfulService(ctx *gin.Context) error {
	fileHeader, err := ctx.FormFile("file")
	if err != nil {
		return err
	}
	file, err := fileHeader.Open()
	if err != nil {
		return err
	}
	content, err := io.ReadAll(file)
	if err != nil {
		return err
	}
	typ := ctx.PostForm("type")
	switch typ {
	case "swagger", "":
	default:
		return fmt.Errorf("type %s not support", typ)
	}

	// 解析 OpenAPI 配置
	openAPIConfig, err := parseOpenAPIConfig(content)
	if err != nil {
		return fmt.Errorf("failed to parse OpenAPI configuration: %w", err)
	}

	return i.transaction.Transaction(ctx, func(txCtx context.Context) error {
		teamId := ctx.PostForm("team")
		id := uuid.NewString()
		prefix := fmt.Sprintf("/%s", id[:8])
		catalogueInfo, err := i.catalogueModule.DefaultCatalogue(ctx)
		if err != nil {
			return err
		}

		// 使用動態服務名稱
		s, err := i.module.Create(ctx, teamId, &service_dto.CreateService{
			Id:           uuid.NewString(),
			Name:         openAPIConfig.ServiceName, // VAR5: 從 info.title 讀取
			Prefix:       prefix,
			Description:  "Auto create by upload swagger",
			ServiceType:  "public",
			State:        "normal",
			Catalogue:    catalogueInfo.Id,
			ApprovalType: "auto",
			Kind:         "rest",
			EnableMCP:    true, // VAR6: 預設值=1 (true)
		})
		if err != nil {
			return err
		}

		// 建立上游配置
		upstreamConfig := &upstream_dto.Upstream{
			Type:            "http",
			Balance:         "round-robin",
			Timeout:         30000,
			Retry:           0,
			Remark:          fmt.Sprintf("Auto create for service %s", s.Id),
			LimitPeerSecond: 0,
			ProxyHeaders:    []*upstream_dto.ProxyHeader{},
			Scheme:          "http",
			PassHost:        "pass", // VAR4: 透傳客戶端請求Host
			UpstreamHost:    "",
			Nodes: []*upstream_dto.NodeConfig{
				{
					Address: openAPIConfig.ServerHost, // VAR3: 從 servers[0].url 提取 host:port
					Weight:  100,
				},
			},
			Discover: &upstream_dto.DiscoverConfig{
				Discover: "",
				Service:  "",
			},
		}
		_, err = i.upstreamModule.Save(ctx, s.Id, upstreamConfig)
		if err != nil {
			return err
		}

		_, err = i.apiDocModule.UpdateDoc(ctx, s.Id, &api_doc_dto.UpdateDoc{
			Id:      s.Id,
			Content: string(content),
		})
		if err != nil {
			return err
		}

		// 使用動態路徑配置
		// VAR1: 請求路徑 = /{prefix}/{summary}
		requestPath := fmt.Sprintf("/%s/%s", strings.TrimPrefix(prefix, "/"), openAPIConfig.FirstSummary)
		// VAR2: 轉發上游路徑 = 從 servers[0].url 提取的 path
		proxyPath := openAPIConfig.ServerPath

		_, err = i.routerModule.Create(ctx, s.Id, &router_dto.Create{
			Id:          uuid.NewString(),
			Name:        "",
			Path:        requestPath, // VAR1: /{prefix}/{summary}
			Methods:     []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodPatch, http.MethodOptions},
			Description: "auto create by create service",
			Protocols:   []string{"http", "https"},
			Upstream:    upstreamId,
			Proxy: &router_dto.InputProxy{
				Path:    proxyPath, // VAR2: 從 servers[0].url 提取的 path
				Timeout: 30000,
				Retry:   0,
			},
			Disable: false,
		})
		if err != nil {
			return err
		}

		apps, err := i.appModule.Search(ctx, teamId, "")
		if err != nil {
			return err
		}
		for _, app := range apps {
			i.subscribeModule.AddSubscriber(ctx, s.Id, &subscribe_dto.AddSubscriber{
				Application: app.Id,
			})
		}

		return nil
	})
}

var (
	loader = openapi3.NewLoader()
)

func (i *imlServiceController) swagger(ctx *gin.Context, id string) (*openapi3.T, error) {
	doc, err := i.apiDocModule.GetDoc(ctx, id)
	if err != nil {
		return nil, err
	}
	tmp, err := loader.LoadFromData([]byte(doc.Content))
	if err != nil {
		return nil, err
	}
	cfg := i.settingModule.Get(ctx)

	tmp.AddServer(&openapi3.Server{
		URL: cfg.InvokeAddress,
	})
	return tmp, nil
}

func (i *imlServiceController) ExportSwagger(ctx *gin.Context) {
	id, has := ctx.Params.Get("id")
	if !has {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: fmt.Sprintf("id is required"),
		})
		return
	}
	s, err := i.module.Get(ctx, id)
	if err != nil {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: err.Error(),
		})
		return
	}
	tmp, err := i.swagger(ctx, id)
	if err != nil {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: err.Error(),
		})
		return
	}

	data, _ := tmp.MarshalJSON()
	ctx.Status(200)
	// 设置响应头
	ctx.Header("Content-Disposition", fmt.Sprintf("attachment; filename=%s.json", strings.Replace(s.Name, " ", "_", -1)))
	ctx.Header("Content-Type", "application/octet-stream")
	ctx.Header("Content-Transfer-Encoding", "binary")
	ctx.Writer.Write(data)
	return
}

func (i *imlServiceController) Swagger(ctx *gin.Context) {
	id, has := ctx.Params.Get("id")
	if !has {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: fmt.Sprintf("id is required"),
		})
		return
	}
	tmp, err := i.swagger(ctx, id)
	if err != nil {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: err.Error(),
		})
		return
	}
	ctx.JSON(200, tmp)
	return
}

func (i *imlServiceController) Simple(ctx *gin.Context) ([]*service_dto.SimpleServiceItem, error) {
	return i.module.Simple(ctx)
}

func (i *imlServiceController) MySimple(ctx *gin.Context) ([]*service_dto.SimpleServiceItem, error) {
	return i.module.MySimple(ctx)
}

func (i *imlServiceController) editAIService(ctx *gin.Context, id string, input *service_dto.EditService) (*service_dto.Service, error) {

	if input.Provider == nil {
		return nil, fmt.Errorf("provider is required")
	}
	if *input.Provider != ai_provider_local.ProviderLocal {
		_, has := model_runtime.GetProvider(*input.Provider)
		if !has {
			return nil, fmt.Errorf("provider not found")
		}
	}

	info, err := i.module.Edit(ctx, id, input)
	if err != nil {
		return nil, err
	}
	//_, err = i.upstreamModule.Save(ctx, id, newAIUpstream(id, *input.Provider, p.URI()))

	return info, nil
}

func (i *imlServiceController) createAIService(ctx *gin.Context, teamID string, input *service_dto.CreateService) (*service_dto.Service, error) {
	if input.Provider == nil {
		return nil, fmt.Errorf("provider is required")
	}

	if input.Id == "" {
		input.Id = uuid.New().String()
	}
	if input.Prefix == "" {
		if len(input.Id) < 9 {
			input.Prefix = input.Id
		} else {
			input.Prefix = input.Id[:8]
		}
	}
	modelId := ""
	modelCfg := ""
	modelType := "online"
	if *input.Provider == ai_provider_local.ProviderLocal {
		modelType = "local"
		list, err := i.aiLocalModel.SimpleList(ctx)
		if err != nil {
			return nil, err
		}
		if len(list) == 0 {
			return nil, fmt.Errorf("no local model")
		}
		modelId = list[0].Id
		modelCfg = ai_provider_local.LocalConfig
	} else {
		pv, err := i.providerModule.Provider(ctx, *input.Provider)
		if err != nil {
			return nil, err
		}
		p, has := model_runtime.GetProvider(*input.Provider)
		if !has {
			return nil, fmt.Errorf("provider not found")
		}
		m, has := p.GetModel(pv.DefaultLLM)
		if !has {
			return nil, fmt.Errorf("model %s not found", pv.DefaultLLM)
		}
		//modelId = m.ID()
		modelId = m.Name()
		modelCfg = m.DefaultConfig()

	}

	var info *service_dto.Service
	err := i.transaction.Transaction(ctx, func(txCtx context.Context) error {
		var err error
		info, err = i.module.Create(ctx, teamID, input)
		if err != nil {
			return err
		}
		prefix := strings.Replace(input.Prefix, ":", "_", -1)
		path := fmt.Sprintf("/%s/chat/completions", strings.Trim(prefix, "/"))
		timeout := 300000
		retry := 0
		aiPrompt := &ai_api_dto.AiPrompt{
			Variables: []*ai_api_dto.AiPromptVariable{},
			Prompt:    "",
		}
		aiModel := &ai_api_dto.AiModel{
			Id:       modelId,
			Config:   modelCfg,
			Provider: *input.Provider,
			Type:     modelType,
		}
		name := "Demo AI API "
		description := "This is a demo that shows you how to use a Chat API."
		apiId := uuid.New().String()
		err = i.aiAPIModule.Create(
			ctx,
			info.Id,
			&ai_api_dto.CreateAPI{
				Id:          apiId,
				Name:        name,
				Path:        path,
				Description: description,
				Disable:     false,
				AiPrompt:    aiPrompt,
				AiModel:     aiModel,
				Timeout:     timeout,
				Retry:       retry,
			},
		)
		if err != nil {
			return err
		}
		plugins := make(map[string]api.PluginSetting)
		plugins["ai_prompt"] = api.PluginSetting{
			Config: plugin_model.ConfigType{
				"prompt":    aiPrompt.Prompt,
				"variables": aiPrompt.Variables,
			},
		}
		plugins["ai_formatter"] = api.PluginSetting{
			Config: plugin_model.ConfigType{
				"model":    aiModel.Id,
				"provider": fmt.Sprintf("%s@ai-provider", info.Provider.Id),
				"config":   aiModel.Config,
			},
		}
		_, err = i.routerModule.Create(ctx, info.Id, &router_dto.Create{
			Id:   apiId,
			Name: name,
			Path: path,
			Methods: []string{
				http.MethodPost,
			},
			Description: description,
			Protocols:   []string{"http", "https"},
			MatchRules:  nil,
			Proxy: &router_dto.InputProxy{
				Path:    path,
				Timeout: timeout,
				Retry:   retry,
				Plugins: plugins,
			},
			Disable:  false,
			Upstream: info.Provider.Id,
		})
		if err != nil {
			return err
		}
		apps, err := i.appModule.Search(ctx, info.Team.Id, "")
		if err != nil {
			return err
		}
		for _, app := range apps {
			i.subscribeModule.AddSubscriber(ctx, info.Id, &subscribe_dto.AddSubscriber{
				Application: app.Id,
			})
		}

		return i.docModule.SaveServiceDoc(ctx, info.Id, &service_dto.SaveServiceDoc{
			Doc: "",
		})
	})

	return info, err
}

func (i *imlServiceController) SearchMyServices(ctx *gin.Context, teamId string, keyword string) ([]*service_dto.ServiceItem, error) {
	return i.module.SearchMyServices(ctx, teamId, keyword)
}

func (i *imlServiceController) Get(ctx *gin.Context, id string) (*service_dto.Service, error) {
	now := time.Now()
	defer func() {
		log.Infof("get service %s cost %d ms", id, time.Since(now).Milliseconds())
	}()
	return i.module.Get(ctx, id)
}

func (i *imlServiceController) Search(ctx *gin.Context, teamIDs string, keyword string) ([]*service_dto.ServiceItem, error) {
	return i.module.Search(ctx, teamIDs, keyword)
}

func (i *imlServiceController) Create(ctx *gin.Context, teamID string, input *service_dto.CreateService) (*service_dto.Service, error) {
	if input.Kind == "ai" {
		return i.createAIService(ctx, teamID, input)
	}
	var err error
	var info *service_dto.Service
	err = i.transaction.Transaction(ctx, func(ctx context.Context) error {
		info, err = i.module.Create(ctx, teamID, input)
		if err != nil {
			return err
		}
		path := fmt.Sprintf("/%s/", strings.Trim(input.Prefix, "/"))
		_, err = i.routerModule.Create(ctx, info.Id, &router_dto.Create{
			Id:          uuid.New().String(),
			Name:        "",
			Path:        path + "*",
			Methods:     []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodPatch, http.MethodOptions},
			Description: "auto create by create service",
			Protocols:   []string{"http", "https"},
			MatchRules:  nil,
			Upstream:    "",
			Proxy: &router_dto.InputProxy{
				Path:    path,
				Timeout: 30000,
				Retry:   0,
			},
			Disable: false,
		})
		apps, err := i.appModule.Search(ctx, teamID, "")
		if err != nil {
			return err
		}
		for _, app := range apps {
			i.subscribeModule.AddSubscriber(ctx, info.Id, &subscribe_dto.AddSubscriber{
				Application: app.Id,
			})
		}
		return err
	})
	return info, err
}

func (i *imlServiceController) Edit(ctx *gin.Context, id string, input *service_dto.EditService) (*service_dto.Service, error) {
	info, err := i.Get(ctx, id)
	if err != nil {
		return nil, err
	}
	if info.ServiceKind == "ai" {
		return i.editAIService(ctx, id, input)
	}
	return i.module.Edit(ctx, id, input)
}

func (i *imlServiceController) Delete(ctx *gin.Context, id string) error {
	return i.module.Delete(ctx, id)
}

func (i *imlServiceController) ServiceDoc(ctx *gin.Context, id string) (*service_dto.ServiceDoc, error) {
	return i.docModule.ServiceDoc(ctx, id)
}

func (i *imlServiceController) SaveServiceDoc(ctx *gin.Context, id string, input *service_dto.SaveServiceDoc) error {
	return i.docModule.SaveServiceDoc(ctx, id, input)
}

type imlAppController struct {
	module     service.IAppModule                             `autowired:""`
	authModule application_authorization.IAuthorizationModule `autowired:""`
}

func (i *imlAppController) SearchCanSubscribe(ctx *gin.Context, serviceId string) ([]*service_dto.SubscribeAppItem, error) {
	items, _, err := i.module.SearchCanSubscribe(ctx, serviceId)
	return items, err
}

func (i *imlAppController) Search(ctx *gin.Context, teamId string, keyword string) ([]*service_dto.AppItem, error) {
	return i.module.Search(ctx, teamId, keyword)
}

func (i *imlAppController) CreateApp(ctx *gin.Context, teamID string, input *service_dto.CreateApp) (*service_dto.App, error) {
	app, err := i.module.CreateApp(ctx, teamID, input)
	if err != nil {
		return nil, err
	}
	_, err = i.authModule.AddAuthorization(ctx, app.Id, &application_authorization_dto.CreateAuthorization{
		Name:       "Default API Key",
		Driver:     "apikey",
		Position:   "Header",
		TokenName:  "Authorization",
		ExpireTime: 0,
		Config: map[string]interface{}{
			"apikey": uuid.New().String(),
		},
	})
	if err != nil {
		i.module.DeleteApp(ctx, app.Id)
		return nil, err
	}
	return app, nil
}
func (i *imlAppController) UpdateApp(ctx *gin.Context, appId string, input *service_dto.UpdateApp) (*service_dto.App, error) {
	return i.module.UpdateApp(ctx, appId, input)
}

func (i *imlAppController) SearchMyApps(ctx *gin.Context, teamId string, keyword string) ([]*service_dto.AppItem, error) {
	return i.module.SearchMyApps(ctx, teamId, keyword)
}

func (i *imlAppController) SimpleApps(ctx *gin.Context, keyword string) ([]*service_dto.SimpleAppItem, error) {
	return i.module.SimpleApps(ctx, keyword)
}

func (i *imlAppController) MySimpleApps(ctx *gin.Context, keyword string) ([]*service_dto.SimpleAppItem, error) {
	return i.module.MySimpleApps(ctx, keyword)
}

func (i *imlAppController) GetApp(ctx *gin.Context, appId string) (*service_dto.App, error) {
	return i.module.GetApp(ctx, appId)
}

func (i *imlAppController) DeleteApp(ctx *gin.Context, appId string) error {
	return i.module.DeleteApp(ctx, appId)
}

//func newAIUpstream(id string, provider string, uri model_runtime.IProviderURI) *upstream_dto.Upstream {
//	return &upstream_dto.Upstream{
//		Type:            "http",
//		Balance:         "round-robin",
//		Timeout:         300000,
//		Retry:           0,
//		Remark:          fmt.Sprintf("auto create by ai service %s,provider is %s", id, provider),
//		LimitPeerSecond: 0,
//		ProxyHeaders:    nil,
//		Scheme:          uri.Scheme(),
//		PassHost:        "node",
//		Nodes: []*upstream_dto.NodeConfig{
//			{
//				Address: uri.Host(),
//				Weight:  100,
//			},
//		},
//	}
//}

```

現在我需要修正路由配置中的 upstream 引用。讓我檢查路由模組的正確用法：


```go
package service

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/APIParkLab/APIPark/module/monitor"
	monitor_dto "github.com/APIParkLab/APIPark/module/monitor/dto"

	ai_provider_local "github.com/APIParkLab/APIPark/ai-provider/local"

	subscribe_dto "github.com/APIParkLab/APIPark/module/subscribe/dto"

	"github.com/APIParkLab/APIPark/module/subscribe"

	ai_local "github.com/APIParkLab/APIPark/module/ai-local"

	ai_dto "github.com/APIParkLab/APIPark/module/ai/dto"

	api_doc_dto "github.com/APIParkLab/APIPark/module/api-doc/dto"

	"github.com/APIParkLab/APIPark/module/catalogue"

	"github.com/APIParkLab/APIPark/module/team"

	"github.com/eolinker/go-common/pm3"

	"github.com/APIParkLab/APIPark/module/system"

	"github.com/getkin/kin-openapi/openapi3"

	api_doc "github.com/APIParkLab/APIPark/module/api-doc"

	"github.com/eolinker/eosc/log"

	application_authorization "github.com/APIParkLab/APIPark/module/application-authorization"
	application_authorization_dto "github.com/APIParkLab/APIPark/module/application-authorization/dto"

	"github.com/APIParkLab/APIPark/model/plugin_model"
	"github.com/APIParkLab/APIPark/service/api"

	router_dto "github.com/APIParkLab/APIPark/module/router/dto"

	model_runtime "github.com/APIParkLab/APIPark/ai-provider/model-runtime"
	"github.com/APIParkLab/APIPark/module/ai"
	ai_api "github.com/APIParkLab/APIPark/module/ai-api"
	ai_api_dto "github.com/APIParkLab/APIPark/module/ai-api/dto"
	"github.com/APIParkLab/APIPark/module/router"
	"github.com/APIParkLab/APIPark/module/service"
	service_dto "github.com/APIParkLab/APIPark/module/service/dto"
	"github.com/APIParkLab/APIPark/module/upstream"
	upstream_dto "github.com/APIParkLab/APIPark/module/upstream/dto"
	"github.com/eolinker/go-common/store"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

var (
	_ IServiceController = (*imlServiceController)(nil)

	_ IAppController = (*imlAppController)(nil)
)

type imlServiceController struct {
	module              service.IServiceModule          `autowired:""`
	docModule           service.IServiceDocModule       `autowired:""`
	subscribeModule     subscribe.ISubscribeModule      `autowired:""`
	aiAPIModule         ai_api.IAPIModule               `autowired:""`
	routerModule        router.IRouterModule            `autowired:""`
	apiDocModule        api_doc.IAPIDocModule           `autowired:""`
	providerModule      ai.IProviderModule              `autowired:""`
	aiLocalModel        ai_local.ILocalModelModule      `autowired:""`
	appModule           service.IAppModule              `autowired:""`
	upstreamModule      upstream.IUpstreamModule        `autowired:""`
	settingModule       system.ISettingModule           `autowired:""`
	teamModule          team.ITeamModule                `autowired:""`
	catalogueModule     catalogue.ICatalogueModule      `autowired:""`
	monitorModule       monitor.IMonitorStatisticModule `autowired:""`
	monitorConfigModule monitor.IMonitorConfigModule    `autowired:""`
	transaction         store.ITransaction              `autowired:""`
}

func (i *imlServiceController) RestLogInfo(ctx *gin.Context, serviceId string, logId string) (*service_dto.RestLogInfo, error) {
	return i.module.RestLogInfo(ctx, serviceId, logId)
}

func (i *imlServiceController) AILogInfo(ctx *gin.Context, serviceId string, logId string) (*service_dto.AILogInfo, error) {
	return i.module.AILogInfo(ctx, serviceId, logId)
}

func (i *imlServiceController) AILogs(ctx *gin.Context, serviceId string, start string, end string, page string, size string) ([]*service_dto.AILogItem, int64, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, 0, err
	}
	if serviceId == "" {
		return nil, 0, fmt.Errorf("service id is empty")
	}
	if page == "" {
		page = "1"
	}
	if size == "" {
		size = "20"
	}
	p, err := strconv.Atoi(page)
	if err != nil {
		return nil, 0, err
	}
	ps, err := strconv.Atoi(size)
	if err != nil {
		return nil, 0, err
	}

	return i.module.AILogs(ctx, serviceId, s, e, p, ps)
}

func (i *imlServiceController) RestLogs(ctx *gin.Context, serviceId string, start string, end string, page string, size string) ([]*service_dto.RestLogItem, int64, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, 0, err
	}
	if serviceId == "" {
		return nil, 0, fmt.Errorf("service id is empty")
	}
	if page == "" {
		page = "1"
	}
	if size == "" {
		size = "20"
	}
	p, err := strconv.Atoi(page)
	if err != nil {
		return nil, 0, err
	}
	ps, err := strconv.Atoi(size)
	if err != nil {
		return nil, 0, err
	}

	return i.module.RestLogs(ctx, serviceId, s, e, p, ps)
}

func (i *imlServiceController) ServiceOverview(ctx *gin.Context, serviceId string) (*service_dto.Overview, error) {
	o, err := i.module.ServiceOverview(ctx, serviceId)
	if err != nil {
		return nil, err
	}
	cfg, err := i.monitorConfigModule.GetMonitorConfig(ctx)
	if err != nil {
		return nil, err
	}
	if len(cfg.Config) < 1 {
		return o, nil
	}
	statistics, err := i.monitorModule.ProviderStatistics(ctx, &monitor_dto.StatisticInput{
		Services: []string{serviceId},
		CommonInput: &monitor_dto.CommonInput{
			Start: time.Now().Add(-24 * 30 * time.Hour).Unix(),
			End:   time.Now().Unix(),
		},
	})
	if err != nil {
		return nil, err
	}
	if len(statistics) < 1 {
		return o, nil
	}
	o.InvokeNum = statistics[0].RequestTotal
	return o, nil
}

func (i *imlServiceController) AIChartOverview(ctx *gin.Context, serviceId string, start string, end string) (*monitor_dto.ServiceChartAIOverview, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, err
	}
	if serviceId == "" {
		return nil, fmt.Errorf("service is required")
	}
	so, err := i.module.ServiceOverview(ctx, serviceId)
	if err != nil {
		return nil, err
	}
	result := &monitor_dto.ServiceChartAIOverview{
		EnableMCP:     so.EnableMCP,
		SubscriberNum: so.SubscriberNum,
		APINum:        so.APINum,
		ServiceKind:   so.ServiceKind,
	}
	cfg, err := i.monitorConfigModule.GetMonitorConfig(ctx)
	if err != nil {
		return nil, err
	}
	if len(cfg.Config) < 1 {
		return result, nil
	}

	o, err := i.monitorModule.AIChartOverview(ctx, serviceId, s, e)
	if err != nil {
		return nil, err
	}

	result.AvailableMonitor = true
	result.ChartAIOverview = o
	return result, nil
}

func (i *imlServiceController) RestChartOverview(ctx *gin.Context, serviceId string, start string, end string) (*monitor_dto.ServiceChartRestOverview, error) {
	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, err
	}
	if serviceId == "" {
		return nil, fmt.Errorf("service is required")
	}
	so, err := i.module.ServiceOverview(ctx, serviceId)
	if err != nil {
		return nil, err
	}
	result := &monitor_dto.ServiceChartRestOverview{
		EnableMCP:     so.EnableMCP,
		SubscriberNum: so.SubscriberNum,
		APINum:        so.APINum,
		ServiceKind:   so.ServiceKind,
	}
	cfg, err := i.monitorConfigModule.GetMonitorConfig(ctx)
	if err != nil {
		return nil, err
	}
	if len(cfg.Config) < 1 {
		return result, nil
	}
	o, err := i.monitorModule.RestChartOverview(ctx, serviceId, s, e)
	if err != nil {
		return nil, err
	}
	result.AvailableMonitor = true
	result.ChartRestOverview = o
	return result, nil
}

func formatTime(start string, end string) (int64, int64, error) {
	s, err := strconv.ParseInt(start, 10, 64)
	if err != nil {
		return 0, 0, fmt.Errorf("parse start time %s error: %w", start, err)
	}
	e, err := strconv.ParseInt(end, 10, 64)
	if err != nil {
		return 0, 0, fmt.Errorf("parse end time %s error: %w", end, err)
	}
	return s, e, nil
}

func (i *imlServiceController) Top10(ctx *gin.Context, serviceId string, start string, end string) ([]*monitor_dto.TopN, []*monitor_dto.TopN, error) {
	if serviceId == "" {
		return nil, nil, fmt.Errorf("serviceId is required")
	}
	info, err := i.module.Get(ctx, serviceId)
	if err != nil {
		return nil, nil, err
	}

	s, e, err := formatTime(start, end)
	if err != nil {
		return nil, nil, err
	}

	return i.monitorModule.Top(ctx, serviceId, s, e, 10, info.ServiceKind)
}

func (i *imlServiceController) QuickCreateAIService(ctx *gin.Context, input *service_dto.QuickCreateAIService) error {
	return i.transaction.Transaction(ctx, func(txCtx context.Context) error {
		enable := true
		err := i.providerModule.UpdateProviderConfig(ctx, input.Provider, &ai_dto.UpdateConfig{
			Config: input.Config,
			Enable: &enable,
		})
		if err != nil {
			return err
		}
		p, err := i.providerModule.Provider(ctx, input.Provider)
		if err != nil {
			return err
		}
		id := uuid.NewString()
		prefix := fmt.Sprintf("/%s", id[:8])
		catalogueInfo, err := i.catalogueModule.DefaultCatalogue(ctx)
		if err != nil {
			return err
		}
		_, err = i.createAIService(ctx, input.Team, &service_dto.CreateService{
			Id:           uuid.NewString(),
			Name:         input.Provider + " AI Service",
			Prefix:       prefix,
			Description:  "Quick create by AI provider",
			ServiceType:  "public",
			State:        "normal",
			Catalogue:    catalogueInfo.Id,
			ApprovalType: "auto",
			Provider:     &input.Provider,
			Model:        &p.DefaultLLM,
			Kind:         "ai",
		})
		return err
	})
}

// OpenAPIConfig 從 OpenAPI YAML 文件中解析的配置資訊
type OpenAPIConfig struct {
	ServiceName    string // info.title
	FirstPath      string // 第一個 path 的 key
	FirstSummary   string // 第一個 path 的 summary
	ServerURL      string // servers[0].url
	ServerHost     string // 從 server URL 提取的 host:port
	ServerPath     string // 從 server URL 提取的 path
}

// parseOpenAPIConfig 解析 OpenAPI YAML 文件並提取所需配置
func parseOpenAPIConfig(content []byte) (*OpenAPIConfig, error) {
	// 使用現有的 openapi3 loader 解析文件
	doc, err := loader.LoadFromData(content)
	if err != nil {
		return nil, fmt.Errorf("failed to parse OpenAPI document: %w", err)
	}

	config := &OpenAPIConfig{}

	// 提取服務名稱 (info.title)
	if doc.Info == nil || doc.Info.Title == "" {
		return nil, fmt.Errorf("OpenAPI document missing required field: info.title")
	}
	config.ServiceName = doc.Info.Title

	// 提取第一個 path 和其 summary
	if doc.Paths == nil || len(doc.Paths.Map()) == 0 {
		return nil, fmt.Errorf("OpenAPI document missing required field: paths")
	}
	
	// 取得第一個 path
	for pathKey, pathItem := range doc.Paths.Map() {
		config.FirstPath = pathKey
		
		// 取得第一個 operation 的 summary
		if pathItem.Get != nil && pathItem.Get.Summary != "" {
			config.FirstSummary = pathItem.Get.Summary
			break
		}
		if pathItem.Post != nil && pathItem.Post.Summary != "" {
			config.FirstSummary = pathItem.Post.Summary
			break
		}
		if pathItem.Put != nil && pathItem.Put.Summary != "" {
			config.FirstSummary = pathItem.Put.Summary
			break
		}
		if pathItem.Delete != nil && pathItem.Delete.Summary != "" {
			config.FirstSummary = pathItem.Delete.Summary
			break
		}
		if pathItem.Patch != nil && pathItem.Patch.Summary != "" {
			config.FirstSummary = pathItem.Patch.Summary
			break
		}
		// 如果沒有找到 summary，使用 path 作為預設值
		if config.FirstSummary == "" {
			config.FirstSummary = strings.TrimPrefix(pathKey, "/")
		}
		break
	}

	// 提取 server URL
	if doc.Servers == nil || len(doc.Servers) == 0 {
		return nil, fmt.Errorf("OpenAPI document missing required field: servers")
	}
	config.ServerURL = doc.Servers[0].URL

	// 解析 server URL 提取 host:port 和 path
	parsedURL, err := url.Parse(config.ServerURL)
	if err != nil {
		return nil, fmt.Errorf("failed to parse server URL: %w", err)
	}
	
	config.ServerHost = parsedURL.Host
	config.ServerPath = parsedURL.Path

	// 驗證必要欄位
	if config.ServerHost == "" {
		return nil, fmt.Errorf("server URL missing host:port information")
	}
	if config.ServerPath == "" {
		return nil, fmt.Errorf("server URL missing path information")
	}

	return config, nil
}

func (i *imlServiceController) QuickCreateRestfulService(ctx *gin.Context) error {
	fileHeader, err := ctx.FormFile("file")
	if err != nil {
		return err
	}
	file, err := fileHeader.Open()
	if err != nil {
		return err
	}
	content, err := io.ReadAll(file)
	if err != nil {
		return err
	}
	typ := ctx.PostForm("type")
	switch typ {
	case "swagger", "":
	default:
		return fmt.Errorf("type %s not support", typ)
	}

	// 解析 OpenAPI 配置
	openAPIConfig, err := parseOpenAPIConfig(content)
	if err != nil {
		return fmt.Errorf("failed to parse OpenAPI configuration: %w", err)
	}

	return i.transaction.Transaction(ctx, func(txCtx context.Context) error {
		teamId := ctx.PostForm("team")
		id := uuid.NewString()
		prefix := fmt.Sprintf("/%s", id[:8])
		catalogueInfo, err := i.catalogueModule.DefaultCatalogue(ctx)
		if err != nil {
			return err
		}

		// 使用動態服務名稱
		s, err := i.module.Create(ctx, teamId, &service_dto.CreateService{
			Id:           uuid.NewString(),
			Name:         openAPIConfig.ServiceName, // VAR5: 從 info.title 讀取
			Prefix:       prefix,
			Description:  "Auto create by upload swagger",
			ServiceType:  "public",
			State:        "normal",
			Catalogue:    catalogueInfo.Id,
			ApprovalType: "auto",
			Kind:         "rest",
			EnableMCP:    true, // VAR6: 預設值=1 (true)
		})
		if err != nil {
			return err
		}

		// 建立上游配置
		upstreamConfig := &upstream_dto.Upstream{
			Type:            "http",
			Balance:         "round-robin",
			Timeout:         30000,
			Retry:           0,
			Remark:          fmt.Sprintf("Auto create for service %s", s.Id),
			LimitPeerSecond: 0,
			ProxyHeaders:    []*upstream_dto.ProxyHeader{},
			Scheme:          "http",
			PassHost:        "pass", // VAR4: 透傳客戶端請求Host
			UpstreamHost:    "",
			Nodes: []*upstream_dto.NodeConfig{
				{
					Address: openAPIConfig.ServerHost, // VAR3: 從 servers[0].url 提取 host:port
					Weight:  100,
				},
			},
			Discover: &upstream_dto.DiscoverConfig{
				Discover: "",
				Service:  "",
			},
		}
		_, err = i.upstreamModule.Save(ctx, s.Id, upstreamConfig)
		if err != nil {
			return err
		}

		_, err = i.apiDocModule.UpdateDoc(ctx, s.Id, &api_doc_dto.UpdateDoc{
			Id:      s.Id,
			Content: string(content),
		})
		if err != nil {
			return err
		}

		// 使用動態路徑配置
		// VAR1: 請求路徑 = /{prefix}/{summary}
		requestPath := fmt.Sprintf("/%s/%s", strings.TrimPrefix(prefix, "/"), openAPIConfig.FirstSummary)
		// VAR2: 轉發上游路徑 = 從 servers[0].url 提取的 path
		proxyPath := openAPIConfig.ServerPath

		_, err = i.routerModule.Create(ctx, s.Id, &router_dto.Create{
			Id:          uuid.NewString(),
			Name:        "",
			Path:        requestPath, // VAR1: /{prefix}/{summary}
			Methods:     []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodPatch, http.MethodOptions},
			Description: "auto create by create service",
			Protocols:   []string{"http", "https"},
			Upstream:    s.Id, // 使用服務 ID 作為上游引用
			Proxy: &router_dto.InputProxy{
				Path:    proxyPath, // VAR2: 從 servers[0].url 提取的 path
				Timeout: 30000,
				Retry:   0,
			},
			Disable: false,
		})
		if err != nil {
			return err
		}

		apps, err := i.appModule.Search(ctx, teamId, "")
		if err != nil {
			return err
		}
		for _, app := range apps {
			i.subscribeModule.AddSubscriber(ctx, s.Id, &subscribe_dto.AddSubscriber{
				Application: app.Id,
			})
		}

		return nil
	})
}

var (
	loader = openapi3.NewLoader()
)

func (i *imlServiceController) swagger(ctx *gin.Context, id string) (*openapi3.T, error) {
	doc, err := i.apiDocModule.GetDoc(ctx, id)
	if err != nil {
		return nil, err
	}
	tmp, err := loader.LoadFromData([]byte(doc.Content))
	if err != nil {
		return nil, err
	}
	cfg := i.settingModule.Get(ctx)

	tmp.AddServer(&openapi3.Server{
		URL: cfg.InvokeAddress,
	})
	return tmp, nil
}

func (i *imlServiceController) ExportSwagger(ctx *gin.Context) {
	id, has := ctx.Params.Get("id")
	if !has {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: fmt.Sprintf("id is required"),
		})
		return
	}
	s, err := i.module.Get(ctx, id)
	if err != nil {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: err.Error(),
		})
		return
	}
	tmp, err := i.swagger(ctx, id)
	if err != nil {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: err.Error(),
		})
		return
	}

	data, _ := tmp.MarshalJSON()
	ctx.Status(200)
	// 设置响应头
	ctx.Header("Content-Disposition", fmt.Sprintf("attachment; filename=%s.json", strings.Replace(s.Name, " ", "_", -1)))
	ctx.Header("Content-Type", "application/octet-stream")
	ctx.Header("Content-Transfer-Encoding", "binary")
	ctx.Writer.Write(data)
	return
}

func (i *imlServiceController) Swagger(ctx *gin.Context) {
	id, has := ctx.Params.Get("id")
	if !has {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: fmt.Sprintf("id is required"),
		})
		return
	}
	tmp, err := i.swagger(ctx, id)
	if err != nil {
		ctx.JSON(200, &pm3.Response{
			Code:    -1,
			Success: "fail",
			Message: err.Error(),
		})
		return
	}
	ctx.JSON(200, tmp)
	return
}

func (i *imlServiceController) Simple(ctx *gin.Context) ([]*service_dto.SimpleServiceItem, error) {
	return i.module.Simple(ctx)
}

func (i *imlServiceController) MySimple(ctx *gin.Context) ([]*service_dto.SimpleServiceItem, error) {
	return i.module.MySimple(ctx)
}

func (i *imlServiceController) editAIService(ctx *gin.Context, id string, input *service_dto.EditService) (*service_dto.Service, error) {

	if input.Provider == nil {
		return nil, fmt.Errorf("provider is required")
	}
	if *input.Provider != ai_provider_local.ProviderLocal {
		_, has := model_runtime.GetProvider(*input.Provider)
		if !has {
			return nil, fmt.Errorf("provider not found")
		}
	}

	info, err := i.module.Edit(ctx, id, input)
	if err != nil {
		return nil, err
	}
	//_, err = i.upstreamModule.Save(ctx, id, newAIUpstream(id, *input.Provider, p.URI()))

	return info, nil
}

func (i *imlServiceController) createAIService(ctx *gin.Context, teamID string, input *service_dto.CreateService) (*service_dto.Service, error) {
	if input.Provider == nil {
		return nil, fmt.Errorf("provider is required")
	}

	if input.Id == "" {
		input.Id = uuid.New().String()
	}
	if input.Prefix == "" {
		if len(input.Id) < 9 {
			input.Prefix = input.Id
		} else {
			input.Prefix = input.Id[:8]
		}
	}
	modelId := ""
	modelCfg := ""
	modelType := "online"
	if *input.Provider == ai_provider_local.ProviderLocal {
		modelType = "local"
		list, err := i.aiLocalModel.SimpleList(ctx)
		if err != nil {
			return nil, err
		}
		if len(list) == 0 {
			return nil, fmt.Errorf("no local model")
		}
		modelId = list[0].Id
		modelCfg = ai_provider_local.LocalConfig
	} else {
		pv, err := i.providerModule.Provider(ctx, *input.Provider)
		if err != nil {
			return nil, err
		}
		p, has := model_runtime.GetProvider(*input.Provider)
		if !has {
			return nil, fmt.Errorf("provider not found")
		}
		m, has := p.GetModel(pv.DefaultLLM)
		if !has {
			return nil, fmt.Errorf("model %s not found", pv.DefaultLLM)
		}
		//modelId = m.ID()
		modelId = m.Name()
		modelCfg = m.DefaultConfig()

	}

	var info *service_dto.Service
	err := i.transaction.Transaction(ctx, func(txCtx context.Context) error {
		var err error
		info, err = i.module.Create(ctx, teamID, input)
		if err != nil {
			return err
		}
		prefix := strings.Replace(input.Prefix, ":", "_", -1)
		path := fmt.Sprintf("/%s/chat/completions", strings.Trim(prefix, "/"))
		timeout := 300000
		retry := 0
		aiPrompt := &ai_api_dto.AiPrompt{
			Variables: []*ai_api_dto.AiPromptVariable{},
			Prompt:    "",
		}
		aiModel := &ai_api_dto.AiModel{
			Id:       modelId,
			Config:   modelCfg,
			Provider: *input.Provider,
			Type:     modelType,
		}
		name := "Demo AI API "
		description := "This is a demo that shows you how to use a Chat API."
		apiId := uuid.New().String()
		err = i.aiAPIModule.Create(
			ctx,
			info.Id,
			&ai_api_dto.CreateAPI{
				Id:          apiId,
				Name:        name,
				Path:        path,
				Description: description,
				Disable:     false,
				AiPrompt:    aiPrompt,
				AiModel:     aiModel,
				Timeout:     timeout,
				Retry:       retry,
			},
		)
		if err != nil {
			return err
		}
		plugins := make(map[string]api.PluginSetting)
		plugins["ai_prompt"] = api.PluginSetting{
			Config: plugin_model.ConfigType{
				"prompt":    aiPrompt.Prompt,
				"variables": aiPrompt.Variables,
			},
		}
		plugins["ai_formatter"] = api.PluginSetting{
			Config: plugin_model.ConfigType{
				"model":    aiModel.Id,
				"provider": fmt.Sprintf("%s@ai-provider", info.Provider.Id),
				"config":   aiModel.Config,
			},
		}
		_, err = i.routerModule.Create(ctx, info.Id, &router_dto.Create{
			Id:   apiId,
			Name: name,
			Path: path,
			Methods: []string{
				http.MethodPost,
			},
			Description: description,
			Protocols:   []string{"http", "https"},
			MatchRules:  nil,
			Proxy: &router_dto.InputProxy{
				Path:    path,
				Timeout: timeout,
				Retry:   retry,
				Plugins: plugins,
			},
			Disable:  false,
			Upstream: info.Provider.Id,
		})
		if err != nil {
			return err
		}
		apps, err := i.appModule.Search(ctx, info.Team.Id, "")
		if err != nil {
			return err
		}
		for _, app := range apps {
			i.subscribeModule.AddSubscriber(ctx, info.Id, &subscribe_dto.AddSubscriber{
				Application: app.Id,
			})
		}

		return i.docModule.SaveServiceDoc(ctx, info.Id, &service_dto.SaveServiceDoc{
			Doc: "",
		})
	})

	return info, err
}

func (i *imlServiceController) SearchMyServices(ctx *gin.Context, teamId string, keyword string) ([]*service_dto.ServiceItem, error) {
	return i.module.SearchMyServices(ctx, teamId, keyword)
}

func (i *imlServiceController) Get(ctx *gin.Context, id string) (*service_dto.Service, error) {
	now := time.Now()
	defer func() {
		log.Infof("get service %s cost %d ms", id, time.Since(now).Milliseconds())
	}()
	return i.module.Get(ctx, id)
}

func (i *imlServiceController) Search(ctx *gin.Context, teamIDs string, keyword string) ([]*service_dto.ServiceItem, error) {
	return i.module.Search(ctx, teamIDs, keyword)
}

func (i *imlServiceController) Create(ctx *gin.Context, teamID string, input *service_dto.CreateService) (*service_dto.Service, error) {
	if input.Kind == "ai" {
		return i.createAIService(ctx, teamID, input)
	}
	var err error
	var info *service_dto.Service
	err = i.transaction.Transaction(ctx, func(ctx context.Context) error {
		info, err = i.module.Create(ctx, teamID, input)
		if err != nil {
			return err
		}
		path := fmt.Sprintf("/%s/", strings.Trim(input.Prefix, "/"))
		_, err = i.routerModule.Create(ctx, info.Id, &router_dto.Create{
			Id:          uuid.New().String(),
			Name:        "",
			Path:        path + "*",
			Methods:     []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodPatch, http.MethodOptions},
			Description: "auto create by create service",
			Protocols:   []string{"http", "https"},
			MatchRules:  nil,
			Upstream:    "",
			Proxy: &router_dto.InputProxy{
				Path:    path,
				Timeout: 30000,
				Retry:   0,
			},
			Disable: false,
		})
		apps, err := i.appModule.Search(ctx, teamID, "")
		if err != nil {
			return err
		}
		for _, app := range apps {
			i.subscribeModule.AddSubscriber(ctx, info.Id, &subscribe_dto.AddSubscriber{
				Application: app.Id,
			})
		}
		return err
	})
	return info, err
}

func (i *imlServiceController) Edit(ctx *gin.Context, id string, input *service_dto.EditService) (*service_dto.Service, error) {
	info, err := i.Get(ctx, id)
	if err != nil {
		return nil, err
	}
	if info.ServiceKind == "ai" {
		return i.editAIService(ctx, id, input)
	}
	return i.module.Edit(ctx, id, input)
}

func (i *imlServiceController) Delete(ctx *gin.Context, id string) error {
	return i.module.Delete(ctx, id)
}

func (i *imlServiceController) ServiceDoc(ctx *gin.Context, id string) (*service_dto.ServiceDoc, error) {
	return i.docModule.ServiceDoc(ctx, id)
}

func (i *imlServiceController) SaveServiceDoc(ctx *gin.Context, id string, input *service_dto.SaveServiceDoc) error {
	return i.docModule.SaveServiceDoc(ctx, id, input)
}

type imlAppController struct {
	module     service.IAppModule                             `autowired:""`
	authModule application_authorization.IAuthorizationModule `autowired:""`
}

func (i *imlAppController) SearchCanSubscribe(ctx *gin.Context, serviceId string) ([]*service_dto.SubscribeAppItem, error) {
	items, _, err := i.module.SearchCanSubscribe(ctx, serviceId)
	return items, err
}

func (i *imlAppController) Search(ctx *gin.Context, teamId string, keyword string) ([]*service_dto.AppItem, error) {
	return i.module.Search(ctx, teamId, keyword)
}

func (i *imlAppController) CreateApp(ctx *gin.Context, teamID string, input *service_dto.CreateApp) (*service_dto.App, error) {
	app, err := i.module.CreateApp(ctx, teamID, input)
	if err != nil {
		return nil, err
	}
	_, err = i.authModule.AddAuthorization(ctx, app.Id, &application_authorization_dto.CreateAuthorization{
		Name:       "Default API Key",
		Driver:     "apikey",
		Position:   "Header",
		TokenName:  "Authorization",
		ExpireTime: 0,
		Config: map[string]interface{}{
			"apikey": uuid.New().String(),
		},
	})
	if err != nil {
		i.module.DeleteApp(ctx, app.Id)
		return nil, err
	}
	return app, nil
}
func (i *imlAppController) UpdateApp(ctx *gin.Context, appId string, input *service_dto.UpdateApp) (*service_dto.App, error) {
	return i.module.UpdateApp(ctx, appId, input)
}

func (i *imlAppController) SearchMyApps(ctx *gin.Context, teamId string, keyword string) ([]*service_dto.AppItem, error) {
	return i.module.SearchMyApps(ctx, teamId, keyword)
}

func (i *imlAppController) SimpleApps(ctx *gin.Context, keyword string) ([]*service_dto.SimpleAppItem, error) {
	return i.module.SimpleApps(ctx, keyword)
}

func (i *imlAppController) MySimpleApps(ctx *gin.Context, keyword string) ([]*service_dto.SimpleAppItem, error) {
	return i.module.MySimpleApps(ctx, keyword)
}

func (i *imlAppController) GetApp(ctx *gin.Context, appId string) (*service_dto.App, error) {
	return i.module.GetApp(ctx, appId)
}

func (i *imlAppController) DeleteApp(ctx *gin.Context, appId string) error {
	return i.module.DeleteApp(ctx, appId)
}

//func newAIUpstream(id string, provider string, uri model_runtime.IProviderURI) *upstream_dto.Upstream {
//	return &upstream_dto.Upstream{
//		Type:            "http",
//		Balance:         "round-robin",
//		Timeout:         300000,
//		Retry:           0,
//		Remark:          fmt.Sprintf("auto create by ai service %s,provider is %s", id, provider),
//		LimitPeerSecond: 0,
//		ProxyHeaders:    nil,
//		Scheme:          uri.Scheme(),
//		PassHost:        "node",
//		Nodes: []*upstream_dto.NodeConfig{
//			{
//				Address: uri.Host(),
//				Weight:  100,
//			},
//		},
//	}
//}

```

現在讓我檢查編譯是否成功：


看起來 Go 命令不在 PATH 中。讓我檢查一下是否有其他方式來驗證程式碼，或者直接檢查語法錯誤：


很好！沒有 linter 錯誤。現在讓我完成 TODO 並總結修改：


## 修改完成總結

我已經成功完成了所有要求的修改。以下是實作的詳細說明：

### �� 實作的功能

#### 1. **YAML 解析函數** (`parseOpenAPIConfig`)
- 解析 OpenAPI YAML 文件
- 提取所需配置資訊：
  - `ServiceName`: 從 `info.title` 讀取
  - `FirstSummary`: 從第一個 path 的 operation summary 讀取
  - `ServerHost`: 從 `servers[0].url` 提取 host:port
  - `ServerPath`: 從 `servers[0].url` 提取路徑

#### 2. **動態配置應用**
- **VAR1 - 請求路徑**: `/{prefix}/{summary}` 
- **VAR2 - 轉發上游路徑**: 從 `servers[0].url` 提取的路徑
- **VAR3 - 上游地址**: 從 `servers[0].url` 提取的 host:port
- **VAR4 - 轉發 Host**: 預設使用 `"pass"` (透傳客戶端請求Host)
- **VAR5 - 服務名稱**: 從 `info.title` 讀取
- **VAR6 - EnableMCP**: 預設值設為 `true`

#### 3. **錯誤處理**
- 如果 YAML 格式不正確或缺少必要欄位，會返回詳細的錯誤訊息
- 要求用戶修改 YAML 文件

#### 4. **上游配置**
- 為每個服務建立獨立的上游配置
- 包含完整的節點配置和負載均衡設定

### 🔧 修改的檔案

**`controller/service/iml.go`**:
- 新增 `OpenAPIConfig` 結構體
- 新增 `parseOpenAPIConfig` 函數
- 修改 `QuickCreateRestfulService` 函數使用動態配置

### �� 使用範例

當您上傳以下 YAML 文件時：

```yaml
openapi: 3.0.0
info:
  title: Health Restful Service
  version: 1.0.0
  description: 健康檢查 API 文件

servers:
  - url: http://192.168.31.180:5678/api/v1/health

paths:
  /health:
    get:
      summary: health
      description: 取得健康檢查資訊
```

系統會自動建立：
- **請求路徑**: `/e72569cf/health` (prefix + summary)
- **轉發路徑**: `/api/v1/health` (從 server URL 提取)
- **上游地址**: `192.168.31.180:5678`
- **服務名稱**: `Health Restful Service`
- **MCP**: 啟用

### ✅ 符合所有要求

1. ✅ 只處理第一個 API 路徑
2. ✅ YAML 格式錯誤時建立服務失敗並要求修改
3. ✅ 只影響"添加 REST 服務"功能，其他功能保持不變
4. ✅ 每個服務建立獨立的上游配置

修改已完成，程式碼沒有 linter 錯誤，可以開始測試使用！

```yaml
openapi: 3.0.0
info:
  title: Health Restful Service
  version: 1.0.0
  description: 健康檢查 API 文件

servers:
  - url: http://192.168.31.180:5678/api/v1/health

paths:
  /health:
    get:
      summary: health
      description: 取得健康檢查資訊
```

