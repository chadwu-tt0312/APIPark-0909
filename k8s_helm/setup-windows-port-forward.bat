chcp 65001
@echo off
echo 設定 Windows 端口轉發到 WSL2...
echo.

for /f "tokens=1" %%i in ('wsl hostname -I') do (
    set WSL_IP=%%i
    goto :found_ip
)
:found_ip

echo WSL2 IP 地址: %WSL_IP%
echo.

REM 設定端口轉發規則
echo 正在設定端口轉發規則...

REM 刪除現有規則（如果存在）
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=31288
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=31899
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=31300
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=31306

REM 新增新的轉發規則
netsh interface portproxy add v4tov4 listenport=31288 listenaddress=0.0.0.0 connectport=31288 connectaddress=%WSL_IP%
netsh interface portproxy add v4tov4 listenport=31899 listenaddress=0.0.0.0 connectport=31899 connectaddress=%WSL_IP%
netsh interface portproxy add v4tov4 listenport=31300 listenaddress=0.0.0.0 connectport=31300 connectaddress=%WSL_IP%
netsh interface portproxy add v4tov4 listenport=31306 listenaddress=0.0.0.0 connectport=31306 connectaddress=%WSL_IP%

echo.
echo ✅ 端口轉發設定完成！
echo.
echo 🌐 現在您可以從任何地方訪問：
echo    - APIPark: http://192.168.31.180:31288
echo    - Apinto: http://192.168.31.180:31899
echo    - Grafana: http://192.168.31.180:31300
echo    - MySQL: 192.168.31.180:31306
echo.
echo 💡 注意：請確保 Windows 防火牆允許這些端口
echo.

REM 顯示當前規則
echo 當前端口轉發規則：
netsh interface portproxy show v4tov4

pause
