---
name: instalar
description: >
  Primeira configuração do FlowOS no negócio do cliente: pesquisa o que já existe (site,
  Instagram, Google), entrevista o dono em poucos minutos e preenche memoria/, marca/ e o final
  do CLAUDE.md. No fim, encaminha pra base de clientes e estratégia de retorno. Use quando o
  usuário disser "/flowos:instalar", "configurar o sistema", "primeiro acesso", ou quando memoria/empresa.md
  estiver vazio.
---

# /flowos:instalar — Primeira configuração

É a primeira impressão do produto. Tem que parecer conversa com alguém que já estudou o negócio,
não formulário. Uma pergunta por vez. Meta: 10 minutos.

## 0. Checagem

Se `memoria/empresa.md` já tiver conteúdo real, perguntar: "Já tem coisa configurada aqui. Quer
recomeçar do zero ou só completar o que falta?"

## 1. Pesquisar antes de perguntar ⭐

> "Oi! Vou configurar o sistema pro teu negócio. Pra não te encher de pergunta, me passa o que
> tiver: nome do negócio, cidade, e se tiver, o site e o @ do Instagram."

Com isso, pesquisar (WebSearch/WebFetch): site, perfil do Google (avaliações, horário, endereço),
Instagram público. Extrair: o que vende, público, diferenciais, preços se públicos, tom das
legendas, cores do logo/site, avaliações (o que elogiam e reclamam).

Mostrar o resumo do que encontrou em até 6 linhas e perguntar: **"Acertei? O que tá errado ou
faltando?"** Isso substitui metade da entrevista.

Se não houver nada online, seguir direto pra entrevista.

## 2. Entrevista (só o que a pesquisa não respondeu)

**Toda pergunta diz pra que serve**, em meia frase, antes de perguntar. O dono responde melhor
quando entende o motivo. Uma pergunta por mensagem, sempre com um exemplo de resposta.

1. **O que vende** — "Pra eu saber do que falar em nome do teu negócio: o que você vende, em uma
   frase, do jeito que falaria pra um vizinho?" (ex: "corte e barba pra homem, no centro")
2. **Quem compra** — "Pra eu escrever mensagens, posts e o site falando com a pessoa certa: quem
   costuma comprar de você?" (ex: "homens de 25 a 45, que trabalham no centro")
3. **Frequência** — "Pra eu saber quando um cliente está sumido e vale chamar de volta: de quanto
   em quanto tempo um cliente fiel costuma voltar?" (ex: "a cada 3 semanas"). Se o negócio não
   tem recompra (ex: evento único), registrar isso e seguir.
4. **Equipe** — "Pra eu saber a quem atribuir cada coisa: você toca sozinho ou tem equipe? Quem
   faz o quê?"
5. **Jeito de escrever** — "Pra eu escrever igual a você, e não como robô: me cola uma mensagem
   real que você mandou pra cliente (WhatsApp, legenda, e-mail)."
6. **O que evitar** — "Pra eu não escrever nada que te incomode: tem algum jeito de escrever que
   te irrita?" (ex: "caro cliente", muito emoji, gíria)
7. **Tempo** — "Pra eu saber o que tirar das tuas costas primeiro: o que mais te toma tempo toda
   semana?"
8. **Objetivo** — "Pra eu priorizar o que te ajuda de verdade: qual o maior objetivo pros
   próximos 3 meses?" (ex: "encher a agenda de terça e quarta")
9. **Visual** — "Pra tudo que eu criar ter a cara do teu negócio: tem logo e cores definidas?
   Se tiver, arrasta o logo pra pasta `marca/`."

Resposta vaga: pedir exemplo uma vez. "Não sei" é resposta válida: registrar `[a confirmar]` e
seguir, sem insistir. A resposta da 3 vai para `memoria/empresa.md` e é a sugestão inicial de
ciclo no `flowos:estrategia-retorno`.

## 3. Preencher

- `memoria/empresa.md` — **resumo** do negócio (máx. ~1 página): o que vende, público, equipe,
  endereço, horário, canais, diferenciais, o que os clientes elogiam.
- `memoria/conhecimento/servicos-e-precos.md` — lista completa de serviços/produtos com preços
  (se houver). Outras notas se a pesquisa trouxer material (`perguntas-frequentes.md`, `equipe.md`).
  Registrar cada nota criada em `memoria/INDICE.md`.
- `memoria/preferencias.md` — tom de voz descrito a partir do exemplo real (citar trechos),
  lista do que evitar, tamanho típico das mensagens, uso de emoji.
- `memoria/estrategia.md` — objetivo de 3 meses, o que toma tempo (candidato a automação),
  prioridades.
- `marca/guia-de-marca.md` — cores (hex), fontes, logo, estilo de foto. Se não houver, deixar
  claro "a definir" e sugerir a partir do site/Instagram.
- `CLAUDE.md` — trocar `[Nome do negócio]` no título e preencher a seção "## Regras deste negócio" com 3–6 linhas específicas (ex: "Nunca
  prometer horário sem confirmar com a agenda", "Clientes são chamados pelo primeiro nome").

Não inventar nada. Onde faltar, deixar `[a confirmar]`.

## 4. Próximos passos (em sequência, perguntando antes de cada)

1. **Base de clientes** → "Agora o que faz o sistema trabalhar por você: me passa tua lista de
   clientes, do jeito que estiver." → `/flowos:importar-clientes`
2. **Estratégia de retorno** → `/flowos:estrategia-retorno`
3. **Canais de envio** → `/flowos:configurar-envio`

Se o dono quiser parar no meio, tudo bem: dizer que da próxima vez que abrir o sistema você
continua de onde parou.

## 5. Fechamento

```
✓ Negócio: memoria/empresa.md
✓ Jeito de escrever: memoria/preferencias.md
✓ Foco: memoria/estrategia.md
✓ Marca: marca/guia-de-marca.md
✓ Clientes: 142 na base          (ou: pendente)
✓ Retorno de clientes: ativo      (ou: pendente)
```

> "Pronto. A partir de amanhã, toda vez que você abrir o sistema eu já te mostro quem chamar e
> por quê. Pra tudo o resto, é só pedir do teu jeito — site, post, resposta pra cliente, conta."

Registrar no diário (`memoria/diario/AAAA-MM.md`): `- DD/MM: FlowOS configurado`.
