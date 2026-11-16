---
title: With Nav (sidebar.show opt-in)
date: 2026-11-16
sidebar:
  show: true
---

Front matter: `sidebar.show: true`.

Expected at width ≥ 1280px: left sidebar **shown** (navigating the two blog
posts), right sidebar **shown**, main width = window − 32rem — even though
this is a blog post on the sidebar-less `single` layout. Page-level opt-in
beats the layout default (an explicit `sidebar.hide` on the page would still
win over it).

## Prose

Perferendis doloribus asperiores repellat, saepe eveniet ut et voluptates
repudiandae sint.

{{< layout-probe >}}

## One more heading

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore
eu fugiat nulla pariatur.
