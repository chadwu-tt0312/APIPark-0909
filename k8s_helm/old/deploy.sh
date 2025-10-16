#!/bin/bash

# APIPark Helm Chart 部署腳本

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 函數：打印彩色訊息
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 檢查 Helm 是否安裝
check_helm() {
    if ! command -v helm &> /dev/null; then
        print_error "Helm 未安裝，請先安裝 Helm 3.0+"
        exit 1
    fi
    print_message "Helm 已安裝: $(helm version --short)"
}

# 檢查 Kubernetes 連線
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl 未安裝，請先安裝 kubectl"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        print_error "無法連接到 Kubernetes 叢集"
        exit 1
    fi
    print_message "Kubernetes 叢集連線正常"
}

# 驗證 Helm chart
validate_chart() {
    print_message "驗證 Helm chart..."
    if helm lint ./apipark; then
        print_message "Helm chart 驗證通過"
    else
        print_error "Helm chart 驗證失敗"
        exit 1
    fi
}

# 安裝或升級
deploy() {
    local release_name=${1:-apipark}
    local namespace=${2:-default}
    
    print_message "開始部署 APIPark..."
    print_message "Release 名稱: $release_name"
    print_message "命名空間: $namespace"
    
    # 檢查是否已存在
    if helm list -n $namespace | grep -q $release_name; then
        print_warning "Release $release_name 已存在，將進行升級..."
        helm upgrade $release_name ./apipark -n $namespace
    else
        print_message "安裝新的 Release..."
        helm install $release_name ./apipark -n $namespace --create-namespace
    fi
    
    print_message "部署完成！"
    print_message "使用以下命令查看狀態:"
    echo "  helm status $release_name -n $namespace"
    echo "  kubectl get pods -n $namespace"
    echo "  kubectl get svc -n $namespace"
}

# 卸載
uninstall() {
    local release_name=${1:-apipark}
    local namespace=${2:-default}
    
    print_warning "卸載 Release: $release_name"
    read -p "確定要卸載嗎？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        helm uninstall $release_name -n $namespace
        print_message "卸載完成"
    else
        print_message "取消卸載"
    fi
}

# 顯示狀態
status() {
    local release_name=${1:-apipark}
    local namespace=${2:-default}
    
    print_message "Release 狀態:"
    helm status $release_name -n $namespace
    
    echo
    print_message "Pod 狀態:"
    kubectl get pods -n $namespace -l app.kubernetes.io/name=apipark
    
    echo
    print_message "Service 狀態:"
    kubectl get svc -n $namespace -l app.kubernetes.io/name=apipark
    
    echo
    print_message "外部連接資訊:"
    export NODE_IP=$(kubectl get nodes -n $namespace -o jsonpath="{.items[0].status.addresses[0].address}" 2>/dev/null || echo "無法獲取節點 IP")
    if [ "$NODE_IP" != "無法獲取節點 IP" ]; then
        echo "  APIPark 管理介面: http://$NODE_IP:18288"
        echo "  MySQL 資料庫: $NODE_IP:33306"
        echo "  Grafana 監控: http://$NODE_IP:30000"
    else
        echo "  請手動檢查服務狀態以獲取連接資訊"
    fi
}

# 主函數
main() {
    case "${1:-deploy}" in
        "deploy")
            check_helm
            check_kubectl
            validate_chart
            deploy "${2:-apipark}" "${3:-default}"
            ;;
        "uninstall")
            check_helm
            uninstall "${2:-apipark}" "${3:-default}"
            ;;
        "status")
            check_helm
            status "${2:-apipark}" "${3:-default}"
            ;;
        "validate")
            check_helm
            validate_chart
            ;;
        *)
            echo "用法: $0 {deploy|uninstall|status|validate} [release_name] [namespace]"
            echo ""
            echo "命令:"
            echo "  deploy     - 部署或升級 APIPark (預設)"
            echo "  uninstall  - 卸載 APIPark"
            echo "  status     - 查看部署狀態"
            echo "  validate   - 驗證 Helm chart"
            echo ""
            echo "範例:"
            echo "  $0 deploy apipark production"
            echo "  $0 status apipark default"
            echo "  $0 uninstall apipark default"
            exit 1
            ;;
    esac
}

main "$@"
