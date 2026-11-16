---
title: Hello (default blog layout)
date: 2026-11-16
---

Front matter: *none (defaults)*.

Expected at width ≥ 1280px: left sidebar **collapsed** (blog layout defaults
it off), right sidebar **shown**, main width = window − 16rem.

## Why posts get full width

Hextra reserves 16rem for a docs tree even on blog posts that have nothing to
show there; WideWeb hands that space to the article instead.

{{< layout-probe >}}

## Until a post asks for navigation

The [companion post](/blog/with-nav/) opts into the section tree with
`sidebar.show: true` — compare the two.
