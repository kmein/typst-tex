#import "../src/lib.typ": article
#show: article.with(paper: "a4", size: "10")

Opening paragraph before the figure, long enough that it wraps onto a second
line of running text in the body.

#figure(
  rect(width: 4cm, height: 2cm, fill: black, stroke: none),
  caption: [A short caption.],
  placement: none,
)

Middle paragraph between the two floats, also long enough to wrap onto a
second line so that the spacing above and below is exercised.

#figure(
  rect(width: 3cm, height: 1.5cm, fill: black, stroke: none),
  caption: [A caption that is deliberately made long enough that it will not fit
    on a single line and therefore has to be set as a justified paragraph instead
    of being centred.],
  placement: none,
)

Closing paragraph after the second figure.
