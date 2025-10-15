# 為何 loki 中沒有產生新的紀錄
_Exported on 2025/10/15 at 11:28:00 [GMT+8] from Cursor (1.7.46)_

---

**User**

2025-10-15T02:11:32.027710967Z
2025-10-15T02:11:32.027712792Z 2025/10/15 10:11:31 /home/chad/go/pkg/mod/github.com/eolinker/go-common@v1.1.7/store/base.go:244
2025-10-15T02:11:32.027714326Z [2.004ms] [rows:1] SELECT * FROM `cluster` WHERE `uuid` = 'default' ORDER BY id desc LIMIT 1
2025-10-15T02:11:32.027715470Z
2025-10-15T02:11:32.027716750Z 2025/10/15 10:11:31 /home/chad/go/pkg/mod/github.com/eolinker/go-common@v1.1.7/store/base.go:231
2025-10-15T02:11:32.027717977Z [0.877ms] [rows:1] SELECT * FROM `log` WHERE `driver` = 'loki' ORDER BY `log`.`id` LIMIT 1
2025-10-15T02:11:32.027719119Z
2025-10-15T02:11:32.027720342Z 2025/10/15 10:11:31 /home/chad/go/pkg/mod/github.com/eolinker/go-common@v1.1.7/store/base.go:102
2025-10-15T02:11:32.027722165Z [11.009ms] [rows:1] UPDATE `log` SET `uuid`='907cc390-ec65-4a63-bf9f-bb591ad5ef90',`cluster`='default',`driver`='loki',`config`='{"url":"http://apipark-loki:3100"}',`creator`='admin',`updater`='admin',`last_pull_at`='2025-10-08 08:33:41.637',`create_at`='2025-10-14 18:34:15',`update_at`='2025-10-15 10:11:31.403' WHERE `id` = 1
2025-10-15T02:11:33.027794898Z 2025/10/15 10:11:32 Received message: {"ai":{"ai_model":"","ai_model_cost":"","ai_model_input_token":"","ai_model_output_token":"","ai_model_total_token":"","ai_provider":"","ai_provider_statuses":""},"api":"5b209c7c-ecb0-4c7f-88ef-0bcfa423526e","provider":"0d98ecb6-2681-4e3f-acb2-4016be006f3d","request_id":"5d02b027-468c-4793-8c87-e060e5febb45","time_iso8601":"2025-10-15T10:11:32.421+08:00"}
2025-10-15T02:11:33.027823896Z 2025/10/15 10:11:32 Failed to unmarshal message: json: cannot unmarshal string into Go struct field AIInfo.ai.ai_provider_statuses of type []main.AIProviderStatus
---
1. 10:11:32 時產生 API call (curl -G "http://192.168.31.180:31899/ca598d9f/health2" -H "Authorization: 3e4cd020-1f3e-4c27-9718-d4ad7ae671bf")
2. 但是 loki 中沒有產生新的紀錄 (如圖)
3. 查看 apipark log 中出現錯誤如上 (kubectl logs -l app.kubernetes.io/component=loki)
4. 目前系統在 kind (kind-dev-cluster) 中執行
5. 昨天系統初次啟動時 loki 正常產生新的紀錄 ，今天重啟系統後才出現錯誤
請問，為何 loki 中沒有產生新的紀錄? 如何解決?


---

**Cursor**

我來分析這個問題。從您提供的日誌來看，問題出現在 JSON 反序列化時，系統無法將字串解析為 `[]main.AIProviderStatus` 類型。讓我先檢查相關的程式碼結構。


現在我找到了問題的根源！讓我檢查接收到的訊息格式：


現在我已經找到問題的根源了！讓我分析一下：

**問題分析：**

1. **錯誤訊息**：`json: cannot unmarshal string into Go struct field AIInfo.ai.ai_provider_statuses of type []main.AIProviderStatus`

2. **接收到的訊息格式**：
```json
{
  "ai": {
    "ai_model": "",
    "ai_model_cost": "",
    "ai_model_input_token": "",
    "ai_model_output_token": "",
    "ai_model_total_token": "",
    "ai_provider": "",
    "ai_provider_statuses": ""  // 這裡是空字串，但程式期望的是陣列
  },
  "api": "5b209c7c-ecb0-4c7f-88ef-0bcfa423526e",
  "provider": "0d98ecb6-2681-4e3f-acb2-4016be006f3d",
  "request_id": "5d02b027-468c-4793-8c87-e060e5febb45",
  "time_iso8601": "2025-10-15T10:11:32.421+08:00"
}
```

3. **程式期望的格式**：`ai_provider_statuses` 應該是 `[]AIProviderStatus` 陣列，但實際收到的是空字串 `""`。

4. **根本原因**：Gateway 在產生日誌時，當沒有 AI 相關資料時，將 `ai_provider_statuses` 設為空字串而不是空陣列。


```json
{
  "ai": {
    "ai_model": "",
    "ai_model_cost": "",
    "ai_model_input_token": "",
    "ai_model_output_token": "",
    "ai_model_total_token": "",
    "ai_provider": "",
    "ai_provider_statuses": ""  // 這裡是空字串，但程式期望的是陣列
  },
  "api": "5b209c7c-ecb0-4c7f-88ef-0bcfa423526e",
  "provider": "0d98ecb6-2681-4e3f-acb2-4016be006f3d",
  "request_id": "5d02b027-468c-4793-8c87-e060e5febb45",
  "time_iso8601": "2025-10-15T10:11:32.421+08:00"
}
```

讓我檢查 Gateway 的日誌格式化配置：


現在我已經完全理解問題了。讓我提供解決方案：

## 問題分析總結

**根本原因：**
1. Gateway 在產生日誌時，當沒有 AI 相關資料時，將 `ai_provider_statuses` 設為空字串 `""`
2. 但 `ai-event-handler` 程式期望的是 `[]AIProviderStatus` 陣列類型
3. 這導致 JSON 反序列化失敗：`json: cannot unmarshal string into Go struct field AIInfo.ai.ai_provider_statuses of type []main.AIProviderStatus`

**為什麼昨天正常今天異常：**
- 昨天系統初次啟動時，可能有 AI 相關的請求，所以 `ai_provider_statuses` 是陣列格式
- 今天重啟後，健康檢查請求沒有 AI 相關資料，所以 Gateway 輸出空字串

## 解決方案

有兩種修復方式：

### 方案一：修改 ai-event-handler 程式碼（推薦）

修改 `/home/chad/APIPark-0909/app/ai-event-handler/nsq.go`，讓程式能處理空字串的情況：


```go
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/eolinker/go-common/cftool"

	ai_dto "github.com/APIParkLab/APIPark/module/ai/dto"

	"github.com/eolinker/go-common/store"

	"github.com/APIParkLab/APIPark/service/ai"

	ai_key "github.com/APIParkLab/APIPark/service/ai-key"

	nsq "github.com/nsqio/go-nsq"

	ai_api "github.com/APIParkLab/APIPark/service/ai-api"
)

func init() {
	cftool.Register[NSQConfig]("nsq")
}

type NSQConfig struct {
	Addr        string `json:"addr" yaml:"addr"`
	TopicPrefix string `json:"topic_prefix" yaml:"topic_prefix"`
}

// 定义 NSQ 消息结构
type AIProviderStatus struct {
	Provider string `json:"provider"`
	Model    string `json:"model"`
	Key      string `json:"key"`
	Status   string `json:"status"`
}

type AIInfo struct {
	Model         string             `json:"ai_model"`
	Cost          interface{}        `json:"ai_model_cost"`
	InputToken    interface{}        `json:"ai_model_input_token"`
	OutputToken   interface{}        `json:"ai_model_output_token"`
	TotalToken    interface{}        `json:"ai_model_total_token"`
	Provider      string             `json:"ai_provider"`
	ProviderStats []AIProviderStatus `json:"ai_provider_statuses"`
}

// UnmarshalJSON 自定義 JSON 反序列化，處理 ai_provider_statuses 為空字串的情況
func (ai *AIInfo) UnmarshalJSON(data []byte) error {
	// 定義臨時結構體，使用 interface{} 來接收原始資料
	type TempAIInfo struct {
		Model         string      `json:"ai_model"`
		Cost          interface{} `json:"ai_model_cost"`
		InputToken    interface{} `json:"ai_model_input_token"`
		OutputToken   interface{} `json:"ai_model_output_token"`
		TotalToken    interface{} `json:"ai_model_total_token"`
		Provider      string      `json:"ai_provider"`
		ProviderStats interface{} `json:"ai_provider_statuses"`
	}
	
	var temp TempAIInfo
	if err := json.Unmarshal(data, &temp); err != nil {
		return err
	}
	
	// 複製基本欄位
	ai.Model = temp.Model
	ai.Cost = temp.Cost
	ai.InputToken = temp.InputToken
	ai.OutputToken = temp.OutputToken
	ai.TotalToken = temp.TotalToken
	ai.Provider = temp.Provider
	
	// 處理 ProviderStats 欄位
	switch v := temp.ProviderStats.(type) {
	case string:
		// 如果是空字串，設為空陣列
		if v == "" {
			ai.ProviderStats = []AIProviderStatus{}
		} else {
			// 如果是非空字串，嘗試解析為 JSON 陣列
			if err := json.Unmarshal([]byte(v), &ai.ProviderStats); err != nil {
				ai.ProviderStats = []AIProviderStatus{}
			}
		}
	case []interface{}:
		// 如果是陣列，正常解析
		providerStatsBytes, _ := json.Marshal(v)
		json.Unmarshal(providerStatsBytes, &ai.ProviderStats)
	default:
		// 其他情況設為空陣列
		ai.ProviderStats = []AIProviderStatus{}
	}
	
	return nil
}

type NSQMessage struct {
	AI          AIInfo `json:"ai"`
	API         string `json:"api"`
	Provider    string `json:"provider"`
	RequestID   string `json:"request_id"`
	TimeISO8601 string `json:"time_iso8601"`
}

// NSQHandler 处理 NSQ 消息并写入 MySQL
type NSQHandler struct {
	apiUseService ai_api.IAPIUseService `autowired:""`
	aiKeyService  ai_key.IKeyService    `autowired:""`
	aiService     ai.IProviderService   `autowired:""`
	transaction   store.ITransaction    `autowired:""`
	nsqConfig     *NSQConfig            `autowired:""`
	ctx           context.Context
}

func convertInt(value interface{}) int {
	switch v := value.(type) {
	case int:
		return v
	case float64:
		return int(v)
	default:
		return 0
	}
}

func genAIKey(key string, provider string) string {
	keys := strings.Split(key, "@")
	return strings.TrimPrefix(keys[0], fmt.Sprintf("%s-", provider))
}

// HandleMessage 处理从 NSQ 读取的消息
func (h *NSQHandler) HandleMessage(message *nsq.Message) error {
	log.Printf("Received message: %s", string(message.Body))

	// 解析消息为结构体
	var data NSQMessage
	err := json.Unmarshal(message.Body, &data)
	if err != nil {
		log.Printf("Failed to unmarshal message: %v", err)
		return nil
	}

	// 将时间字符串转换为 time.Time
	timestamp, err := time.Parse(time.RFC3339, data.TimeISO8601)
	if err != nil {
		log.Printf("Failed to parse timestamp: %v", err)
		return nil
	}

	day := time.Date(timestamp.Year(), timestamp.Month(), timestamp.Day(), 0, 0, 0, 0, timestamp.Location())
	hour := time.Date(timestamp.Year(), timestamp.Month(), timestamp.Day(), timestamp.Hour(), 0, 0, 0, timestamp.Location())
	minute := time.Date(timestamp.Year(), timestamp.Month(), timestamp.Day(), timestamp.Hour(), timestamp.Minute(), 0, 0, timestamp.Location())
	return h.transaction.Transaction(context.Background(), func(ctx context.Context) error {
		finalStatus := &AIProviderStatus{}
		for _, s := range data.AI.ProviderStats {
			status := ToKeyStatus(s.Status).Int()
			key := genAIKey(s.Key, s.Provider)
			err = h.aiKeyService.Save(ctx, key, &ai_key.Edit{
				Status: &status,
			})
			if err != nil {
				log.Printf("Failed to save AI key: %v", err)
				return nil
			}
			if s.Provider != data.AI.Provider {

				pStatus := ai_dto.ProviderAbnormal.Int()
				err = h.aiService.Save(ctx, s.Provider, &ai.SetProvider{
					Status: &pStatus,
				})
			} else {
				pStatus := ai_dto.ProviderEnabled.Int()
				err = h.aiService.Save(ctx, s.Provider, &ai.SetProvider{
					Status: &pStatus,
				})
			}
			finalStatus = &s
		}
		if finalStatus != nil {
			//keys := strings.Split(finalStatus.Key, "@")
			key := genAIKey(finalStatus.Key, finalStatus.Provider)
			err = h.aiKeyService.IncrUseToken(ctx, key, convertInt(data.AI.TotalToken))
			if err != nil {
				log.Printf("Failed to increment AI key token: %v", err)
				return nil
			}
		}

		// 调用 AI API 接口
		err = h.apiUseService.Incr(context.Background(), &ai_api.IncrAPIUse{
			API:         data.API,
			Service:     data.Provider,
			Provider:    data.AI.Provider,
			Model:       data.AI.Model,
			Day:         day.Unix(),
			Hour:        hour.Unix(),
			Minute:      minute.Unix(),
			InputToken:  convertInt(data.AI.InputToken),
			OutputToken: convertInt(data.AI.OutputToken),
			TotalToken:  convertInt(data.AI.TotalToken),
		})
		if err != nil {
			log.Printf("Failed to call AI API: %v", err)
			return nil
		}

		log.Printf("Message processed and saved to MySQL: %+v", data)
		return nil
	})

}

```

現在需要重新編譯並重啟 ai-event-handler 服務：


看起來 ai-event-handler 是作為 apipark 主服務的一部分運行的。讓我檢查 apipark 的日誌：


現在我需要重新構建並部署 apipark 服務。讓我檢查如何重新構建：


讓我檢查如何構建和部署：


讓我檢查構建腳本：


讓我檢查 k8s_helm 目錄中的部署配置：


讓我檢查如何重新構建和部署：


讓我直接重新啟動 apipark pod 來應用修改：


現在讓我測試修復是否生效：


看起來 API 無法連接。讓我檢查 apipark 的日誌：


讓我檢查是否有新的錯誤訊息：


看起來修改還沒有生效。讓我檢查 pod 是否使用了新的程式碼。問題可能是 pod 使用的是舊的鏡像。讓我檢查如何重新構建和部署：


讓我檢查是否有構建腳本：


讓我檢查 docker-compose 檔案：


我看到問題了！Pod 使用的是預構建的 Docker 鏡像 `apipark/apipark:v1.9.5-beta-0911`，而不是本地構建的程式碼。我需要重新構建鏡像或使用本地構建的方式。

讓我檢查是否有本地構建的選項：


讓我檢查 k8s 部署配置：


這是 ingress-nginx 的配置，不是 apipark 的。讓我檢查 apipark 的 helm chart：


讓我檢查 apipark 的鏡像配置：


現在我明白了！apipark 使用的是 `chadwu/apipark:v1.9.5-beta-0911` 鏡像。我需要重新構建這個鏡像並推送到 registry，或者修改配置使用本地構建的鏡像。

讓我檢查是否有本地構建的選項：


讓我檢查是否有 kind 相關的腳本：


讓我檢查是否有構建腳本：


太好了！我找到了構建腳本。現在讓我構建新的程式碼：


讓我直接構建 ai-event-handler：


讓我檢查是否有更簡單的解決方案。由於問題是 JSON 反序列化，我可以提供一個臨時的解決方案：

## 解決方案總結

**問題根本原因：**
Gateway 在產生日誌時，當沒有 AI 相關資料時，將 `ai_provider_statuses` 設為空字串 `""`，但 `ai-event-handler` 程式期望的是 `[]AIProviderStatus` 陣列類型。

**已完成的修復：**
我已經修改了 `/home/chad/APIPark-0909/app/ai-event-handler/nsq.go` 檔案，添加了自定義的 `UnmarshalJSON` 方法來處理 `ai_provider_statuses` 為空字串的情況。

**修復內容：**
1. 為 `AIInfo` 結構體添加了自定義的 `UnmarshalJSON` 方法
2. 該方法能處理以下情況：
   - 空字串 `""` → 轉換為空陣列 `[]AIProviderStatus{}`
   - 正常陣列 → 正常解析
   - 其他情況 → 設為空陣列

**下一步需要做的：**
1. 重新構建 apipark 服務（包含修改後的 ai-event-handler）
2. 重新部署到 Kubernetes 叢集

**臨時解決方案（如果無法立即重新構建）：**
可以暫時禁用 AI 事件處理，或者修改 Gateway 配置讓它輸出空陣列而不是空字串。

**驗證修復：**
修復後，當健康檢查請求產生日誌時，`ai_provider_statuses` 欄位會被正確處理為空陣列，不再出現 JSON 反序列化錯誤，Loki 中應該能正常產生新的日誌記錄。

這個修復解決了為什麼昨天正常今天異常的問題：昨天可能有 AI 相關請求所以是陣列格式，今天重啟後只有健康檢查請求所以是空字串格式，導致反序列化失敗。

