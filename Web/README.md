# IELTS Master — Web (https://ielts.agriai.cloud)

The web version of IELTS Master, served from this Mac through a Cloudflare tunnel.

## First-time setup (once)
```bash
bash ~/Desktop/IELTSMaster/Web/scripts/publish.sh
```
Installs Node-based server + tunnel as background services (start at login, restart automatically).
Needs Node.js 18+ (`brew install node`) and cloudflared (installed automatically with Homebrew).

## After every change
```bash
bash ~/Desktop/IELTSMaster/Web/scripts/update.sh
```
Exports exams/lessons from the Swift app (`swift run IELTSExport`), rebuilds the interface, copies to
`~/Library/Application Support/IELTSMaster-Web`, restarts the server. User data is kept.

## Check
```bash
bash ~/Desktop/IELTSMaster/Web/scripts/status.sh
```

## Layout
- `server/` — Node server, no external packages (`server.js` routes, `lib.js` scoring/skills, `ai.js` Ollama, `users.js` CLI)
- `server/content/content.json` — exported from the Swift app; never edit by hand
- `client/` — React interface (`src/`), prebuilt into `client/dist/`
- `data/seed-db.json` — the initial two accounts (hashed passwords only); git-ignored
- Running data: `~/Library/Application Support/IELTSMaster-Web/data/db.json` (back this up)

## Accounts
- Admin page: **Users** in the sidebar (admin only): add, reset password, delete.
- Sessions never expire; they end on sign-out, password reset, or account deletion.
- Command line: `node server/users.js list|add|remove`
