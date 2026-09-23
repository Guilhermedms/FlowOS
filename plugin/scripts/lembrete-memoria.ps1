# FlowOS — lembrete de memória (gatilho Stop do plugin)
# Quando o Claude termina uma resposta em que alterou arquivos do negócio (site, clientes,
# estratégia, conteúdo…) sem tocar na memória, pede pra ele avaliar se vale atualizar a memória
# e, se valer, perguntar ao usuário. No máximo 1 lembrete a cada 20 minutos por sessão.

$ErrorActionPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

$entrada = [Console]::In.ReadToEnd() | ConvertFrom-Json
if (-not $entrada -or $entrada.stop_hook_active) { exit 0 }

$Projeto = $env:CLAUDE_PROJECT_DIR
if (-not $Projeto) { $Projeto = $entrada.cwd }
if (-not $Projeto -or -not (Test-Path (Join-Path $Projeto '.claude\flowos.json'))) { exit 0 }
$transcricao = $entrada.transcript_path
if (-not $transcricao -or -not (Test-Path $transcricao)) { exit 0 }

# arquivos alterados nesta resposta (do fim da transcrição até a última mensagem do usuário)
$linhas = [IO.File]::ReadAllLines($transcricao, [Text.Encoding]::UTF8)
$alterados = @()
for ($i = $linhas.Count - 1; $i -ge 0; $i--) {
    $l = $linhas[$i]
    if ($l -notmatch '"type":\s*"(user|assistant)"') { continue }
    $o = $l | ConvertFrom-Json
    if (-not $o) { continue }
    if ($o.type -eq 'user') {
        $c = $o.message.content
        $ehTexto = ($c -is [string]) -or (@($c | Where-Object { $_.type -eq 'text' }).Count -gt 0)
        if ($ehTexto -and -not $o.isMeta) { break }
        continue
    }
    foreach ($b in @($o.message.content)) {
        if ($b.type -eq 'tool_use' -and $b.name -in @('Write', 'Edit', 'MultiEdit', 'NotebookEdit') -and $b.input.file_path) {
            $alterados += "$($b.input.file_path)"
        }
    }
}
if ($alterados.Count -eq 0) { exit 0 }

$base = ($Projeto -replace '/', '\').TrimEnd('\') + '\'
$rel = @($alterados | ForEach-Object {
    $p = $_ -replace '/', '\'
    if ($p.StartsWith($base, [StringComparison]::OrdinalIgnoreCase)) { $p.Substring($base.Length) }
} | Where-Object { $_ } | Select-Object -Unique)

$memoria = @($rel | Where-Object { $_ -like 'memoria\*' -or $_ -eq 'CLAUDE.md' -or $_ -like 'marca\*' })
$ignorar = @('sistema\fila-hoje.json', 'saidas\mensagens-de-hoje.html')
$trabalho = @($rel | Where-Object {
    $_ -notlike 'memoria\*' -and $_ -ne 'CLAUDE.md' -and $_ -notlike 'marca\*' -and
    $_ -notlike 'sistema\historico*' -and $_ -notlike 'sistema\segredos\*' -and ($ignorar -notcontains $_)
})
if ($trabalho.Count -eq 0 -or $memoria.Count -gt 0) { exit 0 }

# no máximo 1 lembrete a cada 20 minutos por sessão
$estado = Join-Path $env:TEMP ("flowos-memoria-" + ($entrada.session_id -replace '[^\w-]', '') + '.txt')
if (Test-Path $estado) {
    $ultimo = [datetime]::MinValue
    if ([datetime]::TryParse((Get-Content $estado -Raw).Trim(), [ref]$ultimo) -and ((Get-Date) - $ultimo).TotalMinutes -lt 20) { exit 0 }
}
Set-Content -Path $estado -Value (Get-Date).ToString('o')

$lista = ($trabalho | Select-Object -First 8 | ForEach-Object { $_ -replace '\\', '/' }) -join ', '
$motivo = "[FlowOS] Nesta tarefa foram alterados: $lista. Avalie se isso muda algo DURADOURO no que o sistema sabe do negócio " +
          "(serviço ou preço novo, cliente importante, site publicado, estratégia, processo, ferramenta, equipe). " +
          "Se mudou: registre uma linha no diário (memoria/diario/AAAA-MM.md) e termine perguntando em UMA linha " +
          "'Isso mudou algo no teu negócio — quer que eu atualize a memória?'; se o usuário aceitar, siga a skill flowos:atualizar-memoria. " +
          "Se não mudou nada duradouro, não fale de memória: só registre a linha no diário, se fizer sentido, e encerre."
[ordered]@{ decision = 'block'; reason = $motivo } | ConvertTo-Json -Compress
