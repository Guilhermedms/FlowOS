---
name: configurar-envio
description: >
  Passo a passo guiado pra configurar os canais de envio das mensagens de retorno: Gmail
  (automático, com senha de app) e/ou WhatsApp (assistido). Use quando o usuário disser
  "/flowos:configurar-envio", "configurar gmail", "configurar whatsapp", ou quando o envio falhar
  por falta de configuração.
---

# /flowos:configurar-envio — Canais de envio

Pessoa leiga do outro lado. Um passo por mensagem, espera o "feito" antes do próximo.
Nunca peça a senha no chat.

Perguntar primeiro (se ainda não souber): **"Vai usar WhatsApp, e-mail ou os dois?"**
No fim, atualizar `canais` em `sistema/retorno.json` (`whatsapp`, `email`, `preferencia`).

## WhatsApp (modo assistido)

Não tem configuração técnica. Conferir só:

1. **Qual WhatsApp vai enviar?** Idealmente o WhatsApp Business do negócio.
2. **Ele está no computador?** Recomendar instalar o WhatsApp Desktop (Microsoft Store) ou
   deixar o WhatsApp Web logado no navegador padrão. Os botões abrem nele.
3. **Os telefones da base têm DDD?** Rodar uma checagem em `clientes/clientes.csv`: listar
   quem está sem telefone ou com número curto (menos de 10 dígitos) e oferecer corrigir.
4. Teste: gerar uma mensagem de teste pro número do próprio dono e pedir pra ele clicar.

Se ele perguntar sobre envio 100% automático no WhatsApp: explicar que existe a API oficial da
Meta (WhatsApp Cloud API), sem mensalidade mas com custo por mensagem de marketing (centavos)
e configuração mais longa (conta Business verificada, modelos aprovados). Vale quando passar de
~30 mensagens por dia. Ferramentas "grátis" que automatizam o WhatsApp Web **não** são usadas:
violam os termos e podem banir o número.

## Gmail (automático)

Funciona com qualquer conta Gmail ou Google Workspace. Limite do Google: ~500 e-mails/dia.

**Passo 1 — Verificação em 2 etapas**
> "Abre https://myaccount.google.com/signinoptions/two-step-verification com a conta que vai
> enviar. Se já estiver ativa, me fala. Se não, ativa (o Google pede o celular)."

**Passo 2 — Senha de app**
> "Agora abre https://myaccount.google.com/apppasswords. Em 'Nome do app' escreve FlowOS e
> clica em Criar. Vai aparecer uma senha de 16 letras num quadro amarelo. **Não me manda ela
> aqui** — deixa a tela aberta, que no próximo passo você cola num lugar seguro."

Se a página disser que o recurso não está disponível: a verificação em 2 etapas não está ativa,
ou é conta de trabalho em que o administrador bloqueou — nesse caso, pedir pro administrador
liberar ou usar outra conta.

**Passo 3 — Salvar com segurança**
Abrir a janela de configuração (ela pede e-mail e senha, testa e salva criptografado):

```
flowos-retorno janela-gmail
```

> "Abri uma janela azul. Digita teu Gmail, cola a senha de 16 letras (ela não aparece
> enquanto você digita, é normal) e aperta Enter. Ela manda um e-mail de teste pra você."

**Passo 4 — Confirmar**
Perguntar se o e-mail de teste chegou. Conferir se `sistema/segredos/gmail.xml` existe (só a
existência — nunca ler o conteúdo).

Se não funcionou: senha errada/com erro de digitação (gerar outra), 2 etapas desativada, ou
antivírus bloqueando a porta 587.

## Fechar

Atualizar `sistema/retorno.json` → `canais`. Resumir:
> "Pronto: WhatsApp assistido ✔ · Gmail automático ✔. Amanhã, quando você abrir o sistema, eu já
> te mostro quem chamar."

## Regras

- A senha só existe na janela do PowerShell e criptografada em `sistema/segredos/` (protegida
  pelo login do Windows, fora do git). Se o usuário colar a senha no chat mesmo assim, avisar
  pra revogar essa senha em apppasswords e gerar outra.
- Trocar de computador = configurar de novo (a criptografia é presa ao usuário do Windows).
