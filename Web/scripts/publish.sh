#!/usr/bin/env bash
# One-time setup: installs the site as a background service on this Mac and publishes it at
# https://ielts.agriai.cloud through its own Cloudflare tunnel (your other tunnels are not touched).
#   bash ~/Desktop/IELTSMaster/Web/scripts/publish.sh
set -euo pipefail
source "$(dirname "$0")/common.sh"
need_node

bash "$WEB_SRC/scripts/update.sh" || true

say "Installing the web server as a background service (starts at login, restarts if it stops)…"
mkdir -p "$LA"
cat > "$LA/$SERVER_LABEL.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>$SERVER_LABEL</string>
  <key>ProgramArguments</key><array><string>$NODE</string><string>$RUNTIME/server/server.js</string></array>
  <key>WorkingDirectory</key><string>$RUNTIME</string>
  <key>EnvironmentVariables</key><dict><key>PORT</key><string>$PORT</string><key>IELTS_DATA</key><string>$RUNTIME/data/db.json</string></dict>
  <key>RunAtLoad</key><true/><key>KeepAlive</key><true/>
  <key>StandardOutPath</key><string>$RUNTIME/server.log</string><key>StandardErrorPath</key><string>$RUNTIME/server.log</string>
</dict></plist>
PLIST
launchctl bootout "gui/$(id -u)/$SERVER_LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$LA/$SERVER_LABEL.plist"
sleep 1.5
CODE="$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/api/me" || true)"
[ "$CODE" = "401" ] && say "Server running on http://127.0.0.1:$PORT" || { say "Server did not start (HTTP $CODE). See $RUNTIME/server.log"; exit 1; }

say "Publishing at https://$HOSTNAME_PUBLIC via Cloudflare…"
need_cloudflared
if [ ! -f "$HOME/.cloudflared/cert.pem" ]; then
  say "A browser window will open: choose the agriai.cloud domain and click Authorize."
  "$CF" tunnel login
fi
if ! "$CF" tunnel info "$TUNNEL_NAME" >/dev/null 2>&1; then
  "$CF" tunnel create "$TUNNEL_NAME"
fi
TUNNEL_ID="$("$CF" tunnel list -o json | "$NODE" -e 'let d="";process.stdin.on("data",c=>d+=c).on("end",()=>{const t=JSON.parse(d).find(x=>x.name===process.argv[1]);console.log(t?t.id:"")})' "$TUNNEL_NAME")"
[ -z "$TUNNEL_ID" ] && { say "Could not find the tunnel id."; exit 1; }
"$CF" tunnel route dns --overwrite-dns "$TUNNEL_NAME" "$HOSTNAME_PUBLIC" || true
CFG="$HOME/.cloudflared/$TUNNEL_NAME.yml"
cat > "$CFG" <<YML
tunnel: $TUNNEL_ID
credentials-file: $HOME/.cloudflared/$TUNNEL_ID.json
ingress:
  - hostname: $HOSTNAME_PUBLIC
    service: http://127.0.0.1:$PORT
  - service: http_status:404
YML
cat > "$LA/$TUNNEL_LABEL.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>$TUNNEL_LABEL</string>
  <key>ProgramArguments</key><array><string>$CF</string><string>tunnel</string><string>--config</string><string>$CFG</string><string>run</string><string>$TUNNEL_NAME</string></array>
  <key>RunAtLoad</key><true/><key>KeepAlive</key><true/>
  <key>StandardOutPath</key><string>$RUNTIME/tunnel.log</string><key>StandardErrorPath</key><string>$RUNTIME/tunnel.log</string>
</dict></plist>
PLIST
launchctl bootout "gui/$(id -u)/$TUNNEL_LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$LA/$TUNNEL_LABEL.plist"
say "Waiting for https://$HOSTNAME_PUBLIC …"
for i in $(seq 1 20); do
  CODE="$(curl -s -o /dev/null -w '%{http_code}' "https://$HOSTNAME_PUBLIC/api/me" || true)"
  [ "$CODE" = "401" ] && { say "Live: https://$HOSTNAME_PUBLIC"; exit 0; }
  sleep 3
done
say "The tunnel is running but the site isn't reachable yet (DNS can take a few minutes). Check: $RUNTIME/tunnel.log"
