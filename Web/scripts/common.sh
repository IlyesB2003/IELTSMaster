# Shared settings for the IELTS Master web scripts.
WEB_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"          # ~/Desktop/IELTSMaster/Web
PROJECT="$(cd "$WEB_SRC/.." && pwd)"                                  # ~/Desktop/IELTSMaster
RUNTIME="$HOME/Library/Application Support/IELTSMaster-Web"           # running copy (background services can't read Desktop)
HOSTNAME_PUBLIC="ielts.agriai.cloud"
PORT=8790
TUNNEL_NAME="ielts-master"
LA="$HOME/Library/LaunchAgents"
SERVER_LABEL="cloud.agriai.ielts.server"
TUNNEL_LABEL="cloud.agriai.ielts.tunnel"
say() { printf "\033[1m%s\033[0m\n" "$*"; }
# Finds Node.js 18+, or downloads the official build into the runtime folder (no Homebrew, no admin rights).
need_node() {
  NODE=""
  for c in "$(command -v node 2>/dev/null)" /opt/homebrew/bin/node /usr/local/bin/node "$RUNTIME/node/bin/node"; do
    if [ -n "$c" ] && [ -x "$c" ] && [ "$("$c" -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)" -ge 18 ]; then NODE="$c"; break; fi
  done
  if [ -z "$NODE" ]; then
    local ver=v22.12.0 arch; arch="$( [ "$(uname -m)" = arm64 ] && echo arm64 || echo x64 )"
    say "Node.js not found: downloading Node.js $ver for this Mac (about 45 MB, one time)…"
    mkdir -p "$RUNTIME"
    curl -fL --progress-bar "https://nodejs.org/dist/$ver/node-$ver-darwin-$arch.tar.gz" | tar -xz -C "$RUNTIME"
    rm -rf "$RUNTIME/node" && mv "$RUNTIME/node-$ver-darwin-$arch" "$RUNTIME/node"
    NODE="$RUNTIME/node/bin/node"
  fi
  export PATH="$(dirname "$NODE"):$PATH"   # makes the matching npm available too
}

# Finds cloudflared, or downloads Cloudflare's official build into the runtime folder.
need_cloudflared() {
  CF="$(command -v cloudflared 2>/dev/null || true)"
  for c in /opt/homebrew/bin/cloudflared /usr/local/bin/cloudflared "$RUNTIME/bin/cloudflared"; do [ -z "$CF" ] && [ -x "$c" ] && CF="$c"; done
  if [ -z "$CF" ]; then
    local arch; arch="$( [ "$(uname -m)" = arm64 ] && echo arm64 || echo amd64 )"
    say "cloudflared not found: downloading it from Cloudflare (one time)…"
    mkdir -p "$RUNTIME/bin"
    curl -fL --progress-bar "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-$arch.tgz" | tar -xz -C "$RUNTIME/bin"
    chmod +x "$RUNTIME/bin/cloudflared"
    CF="$RUNTIME/bin/cloudflared"
  fi
}
