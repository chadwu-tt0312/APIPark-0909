#!/bin/bash

# 設定 Apinto 的 Loki 日誌輸出
# 並等待 port-forward 啟動
# lsof -i :9400 # 查看 9400 端口被哪個進程佔用
# pkill -f "kubectl port-forward svc/apipark-apinto 9400" # 停止 port-forward

kubectl port-forward svc/apipark-apinto 9400:9400 &
sleep 5 && 
curl -X PUT http://localhost:9400/api/output/loki@output \
  -H "Content-Type: application/json" \
  -d '{
    "name": "loki",
    "description": "collect access log",
    "driver": "loki",
    "url": "http://apipark-loki:3100",
    "method": "POST",
    "scopes": ["access_log"],
    "labels": {
      "cluster": "$cluster",
      "node": "$node"
    },
    "type": "json",
    "formatter": {
      "fields": [
        "$msec",
        "$service",
        "$provider",
        "$scheme as request_scheme",
        "$url as request_uri",
        "$host as request_host",
        "$header as request_header",
        "$remote_addr",
        "$request_body",
        "$proxy_body",
        "$proxy_method",
        "$proxy_scheme",
        "$proxy_uri",
        "$api",
        "$proxy_host",
        "$proxy_header",
        "$proxy_addr",
        "$response_header",
        "$response_headers",
        "$status",
        "$content_type",
        "$proxy_status",
        "$request_time",
        "$response_time",
        "$node",
        "$cluster",
        "$application",
        "$src_ip",
        "$block_name as strategy",
        "$request_id",
        "$request_method",
        "$authorization",
        "$response_body",
        "$proxy_response_body",
        "$ai_provider",
        "$ai_model",
        "$ai_model_input_token",
        "$ai_model_output_token",
        "$ai_model_total_token"
      ]
    }
  }' | jq . &&
pkill -f "kubectl port-forward svc/apipark-apinto 9400"
echo "Loki output configured successfully."
