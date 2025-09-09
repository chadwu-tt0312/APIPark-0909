# 分析添加 REST 服務流程
_Exported on 2025/9/9 at 15:06:44 [GMT+8] from Cursor (1.5.11)_

---

**User**

目前"添加 REST 服務"時需要
  1. 選擇 OpenAPI 文件(上傳檔案)
  2. 選擇所屬團隊

- 請分析並提供完整"添加 REST 服務"的流程(包含將資料新增到資料庫)。
- 然後與我討論如何修改成"批量添加 REST 服務"(原本一次上傳一個 OpenAPI 文件，變成一次可上傳多個文件)

---

**Cursor**

我來分析"添加 REST 服務"的完整流程，並與您討論如何修改成批量添加功能。


根據我的分析，以下是"添加 REST 服務"的完整流程：

## 目前"添加 REST 服務"的完整流程

### 1. 前端流程
**位置：** `frontend/packages/core/src/pages/guide/RestAIDeploy.tsx`

1. **文件上傳**：
   - 使用 `Upload` 組件，限制只能上傳 `.json` 和 `.yaml` 文件
   - 設定 `multiple: false, maxCount: 1`，只允許單個文件上傳
   - 文件驗證通過後，存儲在表單的 `key` 欄位

2. **團隊選擇**：
   - 通過 `getTeamOptionList()` 獲取可選團隊列表
   - 使用 `Select` 組件讓用戶選擇所屬團隊
   - 預設選擇第一個團隊

3. **提交處理**：
   - 表單驗證通過後，調用 `deployRestServer()` 函數
   - 建立 `FormData` 包含：`file`、`type: 'swagger'`、`team`
   - 發送 POST 請求到 `quick/service/rest` 端點

### 2. 後端流程
**位置：** `controller/service/iml.go` 的 `QuickCreateRestfulService` 方法

1. **文件處理**：
   - 接收 `file` 表單文件
   - 讀取文件內容到記憶體
   - 驗證文件類型（支援 "swagger" 或空值）

2. **資料庫事務處理**：
   - 在事務中執行以下操作：
   
   **a. 建立服務記錄**：
   ```go
   s, err := i.module.Create(ctx, teamId, &service_dto.CreateService{
       Id:           uuid.NewString(),
       Name:         "Restful Service By Swagger",
       Prefix:       prefix,  // 格式: /{id前8位}
       Description:  "Auto create by upload swagger",
       ServiceType:  "public",
       State:        "normal",
       Catalogue:    catalogueInfo.Id,
       ApprovalType: "auto",
       Kind:         "rest",
   })
   ```

   **b. 更新 API 文檔**：
   ```go
   _, err = i.apiDocModule.UpdateDoc(ctx, s.Id, &api_doc_dto.UpdateDoc{
       Id:      s.Id,
       Content: string(content),  // OpenAPI 文件內容
   })
   ```

   **c. 建立路由**：
   ```go
   _, err = i.routerModule.Create(ctx, s.Id, &router_dto.Create{
       Id:          uuid.NewString(),
       Path:        path + "*",  // 萬用字元路由
       Methods:     []string{http.MethodGet, http.MethodPost, ...},
       Description: "auto create by create service",
       Protocols:   []string{"http", "https"},
       Proxy: &router_dto.InputProxy{
           Path:    path,
           Timeout: 30000,
           Retry:   0,
       },
   })
   ```

   **d. 訂閱應用**：
   - 搜尋團隊下的所有應用
   - 為每個應用添加訂閱者

### 3. 資料庫操作
- **服務表**：透過 `serviceService.Create()` 新增服務記錄
- **API 文檔表**：透過 `apiDocService.UpdateDoc()` 儲存 OpenAPI 內容
- **API 表**：透過 `apiService.Create()` 建立路由記錄
- **訂閱表**：透過 `subscribeModule.AddSubscriber()` 建立訂閱關係

---

## 批量添加 REST 服務的修改方案

### 方案一：前端批量上傳 + 後端循環處理

**優點**：實現簡單，復用現有邏輯
**缺點**：事務處理複雜，部分失敗時回滾困難

#### 前端修改：
```typescript
// 修改 Upload 組件支援多文件
const uploadProps: UploadProps = {
  accept: '.json,.yaml',
  name: 'files',  // 改為 files
  multiple: true,  // 改為 true
  maxCount: 10,    // 設定最大上傳數量
  beforeUpload: (file) => {
    // 處理多個文件
    return false
  }
}

// 修改提交邏輯
const deployRestServer = async (files: File[]) => {
  const formData = new FormData()
  files.forEach(file => {
    formData.append('files', file)
  })
  formData.append('type', 'swagger')
  formData.append('team', form.getFieldValue('team'))
  
  // 發送到新的批量端點
  fetchData('quick/service/rest/batch', {
    method: 'POST',
    body: formData
  })
}
```

#### 後端修改：
```go
// 新增批量處理方法
func (i *imlServiceController) BatchCreateRestfulService(ctx *gin.Context) error {
    form, err := ctx.MultipartForm()
    if err != nil {
        return err
    }
    
    files := form.File["files"]
    teamId := ctx.PostForm("team")
    
    var results []BatchResult
    var errors []string
    
    for _, fileHeader := range files {
        result := i.processSingleFile(ctx, fileHeader, teamId)
        results = append(results, result)
        if result.Error != "" {
            errors = append(errors, result.Error)
        }
    }
    
    // 返回批量處理結果
    return ctx.JSON(200, gin.H{
        "success": len(errors) == 0,
        "results": results,
        "errors": errors,
    })
}
```

### 方案二：前端並行上傳 + 後端單個處理

**優點**：事務簡單，錯誤處理清晰
**缺點**：網路請求較多

#### 前端修改：
```typescript
const deployRestServer = async (files: File[]) => {
  const promises = files.map(file => 
    deploySingleRestServer(file, form.getFieldValue('team'))
  )
  
  const results = await Promise.allSettled(promises)
  
  // 處理結果
  const successCount = results.filter(r => r.status === 'fulfilled').length
  const errorCount = results.filter(r => r.status === 'rejected').length
  
  message.info(`成功上傳 ${successCount} 個，失敗 ${errorCount} 個`)
}
```

### 方案三：ZIP 文件上傳 + 後端解壓處理

**優點**：減少網路傳輸，支援大量文件
**缺點**：需要額外的解壓邏輯

#### 實現要點：
1. 前端將多個 OpenAPI 文件打包成 ZIP
2. 後端接收 ZIP 文件並解壓
3. 對每個解壓後的文件執行現有的單個處理邏輯

---

## 建議的實現方案

我建議採用**方案一**，原因如下：

1. **復用現有邏輯**：可以最大程度復用現有的 `QuickCreateRestfulService` 邏輯
2. **用戶體驗好**：一次操作完成多個文件上傳
3. **實現相對簡單**：主要是前端 UI 調整和後端循環處理

### 具體實現步驟：

1. **前端修改**：
   - 修改 `Upload` 組件支援多文件選擇
   - 調整表單驗證邏輯
   - 新增批量上傳進度顯示

2. **後端修改**：
   - 新增 `BatchCreateRestfulService` 方法
   - 復用現有的單個文件處理邏輯
   - 新增批量處理結果回傳

3. **錯誤處理**：
   - 部分文件失敗時，繼續處理其他文件
   - 回傳詳細的成功/失敗信息
   - 提供重試機制

您覺得這個方案如何？需要我詳細說明任何部分的實現細節嗎？

---

