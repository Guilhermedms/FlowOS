# FlowOS — motor de retorno de clientes
# Lê clientes/clientes.csv + sistema/retorno.json, decide quem deve receber mensagem hoje
# e por quê, e cuida do envio (Gmail automático / WhatsApp assistido).
#
# Os dados ficam na pasta do negócio (CLAUDE_PROJECT_DIR ou pasta atual); o script mora no plugin.
# Atalho: flowos-retorno <ação> [...]   (bin/ do plugin)
#
# Uso:
#   retorno.ps1 -Acao verificar            calcula a fila do dia e imprime o resumo
#   retorno.ps1 -Acao mostrar              imprime a fila completa com as mensagens
#   retorno.ps1 -Acao whatsapp [-Itens 1,3] gera a página com os botões do WhatsApp
#   retorno.ps1 -Acao email    [-Itens 1,3] envia pelo Gmail
#   retorno.ps1 -Acao marcar -Itens 1,3 -Status enviado|pulado [-Canal whatsapp]
#   retorno.ps1 -Acao janela-gmail         abre a janela interativa pra salvar a senha de app
#   retorno.ps1 -Acao datas [-Ano 2027]    lista as datas comemorativas do ano
#
# Compatível com Windows PowerShell 5.1 (vem em todo Windows) — sem dependências.

param(
    [ValidateSet('verificar', 'mostrar', 'whatsapp', 'email', 'marcar', 'configurar-gmail', 'janela-gmail', 'datas')]
    [string]$Acao = 'verificar',
    [string]$Itens = '',
    [ValidateSet('enviado', 'pulado')]
    [string]$Status = 'enviado',
    [ValidateSet('whatsapp', 'email')]
    [string]$Canal = 'whatsapp',
    [string]$Hoje = '',
    [int]$Ano = 0,
    [string]$Raiz = '',
    [switch]$NaoAbrir
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

if (-not $Raiz) { $Raiz = $env:CLAUDE_PROJECT_DIR }
if (-not $Raiz) { $Raiz = (Get-Location).Path }
$Arq = @{
    Clientes  = Join-Path $Raiz 'clientes\clientes.csv'
    Config    = Join-Path $Raiz 'sistema\retorno.json'
    Historico = Join-Path $Raiz 'sistema\historico-envios.csv'
    Fila      = Join-Path $Raiz 'sistema\fila-hoje.json'
    Pagina    = Join-Path $Raiz 'saidas\mensagens-de-hoje.html'
    Segredo   = Join-Path $Raiz 'sistema\segredos\gmail.xml'
}
$BR = [Globalization.CultureInfo]::GetCultureInfo('pt-BR')
$Utf8SemBom = New-Object Text.UTF8Encoding($false)

if ($Hoje) { $HojeData = [datetime]::ParseExact($Hoje, 'dd/MM/yyyy', $BR) } else { $HojeData = (Get-Date).Date }

# ---------------------------------------------------------------- leitura

function Ler-Texto([string]$caminho) {
    $bytes = [IO.File]::ReadAllBytes($caminho)
    # Excel em pt-BR salva CSV em Windows-1252; o sistema grava em UTF-8. Aceita os dois.
    try { $t = (New-Object Text.UTF8Encoding($false, $true)).GetString($bytes) }
    catch { $t = [Text.Encoding]::GetEncoding(1252).GetString($bytes) }
    if ($t.Length -gt 0 -and $t[0] -eq [char]0xFEFF) { $t = $t.Substring(1) }
    return $t
}

function Normalizar([string]$s) {
    if (-not $s) { return '' }
    $d = $s.Trim().ToLowerInvariant().Normalize([Text.NormalizationForm]::FormD)
    $sb = New-Object Text.StringBuilder
    foreach ($ch in $d.ToCharArray()) {
        if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch) -ne [Globalization.UnicodeCategory]::NonSpacingMark) { [void]$sb.Append($ch) }
    }
    return (($sb.ToString() -replace '[^a-z0-9]+', '_').Trim('_'))
}

$Apelidos = @{
    'cliente' = 'nome'; 'nome_completo' = 'nome'
    'whatsapp' = 'telefone'; 'celular' = 'telefone'; 'fone' = 'telefone'; 'telefone_whatsapp' = 'telefone'
    'e_mail' = 'email'
    'nascimento' = 'aniversario'; 'data_de_nascimento' = 'aniversario'; 'data_nascimento' = 'aniversario'
    'ultimo_atendimento' = 'ultima_visita'; 'ultima_compra' = 'ultima_visita'; 'data_ultima_visita' = 'ultima_visita'
    'servico' = 'ultimo_servico'; 'ultimo_produto' = 'ultimo_servico'
    'canal_preferido' = 'canal'
}

function Ler-Csv([string]$caminho) {
    if (-not (Test-Path $caminho)) { return @() }
    $t = Ler-Texto $caminho
    $linhas = @($t -split "`r?`n" | Where-Object { $_.Trim() -ne '' })
    if ($linhas.Count -lt 2) { return @() }
    $delim = ';'
    if ($linhas[0] -notmatch ';' -and $linhas[0] -match ',') { $delim = ',' }
    $saida = @()
    foreach ($linha in ($linhas | ConvertFrom-Csv -Delimiter $delim)) {
        $h = @{}
        foreach ($p in $linha.PSObject.Properties) {
            $k = Normalizar $p.Name
            if ($Apelidos.ContainsKey($k)) { $k = $Apelidos[$k] }
            $h[$k] = ("$($p.Value)").Trim()
        }
        $saida += , $h
    }
    return $saida
}

function Ler-Config {
    if (-not (Test-Path $Arq.Config)) { return $null }
    return (Ler-Texto $Arq.Config | ConvertFrom-Json)
}

function Gravar-Json($obj, [string]$caminho) {
    [IO.File]::WriteAllText($caminho, ($obj | ConvertTo-Json -Depth 8), $Utf8SemBom)
}

function Val($obj, [string]$campo, $padrao) {
    if ($null -ne $obj -and $obj.PSObject.Properties.Name -contains $campo -and $null -ne $obj.$campo -and "$($obj.$campo)" -ne '') { return $obj.$campo }
    return $padrao
}

# ---------------------------------------------------------------- datas

$FormatosData = [string[]]@('dd/MM/yyyy', 'd/M/yyyy', 'dd/MM/yy', 'd/M/yy', 'yyyy-MM-dd', 'dd-MM-yyyy', 'dd.MM.yyyy', 'dd/MM/yyyy HH:mm', 'dd/MM/yyyy HH:mm:ss')

function Parse-Data([string]$s) {
    if (-not $s) { return $null }
    $r = [datetime]::MinValue
    if ([datetime]::TryParseExact($s.Trim(), $FormatosData, $BR, [Globalization.DateTimeStyles]::None, [ref]$r)) { return $r.Date }
    return $null
}

# Aniversário: aceita "dd/MM" ou data completa. Devolve @(dia, mês) ou $null.
function Parse-DiaMes([string]$s) {
    if (-not $s) { return $null }
    if ($s.Trim() -match '^(\d{1,2})[/.-](\d{1,2})$') { return @([int]$Matches[1], [int]$Matches[2]) }
    $d = Parse-Data $s
    if ($d) { return @($d.Day, $d.Month) }
    return $null
}

function Data-No-Ano([int]$dia, [int]$mes, [int]$ano) {
    if ($mes -eq 2 -and $dia -eq 29 -and -not [datetime]::IsLeapYear($ano)) { $dia = 28 }
    try { return (Get-Date -Year $ano -Month $mes -Day $dia).Date } catch { return $null }
}

function Enesimo-DiaDaSemana([int]$ano, [int]$mes, [DayOfWeek]$dow, [int]$n) {
    $primeiro = (Get-Date -Year $ano -Month $mes -Day 1).Date
    $offset = ([int]$dow - [int]$primeiro.DayOfWeek + 7) % 7
    return $primeiro.AddDays($offset + 7 * ($n - 1))
}

function Pascoa([int]$y) {
    $a = $y % 19; $b = [math]::Floor($y / 100); $c = $y % 100
    $d = [math]::Floor($b / 4); $e = $b % 4; $f = [math]::Floor(($b + 8) / 25)
    $g = [math]::Floor(($b - $f + 1) / 3); $h = (19 * $a + $b - $d - $g + 15) % 30
    $i = [math]::Floor($c / 4); $k = $c % 4; $l = (32 + 2 * $e + 2 * $i - $h - $k) % 7
    $m = [math]::Floor(($a + 11 * $h + 22 * $l) / 451)
    $mes = [math]::Floor(($h + $l - 7 * $m + 114) / 31); $dia = (($h + $l - 7 * $m + 114) % 31) + 1
    return (Get-Date -Year $y -Month $mes -Day $dia).Date
}

$NomesDatas = [ordered]@{
    'ano-novo' = 'Ano Novo'; 'carnaval' = 'Carnaval'; 'dia-da-mulher' = 'Dia da Mulher'
    'dia-do-consumidor' = 'Dia do Consumidor'; 'pascoa' = 'Páscoa'; 'dia-das-maes' = 'Dia das Mães'
    'dia-dos-namorados' = 'Dia dos Namorados'; 'dia-dos-pais' = 'Dia dos Pais'; 'dia-do-cliente' = 'Dia do Cliente'
    'dia-das-criancas' = 'Dia das Crianças'; 'black-friday' = 'Black Friday'; 'natal' = 'Natal'
}

function Datas-Do-Ano([int]$ano) {
    $p = Pascoa $ano
    return [ordered]@{
        'ano-novo'          = Data-No-Ano 1 1 $ano
        'carnaval'          = $p.AddDays(-47)
        'dia-da-mulher'     = Data-No-Ano 8 3 $ano
        'dia-do-consumidor' = Data-No-Ano 15 3 $ano
        'pascoa'            = $p
        'dia-das-maes'      = Enesimo-DiaDaSemana $ano 5 ([DayOfWeek]::Sunday) 2
        'dia-dos-namorados' = Data-No-Ano 12 6 $ano
        'dia-dos-pais'      = Enesimo-DiaDaSemana $ano 8 ([DayOfWeek]::Sunday) 2
        'dia-do-cliente'    = Data-No-Ano 15 9 $ano
        'dia-das-criancas'  = Data-No-Ano 12 10 $ano
        'black-friday'      = (Enesimo-DiaDaSemana $ano 11 ([DayOfWeek]::Thursday) 4).AddDays(1)
        'natal'             = Data-No-Ano 25 12 $ano
    }
}

# Data do evento de uma regra num ano (ou $null)
function Data-Evento($regra, [int]$ano, $cfg, $cliente) {
    switch ($regra.tipo) {
        'aniversario_cliente' {
            $dm = Parse-DiaMes $cliente['aniversario']
            if ($dm) { return Data-No-Ano $dm[0] $dm[1] $ano }
        }
        'aniversario_empresa' {
            $dm = Parse-DiaMes (Val $cfg.empresa 'aniversario' '')
            if ($dm) { return Data-No-Ano $dm[0] $dm[1] $ano }
        }
        'data' {
            $dm = Parse-DiaMes "$($regra.data)"
            if ($dm) { return Data-No-Ano $dm[0] $dm[1] $ano }
            $cat = Datas-Do-Ano $ano
            if ($cat.Contains("$($regra.data)")) { return $cat["$($regra.data)"] }
        }
    }
    return $null
}

# Se hoje cai na janela [evento - antecedência, evento + tolerância], devolve a data do evento
function Evento-Na-Janela($regra, $cfg, $cliente) {
    $padraoTol = 0; if ($regra.tipo -eq 'aniversario_cliente') { $padraoTol = 3 }
    $ant = [int](Val $regra 'antecedencia_dias' 0)
    $tol = [int](Val $regra 'tolerancia_dias' $padraoTol)
    foreach ($a in @(($HojeData.Year - 1), $HojeData.Year, ($HojeData.Year + 1))) {
        $d = Data-Evento $regra $a $cfg $cliente
        if ($d -and $HojeData -ge $d.AddDays(-$ant) -and $HojeData -le $d.AddDays($tol)) { return $d }
    }
    return $null
}

function Plural([int]$n, [string]$s, [string]$p) { if ($n -eq 1) { return "$n $s" } return "$n $p" }

function Quando([datetime]$d) {
    $diff = ($d - $HojeData).Days
    if ($diff -eq 0) { return 'hoje' }
    if ($diff -gt 0) { return 'em ' + (Plural $diff 'dia' 'dias') }
    return 'há ' + (Plural (-$diff) 'dia' 'dias')
}

# ---------------------------------------------------------------- regras

function Chave-Cliente($c) {
    $tel = ($c['telefone'] -replace '\D', '')
    if ($tel) { return $tel }
    if ($c['email']) { return $c['email'].ToLowerInvariant() }
    return (Normalizar $c['nome'])
}

function Telefone-WhatsApp([string]$t) {
    $d = ($t -replace '\D', '').TrimStart('0')
    if ($d.Length -eq 10 -or $d.Length -eq 11) { return "55$d" }
    if (($d.Length -eq 12 -or $d.Length -eq 13) -and $d.StartsWith('55')) { return $d }
    if ($d.Length -ge 10) { return $d }
    return ''
}

function Sim([string]$s) { return ((Normalizar $s) -in @('sim', 's', 'x', 'true', '1', 'yes')) }

function Tags-Cliente($c) {
    return @(("$($c['tags'])" -split '[,|/]') | ForEach-Object { Normalizar $_ } | Where-Object { $_ })
}

function Publico-Confere($regra, $c) {
    $servico = Val $regra 'servico' ''
    if ($servico -and (Normalizar $c['ultimo_servico']) -notlike "*$(Normalizar $servico)*") { return $false }
    $pub = Val $regra 'publico' $null
    $tagsRegra = @(Val $pub 'tags' @()) | ForEach-Object { Normalizar $_ } | Where-Object { $_ }
    if (@($tagsRegra).Count -gt 0) {
        $tc = Tags-Cliente $c
        if (-not ($tagsRegra | Where-Object { $tc -contains $_ })) { return $false }
    }
    return $true
}

function Preencher([string]$modelo, [hashtable]$v) {
    if (-not $modelo) { return '' }
    $r = $modelo
    foreach ($k in $v.Keys) { $r = $r.Replace("{$k}", "$($v[$k])") }
    return $r
}

$Prioridade = @{ 'aniversario_cliente' = 1; 'aniversario_empresa' = 2; 'data' = 2; 'inatividade' = 3 }

function Calcular-Fila {
    $cfg = Ler-Config
    $res = [ordered]@{ data = $HojeData.ToString('dd/MM/yyyy'); situacao = 'ok'; itens = @(); avisos = @() }

    if (-not $cfg -or -not (Val $cfg 'ativo' $false)) { $res.situacao = 'sem_estrategia'; return $res }
    $regras = @($cfg.regras | Where-Object { Val $_ 'ativo' $true })
    if ($regras.Count -eq 0) { $res.situacao = 'sem_estrategia'; return $res }

    $clientes = @(Ler-Csv $Arq.Clientes)
    if ($clientes.Count -eq 0) { $res.situacao = 'sem_clientes'; return $res }

    $hist = @(Ler-Csv $Arq.Historico)
    $intervalo = [int](Val $cfg 'intervalo_minimo_dias' 15)
    $limite = [int](Val $cfg 'limite_diario' 30)
    $empresa = Val $cfg.empresa 'nome' ''
    $canais = Val $cfg 'canais' $null
    $waOn = [bool](Val $canais 'whatsapp' $false)
    $emOn = [bool](Val $canais 'email' $false)
    $pref = Val $canais 'preferencia' 'whatsapp'

    $inat = @($regras | Where-Object { $_.tipo -eq 'inatividade' } | Sort-Object { [int]$_.dias } -Descending)
    $datas = @($regras | Where-Object { $_.tipo -ne 'inatividade' })

    $itens = @()
    $semContato = @()
    foreach ($c in $clientes) {
        if (-not $c['nome']) { continue }
        if (Sim $c['nao_contatar']) { continue }
        $chave = Chave-Cliente $c
        $hc = @($hist | Where-Object { $_['chave'] -eq $chave })
        $enviados = @($hc | Where-Object { $_['status'] -eq 'enviado' } | ForEach-Object { Parse-Data $_['data'] } | Where-Object { $_ } | Sort-Object -Descending)
        if ($enviados.Count -gt 0 -and $enviados[0] -eq $HojeData) { continue }   # já falou com ele hoje
        $diasDesdeEnvio = 99999; if ($enviados.Count -gt 0) { $diasDesdeEnvio = ($HojeData - $enviados[0]).Days }

        $visita = Parse-Data $c['ultima_visita']
        $primeiro = ($c['nome'] -split '\s+')[0]
        $vars = @{ primeiro_nome = $primeiro; nome = $c['nome']; ultimo_servico = $c['ultimo_servico']; empresa = $empresa; dias = ''; data = ''; evento = '' }
        $cands = @()

        foreach ($r in $datas) {
            if (-not (Publico-Confere $r $c)) { continue }
            if ($r.tipo -ne 'aniversario_cliente' -and $diasDesdeEnvio -lt $intervalo) { continue }
            $ev = Evento-Na-Janela $r $cfg $c
            if (-not $ev) { continue }
            $ref = $ev.ToString('yyyy-MM-dd')
            if ($hc | Where-Object { $_['regra'] -eq $r.id -and $_['referencia'] -eq $ref }) { continue }
            $nomeEv = Val $r 'nome' $r.id
            switch ($r.tipo) {
                'aniversario_cliente' {
                    $q = Quando $ev
                    if ($q -eq 'hoje') { $expl = "faz aniversário hoje ($($ev.ToString('dd/MM')))" }
                    elseif ($q.StartsWith('em')) { $expl = "faz aniversário $q ($($ev.ToString('dd/MM')))" }
                    else { $expl = "fez aniversário $q ($($ev.ToString('dd/MM')))" }
                }
                'aniversario_empresa' { $expl = "aniversário da empresa é $(Quando $ev) ($($ev.ToString('dd/MM')))" }
                default {
                    $expl = "$nomeEv é $(Quando $ev) ($($ev.ToString('dd/MM')))"
                    if ((Quando $ev).StartsWith('há')) { $expl = "$nomeEv foi $(Quando $ev) ($($ev.ToString('dd/MM')))" }
                }
            }
            $cands += , @{ regra = $r; ref = $ref; expl = $expl; ev = $ev; ordem = 0 }
        }

        if ($visita -and $diasDesdeEnvio -ge $intervalo) {
            $diasSem = ($HojeData - $visita).Days
            foreach ($r in $inat) {
                if (-not (Publico-Confere $r $c)) { continue }
                if ($diasSem -lt [int]$r.dias) { continue }
                # a faixa mais alta alcançada decide; se ela já foi tratada nesse sumiço, não insiste
                $ref = $visita.ToString('yyyy-MM-dd')
                $tratada = $hc | Where-Object { $_['regra'] -eq $r.id -and $_['referencia'] -eq $ref }
                if (-not $tratada) {
                    $serv = ''; if ($c['ultimo_servico']) { $serv = " — $($c['ultimo_servico'])" }
                    $expl = "não volta há $diasSem dias (última visita $($visita.ToString('dd/MM/yyyy'))$serv)"
                    $cands += , @{ regra = $r; ref = $ref; expl = $expl; ev = $null; ordem = $diasSem }
                }
                break
            }
        }

        if ($cands.Count -eq 0) { continue }
        $esc = $cands | Sort-Object @{ Expression = { $Prioridade["$($_.regra.tipo)"] } }, @{ Expression = { $_.ordem }; Descending = $true } | Select-Object -First 1

        if ($visita) { $vars.dias = ($HojeData - $visita).Days }
        if ($esc.ev) { $vars.data = $esc.ev.ToString('dd/MM') }
        $vars.evento = Val $esc.regra 'nome' ''

        # canal
        $wa = Telefone-WhatsApp $c['telefone']
        $em = $c['email']
        $disp = @()
        if ($waOn -and $wa) { $disp += 'whatsapp' }
        if ($emOn -and $em) { $disp += 'email' }
        $prefCli = Normalizar $c['canal']
        if ($prefCli -eq 'e_mail' -or $prefCli -eq 'gmail') { $prefCli = 'email' }
        if ($disp -contains $prefCli) { $usar = @($prefCli) }
        elseif ($pref -eq 'ambos') { $usar = $disp }
        elseif ($disp -contains $pref) { $usar = @($pref) }
        else { $usar = @($disp | Select-Object -First 1) }
        $usar = @($usar | Where-Object { $_ })

        $item = [ordered]@{
            n = 0; status = 'pendente'
            nome = $c['nome']; chave = $chave; telefone = $wa; email = $em
            canais = $usar
            regra = $esc.regra.id; motivo = (Val $esc.regra 'nome' $esc.regra.id); tipo = $esc.regra.tipo
            explicacao = $esc.expl; referencia = $esc.ref
            assunto = (Preencher (Val $esc.regra 'assunto' '{evento}') $vars)
            mensagem = (Preencher $esc.regra.mensagem $vars)
            prioridade = $Prioridade["$($esc.regra.tipo)"]; ordem = $esc.ordem
        }
        if ($usar.Count -eq 0) { $semContato += , $item } else { $itens += , $item }
    }

    $itens = @($itens | Sort-Object @{ Expression = { $_.prioridade } }, @{ Expression = { $_.ordem }; Descending = $true })
    if ($itens.Count -gt $limite) {
        $res.avisos += "Limite diário de $limite mensagens: $($itens.Count - $limite) ficaram pra amanhã."
        $itens = @($itens | Select-Object -First $limite)
    }
    foreach ($s in $semContato) { $res.avisos += "$($s.nome) ($($s.motivo)) não tem telefone/e-mail num canal ativo." }

    # preserva mensagens que o dono já editou hoje
    if (Test-Path $Arq.Fila) {
        try {
            $antiga = Ler-Texto $Arq.Fila | ConvertFrom-Json
            if ($antiga.data -eq $res.data) {
                foreach ($it in $itens) {
                    $o = @($antiga.itens) | Where-Object { $_.chave -eq $it.chave -and $_.regra -eq $it.regra } | Select-Object -First 1
                    if ($o) { $it.mensagem = $o.mensagem; $it.assunto = $o.assunto }
                }
            }
        } catch {}
    }

    $i = 1; foreach ($it in $itens) { $it.n = $i; $i++ }
    $res.itens = $itens
    return $res
}

# ---------------------------------------------------------------- fila / histórico

function Ler-Fila {
    if (-not (Test-Path $Arq.Fila)) { throw 'Fila de hoje não existe. Rode -Acao verificar primeiro.' }
    $f = Ler-Texto $Arq.Fila | ConvertFrom-Json
    if ($f.data -ne $HojeData.ToString('dd/MM/yyyy')) { throw "A fila salva é de $($f.data). Rode -Acao verificar pra gerar a de hoje." }
    return $f
}

function Selecionar($fila) {
    $todos = @($fila.itens | Where-Object { $_.status -eq 'pendente' })
    if (-not $Itens) { return $todos }
    $nums = @($Itens -split '[,; ]+' | Where-Object { $_ } | ForEach-Object { [int]$_ })
    return @($todos | Where-Object { $nums -contains [int]$_.n })
}

function Registrar($item, [string]$canal, [string]$status) {
    if (-not (Test-Path $Arq.Historico)) {
        [IO.File]::WriteAllText($Arq.Historico, "data;hora;chave;nome;regra;referencia;canal;status`r`n", (New-Object Text.UTF8Encoding($true)))
    }
    $nome = "$($item.nome)" -replace ';', ','
    $linha = "$($HojeData.ToString('dd/MM/yyyy'));$((Get-Date).ToString('HH:mm'));$($item.chave);$nome;$($item.regra);$($item.referencia);$canal;$status`r`n"
    [IO.File]::AppendAllText($Arq.Historico, $linha, $Utf8SemBom)
}

# ---------------------------------------------------------------- ações

function Acao-Verificar {
    $r = Calcular-Fila
    if ($r.situacao -eq 'sem_estrategia') {
        Write-Output '[Retorno de clientes] A estratégia de retorno ainda não foi configurada. Sugira ao usuário rodar /flowos:estrategia-retorno.'
        return
    }
    if ($r.situacao -eq 'sem_clientes') {
        Write-Output '[Retorno de clientes] Estratégia configurada, mas clientes/clientes.csv está vazio. Sugira /flowos:importar-clientes.'
        return
    }
    Gravar-Json $r $Arq.Fila
    $itens = @($r.itens)
    if ($itens.Count -eq 0) {
        Write-Output "[Retorno de clientes] $($r.data): nenhuma mensagem de retorno pra enviar hoje."
        foreach ($a in $r.avisos) { Write-Output "Aviso: $a" }
        return
    }
    Write-Output "[Retorno de clientes] $($r.data): $($itens.Count) mensagem(ns) pra enviar hoje."
    foreach ($g in ($itens | Group-Object { $_.motivo })) {
        Write-Output ''
        Write-Output "$($g.Name) ($($g.Count)):"
        foreach ($it in $g.Group) { Write-Output "  $($it.n). $($it.nome) — $($it.explicacao) [$(@($it.canais) -join ' + ')]" }
    }
    foreach ($a in $r.avisos) { Write-Output "Aviso: $a" }
    Write-Output ''
    Write-Output 'Fila completa (com as mensagens) em sistema/fila-hoje.json. Siga a skill /flowos:bom-dia pra apresentar e enviar.'
}

function Acao-Mostrar {
    $f = Ler-Fila
    $itens = @($f.itens)
    if ($itens.Count -eq 0) { Write-Output 'Fila vazia.'; return }
    foreach ($it in $itens) {
        Write-Output "[$($it.n)] $($it.nome) — $($it.motivo) — $($it.status)"
        Write-Output "    Por quê: $($it.explicacao)"
        Write-Output "    Canal: $(@($it.canais) -join ' + ')"
        if (@($it.canais) -contains 'email') { Write-Output "    Assunto: $($it.assunto)" }
        Write-Output "    Mensagem: $($it.mensagem -replace "`r?`n", "`n              ")"
        Write-Output ''
    }
}

function Html([string]$s) { return [Net.WebUtility]::HtmlEncode($s) }

function Acao-WhatsApp {
    $f = Ler-Fila
    $sel = @(Selecionar $f | Where-Object { @($_.canais) -contains 'whatsapp' })
    if ($sel.Count -eq 0) { Write-Output 'Nenhuma mensagem pendente de WhatsApp na seleção.'; return }
    $cfg = Ler-Config
    $empresa = Html (Val $cfg.empresa 'nome' 'Seu negócio')
    $cards = foreach ($it in $sel) {
        $link = "https://wa.me/$($it.telefone)?text=$([Uri]::EscapeDataString($it.mensagem))"
@"
    <article class="card" data-n="$($it.n)">
      <header><span class="num">$($it.n)</span><div><h2>$(Html $it.nome)</h2><p class="motivo">$(Html $it.motivo) · $(Html $it.explicacao)</p></div></header>
      <p class="msg">$((Html $it.mensagem) -replace "`r?`n", '<br>')</p>
      <a class="btn" href="$link" target="_blank" rel="noopener">Abrir no WhatsApp</a>
    </article>
"@
    }
    $html = @"
<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Mensagens de hoje — $empresa</title>
<style>
:root{--bg:#f6f3ee;--fg:#1c1a17;--muted:#6b645a;--card:#fff;--line:#e4ded4;--ok:#1f7a4d;--btn:#1c1a17;--btnfg:#f6f3ee}
@media (prefers-color-scheme:dark){:root{--bg:#141311;--fg:#eee9e1;--muted:#a39b8f;--card:#1d1b18;--line:#2e2b26;--ok:#4cc38a;--btn:#eee9e1;--btnfg:#141311}}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.5 system-ui,Segoe UI,sans-serif}
main{max-width:720px;margin:0 auto;padding:40px 16px 80px}
h1{font-size:28px;margin:0 0 4px;letter-spacing:-.02em}.sub{color:var(--muted);margin:0 0 32px}
.card{background:var(--card);border:1px solid var(--line);border-radius:14px;padding:20px;margin-bottom:14px;transition:opacity .3s}
.card header{display:flex;gap:14px;align-items:flex-start}.num{font-weight:700;color:var(--muted);min-width:22px}
h2{font-size:18px;margin:0}.motivo{margin:2px 0 0;color:var(--muted);font-size:14px}
.msg{white-space:normal;margin:14px 0 16px;padding:14px;border-left:3px solid var(--line);background:color-mix(in srgb,var(--bg) 60%,transparent);border-radius:6px}
.btn{display:inline-block;background:var(--btn);color:var(--btnfg);text-decoration:none;padding:10px 18px;border-radius:999px;font-weight:600}
.card.feito{opacity:.45}.card.feito .btn::after{content:"  ✓ aberto"}
</style></head><body><main>
<h1>Mensagens de hoje</h1>
<p class="sub">$empresa · $($HojeData.ToString('dd/MM/yyyy')) · $($sel.Count) cliente(s). Clique em cada botão, confira no WhatsApp e aperte enviar. Quando terminar, volte ao Claude e diga "enviei".</p>
$($cards -join "`n")
</main>
<script>
document.querySelectorAll('.btn').forEach(function(b){b.addEventListener('click',function(){b.closest('.card').classList.add('feito')})});
</script></body></html>
"@
    [IO.File]::WriteAllText($Arq.Pagina, $html, $Utf8SemBom)
    if (-not $NaoAbrir) { Start-Process $Arq.Pagina }
    Write-Output "Página aberta com $($sel.Count) mensagem(ns): saidas/mensagens-de-hoje.html (itens $(($sel | ForEach-Object { $_.n }) -join ', '))."
    Write-Output 'Quando o usuário confirmar que enviou, rode: flowos-retorno marcar -Itens <números> -Status enviado -Canal whatsapp'
}

function Acao-Email {
    $f = Ler-Fila
    $sel = @(Selecionar $f | Where-Object { @($_.canais) -contains 'email' })
    if ($sel.Count -eq 0) { Write-Output 'Nenhuma mensagem pendente de e-mail na seleção.'; return }
    if (-not (Test-Path $Arq.Segredo)) { Write-Output 'Gmail ainda não configurado. Siga a skill /flowos:configurar-envio.'; return }
    $cred = Import-Clixml $Arq.Segredo
    $cfg = Ler-Config
    $empresa = Val $cfg.empresa 'nome' ''
    $rodape = Val $cfg 'rodape_email' 'Se não quiser mais receber nossas mensagens, é só responder SAIR.'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $de = $cred.UserName; if ($empresa) { $de = "$empresa <$($cred.UserName)>" }
    foreach ($it in $sel) {
        try {
            Send-MailMessage -From $de -To $it.email -Subject $it.assunto -Body "$($it.mensagem)`r`n`r`n--`r`n$rodape" `
                -SmtpServer 'smtp.gmail.com' -Port 587 -UseSsl -Credential $cred -Encoding UTF8 -WarningAction SilentlyContinue
            Registrar $it 'email' 'enviado'
            $it.status = 'enviado'
            Write-Output "OK  [$($it.n)] $($it.nome) <$($it.email)>"
        } catch {
            Write-Output "ERRO [$($it.n)] $($it.nome) <$($it.email)>: $($_.Exception.Message)"
        }
    }
    Gravar-Json $f $Arq.Fila
}

function Acao-Marcar {
    if (-not $Itens) { throw 'Informe -Itens (ex: -Itens 1,3,5).' }
    $f = Ler-Fila
    $sel = @(Selecionar $f)
    foreach ($it in $sel) { Registrar $it $Canal $Status; $it.status = $Status }
    Gravar-Json $f $Arq.Fila
    Write-Output "$($sel.Count) item(ns) marcado(s) como $Status`: $(($sel | ForEach-Object { $_.nome }) -join ', ')."
}

function Acao-ConfigurarGmail {
    Write-Host ''
    Write-Host '  Configurar envio pelo Gmail' -ForegroundColor Cyan
    Write-Host '  A senha fica salva criptografada neste computador, só pro seu usuário do Windows.'
    Write-Host '  Use a SENHA DE APP de 16 letras (não a senha normal do Gmail).'
    Write-Host ''
    $email = Read-Host '  Seu endereço do Gmail'
    $senha = Read-Host '  Senha de app (16 letras, pode colar com os espaços)' -AsSecureString
    $plano = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($senha)) -replace '\s', ''
    $cred = New-Object Management.Automation.PSCredential($email.Trim(), (ConvertTo-SecureString $plano -AsPlainText -Force))
    $plano = $null
    Write-Host ''
    Write-Host '  Mandando um e-mail de teste pra você mesmo...'
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Send-MailMessage -From $cred.UserName -To $cred.UserName -Subject 'Teste do FlowOS ✔' `
            -Body 'Se você recebeu isso, o envio automático de e-mails está funcionando.' `
            -SmtpServer 'smtp.gmail.com' -Port 587 -UseSsl -Credential $cred -Encoding UTF8 -WarningAction SilentlyContinue
        New-Item -ItemType Directory -Force (Split-Path $Arq.Segredo) | Out-Null
        $cred | Export-Clixml $Arq.Segredo
        Write-Host '  Deu certo! Confira sua caixa de entrada. Pode fechar esta janela e voltar pro Claude.' -ForegroundColor Green
    } catch {
        Write-Host "  Não funcionou: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host '  Confira se a verificação em 2 etapas está ativa e se usou a senha de app. Nada foi salvo.'
    }
}

function Acao-Datas {
    $a = $Ano; if (-not $a) { $a = $HojeData.Year }
    $cat = Datas-Do-Ano $a
    foreach ($k in $cat.Keys) {
        $d = $cat[$k]
        Write-Output ("{0,-18} {1,-20} {2} ({3})" -f $k, $NomesDatas[$k], $d.ToString('dd/MM/yyyy'), $BR.DateTimeFormat.GetDayName($d.DayOfWeek))
    }
}

switch ($Acao) {
    'verificar' { Acao-Verificar }
    'mostrar' { Acao-Mostrar }
    'whatsapp' { Acao-WhatsApp }
    'email' { Acao-Email }
    'marcar' { Acao-Marcar }
    'configurar-gmail' { Acao-ConfigurarGmail }
    'janela-gmail' {
        # abre a configuração numa janela própria (a senha é digitada lá, nunca no chat)
        Start-Process powershell -ArgumentList @('-NoProfile', '-NoExit', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-Acao', 'configurar-gmail', '-Raiz', "`"$Raiz`"")
        Write-Output 'Janela de configuração do Gmail aberta.'
    }
    'datas' { Acao-Datas }
}
