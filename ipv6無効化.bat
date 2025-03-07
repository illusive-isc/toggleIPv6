@echo off
:: 管理者権限のチェック
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 管理者権限が必要です。管理者権限で再実行しています...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

setlocal enabledelayedexpansion

:: ipconfig の出力から、IPv6 アドレスを持つイーサネット アダプターの名前を抽出
set "adapterName="
set "hasIPv6="

for /f "usebackq delims=" %%L in (`ipconfig`) do (
    set "line=%%L"
    if not "!line:~0,1!"==" " (
        echo !line! | find "イーサネット アダプター" >nul
        if not errorlevel 1 (
            :: 「イーサネット アダプター イーサネット:」形式なので、3番目のトークンを取得
            for /f "tokens=3 delims= " %%A in ("!line!") do (
                set "adapterName=%%A"
                :: 末尾のコロンを除去
                set "adapterName=!adapterName::=!"
            )
            set "hasIPv6=0"
        ) else (
            set "adapterName="
        )
    ) else (
        echo !line! | find "IPv6 アドレス" >nul
        if not errorlevel 1 (
            set "hasIPv6=1"
        )
    )
    if defined adapterName if "!hasIPv6!"=="1" (
        goto :foundAdapter
    )
)
if not defined adapterName (
    echo IPv6 アドレスを持つアダプターが見つかりませんでした。
    pause
    exit /b
)
echo Found adapter: %adapterName%

:: PowerShell を利用して、抽出したアダプター名で IPv6 を一時的に無効化／再有効化する
powershell -NoProfile -Command "try { Disable-NetAdapterBinding -Name '%adapterName%' -ComponentID ms_tcpip6; Write-Host 'IPv6 が無効化されました。'; Write-Host '続行するには何かキーを押してください...'; $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') } finally { Enable-NetAdapterBinding -Name '%adapterName%' -ComponentID ms_tcpip6; Write-Host 'IPv6 が有効化されました。' }"

pause
