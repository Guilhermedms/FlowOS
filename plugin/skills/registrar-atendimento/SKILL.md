---
name: registrar-atendimento
description: >
  Atualiza a última visita e o último serviço de clientes na base quando o usuário conta um
  atendimento ("a Maria veio hoje fazer escova", "atendi o João e o Pedro ontem"), cadastrando
  o cliente se for novo. Use também para "cliente novo", "anota que…", "/flowos:registrar-atendimento".
---

# /flowos:registrar-atendimento

Rápido e silencioso: o dono fala do jeito dele, você atualiza `clientes/clientes.csv`.

1. Extrair da fala: nome(s), data (hoje/ontem/"sexta" → converter pra `dd/mm/aaaa`),
   serviço, e qualquer dado novo (telefone, aniversário, "é pai", "é VIP").
2. Achar o cliente na base (por nome, sem acento/maiúscula). Se houver mais de um com nome
   parecido, perguntar qual. Se não houver, perguntar: "A Maria é nova? Me passa o WhatsApp
   dela que eu cadastro."
3. Atualizar `ultima_visita` (só se a data informada for mais recente que a atual),
   `ultimo_servico`, e demais campos. Tags novas são somadas, não substituem.
4. Responder em uma linha: "Anotado: Maria — escova, 23/09." Sem mostrar a planilha.

Se o dono disser que um cliente pediu pra não receber mais mensagens: `nao_contatar` = `sim`
e confirmar.
