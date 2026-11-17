---
title: Auto-Collapse
type: docs
weight: 5
---

Front matter: *none (all defaults)* — but deliberately **no headings** below
the title, so there is nothing for the right sidebar to list.

Expected at width ≥ 1280px: left sidebar **shown** (this page still has
section siblings to navigate), right sidebar **collapsed automatically**,
main width = window − 16rem.

WideWeb removes the right column when the page has no headings and the TOC
footer would be empty (no tags shown, no edit link) — even though `toc` was
never turned off. Add any `## heading` to this file and the right sidebar
comes back, which is how you can prove the auto-collapse rule to yourself.

{{< layout-probe >}}

