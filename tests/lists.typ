#import "../src/lib.typ": article
#show: article.with(paper: "a4", size: "10")

Paragraph before the list, long enough to wrap onto a second line of body
text so that the spacing above is measured from a full line.

- First item of the itemize list.
- Second item, made long enough that it wraps onto a second line so the
  hanging indentation can be checked as well.
- Third item.

Paragraph between the two lists.

+ First enumerated item.
+ Second enumerated item.

Paragraph after the enumerate list.
