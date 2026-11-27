#!/usr/bin/env bash
# Shows whether the IELTS Master site, tunnel and AI model are running.
source "$(dirname "$0")/common.sh"
printf "Server  : "; [ "$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/api/me")" = "401" ] && echo running || echo "NOT running (see $RUNTIME/server.log)"
printf "Public  : "; C="$(curl -s -o /dev/null -w '%{http_code}' --max-time 8 "https://$HOSTNAME_PUBLIC/api/me")"; [ "$C" = "401" ] && echo "https://$HOSTNAME_PUBLIC reachable" || echo "not reachable (HTTP $C; see $RUNTIME/tunnel.log)"
printf "Ollama  : "; curl -s --max-time 3 http://127.0.0.1:11434/api/tags | grep -o '"name":"[^"]*"' | head -3 | tr '\n' ' ' || true; echo
