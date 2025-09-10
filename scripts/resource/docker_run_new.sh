#!/bin/sh

set -e
. ./init_config.sh   # 改用 POSIX 相容的寫法

OLD_IFS="$IFS"
IFS=","
IFS="$OLD_IFS"

# 建立新的 config.yml
: > config.yml

{
  printf "mysql:\n"
  printf "  user_name: %s\n" "$MYSQL_USER_NAME"
  printf "  password: %s\n" "$MYSQL_PWD"
  printf "  ip: %s\n" "$MYSQL_IP"
  printf "  port: %s\n" "$MYSQL_PORT"
  printf "  db: %s\n" "$MYSQL_DB"

  printf "redis:\n"
  printf "  user_name: %s\n" "$REDIS_USER_NAME"
  printf "  password: %s\n" "$REDIS_PWD"
  printf "  addr:\n"
  for s in $REDIS_ADDR
  do
    printf "    - %s\n" "$s"
  done

  printf "nsq:\n"
  printf "  addr: %s\n" "$NSQ_ADDR"
  printf "  topic_prefix: %s\n" "$NSQ_TOPIC_PREFIX"

  printf "port: 8288\n"

  printf "error_log:\n"
  printf "  dir: %s\n" "$ERROR_DIR"
  printf "  file_name: %s\n" "$ERROR_FILE_NAME"
  printf "  log_level: %s\n" "$ERROR_LOG_LEVEL"
  printf "  log_expire: %s\n" "$ERROR_EXPIRE"
  printf "  log_period: %s\n" "$ERROR_PERIOD"
} > config.yml

cat config.yml

# 啟動主要服務
nohup ./apipark >> run.log 2>&1 &
wait_for_apipark

nohup ./apipark_ai_event_listen >> run.log 2>&1 &

# 初始化判斷
if [ "$Init" = "true" ]; then
  login_apipark
  r=$(is_init)
  if [ "$r" = "true" ]; then
    echo "Already initialized, skipping initialization."
  else
    wait_for_influxdb

    wait_for_apinto
    set_cluster

    wait_for_influxdb
    set_influxdb

    set_loki
    set_nsq
    set_openapi_config

    # 重啟 apipark
    kill -9 "$(pgrep apipark)" || true
    nohup ./apipark >> run.log 2>&1 &
  fi
fi

# 保持 container 前景
tail -F run.log
