---
name: estrategia-retorno
description: >
  Conversa guiada pra montar (ou ajustar) a estratégia de retorno de clientes: quando chamar quem
  sumiu (30/60/90 dias), aniversário do cliente, aniversário da empresa, datas comemorativas
  (Dia das Mães, Dia dos Pais, Dia do Cliente, Black Friday…), ofertas, limites e modelos de
  mensagem. Grava em sistema/retorno.json. Use quando o usuário disser "/flowos:estrategia-retorno",
  "follow-up", "trazer cliente de volta", "mudar o desconto", "adicionar Dia das Mães" etc.
---

# /flowos:estrategia-retorno — Estratégia de retorno de clientes

O dono decide a estratégia; você **sugere com base no negócio dele** e ele ajusta. Uma pergunta
por vez, sempre com uma sugestão pronta pra ele só dizer "pode ser". Nada de formulário.

Antes de começar, ler `memoria/empresa.md` e `memoria/preferencias.md`. Se `sistema/retorno.json`
já existir com regras, perguntar: "Quer revisar tudo ou mudar só uma parte?" e ir direto ao ponto.

Referência de formato: `exemplo.json (nesta pasta da skill)`.

## Passo 1 — Ciclo do cliente

Se `memoria/empresa.md` já registra de quanto em quanto tempo o cliente volta (a configuração inicial
pergunta), usar isso como sugestão e só confirmar: "Você me disse que o cliente volta a cada 3 semanas.
Uso isso como base?". Se não houver, perguntar dizendo o porquê:

> "Pra eu saber quando um cliente está sumido: de quanto em quanto tempo um cliente fiel costuma voltar?"

Se ele não souber, sugerir pelo tipo de negócio (e dizer que é um chute pra calibrar depois):

| Negócio | Ciclo típico |
|---|---|
| Barbearia | 20–30 dias |
| Salão (escova/unha) | 15–30 dias |
| Estética (limpeza de pele) | 30–45 dias |
| Pet shop (banho) | 15–30 dias |
| Dentista / check-up | 180 dias |
| Oficina (revisão) | 180 dias |
| Restaurante / delivery | 15–30 dias |
| Loja de roupa | 60–90 dias |

Se o ciclo muda muito por serviço ("quem faz luzes volta em 90 dias, quem faz escova em 15"),
criar regras separadas com o campo `servico`.

## Passo 2 — Faixas de "cliente sumido"

Propor 3 faixas a partir do ciclo (C), com escalada de oferta — e explicar a lógica:

1. **1× C — lembrete leve**, sem desconto ("tá na hora de…"). A maioria volta só com isso.
2. **2× C — "sentimos sua falta"** + benefício pequeno.
3. **3× C — última tentativa** com oferta mais forte. Depois disso o sistema **para de insistir**
   até o cliente voltar.

Perguntar qual oferta ele topa dar em cada faixa e o **desconto máximo** que aceita.
Lembrar: brinde ou serviço extra muitas vezes funciona melhor que desconto e custa menos.

## Passo 3 — Datas especiais

Mostrar a lista com as datas do ano (rodar `flowos-retorno datas`)
e perguntar quais fazem sentido pro negócio. Sugerir as que combinam com ele:

- 🎂 **Aniversário do cliente** — a mais forte de todas. Precisa da data na base de clientes;
  se não tiver, sugerir começar a pedir no atendimento.
- 🏢 **Aniversário da empresa** — perguntar a data de fundação.
- Ano Novo, Carnaval, Dia da Mulher (8/3), Dia do Consumidor (15/3), Páscoa, Dia das Mães
  (2º domingo de maio), Dia dos Namorados (12/6), Dia dos Pais (2º domingo de agosto),
  Dia do Cliente (15/9), Dia das Crianças (12/10), Black Friday, Natal.
- Datas próprias do negócio: aceitar qualquer `dd/MM` ("semana do cabelo", aniversário da cidade).

Pra cada data escolhida, perguntar:
- **Pra quem?** Todo mundo ou um grupo (Dia dos Pais → só quem é pai; Dia das Mães → mães ou
  quem compra presente). Grupos usam a coluna `tags` da base (ex: `pai`, `mae`, `vip`).
  Se a base não tem essas tags, avisar e oferecer ajudar a marcar.
- **Com quantos dias de antecedência?** Sugerir 3–7 dias pra datas comerciais, 0 pra aniversário.
- **Qual a oferta?**

## Passo 4 — Limites

Sugerir e confirmar:
- **Intervalo mínimo** entre duas mensagens pro mesmo cliente: 15 dias (aniversário fura a fila).
- **Limite por dia:** 30 (WhatsApp assistido fica confortável até aí).

## Passo 5 — Mensagens

Escrever o modelo de cada regra **no tom de `memoria/preferencias.md`**, curto (WhatsApp: até
3 linhas), com uma chamada clara pra ação. Variáveis disponíveis:
`{primeiro_nome}`, `{nome}`, `{ultimo_servico}`, `{dias}`, `{empresa}`, `{data}`, `{evento}`.

Cuidado com `{ultimo_servico}` no meio da frase — o texto tem que funcionar com qualquer serviço
da base ("seu último atendimento ({ultimo_servico})" é mais seguro que "no próximo {ultimo_servico}").
Pra e-mail, escrever também o `assunto`.

Mostrar todas juntas e pedir aprovação. Ajustar até ele gostar.

## Passo 6 — Canal

> "Como você quer mandar: WhatsApp, e-mail ou os dois?"

- **WhatsApp (recomendado pra maioria):** modo assistido — o sistema prepara, ele clica e envia.
  Grátis e sem risco de bloqueio do número.
- **E-mail (Gmail):** 100% automático e grátis. Precisa configurar uma vez.
- **Os dois:** perguntar a preferência (`whatsapp`, `email` ou `ambos` pra mandar nos dois).

Se escolheu e-mail e ainda não configurou, emendar com `/flowos:configurar-envio`.

## Passo 7 — Gravar e testar

1. Gravar `sistema/retorno.json` no formato do exemplo, com `"ativo": true`, `empresa.nome` e
   `empresa.aniversario` preenchidos. IDs das regras em minúsculas-com-hífen, estáveis
   (não renomear depois — o histórico usa o id).
2. Resumir a estratégia em linguagem simples numa tabela (quando → pra quem → oferta).
3. Rodar `flowos-retorno verificar` e mostrar quantos clientes entrariam hoje. Se ninguém, explicar por quê
   (ex: base sem datas de última visita).
4. Oferecer mandar uma mensagem de teste pro próprio dono.
5. Registrar em `memoria/estrategia.md` uma linha: "Estratégia de retorno ativa desde dd/mm/aaaa".

## Regras

- Não inventar desconto: se ele não definiu oferta, a mensagem vai sem oferta.
- Oferta sempre com prazo ("até o fim do mês") — sem prazo ninguém age.
- Não criar mais de 3 faixas de sumido. Mais que isso vira spam.
- Mensagens de e-mail já saem com rodapé de descadastro (LGPD). No WhatsApp, se o cliente pedir
  pra parar, marcar `nao_contatar` = `sim`.
