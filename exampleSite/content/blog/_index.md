---
title: Blog
---

Blog posts use the `single`-style layout, where the left sidebar is off by
default — but `sidebar.show: true` in front matter opts a post back in.

The list page itself uses no sidebars (upstream's phantom 16rem TOC spacer is
removed), so the probe below should read **100% of window** at every width.

{{< layout-probe >}}
