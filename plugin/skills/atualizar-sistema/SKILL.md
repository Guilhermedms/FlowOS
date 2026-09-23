---
name: atualizar-sistema
description: >
  Busca e instala a versão mais nova do FlowOS agora, sem esperar a atualização automática. Use
  quando o usuário disser "atualiza o FlowOS", "tem versão nova?", "/flowos:atualizar-sistema", ou quando
  quem instalou avisar que saiu uma atualização.
---

# /flowos:atualizar-sistema

1. Rodar, nesta ordem:
   - `claude plugin marketplace update flowos`
   - `claude plugin update flowos@flowos`
   Se `claude` não for encontrado, tentar `"$HOME/.local/bin/claude"` (ou
   `%USERPROFILE%\.local\bin\claude.exe`).
2. Se atualizou, dizer em uma linha que a versão nova entra ao **fechar e abrir de novo** o
   Claude (ou rodar `/reload-plugins`). Na próxima abertura o sistema conta o que mudou.
3. Se já estava na última versão: "Você já está com a versão mais nova. ✔"
4. Se deu erro de conexão ou permissão: explicar em linguagem simples e sugerir falar com quem
   instalou o FlowOS. Não tentar consertar configurações do Claude Code por conta própria.

Nunca mexer nos arquivos da pasta do negócio durante a atualização.
