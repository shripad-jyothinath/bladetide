# Security policy

## Supported versions

Bladetide is an **alpha project running on Hedera testnet only**. There is no mainnet deployment and no real-money custody. Security fixes are applied to the `main` branch; older commits and forks are not supported.

## Reporting a vulnerability

**Do not open a public issue for security problems.**

Use GitHub's private vulnerability reporting:

1. Open the repository's **Security** tab.
2. Select **Report a vulnerability**.
3. Include reproduction steps, affected endpoints or files, impact and any suggested fix.

If private reporting is unavailable, contact the maintainer through the GitHub profile linked in the repository and ask for a private channel. Please allow a reasonable window for a fix before public disclosure.

## In scope

- Authentication, session handling and cross-site cookie behavior.
- The HMAC-signed room-server match intake (`POST /internal/matches`).
- Server-authoritative validation in `apps/room-server` (input, rate limits, payload limits, ticket verification).
- `$GOLD` ledger, shop and reward logic, including duplicate-spend and replay resistance.
- Custodial wallet encryption and wallet-link proof verification.
- XSS or injection in the static client, API responses or NFT metadata.
- Secret leakage in the repository, logs or error responses.

## Out of scope

- Findings that require a compromised device, browser extension or Hedera operator key.
- Testnet-only token balances or NFTs, which have no real-world value.
- Denial of service through volumetric traffic at the hosting layer.
- Social engineering, phishing or physical attacks.
- Issues in third-party services (Hedera, Vercel, npm) that are not caused by this code.

## Deployment notes

- The development fallback for `WALLET_ENCRYPTION_KEY` is intentionally loud and insecure. Set a strong random key before exposing the API to anyone.
- `INTERNAL_HMAC_SECRET` must be a long random value shared only by the API and room server.
- The API binds to `127.0.0.1` by default and should sit behind a TLS-terminating reverse proxy such as Caddy.
- Testnet keys must never be reused on mainnet.

## Safe harbor

Good-faith security research that respects privacy, avoids data destruction and follows this policy will not be pursued or reported. Please give the maintainer a chance to fix the issue first.
