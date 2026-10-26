# Documentation

Start here depending on what you need:

| Document | Use it for |
| --- | --- |
| [README](../README.md) | Product overview, screenshots, quick start, controls and feature list. |
| [ARCHITECTURE](ARCHITECTURE.md) | System design, netcode, trust boundaries, data model and failure modes. |
| [DEVELOPMENT](DEVELOPMENT.md) | Maintainer setup, commands, debugging notes, current state and gaps. |
| [MULTIPLAYER_PLAN](MULTIPLAYER_PLAN.md) | Room-server roadmap and protocol phases (M0–M5). |
| [DATABASE_PLAN](DATABASE_PLAN.md) | PostgreSQL/Redis schema, integrity rules and migration phases. |
| [HEDERA_PLAN](HEDERA_PLAN.md) | Wallets, `$GOLD`, NFTs, HCS attestation and the chain roadmap. |
| [ADR 0001](adr/0001-headless-game-core.md) | Why the simulation runs in a Node `vm` harness. |
| [Deployment](../deploy/README.md) | VPS, Caddy, systemd and Vercel runbook. |
| [Room server](../apps/room-server/README.md) | Protocol, configuration and limits for the arena process. |

## Conventions

- Plans describe intended work; the [README](../README.md) and [DEVELOPMENT](DEVELOPMENT.md) describe what is actually implemented.
- When a plan and the code disagree, the code wins. Update the plan or open an issue.
- User-facing brand: **Bladetide**. Legacy `fishio` identifiers are documented in [ARCHITECTURE](ARCHITECTURE.md#legacy-identifiers).
- Screenshots and brand assets live in [`assets/`](assets/).
