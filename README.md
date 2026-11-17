# WideWeb

A [Hugo](https://gohugo.io/) theme and fork of [Hextra](https://github.com/imfing/hextra)
(MIT, by Xin Fang) with one big change: **the main content always uses 100% of the
window**, and the left (main) sidebar and right sidebar (TOC) are fully optional —
whenever a page does not use a sidebar, its space is given to the main display area.

Everything else (dark mode, search, shortcodes, i18n, syntax highlighting, blog,
taxonomy, …) is upstream Hextra behavior.

## Quick start (your own site)

WideWeb is a Hugo module (`github.com/pdwalker/wideweb`), Hugo ≥ 0.146 extended:

```sh
hugo mod get -u github.com/pdwalker/wideweb
```

No Node.js needed: the theme ships its compiled Tailwind CSS.

## Sidebar contract

### Left (main) sidebar — section navigation tree

Resolution order, last match wins:

1. Layout default — on for `docs` pages, off for `home` / `single` / `blog` / etc.
2. `params.sidebar.enable = false` in site config — global off switch.
3. Front matter `sidebar.show = true` — opt a specific page (and its section tree) in.
4. Front matter `sidebar.hide = true` — opt out.
5. Auto-collapse: an enabled sidebar that would render zero nav items is removed
   and its width goes to the main area.

### Right sidebar ("On this page" / TOC, ≥1280px)

1. `params.toc.enable = false` — global off switch.
2. `toc: false` — per-page off switch.
3. Auto-collapse: no headings **and** empty TOC footer (no tags with
   `params.toc.displayTags`, no edit link) → column removed.

Unlike upstream Hextra, a hidden sidebar never reserves space: `toc: false` used to
leave an empty 16rem column, and `displayPlaceholder` used to reserve a spacer — both
removed. No site or page parameter caps page or content width anymore; the
`width` front matter and `params.page.width` are ignored.

## Readable mode (opt-in)

Full-viewport prose can run to 200+ characters per line on an ultrawide monitor.
`readable: true` in front matter (or `params.readable.enable = true` site-wide)
caps paragraphs, lists and quotes at a 75-character measure while the page
itself still spans 100% of the window — tables, code blocks and figures keep
the full width. See `/tests/readable/` on the test site.

## Development & testing

The repo root is the theme; `exampleSite/` is the visual test site.

```sh
cd exampleSite
hugo server -D          # http://localhost:1313
```

Home lists the test matrix; every test page carries a live *layout probe*
(viewport, main width as % of window, sidebar states) that updates on resize.
Agents: see [AGENTS.md](AGENTS.md) for the full workflow and verified expectations.

Rebuild the Tailwind CSS after editing `assets/css/` or adding new `hx:` utility
classes to layouts:

```sh
npm install
npm run build:css   # writes assets/css/compiled/main.css (vendored, commit it)
```

Machine-readable layout assertions (headless Chrome, 1440×900):

```sh
scripts/check-layout.sh   # against hugo server; see AGENTS.md for CI details
```

## License

MIT, same as Hextra; original copyright retained in `LICENSE`. WideWeb changes
© 2026 pdwalker.
