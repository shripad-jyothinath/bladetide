# Changelog

All notable changes to this project are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project aims to follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Professional project documentation: architecture guide, maintainer guide, contribution guide, security policy, code of conduct, issue/PR templates and CI.
- Brand assets (banner, emblem, social preview) and product screenshots.
- Legacy compatibility for sessions, local saves, room tokens, database paths and wallet encryption after the rename.

### Changed

- Renamed the project and repository to **Bladetide**.
- Updated the npm workspace scope to `@bladetide/*`.
- Updated deployment units and paths to `bladetide`.
- Upgraded `better-sqlite3` to 12.x for Node 22/24 support.

### Fixed

- Restored the in-repo documentation flow by replacing the internal handoff note with a maintainer-oriented development guide.

## [0.1.0] — 2026-10-26

### Added

- Server-authoritative WebSocket arena with client prediction, reconciliation, interpolation and reconnect grace.
- Offline practice mode with bots, 25 weapons, 24 fish, 12 hats, 4 maps and 15 stages.
- Email/password accounts, cross-device saves and leaderboards.
- `$GOLD` ledger, tiered shop, workshop upgrades, daily rewards, lucky wheel and stage rewards.
- Hedera testnet integration: HCS match receipts, HTS `$GOLD`, cosmetic NFTs, custodial wallets and wallet linking.
- Signed online result intake (M4).
- Deterministic headless simulation and regression tests.

[Unreleased]: https://github.com/shripad-jyothinath/bladetide/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/shripad-jyothinath/bladetide/releases/tag/v0.1.0
