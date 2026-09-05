// A small pgfplots-flavoured plotting module.
//
// Written natively rather than pulling in a drawing package so that the axes,
// rules and labels match the surrounding LaTeX-style page: 0.4pt frame, ticks
// turned inward, Computer Modern labels at \footnotesize.

// Monochrome by design. Series are told apart by dash pattern and weight, not
// by hue, so the figures survive a black-and-white printer, a photocopier and a
// greyscale e-reader. This also matches the rest of the page, which is a
// classic single-colour LaTeX article.
#let default-palette = (
  luma(0%), luma(0%), luma(0%), luma(0%), luma(35%), luma(35%),
)
#let default-dashes = (
  none, "dashed", "dash-dotted", "densely-dotted", "loosely-dashed", "dotted",
)
#let default-widths = (
  1.0pt, 0.85pt, 0.85pt, 0.95pt, 0.85pt, 0.85pt,
)

#let sx(x, lim, w) = (x - lim.at(0)) / (lim.at(1) - lim.at(0)) * w
#let sy(y, lim, h) = h - (y - lim.at(0)) / (lim.at(1) - lim.at(0)) * h

/// Format a tick value without trailing noise.
#let fmt(v, digits: 0) = {
  let r = calc.round(v, digits: digits)
  if digits <= 0 { str(calc.round(r)) } else { str(r) }
}

/// A line plot.
///
/// `series` is an array of dictionaries with `data` (an array of `(x, y)`
/// pairs), and optionally `label`, `stroke`, `dash`.
#let plot(
  width: 280pt,
  height: 165pt,
  xlim: (0, 1),
  ylim: (0, 1),
  xticks: none,
  yticks: none,
  xlabel: none,
  ylabel: none,
  xdigits: 0,
  ydigits: 0,
  series: (),
  legend: "ne",
  show-grid: true,
  pad-left: 48pt,
  pad-bottom: 26pt,
  pad-top: 6pt,
  // Enough room on the right for the half of the last tick label that sits
  // outside the frame; the whole assembly must fit the 343.7pt text block.
  pad-right: 14pt,
  annotations: (),
) = {
  let w = width
  let h = height
  let ox = pad-left
  let oy = pad-top
  let tickfont = 8pt

  let xt = if xticks == none { () } else { xticks }
  let yt = if yticks == none { () } else { yticks }

  box(width: w + pad-left + pad-right, height: h + pad-top + pad-bottom, {
    // Grid
    if show-grid {
      for t in xt {
        let px = ox + sx(t, xlim, w)
        place(dx: px, dy: oy, line(
          start: (0pt, 0pt), end: (0pt, h), stroke: 0.3pt + luma(80%),
        ))
      }
      for t in yt {
        let py = oy + sy(t, ylim, h)
        place(dx: ox, dy: py, line(
          start: (0pt, 0pt), end: (w, 0pt), stroke: 0.3pt + luma(80%),
        ))
      }
    }

    // Series
    for (i, s) in series.enumerate() {
      let n = calc.rem(i, default-palette.len())
      let col = s.at("stroke", default: default-palette.at(n))
      let dash = s.at("dash", default: default-dashes.at(n))
      let wt = s.at("thickness", default: default-widths.at(n))
      let pts = s.data.map(p => (ox + sx(p.at(0), xlim, w), oy + sy(p.at(1), ylim, h)))
      if pts.len() >= 2 {
        place(curve(
          stroke: (paint: col, thickness: wt, dash: dash, cap: "round"),
          curve.move(pts.first()),
          ..pts.slice(1).map(p => curve.line(p)),
        ))
      }
    }

    // Frame, drawn last so the curves do not cover it.
    place(dx: ox, dy: oy, rect(
      width: w, height: h, stroke: 0.4pt + black, fill: none,
    ))

    // Ticks, turned inward, and their labels.
    for t in xt {
      let px = ox + sx(t, xlim, w)
      place(dx: px, dy: oy + h, line(
        start: (0pt, 0pt), end: (0pt, -3pt), stroke: 0.4pt,
      ))
      place(dx: px, dy: oy + h + 2pt, box(width: 0pt, align(center + top,
        box(width: 40pt, align(center, text(size: tickfont, fmt(t, digits: xdigits)))),
      )))
    }
    for t in yt {
      let py = oy + sy(t, ylim, h)
      place(dx: ox, dy: py, line(
        start: (0pt, 0pt), end: (3pt, 0pt), stroke: 0.4pt,
      ))
      place(dx: ox - 4pt, dy: py, box(width: 0pt, height: 0pt, align(right + horizon,
        box(width: 32pt, height: 0pt, align(right + horizon,
          text(size: tickfont, fmt(t, digits: ydigits)))),
      )))
    }

    // Axis labels
    if xlabel != none {
      place(dx: ox, dy: oy + h + 13pt, box(width: w, align(center,
        text(size: 9pt, xlabel))))
    }
    if ylabel != none {
      // Rotated, and given the full plot height to lay out in so that a long
      // label stays on one line.
      place(dx: 0pt, dy: oy, box(width: 11pt, height: h,
        align(center + horizon, rotate(-90deg, reflow: false,
          box(width: h, align(center, text(size: 9pt, ylabel)))))))
    }

    // Free-form annotations: (x, y, content, align)
    for a in annotations {
      let px = ox + sx(a.at(0), xlim, w)
      let py = oy + sy(a.at(1), ylim, h)
      place(dx: px, dy: py, box(width: 0pt, height: 0pt,
        align(a.at(3, default: left + horizon),
          box(width: 90pt, height: 0pt, align(a.at(3, default: left + horizon),
            text(size: 8pt, a.at(2)))))))
    }

    // Legend
    let labelled = series.filter(s => s.at("label", default: none) != none)
    if legend != none and labelled.len() > 0 {
      let entries = labelled.enumerate().map(((j, s)) => {
        let i = series.position(x => x == s)
        let n = calc.rem(i, default-palette.len())
        grid(
          columns: (20pt, auto),
          column-gutter: 3pt,
          align: horizon,
          line(start: (0pt, 0pt), end: (20pt, 0pt), stroke: (
            paint: s.at("stroke", default: default-palette.at(n)),
            thickness: s.at("thickness", default: default-widths.at(n)),
            dash: s.at("dash", default: default-dashes.at(n)),
          )),
          text(size: 8pt, s.label),
        )
      })
      // Laid out inside a box covering the plot area, so the legend sizes to
      // its content and is aligned within the frame rather than clipped to a
      // guessed width.
      let al = ((if legend.contains("w") { left } else { right })
             + (if legend.contains("s") { bottom } else { top }))
      place(dx: ox, dy: oy, box(width: w, height: h, inset: 5pt, align(al,
        block(
          stroke: 0.4pt + black,
          fill: white,
          inset: 3pt,
          grid(columns: 1, row-gutter: 2.5pt, ..entries),
        ))))
    }
  })
}
