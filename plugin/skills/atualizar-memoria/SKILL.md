---
name: atualizar-memoria
description: >
  Atualiza a memória do negócio com o que mudou: levanta o que aconteceu na conversa e nos
  arquivos (preço novo, serviço, cliente importante, site publicado, estratégia, equipe,
  ferramenta), mostra a proposta e só salva depois da aprovação. Use quando o usuário disser
  "atualiza a memória", "guarda isso", "/flowos:atualizar-memoria", quando aceitar a oferta de
  atualizar a memória, ou no fim de um dia de trabalho.
---

# /flowos:atualizar-memoria

A memória só serve se estiver certa. Aqui você transforma o que mudou em linhas claras no lugar
certo — sem reescrever arquivos inteiros e sem salvar nada que o dono não viu.

## 1. Levantar o que mudou

Olhar, nesta ordem:
- **A conversa desta sessão:** o que o dono disse que é novo ou diferente ("agora abrimos sábado",
  "a escova passou pra R$ 60", "contratei a Júlia", "não faço mais luzes").
- **O que foi feito:** arquivos criados/alterados nesta sessão (sites, clientes, estratégia de
  retorno, conteúdo, skills novas em `.claude/skills/`).
- **O diário do mês** (`memoria/diario/AAAA-MM.md`): linhas de hoje que ainda não viraram memória.

Se o dono pedir uma **revisão completa** ("revisa tudo"), comparar também a memória com a pasta:
site publicado que não consta, estratégia de retorno ativa que não aparece em `estrategia.md`,
número de clientes da base, skills próprias criadas.

## 2. Separar o que é duradouro

Entra na memória: fatos que vão continuar valendo (preços, serviços, horários, equipe, políticas,
preferências de tom, decisões, metas, clientes com história, ferramentas, site no ar).
**Não** entra: tarefas pontuais, rascunhos, conversas sem decisão, dados já na base de clientes.

## 3. Propor (curto)

Mostrar uma lista por destino, com antes → depois quando for correção:

```
Vou atualizar a memória:

📄 conhecimento/servicos-e-precos.md
   • Escova: R$ 50 → R$ 60
📄 empresa.md
   • Horário: + sábado 9h–14h
📄 estrategia.md
   • Site no ar: barbeariadoze.netlify.app (23/09)

Posso salvar?
```

Destinos:

| O que mudou | Onde |
|---|---|
| Resumo do negócio, horário, endereço, equipe, canais | `memoria/empresa.md` |
| Detalhe de um assunto (preços, FAQ, processo, fornecedor, política) | `memoria/conhecimento/<assunto>.md` (+ linha no `INDICE.md` se for nota nova) |
| Tom, estilo, o que evitar | `memoria/preferencias.md` |
| Metas, prioridades, decisões, projetos em andamento | `memoria/estrategia.md` |
| Cliente com história (VIP, preferência, problema) | `memoria/clientes/<nome>.md` (+ índice) |
| Cores, fontes, logo, gosto visual | `marca/guia-de-marca.md` |
| Regra de comportamento só deste negócio | `CLAUDE.md` → "Regras deste negócio" |

## 4. Salvar (depois do "pode")

- Editar só as linhas envolvidas. Não reformatar o arquivo.
- Correção substitui o valor antigo (não deixar dois preços). Se o antigo tiver valor histórico,
  mover pra `## Histórico` no fim da nota com a data.
- Núcleo passando de ~1 página → mover detalhe pra uma nota de conhecimento.
- Registrar no diário: `- DD/MM: memória atualizada (escova R$ 60, sábado aberto)`.
- Confirmar em uma linha: "Memória atualizada ✔ — 3 mudanças."

Se não houver nada novo: "Tá tudo em dia na memória. ✔"
