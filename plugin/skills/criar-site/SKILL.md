---
name: criar-site
description: >
  Cria landing page ou site do negócio com cara de estúdio, não de IA: coleta prints de
  referência por parte do site (hero, menu, seções, botões, tipografia, animações), analisa,
  propõe a direção visual, constrói em HTML/CSS/GSAP (ScrollSmoother, parallax em camadas,
  SplitText no hero), confere com print de tela e publica. Use quando o usuário pedir "site",
  "landing page", "página de vendas", "página do meu negócio", "/flowos:criar-site", ou quiser editar um
  site existente em sites/.
---

# /flowos:criar-site — Site sem cara de IA

O que denuncia site feito por IA não é a tecnologia, é a **falta de decisão**: layout centralizado
genérico, degradê roxo, cards com emoji, fonte padrão, textos vazios. O antídoto é o que esta
skill faz: **referências reais escolhidas pelo dono + decisões explícitas + conferência visual**.

Arquivos de apoio (ler antes de construir):
- `guia-anti-ia.md` — o que evitar e o que fazer, com critérios objetivos
- `padroes-gsap.md` — código dos efeitos (ScrollSmoother, parallax em camadas, SplitText, reveals)
- `catalogo-efeitos.md` — cardápio de efeitos com nome, pra mostrar ao dono
- `base.html` — esqueleto inicial

Cada projeto mora em `sites/<nome-do-projeto>/`:
```
sites/<projeto>/
├── referencias/        prints que o dono mandou (hero-1.png, secao-servicos-1.png…)
├── imagens/            fotos e camadas do site
├── briefing.md         objetivo, conteúdo e análise das referências
├── direcao.md          decisões visuais aprovadas
├── index.html
└── prints/             capturas de conferência (desktop e celular)
```

---

## Fase 1 — Briefing (curto)

Ler `memoria/empresa.md`, `memoria/preferencias.md` e `marca/guia-de-marca.md`. Depois perguntar,
uma por vez, só o que não estiver na memória:

1. "Qual o objetivo da página? O que a pessoa tem que fazer ao final?" (chamar no WhatsApp,
   agendar, comprar, pedir orçamento)
2. "Pra quem é? Quem é a pessoa que vai abrir esse link?"
3. "Quais seções você imagina?" — se não souber, sugerir a partir do objetivo
   (ex: hero → prova social → serviços → como funciona → depoimentos → FAQ → chamada final).
4. "Você tem fotos reais? (do espaço, da equipe, do trabalho)" — foto real é o maior
   diferencial contra cara de IA. Pedir pra colocar em `sites/<projeto>/imagens/`.

## Fase 2 — Referências por parte do site ⭐

Explicar o porquê e pedir as referências **separadas por parte**. Mensagem modelo:

> "Agora a parte mais importante: me mostra o que você acha bonito. Não precisa ser do teu
> ramo — vale qualquer site, app ou até post que te chamou atenção. Tira print (Windows +
> Shift + S) e cola aqui ou salva em `sites/<projeto>/referencias/`. Uma coisa por vez:
>
> 1. **Hero** — a primeira tela, o que aparece antes de rolar
> 2. **Menu** — o topo com os links
> 3. **Seções** — um print pra cada tipo que você quer (serviços, sobre, depoimentos,
>    galeria, preços, FAQ, contato)
> 4. **Botões** — formato, cor, o que acontece ao passar o mouse
> 5. **Letras** — uma tipografia que você goste
> 6. **Movimento** — se viu algum efeito legal, me manda o link do site e fala o que te
>    chamou atenção ('o título sobe', 'as imagens andam em velocidades diferentes')
>
> Se não souber onde procurar: godly.website, land-book.com, lapa.ninja, awwwards.com,
> onepagelove.com, ou o Pinterest com 'landing page + <teu ramo>'."

Regras dessa fase:
- Aceitar uma parte de cada vez. Pra cada print recebido, **ler a imagem** e devolver em 2–3
  linhas o que você enxergou ("Hero com foto ocupando a tela toda, título enorme alinhado à
  esquerda embaixo, menu transparente por cima"). Isso mostra que você entendeu e calibra.
- Salvar os prints com nome da parte: `referencias/hero-1.png`, `referencias/botoes-1.png`,
  `referencias/secao-depoimentos-1.png`.
- Pra **movimento**, como print não mostra animação, mostrar o `catalogo-efeitos.md` e pedir pra
  ele apontar pelo nome ou número.
- Se o dono não tiver referência de alguma parte, tudo bem — você decide seguindo o guia
  anti-IA e a coerência com as outras referências.
- Não copiar um site inteiro. Pegar **princípios** de cada referência (proporção, espaçamento,
  hierarquia, ritmo), nunca textos, imagens ou marca de terceiros.

Registrar em `briefing.md`, por parte: referência → o que pegar dela (layout, escala do título,
espaçamento, cor, raio de borda, peso da fonte, efeito).

## Fase 3 — Direção visual (aprovar antes de codar)

Escrever `direcao.md` e mostrar resumido pro dono:
- **Conceito em uma frase** ("editorial e quente, como revista de barbearia antiga")
- **Tipografia:** par de fontes do Google Fonts com o porquê (ver guia — nada de Inter/Poppins/
  Montserrat por padrão)
- **Cores:** as da marca; se não houver, 1 cor de fundo + 1 de texto + 1 de destaque, tiradas das
  referências ou das fotos
- **Grid e ritmo:** alinhamento, largura máxima, espaçamento entre seções
- **Movimento:** quais efeitos entram e onde (máximo 3 tipos na página inteira)
- **Seções** na ordem, com o título provisório de cada uma

> "Essa é a direção. Posso construir assim ou quer mudar algo?"

## Fase 4 — Construir

- Partir do `base.html`. Um único `index.html` com CSS e JS embutidos, GSAP via CDN.
- Seguir `padroes-gsap.md` à risca (estrutura do ScrollSmoother, `prefers-reduced-motion`,
  carregamento de fontes antes do SplitText).
- **Texto de verdade:** escrever a copy com base na memória do negócio e no tom de
  `preferencias.md`. Nada de lorem ipsum, nada de "Transforme seu negócio". Onde faltar
  informação real (preço, depoimento), deixar marcado `[CONFIRMAR: …]` e listar no fim.
- Imagens: só as do dono. Se faltar, usar um bloco de cor da paleta com proporção certa e
  anotar "foto aqui" — nunca banco de imagem genérico sem ele pedir.
- Botão principal leva ao objetivo real (link `https://wa.me/55…?text=` com mensagem pronta,
  agenda, formulário).
- Responsivo de verdade: pensar o celular primeiro (é de onde vem a maioria dos acessos).

## Fase 5 — Conferir (obrigatório)

Tirar print com o Edge (já vem no Windows), desktop e celular:

```
& "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --headless=new --disable-gpu --hide-scrollbars --virtual-time-budget=5000 --window-size=1440,900 --screenshot="<pasta>\prints\desktop.png" "file:///<caminho absoluto>/index.html?print"
& "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --headless=new --disable-gpu --hide-scrollbars --virtual-time-budget=5000 --window-size=390,844 --screenshot="<pasta>\prints\celular.png" "file:///<caminho absoluto>/index.html?print"
```

- O `?print` é obrigatório: o modo headless desenha poucos quadros e, sem ele, as animações
  aparecem paradas no início (título invisível). O `base.html` já trata esse parâmetro — se o
  site não partiu do base, incluir `if (new URLSearchParams(location.search).has("print")) gsap.ticker.lagSmoothing(0);`.
- Textos das seções só animam ao entrar na tela; no print de página inteira
  (`--window-size=1440,4000`) eles podem aparecer escondidos — isso não é bug. Pra conferir
  layout das seções, gerar o print com `?print&estatico` e tratar `estatico` desligando os efeitos
  (não criar o ScrollSmoother nem os SplitText).

Olhar os prints e passar no **checklist do `guia-anti-ia.md`**. Corrigir o que falhar antes de
mostrar. Depois abrir no navegador pro dono (`Start-Process index.html`) e dizer:
> "Abri no teu navegador. Rola devagar pra ver os efeitos. O que você mudaria?"

## Fase 6 — Ajustes

Ajustes pedidos em linguagem leiga ("mais respiro", "título mais forte", "tá muito escuro")
viram mudanças concretas. Traduzir e confirmar numa linha o que mudou. Se o dono aprovar algo
que vale pra sempre ("gosto de botão arredondado"), oferecer salvar em `marca/guia-de-marca.md`.

## Fase 7 — Publicar

Opção mais simples, grátis e sem instalar nada: **Netlify Drop**.
> "Abre app.netlify.com/drop, cria uma conta grátis e arrasta a pasta `sites/<projeto>` pra
> dentro. Em segundos ele te dá um link. Pra usar teu domínio (www.teunegocio.com.br), me chama
> que eu te guio."

Antes de publicar: conferir `<title>`, descrição, favicon, imagem de compartilhamento
(`og:image`), link do WhatsApp com número certo, e que nenhum `[CONFIRMAR]` sobrou.
