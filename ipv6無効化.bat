@echo off
:: �Ǘ��Ҍ����̃`�F�b�N
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo �Ǘ��Ҍ������K�v�ł��B�Ǘ��Ҍ����ōĎ��s���Ă��܂�...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

setlocal enabledelayedexpansion

:: ipconfig �̏o�͂���AIPv6 �A�h���X�����C�[�T�l�b�g �A�_�v�^�[�̖��O�𒊏o
set "adapterName="
set "hasIPv6="

for /f "usebackq delims=" %%L in (`ipconfig`) do (
    set "line=%%L"
    :: �w�b�_�[�s�i�擪���󔒂łȂ��s�j���`�F�b�N
    if not "!line:~0,1!"==" " (
        echo !line! | find "�C�[�T�l�b�g �A�_�v�^�[" >nul
        if not errorlevel 1 (
            :: �u�C�[�T�l�b�g �A�_�v�^�[ �C�[�T�l�b�g:�v�`���Ȃ̂ŁA3�Ԗڂ̃g�[�N�����擾
            for /f "tokens=3 delims= " %%A in ("!line!") do (
                set "adapterName=%%A"
                :: �����̃R����������
                set "adapterName=!adapterName::=!"
            )
            set "hasIPv6=0"
        ) else (
            set "adapterName="
        )
    ) else (
        :: �ڍ׍s�i�擪�ɋ󔒂�����s�j�̒��ŁuIPv6 �A�h���X�v�����o
        echo !line! | find "IPv6 �A�h���X" >nul
        if not errorlevel 1 (
            set "hasIPv6=1"
        )
    )
    if defined adapterName if "!hasIPv6!"=="1" (
        goto :foundAdapter
    )
)
:foundAdapter
if not defined adapterName (
    echo IPv6 �A�h���X�����A�_�v�^�[��������܂���ł����B
    pause
    exit /b
)
echo Found adapter: %adapterName%

:: PowerShell �𗘗p���āA���o�����A�_�v�^�[���� IPv6 ���ꎞ�I�ɖ������^�ėL��������
powershell -NoProfile -Command "try { Disable-NetAdapterBinding -Name '%adapterName%' -ComponentID ms_tcpip6; Write-Host 'IPv6 ������������܂����B'; Write-Host '���s����ɂ͉����L�[�������Ă�������...'; $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') } finally { Enable-NetAdapterBinding -Name '%adapterName%' -ComponentID ms_tcpip6; Write-Host 'IPv6 ���L��������܂����B' }"

pause
