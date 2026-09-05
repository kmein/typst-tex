#!/usr/bin/env bash
# Numeric companion to compare.sh: print where each word landed in both PDFs
# and flag the ones that moved. Pixel counts say *that* something drifted;
# this says *which element* and by how many points.
#
#   tools/bbox.sh <name> [tolerance-pt]
#
# Run tools/compare.sh <name> first to produce the PDFs.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="${1:?usage: bbox.sh <name> [tolerance-pt]}"
TOL="${2:-0.05}"
OUT="${COMPARE_OUT:-$ROOT/build}/$NAME"

for f in "$OUT/$NAME.pdf" "$OUT/typst.pdf"; do
  [ -f "$f" ] || { echo "missing $f -- run tools/compare.sh $NAME first" >&2; exit 2; }
done

pdftotext -bbox "$OUT/$NAME.pdf" "$OUT/ref.xhtml"
pdftotext -bbox "$OUT/typst.pdf" "$OUT/cand.xhtml"

python3 - "$OUT/ref.xhtml" "$OUT/cand.xhtml" "$TOL" <<'PY'
import re, sys

def words(path):
    out, page = [], 0
    for line in open(path, encoding="utf-8"):
        if "<page" in line:
            page += 1
        m = re.search(r'<word xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="([\d.]+)">(.*?)</word>', line)
        if m:
            out.append((page, float(m[1]), float(m[2]), float(m[3]), float(m[4]), m[5]))
    return out

ref, cand, tol = words(sys.argv[1]), words(sys.argv[2]), float(sys.argv[3])
# pdftotext's reading order puts the page footer in different places in the two
# files; sort each page geometrically so the sequences line up.
key = lambda w: (w[0], round(w[4], 1), w[1])
ref.sort(key=key)
cand.sort(key=key)
print(f"{len(ref)} words in latex output, {len(cand)} in typst output")

n = min(len(ref), len(cand))
# Compare against yMax, not yMin: pdftotext derives the top of a word box from
# the font's declared *ascent*, which differs between CMR's Type 1 fonts and
# Latin Modern's OpenType ones and varies with the cut, so yMin carries a
# per-font-size offset that is not a real displacement. The descent-derived
# yMax agrees exactly between the two.

bad = 0
print(f"{'page':>4} {'word':<22} {'dx':>9} {'dy':>9} {'dwidth':>9}")
for i in range(n):
    p, x0, y0, x1, y1, w = ref[i]
    q, a0, b0, a1, b1, v = cand[i]
    if w != v:
        print(f"{p:>4} text diverges here: latex={w!r} typst={v!r}")
        bad += 1
        break
    dx, dy, dw = a0 - x0, b1 - y1, (a1 - a0) - (x1 - x0)
    if max(abs(dx), abs(dy)) > tol:
        if bad < 40:
            print(f"{p:>4} {w[:22]:<22} {dx:>9.3f} {dy:>9.3f} {dw:>9.3f}")
        bad += 1
if len(ref) != len(cand):
    print(f"!! word count differs by {len(cand) - len(ref)}")
print(f"{bad} of {n} words displaced by more than {tol}pt")
PY
