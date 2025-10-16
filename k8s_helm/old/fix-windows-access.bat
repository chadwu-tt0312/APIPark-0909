@echo off
echo 設定 Windows 到 WSL2 的端口轉發...

REM 刪除現有的 portproxy 規則
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=31288
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=31899
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=31306

REM 設定新的 portproxy 規則
echo 設定 APIPark 主應用程式端口轉發 (31288)...
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=31288 connectaddress=172.18.0.2 connectport=31288

echo 設定 Apinto Gateway 端口轉發 (31899)...
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=31899 connectaddress=172.18.0.2 connectport=31899

echo 設定 MySQL 端口轉發 (31306)...
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=31306 connectaddress=172.18.0.2 connectport=31306

echo.
echo 檢查 portproxy 設定...
netsh interface portproxy show all

echo.
echo 設定完成！現在您可以在 Windows 中使用以下地址：
echo - APIPark: http://localhost:31288
echo - Apinto: http://localhost:31899
echo - MySQL: localhost:31306
echo.
pause
