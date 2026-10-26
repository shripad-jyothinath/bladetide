# Contributing to Bladetide

Thanks for taking the time to contribute. This project is an alpha-stage browser game with a real-time backend, so small, focused changes with tests are the easiest to review and merge.

By participating, you agree to follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## Ways to contribute

- **Report a bug** using the [bug report template](.github/ISSUE_TEMPLATE/bug_report.yml).
- **Propose a feature** using the [feature request template](.github/ISSUE_TEMPLATE/feature_request.yml).
- **Improve the game** — balance, feel, mobile layout, accessibility, art or audio.
- **Strengthen the backend** — netcode, tests, observability, deployment or security.
- **Improve the docs** — setup friction is a bug too.

If you are unsure whether an idea fits, open a discussion or an issue before writing a large patch.

## Development setup

### Requirements

- Node.js **22+** (Node 22 LTS or 24)
- npm 10+
- Optional: Docker (PostgreSQL/Redis), a Hedera **testnet** account

### Install and run

```bash
git clone https://github.com/shripad-jyothinath/bladetide.git
cd bladetide
npm install
npm run dev                 # website + API on http://127.0.0.1:8080
```

For the online arena, start a second terminal:

```bash
npm run room:dev            # ws://127.0.0.1:8787
```

See the [README](README.md) for controls, configuration and the Hedera testnet flow.

## Before opening a pull request

Run the full local check:

```bash
npm run game-core:test
npm run room:test
npm run api:test
npm run typecheck
```

All four must pass. If your change affects gameplay, also run `npm run game-core:sim` and include the relevant numbers or screenshots in the PR.

### Guidelines

- **Keep changes focused.** Avoid unrelated refactors or formatting-only churn.
- **Follow the existing style.** The client is intentionally dependency-free vanilla JavaScript; the server is TypeScript with explicit types at module boundaries.
- **Add tests for behavior changes.** Determinism, protocol, auth, ledger and intake changes need coverage in the nearest test suite.
- **Never commit secrets.** `.env`, operator keys, wallet keys and SQLite data are ignored. Use the `.env.example` files as templates.
- **Do not weaken the trust model.** The room server must validate inputs, rates, payload sizes and catalog IDs. The API must never trust client-authored rewards.
- **Keep the brand consistent.** User-facing copy uses **Bladetide**; legacy `fishio` identifiers are retained only where changing them would break stored sessions, data or encrypted wallets.

### Commit messages

Use short, imperative messages, preferably in the Conventional Commits style:

```text
feat(room): add reconnect grace for dropped sockets
fix(api): reject duplicate shop purchases
docs(readme): document the Hedera testnet setup
test(game-core): cover spawn protection edge cases
```

### Pull request checklist

- [ ] The change is scoped and described clearly.
- [ ] Tests were added or updated where behavior changed.
- [ ] `npm run game-core:test`, `npm run room:test`, `npm run api:test` and `npm run typecheck` pass.
- [ ] No secrets, local databases or generated build output are included.
- [ ] Screenshots or a short recording are attached for UI changes.
- [ ] Documentation is updated if configuration, commands or behavior changed.

## Security

Please do not report security vulnerabilities in public issues. See [SECURITY.md](SECURITY.md) for the private reporting process.

## License

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).
