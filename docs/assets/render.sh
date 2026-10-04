#!/bin/sh
# Render each *.html to PNG at 2x. Needs Google Chrome; web fonts load over the network.
# Per-file canvas size comes from a `<!-- render WIDTHxHEIGHT -->` hint in the HTML
# (defaults to 1000x420). icon.html renders to a transparent PNG.
cd "$(dirname "$0")" || exit 1
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
# Default set: the figures + icon (html name maps 1:1 to png). hero-7/og ship as
# jpg/renamed-png from a separate step — pass them explicitly if you need to re-render.
for f in ${@:-fig-*.html icon.html}; do
  size=$(grep -oE 'render [0-9]+x[0-9]+' "$f" | head -1 | cut -d' ' -f2)
  [ -z "$size" ] && size=1000x420
  bg=""; case "$f" in icon.html) bg="--default-background-color=00000000";; esac
  "$CHROME" --headless=new --disable-gpu --no-sandbox --hide-scrollbars $bg \
    --force-device-scale-factor=2 --virtual-time-budget=6000 \
    --window-size="${size%x*},${size#*x}" \
    --screenshot="$PWD/${f%.html}.png" "file://$PWD/$f" >/dev/null 2>&1
done
