# FlowOS

Sistema operacional do pequeno negócio, rodando no Claude Code (VS Code) no computador do cliente.
Memória da empresa, retorno automático de clientes e sites sem cara de IA — sem mensalidade além
da assinatura do Claude.

## Instalar (Windows)

Abra o PowerShell (Menu Iniciar → "PowerShell") e cole:

```powershell
irm https://raw.githubusercontent.com/Guilhermedms/flowos/main/instalador/instalar.ps1 | iex
```

O instalador prepara Git, VS Code, Claude Code, cria a pasta do negócio, instala o FlowOS e liga
a atualização automática. Depois é só abrir o Claude no VS Code e dizer "oi".

## Como está organizado

```
.claude-plugin/marketplace.json   catálogo (o Claude Code lê daqui)
plugin/                            o FlowOS em si — vai pro computador do cliente e se atualiza
  .claude-plugin/plugin.json         nome e VERSÃO
  CHANGELOG.md                       novidades (o cliente vê o resumo ao atualizar)
  hooks/hooks.json                   gatilho de abertura
  scripts/abertura.ps1               regras + arquivos novos + aviso de versão + retorno do dia
  scripts/retorno.ps1                motor de retorno de clientes
  bin/flowos-retorno(.cmd)           atalho do motor
  regras/regras.md                   comportamento do sistema (substitui o CLAUDE.md genérico)
  skills/                            os comandos /flowos:*
  modelo/                            estrutura da pasta do negócio (criada/completada na abertura)
instalador/instalar.ps1            instalador de 1 linha
```

A pasta de cada negócio guarda **só dados** (memória, clientes, marca, sites). Atualizar o
FlowOS nunca sobrescreve nada lá — a abertura só cria o que estiver faltando.

## Publicar uma atualização

1. Edite o que quiser em `plugin/`.
2. Teste localmente numa pasta de negócio de teste:
   `claude --plugin-dir ./plugin` (dentro da pasta de teste).
3. Suba a versão em `plugin/.claude-plugin/plugin.json` (`1.0.0` → `1.0.1` correção,
   `1.1.0` novidade, `2.0.0` mudança grande).
4. Escreva o que mudou no topo do `plugin/CHANGELOG.md` (`## 1.0.1` + tópicos em linguagem de cliente).
5. `git commit` + `git push`.

Os clientes recebem na próxima vez que abrirem o Claude (a checagem roda em segundo plano; a
versão nova entra na abertura seguinte). Sem mudar a versão, **ninguém recebe nada**.

## Licença

Uso restrito a clientes licenciados — ver [LICENSE](LICENSE).
