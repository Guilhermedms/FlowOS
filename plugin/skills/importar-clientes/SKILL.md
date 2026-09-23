---
name: importar-clientes
description: >
  Monta ou completa a base de clientes (clientes/clientes.csv) a partir do que o usuário tiver:
  planilha, exportação de sistema de agenda, lista de contatos, PDF, foto de caderno ou lista
  digitada. Use quando o usuário disser "/flowos:importar-clientes", "tenho uma planilha de clientes",
  "cadastrar clientes", ou quando a base estiver vazia.
---

# /flowos:importar-clientes — Base de clientes

A base é o combustível do retorno. Sem `ultima_visita`, ninguém é chamado por sumiço; sem
`aniversario`, ninguém recebe parabéns. O trabalho aqui é tirar o máximo do que o dono já tem.

## 1. De onde vêm os dados?

> "Onde você anota seus clientes hoje? Pode me mandar do jeito que estiver — planilha, export
> do sistema de agenda, foto do caderno, lista de contatos. Joga o arquivo na pasta `dados/`."

Aceitar qualquer coisa: `.xlsx`, `.csv`, `.pdf`, `.vcf` (contatos), imagem, texto colado.
Pra `.xlsx`, converter com PowerShell + Excel se instalado; se não, pedir pro usuário
"Salvar como → CSV" no Excel.

## 2. Mapear colunas

Mostrar como vai ler: "Na tua planilha, 'Cliente' vira nome, 'Cel' vira telefone, 'Últ. atend.'
vira última visita. Certo?" Formato final (separador `;`):

`nome;telefone;email;aniversario;ultima_visita;ultimo_servico;tags;canal;nao_contatar;observacoes`

- `telefone`: com DDD, só números ou formatado — o motor normaliza.
- `aniversario`: `dd/mm` ou `dd/mm/aaaa`.
- `ultima_visita`: `dd/mm/aaaa`. Se a origem tem várias visitas por cliente (histórico de
  agenda), pegar a **mais recente** e o serviço dela.
- `tags`: grupos separados por vírgula (`pai`, `mae`, `vip`, `mensal`…).
- `canal`: vazio (usa o padrão), `whatsapp` ou `email`.

## 3. Limpar

- Juntar duplicados (mesmo telefone ou e-mail) mantendo a visita mais recente.
- Listar problemas numa tabela curta: sem telefone e sem e-mail, telefone sem DDD, data
  inválida. Perguntar se corrige agora ou deixa assim.
- Não inventar dado que não está na origem.

## 4. Gravar

- Se a base já tem clientes, **mesclar** (atualizar os existentes pela chave telefone/e-mail,
  adicionar os novos) — nunca sobrescrever sem mostrar o que muda.
- Gravar em UTF-8 com BOM (abre certo no Excel).
- Resumir: "142 clientes importados · 118 com WhatsApp · 60 com aniversário · 97 com última visita".
- Rodar `flowos-retorno verificar` do motor e dizer quantos entrariam na lista hoje.

## Dica pro dono

Se faltam aniversários ou datas de visita, sugerir o hábito: "Quando atender alguém, me fala
'a Maria veio hoje, fez escova' que eu atualizo a base sozinho."
