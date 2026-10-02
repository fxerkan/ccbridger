#!/bin/sh
# Render the hero options to PNG (2x). Needs Google Chrome.
cd "$(dirname "$0")" || exit 1
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
for n in 1 2 3; do
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=2 \
    --window-size=1000,420 --screenshot="$PWD/hero-$n.png" "file://$PWD/hero-$n.html" >/dev/null 2>&1
done
