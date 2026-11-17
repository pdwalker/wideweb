---
title: Wide Layout No TOC
type: docs
layout: wide
weight: 7
---

Front matter: `layout: wide` — and deliberately **no headings**, so the right
sidebar auto-collapses exactly like it does on the docs layouts.

Expected at every width: both sidebars **collapsed**, main width =
**100% of the window**. The wide layout shares the TOC contract: a page with
nothing to list gets no 16rem column. Add a `## heading` and the column comes
back.

{{< layout-probe >}}
