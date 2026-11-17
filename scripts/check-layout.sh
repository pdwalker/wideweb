#!/usr/bin/env bash
# WideWeb layout probe assertions — the machine-readable half of the
# "Verifying layout changes" workflow in AGENTS.md.
#
# Usage: scripts/check-layout.sh [BASE_URL] [CHROME_BINARY]
#   BASE_URL            defaults to http://localhost:1313 (hugo server -D)
#   CHROME_BINARY       defaults to macOS Chrome, then google-chrome/chromium
#   CHROME_EXTRA_FLAGS  extra flags for Chrome (CI sets --no-sandbox)
#
# Expects the site to be served already. Opens each route in headless Chrome
# at a 1440x900 window and asserts the live layout probe against the contract:
#
#   main + 256px x (visible sidebars) == documentElement.clientWidth
#
# i.e. the main area always consumes exactly what the sidebars surrender —
# independent of scrollbar width (classic macOS scrollbars eat 15px of
# clientWidth on scrolling pages, which is why raw main widths like 913 vs
# 928 in AGENTS.md's table differ). Reports every mismatch, exits 1 if any.

set -u
set -o pipefail

BASE="${1:-http://localhost:1313}"
CHROME="${2:-}"
if [ -z "$CHROME" ]; then
  if [ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
    CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
  elif command -v google-chrome >/dev/null 2>&1; then
    CHROME="$(command -v google-chrome)"
  elif command -v chromium >/dev/null 2>&1; then
    CHROME="$(command -v chromium)"
  else
    echo "error: no Chrome binary found; pass it as the second argument" >&2
    exit 2
  fi
fi

SIDEBAR_PX=256 # 16rem at 16px root font
TOLERANCE="${TOLERANCE:-3}"
FAILURES=0

probe_line() { # $1 = route → probe text extracted from the live DOM
  "$CHROME" --headless=new --disable-gpu --no-first-run --window-size=1440,900 \
    --virtual-time-budget=4000 ${CHROME_EXTRA_FLAGS:-} --dump-dom "$BASE$1" 2>/dev/null |
    grep -o 'viewport [0-9]*px  |  main [0-9]*px ([0-9]*% of window)[^<]*' | head -n 1
}

# expect <route> <left> <right> [prose_min prose_max]
#   left/right   expected "shown" | "collapsed" at this window width
#   prose_*      optional bounds on the width of the first paragraph in
#                .content (reading-measure assertion); pages without a
#                leading prose paragraph omit the bounds.
expect() {
  local route="$1" want_left="$2" want_right="$3"
  local prose_min="${4:-}" prose_max="${5:-}"
  local line vw cvw main left right prose=""
  line="$(probe_line "$route")"
  if [ -z "$line" ]; then
    printf 'FAIL %-24s no probe output (page missing or JS failed)\n' "$route"
    FAILURES=$((FAILURES + 1))
    return
  fi
  vw="$(printf '%s' "$line" | sed -E 's/viewport ([0-9]+)px.*/\1/')"
  main="$(printf '%s' "$line" | sed -E 's/.*main ([0-9]+)px.*/\1/')"
  left="$(printf '%s' "$line" | sed -E 's/.*left sidebar: ([a-z]+).*/\1/')"
  right="$(printf '%s' "$line" | sed -E 's/.*right sidebar: ([a-z]+).*/\1/')"
  cvw="$(printf '%s' "$line" | sed -E 's/.*cvw ([0-9]+)px.*/\1/')"
  if [ -n "$prose_min" ]; then
    if printf '%s' "$line" | grep -q 'prose [0-9]*px'; then
      prose="$(printf '%s' "$line" | sed -E 's/.*prose ([0-9]+)px.*/\1/')"
    else
      prose="missing"
    fi
  fi

  local sidebars=0
  [ "$left" = shown ] && sidebars=$((sidebars + 1))
  [ "$right" = shown ] && sidebars=$((sidebars + 1))
  local want_main=$((cvw - SIDEBAR_PX * sidebars))

  local ok=1 problems=""
  [ "$vw" = 1440 ] || { ok=0; problems="$problems viewport=${vw}px(want 1440)"; }
  [ "$left" = "$want_left" ] || { ok=0; problems="$problems left=${left}(want ${want_left})"; }
  [ "$right" = "$want_right" ] || { ok=0; problems="$problems right=${right}(want ${want_right})"; }
  if [ "$main" -lt $((want_main - TOLERANCE)) ] || [ "$main" -gt $((want_main + TOLERANCE)) ]; then
    ok=0; problems="$problems main=${main}px(want ${want_main}px=cvw-${SIDEBAR_PX}x${sidebars})"
  fi
  if [ -n "$prose_min" ]; then
    if [ "$prose" = missing ]; then ok=0; problems="$problems prose=missing"
    elif [ "$prose" -lt "$prose_min" ] || [ "$prose" -gt "$prose_max" ]; then
      ok=0; problems="$problems prose=${prose}px(want ${prose_min}..${prose_max})"
    fi
  fi

  local got_suffix="main ${main}px cvw=${cvw}px left=${left} right=${right}"
  [ -n "$prose" ] && got_suffix="$got_suffix prose=${prose}px"
  if [ "$ok" = 1 ]; then
    printf 'ok   %-24s %s\n' "$route" "$got_suffix"
  else
    printf 'FAIL %-24s %s →%s\n' "$route" "$got_suffix" "$problems"
    FAILURES=$((FAILURES + 1))
  fi
}

# static_check <route> <must-contain-ERE> [must-not-contain-ERE]
# For generated pages without a probe shortcode (term pages): asserts the
# markup contract instead of measured widths.
static_check() {
  local route="$1" want="$2" unwanted="${3:-}"
  local body
  body="$(curl -fsS "$BASE$route" 2>/dev/null)"
  if [ -z "$body" ]; then
    printf 'FAIL %-24s page not served\n' "$route"
    FAILURES=$((FAILURES + 1))
    return
  fi
  if printf '%s' "$body" | grep -qE "$want" &&
     { [ -z "$unwanted" ] || ! printf '%s' "$body" | grep -qE "$unwanted"; }; then
    printf 'ok   %-24s static markup contract\n' "$route"
  else
    printf 'FAIL %-24s static markup contract (want /%s/%s)\n' "$route" "$want" "${unwanted:+ , without /$unwanted/}"
    FAILURES=$((FAILURES + 1))
  fi
}

echo "== WideWeb layout probe @ 1440x900 against $BASE =="

# The sidebar contract (see AGENTS.md): every route must satisfy
# main == clientWidth − 256px per visible sidebar.
expect /tests/                shown shown
expect /tests/both-sidebars/  shown shown
expect /tests/left-only/      shown collapsed
expect /tests/right-only/     collapsed shown
expect /tests/no-sidebars/    collapsed collapsed 1200 1500
expect /tests/auto-collapse/  shown collapsed
expect /tests/wide/           collapsed shown
expect /tests/wide-no-toc/    collapsed collapsed
expect /tests/readable/       shown shown           400  800
expect /tests/toc-tags/       shown shown
expect /about/                collapsed shown
expect /blog/                 collapsed collapsed
expect /blog/hello/           collapsed shown
expect /blog/with-nav/        shown shown
expect /                      collapsed collapsed

# Taxonomy pages carry no probe shortcode; assert the markup contract instead
# (term.html: sidebar hardcoded off, TOC suppressed, page width uncapped).
static_check /tags/wideweb/ 'hextra-max-page-width' 'hextra-toc'

echo
if [ "$FAILURES" -gt 0 ]; then
  echo "$FAILURES check(s) failed."
  exit 1
fi
echo "All layout checks passed."
