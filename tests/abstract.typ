#import "../src/lib.typ": article
#show: article.with(
  title: [On the Measurement of Things],
  authors: ([Ada Lovelace],),
  date: [September 5, 2026],
  abstract: [
    This abstract is long enough that it wraps onto more than one line, which is
    what we need in order to check the quotation margins on both sides as well as
    the paragraph indentation inside the abstract environment itself.
  ],
)

Body paragraph following the abstract, also long enough to wrap onto a second
line of running text.
