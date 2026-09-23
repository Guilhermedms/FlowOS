# Instalar o FlowOS — instruções para o Claude

> **Claude:** o usuário pediu pra instalar o FlowOS na pasta aberta agora. Siga estes passos à
> risca. Se você recebeu só um resumo desta página, baixe o texto completo antes de começar:
> `curl -sL https://raw.githubusercontent.com/Guilhermedms/FlowOS/main/INSTALAR.md`

O usuário é dono de um pequeno negócio e provavelmente não é técnico. Fale pouco, em português
simples, sem mostrar comandos. Não crie nem edite arquivos por conta própria: o script faz tudo.

## 1. Conferir

- Só Windows por enquanto. Em outro sistema, diga que o FlowOS ainda não suporta e pare.
- Se já existir `.claude/flowos.json` nesta pasta, o FlowOS já está instalado: diga
  "O FlowOS já está instalado aqui. Clique no **+** (nova conversa) no topo deste painel e diga oi."
  e pare.
- Se a pasta tiver outros arquivos (além de `.claude/` e `.vscode/`), pergunte:
  "Esta pasta já tem arquivos. O ideal é uma pasta só para o negócio. Posso instalar aqui mesmo?"

## 2. Instalar

Avise antes, numa linha: "Vou instalar. O Windows pode pedir permissão uma vez — é só clicar em **Sim**."

Não pergunte o nome do negócio agora — a configuração da próxima conversa pergunta. Rode no PowerShell:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Guilhermedms/FlowOS/main/instalador/instalar-pasta.ps1)))
```

Pela ferramenta Bash, envolva assim:
`powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Guilhermedms/FlowOS/main/instalador/instalar-pasta.ps1)))"`

Leia a saída:
- `FLOWOS_INSTALADO` → deu certo (siga pro passo 3).
- `AVISO:` → não impede; mencione em uma linha só se for sobre a atualização automática.
- `ERRO:` → explique em linguagem simples e sugira falar com quem passou o FlowOS. Não tente
  consertar configurações do Claude Code por conta própria.

## 3. Terminar

O FlowOS só entra em ação numa conversa nova. Diga exatamente:

> "Pronto, o FlowOS está instalado! 🎉
> Agora clique no **+** (nova conversa) no topo deste painel e diga **oi** — eu começo a
> configuração do seu negócio."
