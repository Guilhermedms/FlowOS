# Padrões GSAP

GSAP 3.13+ é 100% gratuito, incluindo ScrollSmoother e SplitText (antes eram pagos). Carregar
pela CDN, nesta ordem, antes do `</body>`:

```html
<script src="https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/gsap.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/ScrollTrigger.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/ScrollSmoother.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/SplitText.min.js"></script>
```

## Regras que evitam 90% dos bugs

1. **Estrutura do ScrollSmoother:** todo o conteúdo que rola fica dentro de
   `#smooth-wrapper > #smooth-content`. Elementos `position: fixed` (menu, botão flutuante de
   WhatsApp) ficam **fora** do wrapper, senão eles rolam junto.
2. **Tudo dentro de `gsap.matchMedia()`** com `(prefers-reduced-motion: no-preference)`. Quem
   pediu menos movimento no sistema recebe a página estática e legível.
3. **SplitText só depois das fontes:** `document.fonts.ready.then(...)` e `autoSplit: true`
   (refaz a quebra quando a largura muda). Senão as linhas quebram errado.
4. **Esconder antes de animar** pra não piscar: o CSS esconde (`visibility: hidden`) só quando há
   JS e movimento permitido; a animação revela com `autoAlpha`.
5. **Links de âncora** (`#servicos`) precisam passar pelo `smoother.scrollTo()`.
6. `data-speed` / `data-lag` só funcionam com `effects: true`.

## Base

```js
gsap.registerPlugin(ScrollTrigger, ScrollSmoother, SplitText);
const mm = gsap.matchMedia();

mm.add("(prefers-reduced-motion: no-preference)", () => {
  const smoother = ScrollSmoother.create({
    wrapper: "#smooth-wrapper",
    content: "#smooth-content",
    smooth: 1.2,        // segundos pra "alcançar" a rolagem — 1 a 1.5 fica elegante
    effects: true,      // liga data-speed e data-lag
    smoothTouch: 0.1,   // leve no celular
  });

  document.querySelectorAll('a[href^="#"]').forEach((a) => {
    a.addEventListener("click", (e) => {
      const alvo = a.getAttribute("href");
      if (alvo.length > 1 && document.querySelector(alvo)) {
        e.preventDefault();
        smoother.scrollTo(alvo, true, "top 80px");
      }
    });
  });

  // ...efeitos abaixo aqui dentro
});
```

## 2 · Hero em camadas (parallax)

Várias imagens empilhadas, todas `position: absolute` dentro do mesmo container. A camada da
**frente** anda na velocidade normal; as de **trás** andam mais devagar — isso cria a
profundidade. Ex. com 4 imagens: `img01` na frente, `img04` no fundo.

```html
<section class="hero">
  <div class="camadas" aria-hidden="true">
    <img class="camada" src="imagens/img04.png" alt="" data-speed="clamp(0.5)"  style="z-index:1">
    <img class="camada" src="imagens/img03.png" alt="" data-speed="clamp(0.65)" style="z-index:2">
    <img class="camada" src="imagens/img02.png" alt="" data-speed="clamp(0.8)"  style="z-index:3">
    <h1 class="hero-titulo" data-speed="clamp(0.72)" style="z-index:3">Título<br>em duas linhas</h1>
    <img class="camada" src="imagens/img01.png" alt="" data-speed="clamp(1)"   style="z-index:4">
  </div>
</section>
```

```css
.hero { position: relative; height: 100svh; min-height: 560px; overflow: hidden; }
.camadas { position: absolute; inset: 0; }
.camada { position: absolute; left: 0; top: 0; width: 100%; height: 115%;
          object-fit: cover; object-position: center bottom; pointer-events: none; }
```

- `clamp()` faz a camada começar na posição natural (sem pular) mesmo estando no topo da página.
- Colocar o título **entre** camadas (atrás da pessoa, na frente do cenário) é o que dá o
  efeito "revista". Ajustar o `z-index`.
- As camadas da frente precisam ser **PNG sem fundo** (recorte). O fundo pode ser JPG.
- Menos de 0.4 de speed costuma exagerar. Diferença de 0.15 entre camadas já dá profundidade.
- Pra recortar a foto do cliente: remove.bg ou o recurso "remover fundo" do Windows (Fotos /
  Paint) — orientar o dono se ele não souber.

## 3 · Título entrando por linhas (máscara)

```css
@media (prefers-reduced-motion: no-preference) { .js [data-split] { visibility: hidden; } }
```

```js
document.fonts.ready.then(() => {
  SplitText.create(".hero-titulo", {
    type: "lines",
    mask: "lines",          // cada linha ganha uma "janela" — o texto sobe por trás dela
    autoSplit: true,
    onSplit(self) {
      gsap.set(self.elements, { autoAlpha: 1 });
      return gsap.from(self.lines, {
        yPercent: 110, duration: 1.25, ease: "expo.out", stagger: 0.1, delay: 0.15,
      });
    },
  });
});
```

## 4 · Letras em cascata

```js
SplitText.create(".destaque", {
  type: "chars", autoSplit: true,
  onSplit(self) {
    gsap.set(self.elements, { autoAlpha: 1 });
    return gsap.from(self.chars, { yPercent: 60, autoAlpha: 0, duration: 0.7,
      ease: "power3.out", stagger: 0.025 });
  },
});
```

## 7 · Texto por linhas nas seções (ao entrar na tela)

```js
document.fonts.ready.then(() => {
  gsap.utils.toArray("[data-split='linhas']").forEach((el) => {
    SplitText.create(el, {
      type: "lines", mask: "lines", autoSplit: true,
      onSplit(self) {
        gsap.set(el, { autoAlpha: 1 });
        return gsap.from(self.lines, {
          yPercent: 105, duration: 1.1, ease: "power4.out", stagger: 0.08,
          scrollTrigger: { trigger: el, start: "top 85%" },
        });
      },
    });
  });
});
```

## 5 · Imagem se revelando (cortina)

```html
<figure class="revela"><img src="imagens/servico.jpg" alt="Descrição real"></figure>
```
```css
.revela { overflow: hidden; }
.revela img { width: 100%; height: 100%; object-fit: cover; display: block; }
```
```js
gsap.utils.toArray(".revela").forEach((fig) => {
  const tl = gsap.timeline({ scrollTrigger: { trigger: fig, start: "top 80%" } });
  tl.fromTo(fig, { clipPath: "inset(100% 0% 0% 0%)" },
                 { clipPath: "inset(0% 0% 0% 0%)", duration: 1.3, ease: "expo.inOut" })
    .from(fig.querySelector("img"), { scale: 1.3, duration: 1.6, ease: "expo.out" }, 0.2);
});
```

## 6 · Imagem com zoom/parallax dentro da moldura

```html
<div class="moldura"><img src="imagens/ambiente.jpg" alt="" data-speed="auto"></div>
```
```css
.moldura { overflow: hidden; height: 80vh; }
.moldura img { width: 100%; height: 130%; object-fit: cover; }  /* maior que a moldura */
```
`data-speed="auto"` calcula sozinho o quanto a imagem pode andar sem mostrar borda.

## 8 · Faixa corrida (marquee)

```html
<div class="faixa"><div class="faixa-trilho">
  <span>Corte · Barba · Sobrancelha · </span><span>Corte · Barba · Sobrancelha · </span>
</div></div>
```
```css
.faixa { overflow: hidden; white-space: nowrap; }
.faixa-trilho { display: inline-flex; }
```
```js
gsap.to(".faixa-trilho", { xPercent: -50, duration: 22, ease: "none", repeat: -1 });
```

## 9 · Seção fixa com troca de conteúdo

```js
const passos = gsap.utils.toArray(".passo");
const tl = gsap.timeline({
  scrollTrigger: { trigger: ".como-funciona", start: "top top",
                   end: "+=" + passos.length * 100 + "%", pin: true, scrub: 1 },
});
passos.forEach((p, i) => {
  if (i === 0) return;
  tl.to(passos[i - 1], { autoAlpha: 0, y: -40 }).from(p, { autoAlpha: 0, y: 40 }, "<");
});
```
(`.passo` empilhados com `position: absolute` dentro da seção.)

## 10 · Rolagem horizontal

```js
const trilho = document.querySelector(".horizontal-trilho");
gsap.to(trilho, {
  x: () => -(trilho.scrollWidth - window.innerWidth), ease: "none",
  scrollTrigger: { trigger: ".horizontal", start: "top top", pin: true, scrub: 1,
                   end: () => "+=" + (trilho.scrollWidth - window.innerWidth),
                   invalidateOnRefresh: true },
});
```

## 11 · Contador

```js
gsap.utils.toArray("[data-contar]").forEach((el) => {
  const alvo = Number(el.dataset.contar), obj = { v: 0 };
  gsap.to(obj, { v: alvo, duration: 2, ease: "power2.out",
    scrollTrigger: { trigger: el, start: "top 85%" },
    onUpdate: () => (el.textContent = Math.round(obj.v).toLocaleString("pt-BR")) });
});
```

## 12 · Botão magnético (só com mouse)

```js
if (matchMedia("(pointer: fine)").matches) {
  document.querySelectorAll(".magnetico").forEach((b) => {
    const x = gsap.quickTo(b, "x", { duration: 0.5, ease: "power3" });
    const y = gsap.quickTo(b, "y", { duration: 0.5, ease: "power3" });
    b.addEventListener("mousemove", (e) => {
      const r = b.getBoundingClientRect();
      x((e.clientX - r.left - r.width / 2) * 0.3);
      y((e.clientY - r.top - r.height / 2) * 0.3);
    });
    b.addEventListener("mouseleave", () => { x(0); y(0); });
  });
}
```

## 13 · Cabeçalho que some e volta

```js
const topo = gsap.from(".topo", { yPercent: -110, paused: true, duration: 0.35, ease: "power2.out" }).progress(1);
ScrollTrigger.create({ start: "top -120", onUpdate: (s) => (s.direction === -1 ? topo.play() : topo.reverse()) });
```
