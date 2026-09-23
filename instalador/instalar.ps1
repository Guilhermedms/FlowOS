# FlowOS — instalador para Windows
#
# Cole no PowerShell (Menu Iniciar → digite "PowerShell" → Enter):
#   irm https://raw.githubusercontent.com/Guilhermedms/FlowOS/main/instalador/instalar.ps1 | iex
#
# O que ele faz (pula o que já existir):
#   1. Git  2. VS Code  3. Claude Code  4. extensão do Claude no VS Code
#   5. pasta do negócio  6. plugin FlowOS  7. atualização automática  → abre o VS Code

$ErrorActionPreference = 'Stop'
$Marketplace = 'Guilhermedms/FlowOS'   # <- repositório do FlowOS no GitHub
$NomeMarketplace = 'flowos'
$Plugin = 'flowos@flowos'

function Passo([int]$n, [string]$texto) { Write-Host ''; Write-Host "  [$n/7] $texto" -ForegroundColor Cyan }
function Ok([string]$texto) { Write-Host "        ✓ $texto" -ForegroundColor Green }
function Aviso([string]$texto) { Write-Host "        ! $texto" -ForegroundColor Yellow }
function Tem([string]$cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Recarregar-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User') + ";$env:USERPROFILE\.local\bin"
}
function Instalar-Winget([string]$id, [string]$nome) {
    if (-not (Tem 'winget')) { throw "Não encontrei o winget (Instalador de Aplicativos). Instale o $nome manualmente e rode este instalador de novo." }
    winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements | Out-Null
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
function Gravar-Json($obj, [string]$caminho) {
    [IO.File]::WriteAllText($caminho, ($obj | ConvertTo-Json -Depth 10), (New-Object Text.UTF8Encoding($false)))
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
    code --install-extension anthropic.claude-code --force 2>$null | Out-Null
    Ok 'extensão pronta'

    # 5. Pasta do negócio
    Passo 5 'Pasta do negócio'
    $nome = ''
    while (-not $nome.Trim()) { $nome = Read-Host '        Nome do negócio' }
    $padrao = Join-Path ([Environment]::GetFolderPath('MyDocuments')) (Slug $nome)
    $resp = Read-Host "        Onde criar? [Enter = $padrao]"
    $pasta = $padrao; if ($resp.Trim()) { $pasta = $resp.Trim() }
    New-Item -ItemType Directory -Force (Join-Path $pasta '.claude') | Out-Null

    $marcador = Join-Path $pasta '.claude\flowos.json'
    if (-not (Test-Path $marcador)) {
        Gravar-Json ([ordered]@{ negocio = $nome.Trim(); instalado_em = (Get-Date).ToString('yyyy-MM-dd'); versao = '0' }) $marcador
    }
    $settingsArq = Join-Path $pasta '.claude\settings.json'
    if (-not (Test-Path $settingsArq)) {
        Gravar-Json ([ordered]@{
            extraKnownMarketplaces = @{ $NomeMarketplace = @{ source = @{ source = 'github'; repo = $Marketplace } } }
            permissions = [ordered]@{
                allow = @('Bash(flowos-retorno:*)', 'PowerShell(flowos-retorno:*)', 'Read(./**)',
                          'Edit(./memoria/**)', 'Edit(./marca/**)', 'Edit(./clientes/**)', 'Edit(./sites/**)',
                          'Edit(./conteudo/**)', 'Edit(./saidas/**)', 'Edit(./sistema/retorno.json)',
                          'Edit(./sistema/fila-hoje.json)', 'Edit(./CLAUDE.md)')
                deny  = @('Read(./sistema/segredos/**)', 'Edit(./sistema/segredos/**)')
            }
        }) $settingsArq
    }
    Ok $pasta

    # 6. Plugin FlowOS (instalado só pra esta pasta)
    Passo 6 'FlowOS'
    Push-Location $pasta
    try {
        claude plugin marketplace add $Marketplace 2>&1 | Out-Null
        claude plugin install $Plugin --scope project
        if ($LASTEXITCODE -ne 0) { throw 'Não consegui instalar o plugin FlowOS (veja a mensagem acima).' }
    } finally { Pop-Location }
    Ok 'plugin instalado'

    # 7. Atualização automática (marketplaces de terceiros vêm com ela desligada)
    Passo 7 'Atualização automática'
    $ms = Join-Path $env:ProgramFiles 'ClaudeCode\managed-settings.json'
    $tmp = Join-Path $env:TEMP 'flowos-autoupdate.ps1'
    @"
`$ErrorActionPreference = 'Stop'
`$arq = '$ms'
New-Item -ItemType Directory -Force (Split-Path `$arq) | Out-Null
`$cfg = if (Test-Path `$arq) { Get-Content `$arq -Raw | ConvertFrom-Json } else { New-Object PSObject }
if (-not `$cfg.PSObject.Properties['extraKnownMarketplaces']) { `$cfg | Add-Member extraKnownMarketplaces (New-Object PSObject) }
`$entrada = [pscustomobject]@{ source = [pscustomobject]@{ source = 'github'; repo = '$Marketplace' }; autoUpdate = `$true }
`$cfg.extraKnownMarketplaces | Add-Member -Force '$NomeMarketplace' `$entrada
[IO.File]::WriteAllText(`$arq, (`$cfg | ConvertTo-Json -Depth 10), (New-Object Text.UTF8Encoding(`$false)))
"@ | Set-Content -Path $tmp -Encoding UTF8
    try {
        Start-Process powershell -Verb RunAs -Wait -WindowStyle Hidden -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$tmp`"")
        if (Test-Path $ms) { Ok 'ligada — o FlowOS se atualiza sozinho' } else { throw 'sem arquivo' }
    } catch {
        Aviso 'Não deu pra ligar sozinho. No Claude, digite /plugin → Marketplaces → flowos → Enable auto-update.'
    } finally { Remove-Item $tmp -ErrorAction SilentlyContinue }

    Write-Host ''
    Write-Host '  Pronto! Abrindo o VS Code…' -ForegroundColor Green
    Write-Host ''
    Write-Host '  No VS Code:' -ForegroundColor White
    Write-Host '   1. Clique no ícone do Claude (✳) no canto superior direito ou na barra lateral'
    Write-Host '   2. Entre com a sua conta Claude (plano Pro ou superior)'
    Write-Host '   3. Se perguntar se confia na pasta, clique em "Sim, confio"'
    Write-Host '   4. Escreva "oi" — o FlowOS começa a configuração do seu negócio'
    Write-Host ''
    code $pasta
}
catch {
    Write-Host ''
    Write-Host "  A instalação parou: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host '  Tire um print desta tela e mande pra quem te passou o FlowOS.' -ForegroundColor Gray
}
