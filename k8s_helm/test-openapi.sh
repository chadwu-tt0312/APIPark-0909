set -x

Cookie=""

if [[ "$ApiparkAddress" == "" ]]; then
  ApiparkAddress="http://127.0.0.1:8288"
fi

echo_fail() {
  printf "\e[91m✘ Error:\e[0m $@\n" >&2
}

echo_pass() {
  printf "\e[92m✔ Passed:\e[0m $@\n" >&2
}

echo_info() {
  printf "\e[96mℹ Info:\e[0m $1\n" >&2
}

echo_wait() {
  printf "\e[95m⏳ Waiting:\e[0m $1\n" >&2
}

request_apipark() {
  path=$1
  body=$2
  method=$3
  if [[ "$method" == "" ]]; then
    method="POST"
  fi
  if [[ "$Cookie" == "" ]]; then
    cmd="curl -X ${method} -s -i -H \"Content-Type: application/json\" -d '$body' \"${ApiparkAddress}${path}\""
    echo_info "Executing: $cmd"  # 打印命令
    response=$(eval "$cmd")
  else
    cmd="curl -X ${method} -s -i -H \"Content-Type: application/json\" -H \"Cookie: $Cookie\" -d '$body' \"${ApiparkAddress}${path}\""
    echo_info "Executing: $cmd"  # 打印命令
    response=$(eval "$cmd")
  fi
  echo "$response"
}

is_init() {
  path="/api/v1/system/general"
  method="GET"
  response=$(request_apipark "$path" "" "$method")
  # 从响应中提取 site_prefix
  site_prefix=$(echo "${response}" | grep '^{.*}$' | sed 's/.*"site_prefix":"\{0,1\}\([^"]*\)"\{0,1\}.*/\1/')
  if [ -z "$site_prefix" ]; then
    echo_pass "No apipark openapi address set"
    echo false
  else
    echo_pass "Apipark openapi address found: $site_prefix"
    echo true
  fi
}

set_openapi_config() {
  IP=$(dig +short myip.opendns.com @resolver1.opendns.com | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$')
#   IP=$(curl -s https://api.ipify.org)
  if [ -z "$IP" ]; then
    echo_fail "Failed to resolve IP address"
    # exit 1
    IP="127.0.0.1"
  fi
  body='{"site_prefix":"http://'"${IP}"':8288"}'
  response=$(request_apipark "/api/v1/system/general" "$body")
#   code=$(echo "${response}" | grep '^{.*}$' | sed 's/.*"code":\([0-9]*\).*/\1/')
  code=$(echo "${response}" | grep -o '"code":[0-9]*' | head -1 | sed 's/[^0-9]*//g')
  if ! [[ "$code" =~ ^[0-9]+$ ]]; then
  code=9999
  fi
  if [ "$code" -eq 0 ]; then
    echo_pass "Update apipark openapi address successfully"
  else
    echo_fail "Update apipark openapi address failed: ${response}"
    exit 1
  fi
}

# set_openapi_config
is_init
