#!/usr/bin/env bash
# Run every comparison test and summarise.
#   tools/check.sh [name ...]
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ $# -gt 0 ]; then tests=("$@"); else
  tests=(); for f in tests/*.typ; do
    n="$(basename "$f" .typ)"
    [ -f "tests/reference/$n.tex" ] && tests+=("$n")
  done
fi

# Per-test thresholds, in percent of differing pixels. Everything is 0.5%
# unless a test is known to hit a documented engine difference, in which case
# the reason is printed alongside so the number is not silently excused.
threshold_for() {
  case "$1" in
    showcase) echo "2.5|float-only page: LaTeX centres it, Typst tops it" ;;
    *)        echo "0.5|" ;;
  esac
}

fail=0
printf '%-14s %10s %10s  %-6s %s\n' TEST PIXELS PERCENT STATUS NOTE
for t in "${tests[@]}"; do
  spec=$(threshold_for "$t"); THRESHOLD="${spec%%|*}"; note="${spec#*|}"
  export THRESHOLD
  out=$(tools/compare.sh "$t" 2>&1)
  if [ $? -ne 0 ] && ! grep -q "^total" <<<"$out"; then
    printf '%-14s %10s %10s  %s\n' "$t" - - "BUILD FAILED"; fail=1; continue
  fi
  px=$(grep '^total' <<<"$out" | grep -oE '[0-9]+' | head -1)
  pct=$(awk '/^[0-9]/{s+=$3; n++} END{if(n) printf "%.4f", s/n}' <<<"$(grep -E '^[0-9]+ ' <<<"$out" | tr -d '%')")
  st=ok; grep -q "OVER THRESHOLD" <<<"$out" && { st="CHECK"; fail=1; }
  printf '%-14s %10s %9s%%  %-6s %s\n' "$t" "${px:-?}" "${pct:-?}" "$st" "$note"
done
exit $fail
