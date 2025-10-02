# Windows PowerShell 腳本 - 檢查 APIPark 訪問
Write-Host "=== APIPark Windows 訪問診斷 ===" -ForegroundColor Green
Write-Host ""

# 檢查 portproxy 設定
Write-Host "1. 檢查 portproxy 設定:" -ForegroundColor Yellow
netsh interface portproxy show all
Write-Host ""

# 檢查 Windows 防火牆規則
Write-Host "2. 檢查 Windows 防火牆規則:" -ForegroundColor Yellow
Get-NetFirewallRule -DisplayName "*31288*" -ErrorAction SilentlyContinue
Get-NetFirewallRule -DisplayName "*31899*" -ErrorAction SilentlyContinue
Write-Host ""

# 測試連接
Write-Host "3. 測試連接:" -ForegroundColor Yellow
Write-Host "測試 localhost:31288..."
try {
    $response = Invoke-WebRequest -Uri "http://localhost:31288" -TimeoutSec 5 -UseBasicParsing
    Write-Host "✅ localhost:31288 可訪問" -ForegroundColor Green
} catch {
    Write-Host "❌ localhost:31288 無法訪問: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "測試 172.18.0.2:31288..."
try {
    $response = Invoke-WebRequest -Uri "http://172.18.0.2:31288" -TimeoutSec 5 -UseBasicParsing
    Write-Host "✅ 172.18.0.2:31288 可訪問" -ForegroundColor Green
} catch {
    Write-Host "❌ 172.18.0.2:31288 無法訪問: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== 建議解決方案 ===" -ForegroundColor Green
Write-Host "1. 以管理員身份執行 fix-windows-access.bat"
Write-Host "2. 或在 WSL2 中執行: ./start-port-forward.sh"
Write-Host "3. 檢查 Windows 防火牆是否阻擋了這些端口"
Write-Host ""
