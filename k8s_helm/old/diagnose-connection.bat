@echo off
chcp 65001
echo APIPark 連線診斷工具
echo ====================
echo.

REM 取得 WSL2 IP
for /f "tokens=1" %%i in ('wsl hostname -I') do (
    set WSL_IP=%%i
    goto :found_ip
)
:found_ip

echo 1. 系統資訊：
echo    - WSL2 IP: %WSL_IP%
echo    - Windows IP: 
ipconfig | findstr "IPv4"
echo.

echo 2. 檢查端口轉發規則：
netsh interface portproxy show all
echo.

echo 3. 檢查防火牆規則：
netsh advfirewall firewall show rule name="APIPark-31288" 2>nul
if %errorlevel% neq 0 (
    echo    ❌ 未找到 APIPark-31288 防火牆規則
) else (
    echo    ✅ APIPark-31288 防火牆規則存在
)
echo.

echo 4. 測試 WSL2 內部連線：
wsl curl -s -o nul -w "WSL2 內部連線狀態: %%{http_code}\n" http://localhost:31288/ || echo "WSL2 內部無法連線"
echo.

echo 5. 測試 Windows 到 WSL2 連線：
curl -s -o nul -w "Windows 到 WSL2 連線狀態: %%{http_code}\n" http://localhost:31288/ || echo "Windows 到 WSL2 無法連線"
echo.

echo 6. 建議的解決方案：
echo    a) 使用 http://localhost:31288 而不是 http://192.168.31.180:31288
echo    b) 確保防火牆允許端口 31288
echo    c) 確保 WSL2 中的 kubectl port-forward 正在運行
echo.

pause
