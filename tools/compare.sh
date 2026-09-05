#!/usr/bin/env bash
# Compile the same document with pdflatex and typst, then measure how far apart
# the two pages are. This is what makes "looks exactly like LaTeX" a
# measurement rather than a claim.
#
#   tools/compare.sh <name> [dpi]
#
# expects tests/reference/<name>.tex and tests/<name>.typ
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="${1:?usage: compare.sh <name> [dpi]}"
DPI="${2:-300}"
OUT="${COMPARE_OUT:-$ROOT/build}/$NAME"

TEX="$ROOT/tests/reference/$NAME.tex"
TYP="$ROOT/tests/$NAME.typ"
[ -f "$TEX" ] || { echo "missing $TEX" >&2; exit 2; }
[ -f "$TYP" ] || { echo "missing $TYP" >&2; exit 2; }

rm -rf "$OUT"; mkdir -p "$OUT"

pdflatex -interaction=batchmode -halt-on-error \
         -output-directory "$OUT" "$TEX" >/dev/null 2>&1 || {
  echo "pdflatex failed; see $OUT/$NAME.log" >&2; exit 1; }
# A second pass so cross-references and page counts settle.
pdflatex -interaction=batchmode -halt-on-error \
         -output-directory "$OUT" "$TEX" >/dev/null 2>&1
typst compile --root "$ROOT" "$TYP" "$OUT/typst.pdf"

pdftoppm -r "$DPI" -gray -png "$OUT/$NAME.pdf" "$OUT/ref"
pdftoppm -r "$DPI" -gray -png "$OUT/typst.pdf" "$OUT/cand"

status=0
total=0
printf '%-6s %12s %12s   %s\n' page differing percent verdict
for ref in "$OUT"/ref-*.png; do
  page="${ref##*/ref-}"; page="${page%.png}"
  cand="$OUT/cand-$page.png"
  if [ ! -f "$cand" ]; then
    printf '%-6s %12s %12s   %s\n' "$page" - - "MISSING in typst output"
    status=1; continue
  fi
  # -fuzz absorbs antialiasing differences between the two rasterisers; what
  # survives is genuine displacement of ink.
  diff=$(magick compare -metric AE -fuzz 5% "$ref" "$cand" \
           "$OUT/diff-$page.png" 2>&1 || true)
  # ImageMagick reports AE as a float; keep all arithmetic in python.
  diff="${diff%% *}"
  px=$(magick identify -format '%[fx:w*h]' "$ref")
  read -r diff pct over <<<"$(python3 -c "
d = float('$diff'); print(int(d), f'{100*d/$px:.4f}', int(100*d/$px > ${THRESHOLD:-0.5}))")"
  verdict=ok; [ "$over" = 1 ] && { verdict="OVER THRESHOLD"; status=1; }
  total=$((total + diff))
  printf '%-6s %12s %11s%%   %s\n' "$page" "$diff" "$pct" "$verdict"
done

extra=$(ls "$OUT"/cand-*.png 2>/dev/null | wc -l)
pages=$(ls "$OUT"/ref-*.png 2>/dev/null | wc -l)
[ "$extra" != "$pages" ] && { echo "page count differs: latex=$pages typst=$extra"; status=1; }

echo "total differing pixels: $total   (diff images in $OUT/diff-*.png)"
exit $status
