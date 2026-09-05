# typst-tex

[![CI](https://github.com/kmein/typst-tex/actions/workflows/ci.yml/badge.svg)](https://github.com/kmein/typst-tex/actions/workflows/ci.yml)

**Typst was created, in part, so that people would not have to use LaTeX.**

This repository uses Typst to *be* LaTeX. On purpose. To within 0.05 points.

```typst
#import "src/lib.typ": article
#show: article.with(title: [A Perfectly Normal Document])

= This is fine
```

Output is `\documentclass[a4paper]{article}`. Not "inspired by". Not "in the
spirit of". The two PDFs are diffed pixel by pixel and the residual is
antialiasing.

(The repository is `typst-tex`; the package inside it is `latex-article`, which
is the name you import. Yes, this is already confusing. It does not get better.)

---

## Your scientists were so preoccupied with whether they could

They did not stop to think whether they should. Neither did I. Here is the
galaxy-brain progression that produced this repository:

🧠 Use LaTeX.

🧠 Use Typst, like a person with a life.

🧠 Use Typst with a template that looks *a bit* like LaTeX.

🧠 Read `size10.clo` and implement LaTeX's actual page-geometry algorithm.

🧠 Run `tftopl` on Computer Modern's `.tfm` files to recover font parameters
that TeX has been quietly using since 1978.

🌌 Patch `\@maketitle` and run `\showthe\prevdepth` to interrogate TeX about its
feelings, because one line of the title block was 0.4pt off and I could not let
it go.

All five of those things are in this repo. The last one is in `src/title.typ`.

---

## The receipts

Everyone writes a "LaTeX-like" Typst template. Here is what they miss.

### TeX's point is not your point

TeX's point is **1/72.27 inch**. Typst's point — like PostScript's, like PDF's,
like everyone else's — is **1/72 inch**. In 1978 the American printer's point
was 1/72.27 inch, and Donald Knuth is not a man who rounds.

So a LaTeX "10pt" document has a body font of **9.96264 Typst pt** and a text
width of **343.711**, not 345. Every hand-tuned template on the internet is
0.37% too big, and it compounds across the page, and nobody has noticed.

### LaTeX's margins are not symmetric and never have been

```tex
\def\@settopoint#1{\divide#1\p@\multiply#1\p@}
```

That is integer truncation. Consequently, on a4/10pt, LaTeX's left margin is
**124.802pt** and its right margin is **126.763pt**. Your beautiful centred text
block has been two points off-centre since the Reagan administration.

We reproduce this faithfully. That's the job.

### `\quad` is wider than the font

I spent a genuinely embarrassing amount of time on section headings being
1.8pt too far left before running `tftopl` on `cmbx12.tfm` and discovering:

```
(QUAD R 1.125)
```

TeX's `em` is not the font size. It is whatever the font's `QUAD` parameter
says it is, and Computer Modern's **bold** cuts say 1.125–1.15em. So the
`\quad` after "3.2" in a section heading is *wider than the heading's type
size*. `src/fonts.typ` carries the QUAD of every CM cut, harvested from the
metrics files by hand.

### Bold stops at 12pt because `cmbx17` does not exist

`ot1cmr.fd` reveals that NFSS picks a different physical font for every size —
`cmr8` for footnotes, `cmr12` at 14.4pt, `cmr17` above that — but bold caps out
at `cmbx12`, because Knuth never cut a `cmbx17`. Latin Modern, faithful to a
fault, correspondingly ships no bold for "Latin Modern Roman 17".

The template reproduces the entire lookup table. Including the hole.

### `center` and `quotation` do not agree, and it matters

`center` is a `trivlist`, which does **not** execute `\@listi`, so it uses the
ambient `\topsep`. `quotation` is a real `list`, which **does**, so it picks up
`\small`'s tighter value. This one distinction explains every vertical gap in
the abstract, and I found it by measuring gaps in a PDF and refusing to accept
that they were arbitrary.

### The date in `\maketitle` is haunted

`{\large \@date}` closes its group *before* `\end{center}` triggers `\par`. So
TeX appends that one line with `\baselineskip` at **normalsize**, not `\large`,
and against the author tabular's 4.2pt depth there is no room for interline
glue, so it silently falls back to `\lineskip`.

Net effect: **the vertical position of the date depends on the ink height of the
date.** Change "September" to "May" and the line moves.

`src/title.typ` reproduces this by measuring the ink height of your date at
compile time and reimplementing TeX's glue decision. I am not joking. There is a
`calc.max` in there that is, functionally, TeX's `\lineskiplimit`.

---

## Trust nothing: the harness

> ❌ "It looks pretty LaTeX-ish to me, ship it"
>
> ✅ Rasterise both PDFs at 300 DPI and compare them per pixel

```
tools/check.sh              # every test
tools/compare.sh <name>     # pdflatex + typst → 300 DPI → pixel diff
tools/bbox.sh <name> [tol]  # per-word coordinate deltas, to see *what* moved
```

`compare.sh` compiles `tests/reference/<name>.tex` with pdflatex and
`tests/<name>.typ` with Typst, rasterises both, and reports differing pixels per
page with a composite diff image. `bbox.sh` tells you *which element* drifted
rather than merely that something did.

**The number that justifies the whole exercise:** across `grid`, `grid11`,
`grid12` and `letter` — 60 paragraphs over two pages, at three type sizes, on
two paper sizes — **no word is displaced by more than 0.05pt**, and the page
break falls on the same line.

| suite | covers | pixel diff |
|---|---|---|
| probe, grid, grid11, grid12, letter | geometry, baseline grid | 0.02–0.21% |
| sections, runin, title, abstract, punct | headings, `\maketitle`, abstract, protrusion | 0.10–0.25% |
| floats, lists, notes | captions, lists, footnotes | 0.19–0.40% |

15/15 passing. The residual is Type 1 vs OpenType antialiasing.

### One bug that got away for a while

Typst hangs line-final punctuation ~2.2pt into the margin. `pdflatex` without
`microtype` does not protrude at all. My entire test suite missed this because
no test sentence happened to end a line with a comma. I only found it after
writing eight thousand words about tea (below).

`tests/punct.typ` now exists so that can never happen again. Task failed
successfully.

---

## Usage

```typst
#import "src/lib.typ": article

#show: article.with(
  title: [A Metrically Exact Article],
  authors: ([Ada Lovelace],),
  date: [September 5, 2026],
  abstract: [...],
)
```

| option | values |
|---|---|
| `paper` | `"a4"`, `"a5"`, `"b5"`, `"letter"`, `"legal"`, `"executive"` |
| `size` | `"10"`, `"11"`, `"12"` |
| `twoside` | `false` |
| `optical` | `true` — per-size CM font cuts, as NFSS would |
| `portable` | `false` — use the New Computer Modern bundled in the Typst binary |
| `page-numbers` | `true` |

Geometry is not a table of magic numbers; `src/geometry.typ` runs LaTeX's own
algorithm, so every paper/size combination it supports works.

### Nix

```bash
nix run   github:kmein/typst-tex#typst -- compile --root . mydoc.typ
nix build github:kmein/typst-tex#tea      # the 23 pages about tea
nix develop                               # both engines, rasteriser, pixel differ
nix flake check                           # see below
```

`packages.typst` is a Typst wrapper with this package importable as
`@preview/latex-article:0.1.0` and Latin Modern already on the font path, so it
works in a sandbox with no system fonts:

```typst
#import "@preview/latex-article:0.1.0": article
```

`nix flake check` compiles fifteen documents twice — once in Typst, once in
pdfTeX — rasterises thirty PDFs at 300 DPI and compares them pixel by pixel. It
is, I am reasonably confident, the most rigorous continuous integration ever
built for a problem nobody has.

---

## Things I could not fix and have made peace with

Documented so that "exactly" is not allowed to overreach:

- **Line breaking.** Typst's justifier is Knuth–Plass-*like* but exposes none of
  TeX's `\tolerance`, `\hyphenpenalty`, `\adjdemerits`. TeX will squeeze a line
  to fit one more word where Typst gives up. One different break cascades. This
  is the hard ceiling, and I have stared at it for some time.
- **Space factors.** TeX widens the space after `.` `?` `!` `:` `;` `,`. Typst
  has no equivalent. Where the template owns the text — the `Figure 1:`
  separator — I apply the correction by hand, using CM's `EXTRASPACE`, like a
  Victorian.
- **Rubber glue.** LaTeX's skips carry `plus`/`minus` that TeX's page builder
  redistributes. Typst's vertical spacing is rigid. `\addvspace`'s
  take-the-maximum semantics *are* reproduced, using Typst's weak spacing,
  which turns out to be the same idea.
- **`\prevdepth`.** TeX measures space above a float from the bottom of the
  previous line, not its baseline. Our line boxes end at the baseline, so the
  depth is added back as a constant — 0.194445em, the greatest `CHARDP` in
  `cmr10`, which I looked up, because of course I did.
- **Float-only pages.** LaTeX centres them (`\@fptop` is `0pt plus 1fil`);
  Typst tops them.

Plus a few Typst-side workarounds that live in `src/base.typ` and are funnier
than they should be, including a paragraph of *literally zero height* whose sole
purpose is to preserve the "follows a paragraph" chain so that first-line
indentation behaves the way LaTeX's does.

Not implemented: bibliography, theorems, `twocolumn`, `report`/`book`.

---

## But at what cost?

To prove the template worked I needed a long document. Obviously I could have
used lorem ipsum.

Instead there is **`examples/tea/`**: a 23-page, 33-equation, 7-figure,
4-table guide to the thermal physics of a cooling cup of tea. It develops
Fourier conduction, Rayleigh–Nusselt natural convection, Stefan–Boltzmann
radiation, and evaporation via Clausius–Clapeyron and the Chilton–Colburn
analogy, then uses the resulting model to settle when to add the milk.

> *We have pgfplots at home.*
>
> The pgfplots at home: `examples/tea/plot.typ`, 179 lines, monochrome,
> dash-pattern cycling, written from scratch because I wanted the axis labels in
> Computer Modern and the frame at exactly 0.4pt.

Every number quoted in its prose is computed by `examples/tea/physics.typ`, so
the text and the graphs cannot disagree. Then I had a second AI adversarially
audit the physics. It found six errors, including a milk heat capacity that was
off by a factor of 1000 — I had written 30 litres of milk into a teacup — and
one modelling inconsistency that moved a headline number by 13%.

All fixed. The tea is now correct to a standard nobody asked for, in a typeface
nobody will notice, on a page geometry that is provably two points off-centre.

```
typst compile --root . examples/tea/tea.typ examples/tea/tea.pdf
```

---

## Layout

```
src/units.typ      TeX-point conversion, \@settopoint
src/geometry.typ   the size1X.clo algorithm: paper + size -> margins
src/fonts.typ      CM optical cuts, QUAD and CHARDP harvested from the TFMs
src/base.typ       style object, size switching, cursed content helpers
src/lib.typ        the article() entry point, page setup, sectioning
src/title.typ      \maketitle, the haunted date line, the abstract
src/floats.typ     figures and \@makecaption
src/lists.typ      itemize and enumerate
src/notes.typ      footnotes and display skips
tools/             the pixel-diff harness
tests/             per-feature documents and their LaTeX twins
examples/tea/      23 pages about tea (see above, and reconsider your life)
```

Requires Typst 0.14+, and for the harness a TeX installation plus `pdftoppm`,
ImageMagick and `mutool`.

---

## FAQ

**Why is the repo called `typst-tex` and the package `latex-article`?**
The repository is the crime scene. The package is the evidence.

**Why?**
Because `\@settopoint` is integer truncation and somebody had to say so.

**Is this a good idea?**
No.

**Is it correct?**
Yes. That is the entire problem.

It ain't much, but it's honest work.
