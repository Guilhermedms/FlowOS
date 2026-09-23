---
name: instalar
description: >
  Primeira configuração do FlowOS no negócio do cliente: pesquisa o que já existe (site,
  Instagram, Google), entrevista o dono em poucos minutos e preenche memoria/, marca/ e o final
  do CLAUDE.md. No fim, apresenta o que o FlowOS faz (cada recurso se configura numa conversa própria). Use quando o
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
3. **Equipe** — "Pra eu saber a quem atribuir cada coisa: você toca sozinho ou tem equipe? Quem
   faz o quê?"
4. **Jeito de escrever** — "Pra eu escrever igual a você, e não como robô: me cola uma mensagem
   real que você mandou pra cliente (WhatsApp, legenda, e-mail)."
5. **O que evitar** — "Pra eu não escrever nada que te incomode: tem algum jeito de escrever que
   te irrita?" (ex: "caro cliente", muito emoji, gíria)
6. **Tempo** — "Pra eu saber o que tirar das tuas costas primeiro: o que mais te toma tempo toda
   semana?"
7. **Gargalo** — "Pra eu focar no que destrava teu negócio: o que tá segurando ele de crescer
   hoje?" (ex: "pouca gente nova chegando", "cliente não volta", "não tenho tempo pra divulgar")
8. **Visual** — "Pra tudo que eu criar ter a cara do teu negócio: tem logo e cores definidas?
   Se tiver, arrasta o logo pra pasta `marca/`."

Resposta vaga: pedir exemplo uma vez. "Não sei" é resposta válida: registrar `[a confirmar]` e
seguir, sem insistir.

Não perguntar sobre frequência de volta, descontos ou mensagens pra clientes aqui: isso é
decidido numa conversa própria, depois de o dono entender como o retorno de clientes funciona.

## 3. Preencher

- `memoria/empresa.md` — **resumo** do negócio (máx. ~1 página): o que vende, público, equipe,
  endereço, horário, canais, diferenciais, o que os clientes elogiam.
- `memoria/conhecimento/servicos-e-precos.md` — lista completa de serviços/produtos com preços
  (se houver). Outras notas se a pesquisa trouxer material (`perguntas-frequentes.md`, `equipe.md`).
  Registrar cada nota criada em `memoria/INDICE.md`.
- `memoria/preferencias.md` — tom de voz descrito a partir do exemplo real (citar trechos),
  lista do que evitar, tamanho típico das mensagens, uso de emoji.
- `memoria/estrategia.md` — gargalo atual (nas palavras do dono), o que toma tempo (candidato a
  automação) e prioridades derivadas do gargalo (o que ataca ele direto).
- `marca/guia-de-marca.md` — cores (hex), fontes, logo, estilo de foto. Se não houver, deixar
  claro "a definir" e sugerir a partir do site/Instagram.
- `CLAUDE.md` — trocar `[Nome do negócio]` no título e preencher a seção "## Regras deste negócio" com 3–6 linhas específicas (ex: "Nunca
  prometer horário sem confirmar com a agenda", "Clientes são chamados pelo primeiro nome").

Não inventar nada. Onde faltar, deixar `[a confirmar]`.

## 4. Apresentar o que vem depois (sem emendar)

A configuração inicial termina aqui. **Não** começar outra configuração nesta conversa. Apresentar
em poucas linhas o que o FlowOS faz e como começar cada coisa — cada uma na sua própria conversa:

> "Agora você pode usar o FlowOS pra:
> • **Trazer clientes de volta** — eu te aviso todo dia quem sumiu, quem faz aniversário e as datas
>   especiais, e já deixo a mensagem pronta. Pra configurar, abra uma conversa nova e diga
>   **"quero configurar o retorno de clientes"** — lá eu te explico como funciona e a gente monta junto.
> • **Criar teu site** — diga **"quero um site"**.
> • **Qualquer outra coisa do dia a dia** — é só pedir do teu jeito."

## 5. Fechamento

```
✓ Negócio: memoria/empresa.md
✓ Jeito de escrever: memoria/preferencias.md
✓ Foco: memoria/estrategia.md
✓ Marca: marca/guia-de-marca.md
```

Mostrar o resumo acima antes da apresentação do passo 4.

Registrar no diário (`memoria/diario/AAAA-MM.md`): `- DD/MM: FlowOS configurado`.
