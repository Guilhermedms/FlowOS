---
name: organizar-memoria
description: >
  Faxina da memória do negócio: mantém o núcleo curto, move detalhes pra notas de conhecimento,
  junta duplicadas, remove o que ficou desatualizado e refaz o índice. Use quando o usuário pedir
  "organiza a memória", "/flowos:organizar-memoria", ou quando o núcleo passar de uma página ou
  houver mais de 30 notas.
---

# /flowos:organizar-memoria

Objetivo: o sistema continuar rápido e certeiro com o passar dos meses. Nada é apagado sem o dono ver.

1. **Levantar:** ler `memoria/empresa.md`, `preferencias.md`, `estrategia.md`, `INDICE.md`, a
   lista de `memoria/conhecimento/` e `memoria/clientes/`, e os 2 últimos meses de `memoria/diario/`.
2. **Diagnosticar** e mostrar uma lista curta de propostas:
   - Núcleo com detalhe demais → mover pra nota de conhecimento (ex: tabela de preços →
     `conhecimento/servicos-e-precos.md`), deixando no núcleo só o resumo.
   - Notas sobre o mesmo assunto → juntar.
   - Informação contraditória (dois preços pro mesmo serviço) → perguntar qual vale.
   - Informação velha (promoção vencida, funcionário que saiu, prioridade concluída) → arquivar
     no fim da nota em "## Histórico" ou remover, conforme o dono preferir.
   - Decisões importantes que só estão no diário → promover pra nota ou pro núcleo.
   - Notas que não estão no índice → incluir.
3. **Aplicar** o que o dono aprovar. Manter cada arquivo do núcleo com até ~1 página.
4. **Refazer `INDICE.md`**: uma linha por nota, `- [título](caminho) — do que trata`, em ordem
   de assunto.
5. Registrar no diário: `- DD/MM: memória organizada (N notas, núcleo enxugado)`.
