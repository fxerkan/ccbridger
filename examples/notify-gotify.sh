#!/bin/sh
# notify_cmd example: push to a Gotify server, tap opens the relay conversation in the Claude app.
#   "notify_cmd": "GOTIFY_URL=https://gotify.example.com /path/to/examples/notify-gotify.sh"
# The app token is read from the macOS Keychain (service "ccb-gotify") unless GOTIFY_TOKEN is set:
#   security add-generic-password -U -s ccb-gotify -a ccb -w
# Needs curl and jq.
TOKEN="${GOTIFY_TOKEN:-$(security find-generic-password -s ccb-gotify -w 2>/dev/null)}"
[ -n "$GOTIFY_URL" ] && [ -n "$TOKEN" ] || exit 0
jq -n --arg t "$CCB_TITLE" --arg m "$CCB_BODY" --arg u "$CCB_URL" '{title:$t, message:$m, priority:8,
  extras:{"client::display":{contentType:"text/markdown"}, "client::notification":{click:{url:$u}}}}' |
curl -s -m 8 -A ccb/1 -H "X-Gotify-Key: $TOKEN" -H "Content-Type: application/json" -d @- \
  "${GOTIFY_URL%/}/message" >/dev/null
