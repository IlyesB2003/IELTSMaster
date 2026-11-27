# IELTS Master

An IELTS Academic preparation platform with a native macOS application and a React web interface. It brings together practice for Reading, Listening, Writing and Speaking, learning resources, progress tracking and AI-assisted study.

## Features

- English and Arabic interface support.
- Mock examinations and focused practice activities.
- Grammar, vocabulary and academic English study resources.
- Progress tracking, adaptive study plans and a mistake notebook.
- AI teacher integration with optional local Ollama models.
- Native macOS audio and pronunciation tools.

Practice scores and AI feedback are estimates, not official IELTS results. This is an independent educational project.

## Native macOS application

Requires macOS 14 or later and a Swift 5.9-compatible toolchain (Xcode or Command Line Tools).

From the repository root:

```bash
swift run IELTSMaster
```

Verification commands:

```bash
swift test
swift run IELTSTestRunner
```

To package the application:

```bash
bash Scripts/build_and_package.sh
```

Generated application bundles and disk images are written to `dist/` and excluded from Git.

## Web application

Requires Node.js 18 or later and npm, as declared by the project.

Build the interface:

```bash
cd Web/client
npm ci
npm run build
cd ..
npm start
```

Open **http://localhost:8790**. The server creates a local database under `Web/data/`. No existing accounts or user progress are included in this repository.

Create your own administrator account from `Web/`:

```bash
node server/users.js add "First" "Last" "admin@example.com" "REPLACE_WITH_YOUR_PASSWORD" admin
```

Replace the example details and password before running the command. The CLI accepts the password as a command argument.

For frontend development, run the server from `Web/` with `PORT=8791 npm start`, then run `npm run dev` from `Web/client/` in another terminal. Vite proxies `/api` requests to port 8791.

Optional server settings: `PORT`, `IELTS_DATA` (database path), and `OLLAMA_URL` (default `http://127.0.0.1:11434`).

The Cloudflare scripts under `Web/scripts/` are specific to the original deployment. Review their domain and service settings before using them for a different deployment.

## Repository structure

| Directory | Contents |
| --- | --- |
| `Sources/` | Native Swift application, core services and content exporter |
| `Tests/` | Swift tests |
| `Web/client/` | React and Vite interface |
| `Web/server/` | Node.js server and web learning content |
| `Content/` | Content authoring sources |
| `Scripts/` | Build, content generation and audit utilities |
| `Docs/` | Architecture, audits and educational source notes |

Some documents under `Docs/` are historical snapshots and may describe earlier content counts.

## Publishing

See [GITHUB_SETUP_AR.md](GITHUB_SETUP_AR.md) for Arabic upload instructions. Local credentials, account databases, build outputs and old archives are excluded from this prepared copy.

No open-source license has been selected for this prepared copy.
