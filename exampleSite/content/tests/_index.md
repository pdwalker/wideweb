---
title: Layout Tests
type: docs
weight: 1
---

This section exercises every sidebar combination of the WideWeb theme. Each
page states its front matter, its expected layout, and a live layout probe.

The right sidebar only appears at window widths ≥ 1280px (the `xl` breakpoint,
same as upstream Hextra); below that it is responsive-hidden and the main area
automatically takes its space. The left sidebar collapses below 768px into the
hamburger overlay on pages that use it.

## How to verify

1. Run `hugo server` in the repository root.
2. Visit the pages listed on the [home page](/).
3. Check the layout probe line on each page.
4. Drag the window narrower and wider and watch the main width reflow — it
   should always equal *window − (visible sidebars × 16rem)*, and never be
   capped by a fixed max-width.
