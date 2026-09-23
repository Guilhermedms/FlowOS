---
name: bom-dia
description: >
  Apresenta as mensagens de retorno de clientes do dia (aniversários, clientes sumidos, datas
  especiais), explica por que cada cliente está na lista, pede aprovação e envia por WhatsApp
  e/ou Gmail. Use na primeira resposta da sessão quando o bloco "[Retorno de clientes]" trouxer
  mensagens, ou quando o usuário disser "bom dia", "o que tem pra hoje", "mensagens de hoje", "/flowos:bom-dia".
---

# /flowos:bom-dia — Mensagens de retorno do dia

O dono abriu o sistema. Seu trabalho: mostrar quem precisa receber mensagem hoje, **por quê**, e
resolver isso em menos de 2 minutos. Tom de sócio que já fez a lição de casa.

Comando do motor (sempre a partir da raiz da pasta):
`flowos-retorno <ação>`

## 1. Ter a fila em mãos

- Se o bloco `[Retorno de clientes]` já veio no contexto desta sessão, usar ele.
- Se não (usuário chamou `/flowos:bom-dia` depois), rodar `flowos-retorno verificar`.
- Rodar `flowos-retorno mostrar` pra ter o texto completo de cada mensagem.

Se não houver mensagens: "Nenhum cliente pra chamar hoje. ✔" e seguir.

## 2. Apresentar

Agrupar por motivo, na ordem: aniversários → datas especiais → clientes sumidos. Formato:

```
Bom dia! Hoje tem 5 clientes pra chamar:

🎂 Aniversário
 1. Ana Lima — faz aniversário hoje

📅 Dia do Cliente (15/09)
 2. Marcos Dias — campanha começa hoje

⏳ Clientes que não voltaram
 3. João Pereira — 47 dias sem vir (último: corte e barba)
 4. Carlos Souza — 84 dias sem vir → já está na faixa de 60 dias, vai com o desconto de 10%

Canal: 1, 2 e 3 por WhatsApp · 4 por e-mail
```

Explicar o porquê em linguagem de gente, não de sistema ("faz 47 dias que ele não aparece; o
ciclo normal dele é 30"). Se houver avisos (cliente sem telefone, limite diário), mencionar em
uma linha no fim.

Depois perguntar:
> "Quer ver as mensagens antes, mandar todas, ou tirar alguém da lista?"

## 3. Ajustes (se pedir)

- **Ver mensagens:** mostrar o texto de cada uma (numeradas).
- **Mudar uma mensagem:** editar o campo `mensagem` (e `assunto`, se for e-mail) do item em
  `sistema/fila-hoje.json`. Manter o tom de `memoria/preferencias.md`. Se o ajuste parecer
  permanente ("nunca fala desconto no aniversário"), oferecer salvar no modelo da regra em
  `sistema/retorno.json`.
- **Tirar alguém:** `flowos-retorno marcar -Itens <n> -Status pulado` (não volta a aparecer nesse ciclo).
- **Deixar pra amanhã:** não fazer nada com o item; ele volta na próxima abertura.
- **Nunca mais contatar:** `nao_contatar` = `sim` em `clientes/clientes.csv`.

## 4. Enviar (só depois do "pode mandar")

**E-mail** (automático): `flowos-retorno email -Itens <números>` → mostrar o resultado (OK/erro).
Se disser que o Gmail não está configurado, oferecer `/flowos:configurar-envio`.

**WhatsApp** (assistido, grátis e sem risco de ban): `flowos-retorno whatsapp -Itens <números>` → abre
uma página com um botão por cliente. Explicar:
> "Abri uma página com os botões. Clica em cada um — o WhatsApp abre com a mensagem pronta,
> é só apertar enviar. Me avisa quando terminar."

Quando o usuário confirmar ("enviei", "pronto"), perguntar se mandou todos. Então:
`flowos-retorno marcar -Itens <os que ele mandou> -Status enviado -Canal whatsapp`.

## 5. Fechar

Uma linha: "Feito: 4 mensagens enviadas. Amanhã eu te mostro os próximos." Se algum cliente
respondeu querendo marcar, lembrar que dá pra registrar com "a Ana marcou pra sexta".

## Regras

- Nunca enviar sem aprovação explícita nesta sessão.
- Nunca inventar motivo — usar a explicação que o motor deu.
- Se o usuário quiser mudar a estratégia (faixas, descontos, datas), mandar pro `/flowos:estrategia-retorno`.
