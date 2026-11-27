#!/usr/bin/env bash
# Updates the published site with the latest code and content, then restarts it.
#   bash ~/Desktop/IELTSMaster/Web/scripts/update.sh
set -euo pipefail
source "$(dirname "$0")/common.sh"
need_node
SKIP_EXPORT=0
case "${1:-}" in
  --skip-export) SKIP_EXPORT=1 ;;
  "") ;;
  *) echo "Usage: $0 [--skip-export]" >&2; exit 2 ;;
esac

say "1/4 Exporting content from the Swift app (exams, lessons)…"
if [ "$SKIP_EXPORT" = 1 ]; then
  echo "   Publishing the prepared, validated JSON content without re-exporting."
elif command -v swift >/dev/null; then
  (cd "$PROJECT" && CLANG_MODULE_CACHE_PATH=/tmp/clang-module-cache swift run -c release IELTSExport "$WEB_SRC/server/content" 2>&1 | tail -2) \
    || { echo "Content export failed; publication stopped." >&2; exit 1; }
else
  echo "Swift not found. Prepare and validate JSON, then use --skip-export." >&2; exit 1
fi
node "$PROJECT/Scripts/sync_native_content.mjs"

say "2/4 Building the web interface…"
if command -v npm >/dev/null; then
  if [ ! -d "$WEB_SRC/client/node_modules" ]; then
    (cd "$WEB_SRC/client" && npm ci --silent --no-audit --no-fund)
  fi
  (cd "$WEB_SRC/client" && npm run build)
else
  echo "npm not found; publication stopped." >&2; exit 1
fi
node --check "$WEB_SRC/server/server.js"
node --check "$WEB_SRC/server/lib.js"
python3 "$PROJECT/Scripts/check_completed_bank.py"

say "3/4 Copying to the running location…"
mkdir -p "$RUNTIME/server" "$RUNTIME/client" "$RUNTIME/data"
# Preserve the previous application files for rollback; do not copy or replace user data.
BACKUP="$RUNTIME/backups/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$BACKUP"
cp -R "$RUNTIME/server" "$BACKUP/server"
if [ -d "$RUNTIME/client/dist" ]; then cp -R "$RUNTIME/client/dist" "$BACKUP/client-dist"; fi
if [ -f "$RUNTIME/package.json" ]; then cp "$RUNTIME/package.json" "$BACKUP/package.json"; fi
rsync -a --delete "$WEB_SRC/server/" "$RUNTIME/server/"
rsync -a --delete "$WEB_SRC/client/dist/" "$RUNTIME/client/dist/"
cp "$WEB_SRC/package.json" "$RUNTIME/package.json"
if [ ! -f "$RUNTIME/data/db.json" ] && [ -f "$WEB_SRC/data/seed-db.json" ]; then
  cp "$WEB_SRC/data/seed-db.json" "$RUNTIME/data/db.json"
  echo "   Created the account database from the seed (2 accounts)."
fi

say "4/4 Restarting the server…"
if launchctl print "gui/$(id -u)/$SERVER_LABEL" >/dev/null 2>&1; then
  launchctl kickstart -k "gui/$(id -u)/$SERVER_LABEL"
  sleep 1.5
  if [ "$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/api/me")" = "401" ]; then
    say "Updated. Live at https://$HOSTNAME_PUBLIC"
  else
    say "The server didn't answer. Previous application files: $BACKUP. See: $RUNTIME/server.log"
    exit 1
  fi
else
  echo "   The background service isn't installed yet. Run:  bash \"$WEB_SRC/scripts/publish.sh\""
  exit 1
fi
