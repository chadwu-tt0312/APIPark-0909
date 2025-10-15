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
		if finalStatus != nil && finalStatus.Key != "" && finalStatus.Provider != "" {
			//keys := strings.Split(finalStatus.Key, "@")
			key := genAIKey(finalStatus.Key, finalStatus.Provider)
			totalToken := convertInt(data.AI.TotalToken)
			if totalToken > 0 {
				err = h.aiKeyService.IncrUseToken(ctx, key, totalToken)
				if err != nil {
					log.Printf("Failed to increment AI key token: %v", err)
					return nil
				}
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
