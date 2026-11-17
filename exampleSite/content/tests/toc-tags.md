---
title: TOC Tags Footer
type: docs
weight: 9
tags:
  - wideweb
  - layout-test
---

Front matter: `tags: [wideweb, layout-test]`, deliberately **no headings** —
and this site sets `params.toc.displayTags = true`.

Expected at width ≥ 1280px: left sidebar **shown**, right sidebar **shown**
despite zero headings — the tag list is TOC footer content, so the
auto-collapse rule does *not* fire. Main width = window − 32rem. Remove the
`tags` and the column disappears; that pairs with
[Auto-Collapse](/tests/auto-collapse/), where the footer is empty.

The tags also create the [tag pages](/tags/wideweb/), which exercise the
taxonomy layouts: no sidebars, main width = 100% of the window.

{{< layout-probe >}}
