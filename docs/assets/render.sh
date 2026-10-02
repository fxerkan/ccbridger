#!/bin/sh
# Render every hero-N.html to hero-N.png (2x). Needs Google Chrome; options 4-6 load web fonts.
cd "$(dirname "$0")" || exit 1
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
for f in ${@:-hero-*.html}; do
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=2 \
    --virtual-time-budget=6000 --window-size=1000,420 \
    --screenshot="$PWD/${f%.html}.png" "file://$PWD/$f" >/dev/null 2>&1
done
