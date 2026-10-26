# Bladetide room server

Authoritative real-time arena. One process hosts one 4000×4000 map with a configurable number of **human** players. The server runs the same simulation as the browser (`@bladetide/game-core` loads `apps/web/src/*.js` in a headless VM) at a fixed 60 Hz and owns every position, kill and pickup. Clients send inputs only.

## Run

```bash
npm install
npm run room:dev            # from the repo root → ws://127.0.0.1:8787
curl http://127.0.0.1:8787/healthz
```

Then serve the game (`npm run dev` → <http://127.0.0.1:8080>) and press **PLAY ONLINE**. Point a client at a different arena with `?room=ws://host:port` or `window.BLADETIDE_ROOM_URL`.

## Configuration

| Variable | Default | Meaning |
| --- | --- | --- |
| `ROOM_HOST` / `ROOM_PORT` | `0.0.0.0` / `8787` | Listen address. |
| `ROOM_MAX_PLAYERS` | `16` | Humans per arena (no bots, ever). |
| `ROOM_TICK_RATE` | `60` | Simulation frames per second. |
| `ROOM_SNAPSHOT_RATE` | `20` | Snapshots per second per client. |
| `ROOM_SEED` | `0` (random) | Deterministic arena seed. |
| `ROOM_RECONNECT_GRACE_MS` | `20000` | Keep a disconnected player's fish before removing it. |
| `ROOM_MAX_MSGS_PER_SEC` | `120` | Flood limit per connection. |
| `ROOM_NAME` | `reef-1` | Label in logs and health output. |
| `ROOM_API_URL` | empty | API base URL for signed match intake. |
| `INTERNAL_HMAC_SECRET` | dev placeholder | Shared secret for `POST /internal/matches`; must match the API. |

## Protocol (JSON over WebSocket; binary lands in M2)

**Client → server:** `hello` (name, cosmetics, workshop upgrades, viewport, optional reconnect token and signed room ticket), `input` `{seq, a (angle), b (boost)}` at 30 Hz, `respawn`, `ping`, `leave`.

**Server → client:** `welcome` / `spawn` (full state), `snap` at 20 Hz (`you`, player states, delta-encoded nearby `add`/`del` food/chests/power-ups, `ev` events, periodic `lb` leaderboard), `match_end`, `match_receipt`, `pong`, `bye`.

**Trust model:** the server validates every message — finite angle, monotonic sequence, name length, catalog IDs, upgrade caps, message rate and an 8 KB payload limit. Clients cannot set positions, kills or rewards. A valid room ticket links an arena session to an account; on death the room signs the result with HMAC and posts it to the API.

## Tests

```bash
npm run room:test           # 16 tests: room behaviour, protocol, reconnect, flood, intake + real 2-client WebSocket game
npm run room:typecheck
```

## Scope and limits

- Continuous endless arena (respawn on death). Round-based matches are planned for M2.
- One room per process; no matchmaking, room director or Redis presence yet (M3).
- Online results are attested through the API when `ROOM_API_URL` and `INTERNAL_HMAC_SECRET` are configured; guests play without a ticket.
- JSON snapshots with radius-based interest management; all players are broadcast.
