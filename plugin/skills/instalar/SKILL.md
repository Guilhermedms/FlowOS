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

1. "O que você vende, em uma frase, do jeito que falaria pra um vizinho?"
2. "Quem é teu cliente típico? Pensa num cliente real que você gosta de atender."
3. "Você toca sozinho ou tem equipe? Quem faz o quê?"
4. "Me cola uma mensagem real que você mandou pra cliente (WhatsApp, legenda, e-mail). É pra eu
   aprender teu jeito de escrever."
5. "Tem alguma forma de escrever que te irrita? (ex: 'caro cliente', muito emoji, gíria)"
6. "O que mais te toma tempo toda semana?"
7. "Qual o maior objetivo pros próximos 3 meses?"
8. "Tem logo e cores definidas? Se tiver, joga o logo em `marca/`."

Resposta vaga: pedir exemplo uma vez. Depois registrar o que veio e seguir.

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
