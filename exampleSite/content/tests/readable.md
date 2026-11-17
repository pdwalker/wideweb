---
title: Readable (opt-in reading measure)
type: docs
readable: true
weight: 8
---

Front matter: `readable: true` (the site-wide default is
`params.readable.enable = true`; front matter always wins).

Expected at width ≥ 1280px: left sidebar **shown**, right sidebar **shown**,
main width = window − 32rem — the same 913px as [Both
Sidebars](/tests/both-sidebars/). The difference is invisible in the page
width but obvious in the probe's **prose** token: paragraphs and lists stay
capped at a ~75-character measure no matter how wide the window gets, while
tables, code blocks and figures below keep using the full main column.

{{< layout-probe >}}

## Paragraphs get capped

Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis
voluptatibus maiores alias consequatur aut perferendis doloribus asperiores
repellat. Excepturi sint occaecati cupiditate non provident, similique sunt
in culpa, qui officia deserunt mollitia animi, id est laborum.

Lists are capped too:

- The measure applies to `p`, `ul`, `ol`, `dl` and `blockquote` blocks
- The page itself still spans 100% of the window
- Tables and code keep full-bleed, as the next sections show

## Tables stay full-bleed

| Region | Left sidebar | Right sidebar | Main width | Contract |
| --- | --- | --- | --- | --- |
| Docs | shown | shown | window − 32rem | full navigation |
| Blog | collapsed | shown | window − 16rem | article focus |
| No sidebars | collapsed | collapsed | 100% of window | data-dense tables |

## Code stays full-bleed

```sh
hugo --gc            # production-ish build check (must be 0 ERROR/WARN)
npm run build:css    # only after editing assets/css/ or layouts/ hx: classes
```
