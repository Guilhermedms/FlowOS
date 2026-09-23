# FlowOS — prepara uma pasta de negócio e instala o plugin (sem perguntas: pode ser rodado pelo Claude)
#
# Uso (baixa sempre a versão mais nova):
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/Guilhermedms/FlowOS/main/instalador/instalar-pasta.ps1)))
#
# Parâmetros:
#   -Negocio   nome do negócio (padrão: nome da pasta)
#   -Pasta     pasta do negócio (padrão: pasta atual)
#   -SemAtualizacaoAutomatica   não pede permissão de administrador pra ligar o auto-update
#
# Saída pensada pra ser lida pelo Claude: linhas "OK:", "AVISO:", "ERRO:" e, no fim, "FLOWOS_INSTALADO".

param(
    [string]$Negocio = '',
    [string]$Pasta = '',
    [string]$Repo = 'Guilhermedms/FlowOS',
    [switch]$SemAtualizacaoAutomatica
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$Utf8 = New-Object Text.UTF8Encoding($false)

function Recarregar-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User') + ";$env:USERPROFILE\.local\bin"
}
# Programas externos via cmd: no PowerShell 5.1, texto na saída de erro vira erro fatal.
function Rodar([string]$linha, [switch]$Mostrar) {
    if ($Mostrar) { cmd /c "$linha 2>&1" | ForEach-Object { "   $_" } | Out-Host } else { cmd /c "$linha >nul 2>&1" }
    return $LASTEXITCODE
}
function Gravar-Json($obj, [string]$caminho) {
    [IO.File]::WriteAllText($caminho, ($obj | ConvertTo-Json -Depth 10), $Utf8)
}
function Achar-Claude {
    $c = Get-Command claude -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    $nativo = Join-Path $env:USERPROFILE '.local\bin\claude.exe'
    if (Test-Path $nativo) { return $nativo }
    # executável que vem dentro da extensão do VS Code (a versão mais nova)
    $ext = Get-ChildItem (Join-Path $env:USERPROFILE '.vscode\extensions') -Directory -Filter 'anthropic.claude-code-*' -ErrorAction SilentlyContinue |
        Sort-Object { [version](($_.Name -replace '^anthropic\.claude-code-', '') -replace '-.*$', '') } -Descending
    foreach ($d in $ext) {
        $exe = Join-Path $d.FullName 'resources\native-binary\claude.exe'
        if (Test-Path $exe) { return $exe }
    }
    return $null
}

try {
    Recarregar-Path
    if (-not $Pasta) { $Pasta = (Get-Location).Path }
    $Pasta = (Resolve-Path $Pasta).Path
    if (-not $Negocio.Trim()) { $Negocio = Split-Path $Pasta -Leaf }

    # Git (o Claude Code usa pra baixar o FlowOS do GitHub)
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Output 'AVISO: Git não encontrado — instalando (o Windows pode pedir permissão).'
        [void](Rodar 'winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements')
        Recarregar-Path
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Não consegui instalar o Git. Instale em https://git-scm.com/download/win e rode de novo.' }
    }
    Write-Output 'OK: Git'

    $claude = Achar-Claude
    if (-not $claude) { throw 'Não encontrei o Claude Code neste computador (nem o da extensão do VS Code).' }
    Write-Output "OK: Claude Code ($claude)"

    # pasta do negócio
    $dirClaude = Join-Path $Pasta '.claude'
    New-Item -ItemType Directory -Force $dirClaude | Out-Null
    $marcador = Join-Path $dirClaude 'flowos.json'
    if (-not (Test-Path $marcador)) {
        Gravar-Json ([ordered]@{ negocio = $Negocio.Trim(); instalado_em = (Get-Date).ToString('yyyy-MM-dd'); versao = '0' }) $marcador
    }
    $settingsArq = Join-Path $dirClaude 'settings.json'
    $mercado = [pscustomobject]@{ source = [pscustomobject]@{ source = 'github'; repo = $Repo } }
    if (Test-Path $settingsArq) {
        $s = [IO.File]::ReadAllText($settingsArq, $Utf8) | ConvertFrom-Json
        if (-not $s.PSObject.Properties['extraKnownMarketplaces']) { $s | Add-Member extraKnownMarketplaces (New-Object PSObject) }
        $s.extraKnownMarketplaces | Add-Member -Force flowos $mercado
        Gravar-Json $s $settingsArq
    } else {
        Gravar-Json ([ordered]@{
            extraKnownMarketplaces = [pscustomobject]@{ flowos = $mercado }
            permissions = [ordered]@{
                allow = @('Bash(flowos-retorno:*)', 'PowerShell(flowos-retorno:*)', 'Read(./**)',
                          'Edit(./memoria/**)', 'Edit(./marca/**)', 'Edit(./clientes/**)', 'Edit(./sites/**)',
                          'Edit(./conteudo/**)', 'Edit(./saidas/**)', 'Edit(./sistema/retorno.json)',
                          'Edit(./sistema/fila-hoje.json)', 'Edit(./CLAUDE.md)')
                deny  = @('Read(./sistema/segredos/**)', 'Edit(./sistema/segredos/**)')
            }
        }) $settingsArq
    }
    Write-Output "OK: pasta do negócio ($Pasta)"

    # plugin no escopo do USUÁRIO: o painel do Claude no VS Code não mostra o diálogo de confiança e,
    # sem confiança, ignora o .claude/settings.json da pasta (onde um plugin de projeto seria ativado).
    # Fora de pastas FlowOS o plugin fica inerte: os gatilhos só agem onde existe .claude/flowos.json.
    Push-Location $Pasta
    try {
        [void](Rodar "`"$claude`" plugin marketplace add $Repo")
        $codigo = Rodar "`"$claude`" plugin install flowos@flowos --scope user" -Mostrar
        if ($codigo -ne 0) {
            $lista = cmd /c "`"$claude`" plugin list 2>&1" | Out-String
            if ($lista -notmatch '(?s)flowos@flowos.*?Scope:\s*user') { throw 'Não consegui instalar o plugin FlowOS (veja a mensagem acima).' }
        }
    } finally { Pop-Location }
    Write-Output 'OK: plugin FlowOS instalado'

    # permissões do FlowOS nas configurações do usuário (as da pasta só valem com confiança, que o VS Code não pede)
    $configDir = $env:CLAUDE_CONFIG_DIR; if (-not $configDir) { $configDir = Join-Path $env:USERPROFILE '.claude' }
    $userSettings = Join-Path $configDir 'settings.json'
    New-Item -ItemType Directory -Force (Split-Path $userSettings) | Out-Null
    if (Test-Path $userSettings) {
        Copy-Item $userSettings "$userSettings.flowos-backup" -Force
        $u = [IO.File]::ReadAllText($userSettings, $Utf8) | ConvertFrom-Json
    } else { $u = New-Object PSObject }
    if (-not $u.PSObject.Properties['permissions']) { $u | Add-Member permissions (New-Object PSObject) }
    foreach ($tipo in @('allow', 'deny')) {
        $atuais = @(); if ($u.permissions.PSObject.Properties[$tipo]) { $atuais = @($u.permissions.$tipo) }
        $novas = if ($tipo -eq 'allow') {
            @('Bash(flowos-retorno:*)', 'PowerShell(flowos-retorno:*)', 'Edit(./memoria/**)', 'Edit(./marca/**)',
              'Edit(./clientes/**)', 'Edit(./sites/**)', 'Edit(./conteudo/**)', 'Edit(./saidas/**)',
              'Edit(./sistema/retorno.json)', 'Edit(./sistema/fila-hoje.json)')
        } else { @('Read(./sistema/segredos/**)', 'Edit(./sistema/segredos/**)') }
        $u.permissions | Add-Member -Force $tipo @($atuais + @($novas | Where-Object { $atuais -notcontains $_ }))
    }
    Gravar-Json $u $userSettings
    Write-Output 'OK: permissões do FlowOS'

    # atualização automática (marketplaces de terceiros vêm com ela desligada) — precisa de administrador
    if ($SemAtualizacaoAutomatica) {
        Write-Output 'AVISO: atualização automática não ligada (pedido). O cliente pode usar /flowos:atualizar-sistema.'
    } else {
        $ms = Join-Path $env:ProgramFiles 'ClaudeCode\managed-settings.json'
        $tmp = Join-Path $env:TEMP 'flowos-autoupdate.ps1'
        @"
`$ErrorActionPreference = 'Stop'
`$arq = '$ms'
New-Item -ItemType Directory -Force (Split-Path `$arq) | Out-Null
`$cfg = if (Test-Path `$arq) { Get-Content `$arq -Raw | ConvertFrom-Json } else { New-Object PSObject }
if (-not `$cfg.PSObject.Properties['extraKnownMarketplaces']) { `$cfg | Add-Member extraKnownMarketplaces (New-Object PSObject) }
`$entrada = [pscustomobject]@{ source = [pscustomobject]@{ source = 'github'; repo = '$Repo' }; autoUpdate = `$true }
`$cfg.extraKnownMarketplaces | Add-Member -Force 'flowos' `$entrada
[IO.File]::WriteAllText(`$arq, (`$cfg | ConvertTo-Json -Depth 10), (New-Object Text.UTF8Encoding(`$false)))
"@ | Set-Content -Path $tmp -Encoding UTF8
        try {
            Start-Process powershell -Verb RunAs -Wait -WindowStyle Hidden -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$tmp`"")
            $ok = (Test-Path $ms) -and ((Get-Content $ms -Raw) -match [regex]::Escape($Repo))
            if ($ok) { Write-Output 'OK: atualização automática ligada' } else { throw 'x' }
        } catch {
            Write-Output 'AVISO: atualização automática não foi ligada (permissão negada). Dá pra ligar depois: /plugin → Marketplaces → flowos → Enable auto-update.'
        } finally { Remove-Item $tmp -ErrorAction SilentlyContinue }
    }

    Write-Output "FLOWOS_INSTALADO pasta=$Pasta"
}
catch {
    Write-Output "ERRO: $($_.Exception.Message)"
}
