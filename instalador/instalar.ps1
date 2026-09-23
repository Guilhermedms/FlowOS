# FlowOS — instalador para Windows
#
# Cole no PowerShell (Menu Iniciar → digite "PowerShell" → Enter):
#   irm https://raw.githubusercontent.com/Guilhermedms/FlowOS/main/instalador/instalar.ps1 | iex
#
# O que ele faz (pula o que já existir):
#   1. Git  2. VS Code  3. Claude Code  4. extensão do Claude no VS Code
#   5. pasta do negócio  6. plugin FlowOS + atualização automática (instalar-pasta.ps1)  7. abre o VS Code

$ErrorActionPreference = 'Stop'
$Marketplace = 'Guilhermedms/FlowOS'   # <- repositório do FlowOS no GitHub

function Passo([int]$n, [string]$texto) { Write-Host ''; Write-Host "  [$n/7] $texto" -ForegroundColor Cyan }
function Ok([string]$texto) { Write-Host "        ✓ $texto" -ForegroundColor Green }
function Aviso([string]$texto) { Write-Host "        ! $texto" -ForegroundColor Yellow }
function Tem([string]$cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Recarregar-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User') + ";$env:USERPROFILE\.local\bin"
}
# Programas externos rodam via cmd: no PowerShell 5.1, qualquer texto na saída de erro (ex: aviso do Node)
# vira erro fatal com ErrorActionPreference=Stop. Devolve o código de saída.
function Rodar([string]$linha, [switch]$Mostrar) {
    if ($Mostrar) { cmd /c "$linha 2>&1" | Out-Host } else { cmd /c "$linha >nul 2>&1" }
    return $LASTEXITCODE
}
function Instalar-Winget([string]$id, [string]$nome) {
    if (-not (Tem 'winget')) { throw "Não encontrei o winget (Instalador de Aplicativos). Instale o $nome manualmente e rode este instalador de novo." }
    [void](Rodar "winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements")
    Recarregar-Path
}
function Slug([string]$s) {
    $d = $s.Trim().ToLowerInvariant().Normalize([Text.NormalizationForm]::FormD)
    $sb = New-Object Text.StringBuilder
    foreach ($ch in $d.ToCharArray()) {
        if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch) -ne [Globalization.UnicodeCategory]::NonSpacingMark) { [void]$sb.Append($ch) }
    }
    return (($sb.ToString() -replace '[^a-z0-9]+', '-').Trim('-'))
}

try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
Clear-Host
Write-Host ''
Write-Host '  FlowOS — instalação' -ForegroundColor White
Write-Host '  Leva uns 5 minutos. Se o Windows pedir permissão, clique em Sim.' -ForegroundColor Gray
Recarregar-Path

try {
    # 1. Git (o Claude Code usa pra baixar o FlowOS)
    Passo 1 'Git'
    if (Tem 'git') { Ok 'já instalado' } else { Instalar-Winget 'Git.Git' 'Git'; Ok 'instalado' }

    # 2. VS Code
    Passo 2 'VS Code'
    if (Tem 'code') { Ok 'já instalado' } else { Instalar-Winget 'Microsoft.VisualStudioCode' 'VS Code'; Ok 'instalado' }

    # 3. Claude Code (instalador oficial da Anthropic)
    Passo 3 'Claude Code'
    if (Tem 'claude') { Ok 'já instalado' } else {
        Invoke-RestMethod 'https://claude.ai/install.ps1' | Invoke-Expression
        Recarregar-Path
        if (-not (Tem 'claude')) { throw 'O Claude Code não ficou disponível. Feche esta janela, abra outra e rode o instalador de novo.' }
        Ok 'instalado'
    }

    # 4. Extensão do Claude no VS Code
    Passo 4 'Claude no VS Code'
    [void](Rodar 'code --install-extension anthropic.claude-code --force')
    Ok 'extensão pronta'

    # 5–7. Pasta do negócio + plugin + atualização automática (mesmo script da instalação pelo Claude)
    Passo 5 'Pasta do negócio'
    $nome = ''
    while (-not $nome.Trim()) { $nome = Read-Host '        Nome do negócio' }
    $padrao = Join-Path ([Environment]::GetFolderPath('MyDocuments')) (Slug $nome)
    $resp = Read-Host "        Onde criar? [Enter = $padrao]"
    $pasta = $padrao; if ($resp.Trim()) { $pasta = $resp.Trim() }
    New-Item -ItemType Directory -Force $pasta | Out-Null

    Passo 6 'FlowOS (o Windows vai pedir permissão uma vez — clique em Sim)'
    $script = Invoke-RestMethod "https://raw.githubusercontent.com/$Marketplace/main/instalador/instalar-pasta.ps1"
    $saida = @(& ([scriptblock]::Create($script)) -Negocio $nome.Trim() -Pasta $pasta -Repo $Marketplace)
    foreach ($l in $saida) {
        if ($l -like 'OK:*') { Ok ($l -replace '^OK:\s*', '') }
        elseif ($l -like 'AVISO:*') { Aviso ($l -replace '^AVISO:\s*', '') }
        elseif ($l -like 'ERRO:*') { throw ($l -replace '^ERRO:\s*', '') }
        elseif ($l -notlike 'FLOWOS_INSTALADO*') { Write-Host $l }
    }
    if (-not ($saida | Where-Object { $_ -like 'FLOWOS_INSTALADO*' })) { throw 'A instalação do FlowOS não terminou.' }

    Passo 7 'Tudo pronto'
    Write-Host ''
    Write-Host '  Pronto! Abrindo o VS Code…' -ForegroundColor Green
    Write-Host ''
    Write-Host '  No VS Code:' -ForegroundColor White
    Write-Host '   1. Clique no ícone do Claude (✳) no canto superior direito ou na barra lateral'
    Write-Host '   2. Entre com a sua conta Claude (plano Pro ou superior)'
    Write-Host '   3. Se perguntar se confia na pasta, clique em "Sim, confio"'
    Write-Host '   4. Escreva "oi" — o FlowOS começa a configuração do seu negócio'
    Write-Host '      (se nada acontecer, clique no + no topo do painel pra abrir uma conversa nova e diga oi de novo)'
    Write-Host ''
    [void](Rodar "code `"$pasta`"")
}
catch {
    Write-Host ''
    Write-Host "  A instalação parou: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host '  Tire um print desta tela e mande pra quem te passou o FlowOS.' -ForegroundColor Gray
}
