# FlowOS — abertura de sessão (gatilho SessionStart do plugin)
# Tudo que este script imprime entra no contexto do Claude.
#  1. Só age em pastas de negócio FlowOS (marcador .claude/flowos.json)
#  2. Cria na pasta do negócio os arquivos que faltam (instalação nova ou versão nova) — nunca sobrescreve
#  3. Avisa quando o FlowOS foi atualizado (lendo o CHANGELOG)
#  4. Entrega as regras do sistema (vêm do plugin → atualizam junto)
#  5. Roda a verificação de retorno de clientes do dia
# Cada etapa tem seu próprio try/catch: uma falha nunca impede as outras.

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$Utf8 = New-Object Text.UTF8Encoding($false)

$Projeto = $env:CLAUDE_PROJECT_DIR
if (-not $Projeto) { $Projeto = (Get-Location).Path }
$Marcador = Join-Path $Projeto '.claude\flowos.json'
if (-not (Test-Path $Marcador)) { exit 0 }

$Plugin = Split-Path $PSScriptRoot -Parent
$Modelo = Join-Path $Plugin 'modelo'

# ---- 2. arquivos que faltam
$criados = @()
try {
    foreach ($arq in (Get-ChildItem $Modelo -Recurse -File -Force)) {
        $rel = $arq.FullName.Substring($Modelo.Length).TrimStart('\')
        if ($rel -eq 'gitignore') { $rel = '.gitignore' }
        $destino = Join-Path $Projeto $rel
        if (-not (Test-Path $destino)) {
            New-Item -ItemType Directory -Force (Split-Path $destino) | Out-Null
            Copy-Item $arq.FullName $destino
            if ($arq.Name -ne '.gitkeep') { $criados += $rel }
        }
    }
} catch { Write-Output "[FlowOS] Aviso: não consegui criar arquivos da pasta ($($_.Exception.Message))." }

# ---- 3. versão
try {
    $versao = ([IO.File]::ReadAllText((Join-Path $Plugin '.claude-plugin\plugin.json'), $Utf8) | ConvertFrom-Json).version
    $info = [IO.File]::ReadAllText($Marcador, $Utf8) | ConvertFrom-Json
    $anterior = "$($info.versao)"
    $atualizou = $anterior -and $anterior -ne '0' -and $anterior -ne $versao
    if ($atualizou) {
        Write-Output "[FlowOS atualizado: $anterior → $versao] Na primeira resposta, conte ao usuário em 1–3 linhas simples o que mudou:"
        $log = [IO.File]::ReadAllText((Join-Path $Plugin 'CHANGELOG.md'), $Utf8)
        $m = [regex]::Match($log, '(?ms)^## ' + [regex]::Escape($versao) + '\s*$(.*?)(?=^## |\z)')
        if ($m.Success) { Write-Output $m.Groups[1].Value.Trim() }
        if ($criados.Count -gt 0) { Write-Output "Arquivos novos na pasta do negócio: $($criados -join ', ')" }
        Write-Output ''
    }
    if ($anterior -ne $versao) {
        $info | Add-Member -NotePropertyName versao -NotePropertyValue $versao -Force
        [IO.File]::WriteAllText($Marcador, ($info | ConvertTo-Json), $Utf8)
    }
} catch { Write-Output "[FlowOS] Aviso: não consegui conferir a versão ($($_.Exception.Message))." }

# ---- 4. regras
try { Write-Output ([IO.File]::ReadAllText((Join-Path $Plugin 'regras\regras.md'), $Utf8)) }
catch { Write-Output '[FlowOS] Não consegui ler as regras do sistema — o plugin pode estar corrompido. Sugira /flowos:atualizar-sistema.' }
Write-Output ''

# ---- 5. retorno de clientes
try { & (Join-Path $PSScriptRoot 'retorno.ps1') -Acao verificar -Raiz $Projeto }
catch { Write-Output "[Retorno de clientes] Erro ao verificar: $($_.Exception.Message). Avise o usuário em uma linha e ofereça revisar clientes/clientes.csv e sistema/retorno.json." }
