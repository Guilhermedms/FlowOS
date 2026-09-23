<p align="center"><img src="assets/logo.png" alt="FlowOS" width="220"></p>

# FlowOS

Sistema operacional do pequeno negócio, rodando no Claude Code (VS Code) no computador do cliente.
Memória da empresa, retorno automático de clientes e sites sem cara de IA — sem mensalidade além
da assinatura do Claude.

## Instalar (Windows)

### Pelo Claude no VS Code (quem já tem VS Code + Claude)

1. Crie uma pasta pro negócio e abra no VS Code (Arquivo → Abrir Pasta).
2. Abra o Claude, aceite **confiar na pasta** e cole:

   ```
   Instala o FlowOS nesta pasta seguindo https://raw.githubusercontent.com/Guilhermedms/FlowOS/main/INSTALAR.md
   ```

3. Quando ele terminar, clique no **+** (nova conversa) e diga **oi**.

### Pelo PowerShell (computador sem nada instalado)

Menu Iniciar → "PowerShell" → cole:

```powershell
irm https://raw.githubusercontent.com/Guilhermedms/FlowOS/main/instalador/instalar.ps1 | iex
```

Instala Git, VS Code e Claude Code se faltarem, cria a pasta do negócio, instala o FlowOS e
abre o VS Code. Depois: entrar na conta Claude, confiar na pasta e dizer **oi**.

Os dois caminhos usam o mesmo `instalador/instalar-pasta.ps1` (pasta + plugin + atualização automática).

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
instalador/instalar.ps1            instalador de 1 linha (PC zerado)
instalador/instalar-pasta.ps1      prepara a pasta + instala o plugin (usado pelos dois caminhos)
INSTALAR.md                        instruções pro Claude instalar pelo chat
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
