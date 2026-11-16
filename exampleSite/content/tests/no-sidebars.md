---
title: No Sidebars
type: docs
weight: 4
sidebar:
  hide: true
toc: false
---

Front matter: `sidebar.hide: true` and `toc: false`.

Expected at every width: **both sidebars collapsed**, main width =
**100% of the window**. This is the core WideWeb promise — the prose column
spans the full viewport (minus the 3rem content padding) with no max-width
capping it, even on an ultra-wide monitor.

## Full-bleed prose

Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit
laboriosam, nisi ut aliquid ex ea commodi consequatur. Quis autem vel eum iure
reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur.

{{< layout-probe >}}

## Resize me

At the current window width the probe should report `100%` for main width.
Drag the window from narrow to full-screen: it should remain `100%`
throughout, and the sidebars should never reappear at any breakpoint.
