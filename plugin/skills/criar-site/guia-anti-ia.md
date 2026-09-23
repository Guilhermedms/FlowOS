# Guia anti-cara-de-IA

Site de IA é reconhecível em 2 segundos porque repete as mesmas escolhas "seguras". Cada item
abaixo é uma decisão que precisa ser tomada de propósito.

## ❌ Sinais de IA — não fazer

**Visual**
- Degradê roxo/azul/rosa no fundo ou no texto. Glow neon. Glassmorphism sem motivo.
- Tudo centralizado, seção após seção, com o mesmo espaçamento.
- Grid de 3 cards iguais com ícone/emoji em cima, título e 2 linhas de texto.
- Inter, Poppins, Montserrat ou Roboto como única fonte, tudo em peso 400/600.
- Cantos arredondados de 16–24px em tudo, sombras difusas cinza em tudo.
- Ícones genéricos (foguete, raio, escudo, check verde) decorando títulos.
- Ilustração 3D genérica ou foto de banco (gente sorrindo pro laptop).
- Botão com degradê e seta →. Badge "✨ Novo" acima do título.

**Texto**
- "Transforme seu negócio", "Leve sua X ao próximo nível", "Soluções inovadoras",
  "Desbloqueie", "Potencialize", "Descubra o poder de", "Seja bem-vindo".
- Títulos em três palavras com ponto. Rápido. Simples. Eficiente.
- Listas de benefícios abstratos sem número, nome ou exemplo concreto.
- Emoji no meio de título.

**Movimento**
- Todos os elementos aparecendo com o mesmo fade-up, do mesmo jeito, na mesma velocidade.
- Animação em tudo. Hover que só aumenta escala 1.05.

## ✅ O que dá cara de estúdio

**Tipografia com personalidade**
- Um par com contraste: serifada expressiva + sans neutra, ou grotesca condensada + serifada.
  Exemplos do Google Fonts: Fraunces, Instrument Serif, DM Serif Display, Playfair Display,
  Cormorant, Bricolage Grotesque, Space Grotesk, Syne, Archivo (Expanded/Condensed),
  Familjen Grotesk, Manrope, Figtree. Escolher pelo conceito, não pela moda.
- **Escala dramática**: título do hero grande de verdade (`clamp(3rem, 9vw, 8.5rem)`),
  entrelinha apertada (0.9–1.05), `letter-spacing` negativo em títulos grandes.
- Contraste de peso e tamanho entre título, apoio e corpo. Textos pequenos em caixa-alta com
  espaçamento (rótulos de seção: `01 — Serviços`).

**Layout editorial**
- Grid assimétrico: título ocupando 7 colunas e texto em 4, deslocado. Alinhamento à esquerda
  como padrão; centralizar só com intenção.
- Variar o ritmo: uma seção cheia de respiro, a seguinte densa; uma imagem sangrando até a
  borda, a próxima contida.
- Números e dados reais em destaque ("+1.200 cortes/mês", "desde 2009").
- Linhas finas (1px) e numeração como estrutura, no lugar de cards com sombra.

**Cor**
- Paleta curta: fundo que não é branco puro (off-white, creme, quase-preto), texto que não é
  preto puro, um único destaque usado com parcimônia.
- Tirar as cores das fotos reais do negócio ou das referências.

**Imagem**
- Foto real do negócio, da equipe, do trabalho. Recortes (PNG sem fundo) em camadas pra parallax.
- Tratar as fotos com consistência (mesmo tom, mesmo contraste).
- Imagens grandes. Uma foto forte vale mais que 6 pequenas.

**Texto**
- Específico e concreto: nomes, números, lugares, o que exatamente acontece.
- Na voz do dono (ver `memoria/preferencias.md`). Frases que só esse negócio poderia dizer.

**Movimento com hierarquia** (ver `padroes-gsap.md`)
- 1 efeito protagonista (ex: hero em camadas com parallax + título entrando por linhas).
- 1–2 efeitos de apoio (reveal de imagem com máscara, texto por linhas nas seções).
- Easing expressivo (`expo.out`, `power4.out`), durações 0.9–1.4s, `stagger` curto.
- Rolagem suave com ScrollSmoother. Sempre respeitar `prefers-reduced-motion`.

## Checklist antes de mostrar ao dono

Olhando os prints de desktop e celular:

- [ ] Se eu tirasse o logo, dava pra saber de que negócio é? (foto real, texto específico)
- [ ] A fonte do título é uma escolha, não a padrão?
- [ ] Existe pelo menos uma quebra de simetria no layout?
- [ ] Nenhum degradê roxo, emoji decorativo, card-com-ícone em grade de 3?
- [ ] Nenhuma frase da lista proibida?
- [ ] O título do hero tem tamanho de impacto também no celular?
- [ ] O botão principal leva ao objetivo real e aparece sem rolar?
- [ ] No celular nada vaza pra fora da tela (sem rolagem horizontal)?
- [ ] Contraste de texto legível (texto claro em foto tem sombra/escurecimento)?
- [ ] Os efeitos seguem o que o dono escolheu no catálogo, no máximo 3 tipos?
