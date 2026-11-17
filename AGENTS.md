# AGENTS.md — WideWeb development guide

WideWeb is a Hugo theme: a fork of [Hextra](https://github.com/imfing/hextra)
(MIT) where main content always uses **100% of the window** and the optional
left/right sidebars surrender their space to the main area when unused.

## Repo layout

```
/                       the theme (Hugo module github.com/pdwalker/wideweb)
  layouts/              Go HTML templates (docs/, blog/, _partials/, _shortcodes/, …)
  assets/css/           Tailwind v4 source CSS (styles.css imports components/*)
  assets/css/compiled/main.css   vendored build output — commit any changes to it
  assets/js/core/       vanilla JS per component (menu.js, sidebar.js, …)
  i18n/ data/ static/   translations, icons.yaml, theme assets
  hugo.toml             theme config (hugoVersion + outputFormats llms/markdown)
  go.mod                module github.com/pdwalker/wideweb
  package.json          CSS build: npm run build:css (postcss + @tailwindcss/postcss)
exampleSite/            visual test site (Hugo module .../exampleSite)
  hugo.toml             [module] imports wideweb; go.mod has replace ../ (offline)
  content/              test pages: tests/ section + blog/ + about
  layouts/shortcodes/layout-probe.html   JS probe measuring layout live
```

## Run / test

```sh
cd exampleSite && hugo server -D         # http://localhost:1313
cd exampleSite && hugo --gc              # production-ish build check (must be 0 ERROR/WARN)
npm install && npm run build:css         # only after editing assets/css/ or layouts/ hx: classes
```

## Verifying layout changes (the workflow that works)

Chrome headless gives machine-readable truth; this agent harness cannot view
screenshots, so parse the probe text from the live DOM:

```sh
cd exampleSite && (hugo server -D --port 1313 >/tmp/hugo-serve.log 2>&1 &) && sleep 4
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new --disable-gpu --no-first-run --window-size=1440,900 \
  --virtual-time-budget=4000 --dump-dom http://localhost:1313/tests/no-sidebars/ \
  | grep -o 'viewport [0-9]*px  |  main [0-9]*px ([0-9]*% of window)'
```

Use `--screenshot=path.png` for visual artifacts a human can review
(`/tmp/wwshots/` was the last run). Kill the server when done (`pkill -f "hugo server"`).

### Verified expectations (window 1440×900, as of 2026-11)

| Route | left | right | main width |
| --- | --- | --- | --- |
| `/tests/no-sidebars/` | collapsed | collapsed | **1440px (100%)** |
| `/tests/both-sidebars/` | shown | shown | 913px |
| `/tests/left-only/` | shown | collapsed | 1184px |
| `/tests/right-only/` | collapsed | shown | 1184px |
| `/tests/auto-collapse/` | shown | auto-collapsed (page has no h2+) | 1184px |
| `/tests/wide/` | collapsed (wide layout default) | shown | 1184px |
| `/tests/wide-no-toc/` | collapsed | collapsed (auto) | **1440px (100%)** |
| `/tests/readable/` | shown | shown | 928px; first prose block capped ~75ch |
| `/tests/toc-tags/` | shown | shown — tag footer keeps TOC alive | 928px |
| `/blog/` | collapsed | collapsed | **1440px (100%)** |
| `/blog/hello/` | collapsed (layout default) | shown | 1184px |
| `/blog/with-nav/` | shown (`sidebar.show: true`) | shown | 928px |
| `/about/` | collapsed | shown | 1184px |
| `/tags/wideweb/` | collapsed | collapsed | **100%** (markup contract) |
| `/` (home) | collapsed | collapsed | ~100% |

The 928-vs-913 delta is **not** a padding trick: it is the 15px classic macOS
scrollbar. Scrolling pages have `documentElement.clientWidth` = window − 15px
while `window.innerWidth` still reads 1440. That is why the live probe also
emits `cvw NNNNpx` and why `scripts/check-layout.sh` asserts the
scrollbar-independent identity
`main == cvw − 256px × visible-sidebars` instead of frozen pixel values.

### Automated layout checks

```sh
scripts/check-layout.sh [BASE_URL]   # default http://localhost:1313
```

Headless-Chrome assertions of the contract above (1440×900 window): sidebar
visibility per route, the `main == cvw − sidebars` identity, the reading-measure
prose bounds, and the taxonomy pages' markup contract. CI
(`.github/workflows/ci.yml`) runs this plus `hugo --gc` (0 ERROR/WARN) and a
compiled-CSS drift check on every push/PR.

## The sidebar contract (implemented, do not regress)

Left — `_partials/sidebar.html`, last match wins:
layout dict `disableSidebar` → site `params.sidebar.enable=false` →
front matter `sidebar.show=true` → front matter `sidebar.hide=true` →
auto-collapse when `where (union FirstSection.RegularPages FirstSection.Sections)
"Params.sidebar.exclude" "!=" true` is empty **and** `site.Menus.sidebar` empty.
Collapsed sidebars still render as the <768px mobile hamburger overlay; the
theme/lang switcher moves to the footer via the `enableFooterSwitches` page store.

Right — `_partials/toc.html`: `.Params.toc | default (site.Params.toc.enable |
default true)`, and the whole `<nav>` (not just its content!) is omitted when
`toc` is off or there are no headings and no footer content (tags w/
`params.toc.displayTags`, editURL). Omitting the nav is the fix for Hextra's
empty-16rem-column bug — keep it.

Width — `assets/css/variables.css` is the single source: `--hextra-max-page-width:
100%`, `--hextra-max-content-width: none`, navbar/footer 100%. The `width` front
matter and `params.page.width`/`navbar.width`/`footer.width` are ignored by design
(`_partials/utils/page-width-override.html` is deleted — never re-add it). The
**reading measure** is the one opt-in exception to uncapped prose: front matter
`readable: true` or site `params.readable.enable = true` adds `hextra-readable`
to `<main>` (resolved by `_partials/utils/page-readable.html`), which caps
paragraph/list line length at 75ch via `assets/css/components/readable.css`
while the page still spans 100% and tables/code/figures stay full-bleed.
`layout: wide` follows the same contract (100% page, TOC included, sidebar off
by default but `sidebar.show` still opts in).

Breakpoints: right TOC is Tailwind `xl` (≥1280px); sidebar→overlay is CSS media
`max-width: 48rem` (768px); `menu.js` guards null menu/sidebar containers.

## Gotchas (each was learned painfully — trust these)

1. **Hugo ≥0.165 strips HTML comments from output.** Debug template logic with
   visible text (e.g. a red `<p>`), never `<!-- comments -->`.
2. **Go templates: `len site.Menus.sidebar` crashes with a nil-reflection error
   when the menu is undefined.** Wrap: `default (slice) site.Menus.sidebar`. Also
   remember template `and`/`or` short-circuit, so the crash may surface only on
   some pages.
3. **`rsync --exclude='docs'` excludes at any depth** (it nuked `layouts/docs/`).
   When re-vendoring upstream, anchor patterns: `--exclude='/docs/'` etc.
4. **New `hx:` utility classes in layouts require a Tailwind rebuild** or they
   silently render unstyled. `npm run build:css` from repo root, then commit
   `assets/css/compiled/main.css` (it's vendored so users need no Node).
5. Hugo module resolution: exampleSite needs BOTH a `require` (placeholder
   pseudo-version ok) AND `replace => ../` in `exampleSite/go.mod`, otherwise
   `hugo` runs `go get <module>@upgrade` and tries to hit the real GitHub remote.
6. Hugo caches under `~/Library/Caches/hugo_cache/<project>/` — only resource
   caches, templates are never stale. If a change "doesn't take", suspect your
   own diff before suspecting the cache (`hugo --ignoreCache` to rule out).
7. `chrome-devtools-axi` (as of 2026-11) has a broken bridge: `eval`/`snapshot`
   fail ("pageId: expected number") and `screenshot` reports success but writes
   nothing. Use headless Chrome directly instead.
8. `hugo server` started from the theme root serves an empty "theme site" —
   always run it from `exampleSite/`.
9. **Classic macOS scrollbars shift raw pixel expectations by 15px** on
   scrolling pages (`innerWidth` 1440 vs `clientWidth` 1425). Assert against
   `clientWidth` (the probe's `cvw` token), not window width —
   `scripts/check-layout.sh` does exactly this.

## Syncing with upstream Hextra

Forked from imfing/hextra main as of 2026-11-16 (Tailwind v4.3 era; upstream
version line v0.13). To pull changes: clone upstream, diff per directory, and
re-apply only files not diverged by WideWeb (`assets/css/variables.css`,
`layouts/_partials/sidebar.html`, `layouts/_partials/toc.html`,
`assets/js/core/menu.js`, deleted `layouts/_partials/utils/page-width-override.html`;
all other layouts intentionally untouched). Upstream's own `docs/`, `tests/`,
`examples/`, `images/`, CI and playwright config are NOT in this repo. After any
CSS/template change: rebuild CSS, run both builds, re-run the probe table above.

## Conventions

- Templates: hextra style — `{%- -}}` whitespace control, `{{- define "name" -}}`
  partial templates, dict-passing partials; keep it.
- Test matrix changes: if you add/remove test pages, update this file's
  expectation table, README's matrix, and `exampleSite/content/_index.md`, and
  add the route to `scripts/check-layout.sh`.
- Commit compiled CSS with its source change; `.gitattributes` marks it
  linguist-generated.
- CI is `.github/workflows/ci.yml`: (1) compiled-CSS drift check, (2) `hugo
  --gc` of `exampleSite` failing on any ERROR/WARN, (3) `scripts/check-layout.sh`
  against a static server of the built site. Keep the expectations in
  AGENTS.md, README and the script in sync.
- Do not commit: `public/`, `resources/`, `node_modules/`, `hugo_stats.json`,
  `.hugo_build.lock` (see `.gitignore`).

## License

MIT fork of Hextra: preserve upstream copyright in `LICENSE`; keep the
`[original]` block in `theme.toml` intact.
