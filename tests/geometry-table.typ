// Prints the computed geometry so it can be diffed against LaTeX's own values.
#import "../src/geometry.typ": layout
#set page(width: 210mm, height: auto, margin: 6mm)
#set text(size: 7pt, font: "DejaVu Sans Mono")
#for paper in ("a4", "letter") {
  for sz in ("10", "11", "12") {
    let g = layout(paper: paper, size: sz)
    [*#paper / #sz pt* \ ]
    for (k, v) in g {
      if type(v) in (float, int) {
        [#k = #calc.round(v, digits: 4) TeXpt = #calc.round(v * 72.0 / 72.27, digits: 4) pt \ ]
      }
    }
    [ \ ]
  }
}
