# Development guide

This is the maintainer-facing state of the project: how to run it, where the important code lives, what is finished, and what is still missing. For the high-level product overview, start with the [README](../README.md). For system design, read [ARCHITECTURE.md](ARCHITECTURE.md).

## Current state

Implemented and playable:

- Offline practice with bots, 25 weapons, 24 fish species, 12 hats, 4 maps, 15 challenge stages and frenzy mode.
- Accounts with email/password auth, sliding cookie sessions and cross-device save sync.
- `$GOLD` ledger, tiered shop, workshop upgrades, daily gift, lucky wheel, stage rewards and leaderboards.
- Authoritative online arena over WebSocket: prediction, reconciliation, interpolation, interest-managed food/chests, reconnect grace and kill feed.
- Hedera testnet integration: HCS match receipts, HTS `$GOLD`, cosmetic NFTs, custodial wallets, wallet linking and edition limits.
- Signed online result intake from the room server (M4).
- Headless deterministic simulation with regression tests.

Still open:

- M2 binary protocol and higher player counts.
- Matchmaking, multiple rooms and Redis-backed presence.
- PostgreSQL adapter (the schema and Docker setup exist; the runtime still uses SQLite).
- WalletConnect signing for spending from externally linked wallets.
- Marketplace, tournaments and mainnet hardening.
- More mobile performance work and accessibility polish.

## Repository map

```text
apps/web/                  static client
  index.html               menu, HUD, modals and game bootstrap
  src/game.js              main engine, collision, maps, game loop
  src/entities.js          fish, weapons, blades, hats
  src/food.js              sushi, power-ups, chests
  src/shop.js              catalog, tiers, saves, prices
  src/ai.js                offline bots (never online)
  src/net.js               online client and reconnect logic
  src/api.js               accounts, saves, gold, NFTs, leaderboard
  src/item3d.js            Three.js item previews + 2D fallback

apps/api/                  Fastify + TypeScript
  src/auth.ts              sessions, cookies, password hashing
  src/save.ts              account save sync
  src/config.ts            env parsing and DB path resolution
  src/hedera/              HCS, HTS, wallets, tickets, shop, receipts
  db/schema.sql            PostgreSQL schema
  db/sqlite/schema.sql     local SQLite schema

apps/room-server/          authoritative arena
  src/room.ts              simulation loop, validation, intake
  src/protocol.ts          message types and sanitizers
  src/tickets.ts           cross-app room-ticket verification

packages/game-core/        headless deterministic harness
  src/harness.js           vm loader, seeded RNG, virtual timers
  bin/sim.js               CLI match runner

docs/                      architecture, plans, ADR, assets
deploy/                    Caddy, systemd, VPS runbook
archive/                   old prototype, not maintained
```

## Local setup

```bash
npm install
npm run dev                 # website + API on http://127.0.0.1:8080
```

The API serves `apps/web` from the same origin, so cookies and save sync work without CORS. Guests need no account. The local SQLite database is created at `apps/api/data/bladetide.db`.

For online play, start the room server in a second terminal:

```bash
npm run room:dev            # ws://127.0.0.1:8787
```

Open two tabs, enter names and press **PLAY ONLINE**. Use `?room=ws://host:port` to point a client at another arena.

### Requirements

- Node.js 22+ (Node 22 LTS and 24 are tested).
- npm 10+.
- Optional: Docker for PostgreSQL/Redis, and a Hedera testnet account for chain features.

## Commands

| Command | What it does |
| --- | --- |
| `npm run dev` | API + static site on `:8080`. |
| `npm run room:dev` | Authoritative arena on `:8787`. |
| `npm run web:serve` | Static-only server on `:8137` (no accounts). |
| `npm run game-core:sim` | Deterministic 5-minute bot match with a summary. |
| `npm run game-core:test` | Determinism, balance and progression tests. |
| `npm run room:test` | Protocol, prediction, reconnect, flood and two-client tests. |
| `npm run api:test` | Auth, sessions, saves, ledger, shop, tickets and intake tests. |
| `npm run typecheck` | TypeScript for the API and room server. |
| `npm run hedera:setup -- --write-env` | Create/reuse HCS topic, `$GOLD` token and NFT collection. |
| `npm run hedera:wallet` | Create or inspect a Hedera wallet. |
| `npm run hedera:claim` | Repair pending token/NFT airdrops. |

## Configuration

Copy the example files before customizing:

```bash
cp apps/api/.env.example apps/api/.env
cp apps/room-server/.env.example apps/room-server/.env
```

The game runs with no variables. Important settings:

- `BLADETIDE_DB_PATH` — SQLite path; `FISHIO_DB_PATH` is a legacy alias.
- `INTERNAL_HMAC_SECRET` — must match between API and room server.
- `WEB_ORIGIN` — comma-separated origins for cross-site cookies.
- `HEDERA_*` — operator credentials and auto-created resource IDs.
- `WALLET_ENCRYPTION_KEY` — required for custodial wallets in anything other than local testing.
- `PUBLIC_BASE_URL` — public URL used in NFT metadata.

Never commit `.env`, `apps/api/data/`, operator keys or wallet keys.

## Branding and legacy identifiers

The project was renamed from **Fish.IO** to **Bladetide**. New code and data use `bladetide`, but several `fishio` names are intentionally preserved for compatibility:

- A pre-rename SQLite file is used automatically when no new database exists.
- The old `fishio_session` cookie is accepted and replaced on renewal.
- Guest save, guide, compact-UI and room-token keys are migrated on first read.
- The old intake content type and signature header are accepted.
- Wallet encryption keeps legacy salts so existing custodial wallets still decrypt.

Do not rename cryptographic salts or the dev fallback key without a migration. Do not remove the legacy fallbacks until the deployed data has been migrated.

## Gameplay notes

- Offline practice is the full single-player experience; online is a continuous humans-only arena (respawn on death).
- Online bots and bosses are disabled server-side.
- The blade is mounted on the snout. Side/rear hits slice; head-on blades parry.
- Match modes: classic 10 minutes and frenzy 2 minutes (online is endless until death).
- Prices and rewards are computed on the server for signed-in players. Guest gold is practice-only and cannot convert.

## Debugging tips

- The live game object is available as the bare global `game` inside the page (not `window.game` in all contexts).
- `browser.evaluate` can drive deterministic steps with `for (let i=0;i<900;i++){ game.update(1); }`.
- Headless/occluded browsers may throttle `requestAnimationFrame`; step the simulation manually when testing.
- The room server logs invalid tickets and rejected messages; check its terminal output first for online issues.
- The API logs every request in development. Tests use temporary SQLite files and do not touch your local data.
- The client falls back to 2D/emoji item icons if WebGL is unavailable. This is also useful for deterministic screenshots.

## Hedera testnet checklist

1. Create a funded testnet account at <https://portal.hedera.com>.
2. Add `HEDERA_OPERATOR_ID`, `HEDERA_OPERATOR_KEY` and `HEDERA_NETWORK=testnet` to `apps/api/.env`.
3. Run `npm run hedera:setup -- --write-env` and restart the API.
4. Verify a match produces an HCS receipt link and a `$GOLD` ledger credit.
5. Optionally run `npm run hedera:setup -- --demo-account` for an end-to-end proof.

Testnet only. Do not reuse these keys on mainnet.

## Repository settings

Keep the public repository metadata in sync with the brand:

- **Description:** “Bladetide — a server-authoritative multiplayer .io arena with accounts, live leaderboards, and optional Hedera testnet rewards.”
- **Homepage:** the current live deployment URL.
- **Topics:** `browser-game`, `io-game`, `multiplayer`, `websocket`, `hedera`, `web3`, `canvas`, `typescript`, `fastify`, `nodejs`, `html5-game`.
- **Social preview:** upload [`docs/assets/brand/social-preview.png`](assets/brand/social-preview.png) under **Settings → General → Social preview**.
- **Discussions:** enabled if the issue templates link to them.

The repository slug is `bladetide`; GitHub redirects the old `fish-game` URL, but the Vercel deployment keeps its original slug until the project is renamed there.

## Deployment

The VPS runbook is in [deploy/README.md](../deploy/README.md). In short:

- Vercel serves `apps/web`; `apps/web/vercel.json` proxies `/api` to the VPS.
- Caddy terminates TLS and proxies the API (`:18080`) and room server (`:18787`).
- systemd units and a self-contained installer live under `deploy/`.
- Re-running `deploy/server-install.sh` is the update path; `.env` files are preserved.

## Tests before a release

```bash
npm run game-core:test
npm run room:test
npm run api:test
npm run typecheck
```

Then smoke-test in a browser:

1. Guest practice starts and controls work.
2. Sign up, play a match, refresh, and confirm progress restores.
3. Two tabs join the online arena and see each other.
4. Kill a fish online and confirm the result/receipt path (when Hedera is enabled).
5. Open the shop, buy an affordable item, and confirm the balance debits once.
6. Check the mobile layout in a narrow viewport.

## History

The original game prototype was built as a browser `.io` game and later extended into the server-authoritative, account-based, Hedera-integrated project in this repository. The old prototype is kept in [`archive/`](../archive/) and is not maintained.
