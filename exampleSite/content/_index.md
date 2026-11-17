---
title: Home
toc: false
---

Welcome to the **WideWeb** layout test site. WideWeb is a fork of
[Hextra](https://github.com/imfing/hextra) whose main content always spans
**100% of the window**; the left sidebar and the right sidebar (TOC) are fully
optional, and any space they do not use is given to the main area.

Every test page carries a *Layout probe* showing the measured main width and
which sidebars are currently rendered.

## Test matrix

| Page | Front matter | Expected left | Expected right (≥1280px) | Expected main width |
| --- | --- | --- | --- | --- |
| [Layout Tests index](/tests/) | *(none — all defaults)* | shown | shown | window − 32rem |
| [Both sidebars](/tests/both-sidebars/) | *(defaults)* | shown | shown | window − 32rem |
| [Left sidebar only](/tests/left-only/) | `toc: false` | shown | **collapsed** | window − 16rem |
| [Right sidebar only](/tests/right-only/) | `sidebar.hide: true` | **collapsed** | shown | window − 16rem |
| [No sidebars](/tests/no-sidebars/) | `sidebar.hide` + `toc: false` | **collapsed** | **collapsed** | **100% of window** |
| [Auto-collapse](/tests/auto-collapse/) | *(no headings on page)* | shown | **collapsed (auto)** | window − 16rem |
| [Wide layout](/tests/wide/) | `layout: wide` | **collapsed** | shown | window − 16rem |
| [Wide layout, no TOC](/tests/wide-no-toc/) | `layout: wide` + no headings | **collapsed** | **collapsed (auto)** | **100% of window** |
| [Readable](/tests/readable/) | `readable: true` | shown | shown | window − 32rem, prose capped ~75ch |
| [TOC tags footer](/tests/toc-tags/) | `tags:` + no headings | shown | shown (**tag footer keeps it alive**) | window − 32rem |
| [About](/about/) | non-docs single page | **collapsed** | shown | window − 16rem |
| [Blog index](/blog/) | list layout | **collapsed** | **collapsed** | **100% of window** |
| [Blog post](/blog/hello/) | blog layout | **collapsed** | shown | window − 16rem |
| [Tag page](/tags/wideweb/) | taxonomy layout | **collapsed** | **collapsed** | **100% of window** |

{{< layout-probe >}}

This home page itself uses no sidebars, so the probe above should read
**100% of window** at every desktop width.
