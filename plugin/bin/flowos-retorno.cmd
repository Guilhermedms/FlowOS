@echo off
rem Atalho do motor de retorno do FlowOS (cmd/PowerShell). Uso: flowos-retorno <ação> [parâmetros]
set "ACAO=%~1"
if "%ACAO%"=="" set "ACAO=verificar"
shift
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\retorno.ps1" -Acao %ACAO% %1 %2 %3 %4 %5 %6 %7 %8
