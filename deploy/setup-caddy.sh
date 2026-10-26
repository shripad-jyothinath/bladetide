#!/usr/bin/env bash
# Safely add the Bladetide reverse-proxy sites to the EXISTING Caddy config.
# It never edits existing site blocks — it only writes a separate snippet file
# and adds one `import` line (with backup + validate + rollback).
#
# Usage:
#   bash deploy/setup-caddy.sh <api-domain> <room-domain>
#
# No DNS yet? sslip.io maps IPs automatically, so this works immediately:
#   bash deploy/setup-caddy.sh api.69-62-81-172.sslip.io room.69-62-81-172.sslip.io
set -euo pipefail

API_DOMAIN="${1:?usage: setup-caddy.sh <api-domain> <room-domain>}"
ROOM_DOMAIN="${2:?usage: setup-caddy.sh <api-domain> <room-domain>}"

if [ "$(id -u)" -ne 0 ]; then
  echo "error: run as root" >&2
  exit 1
fi

CADDYFILE="${CADDYFILE:-/etc/caddy/Caddyfile}"
SNIPPET_FILE="/etc/caddy/bladetide.caddy"
if [ ! -f "$CADDYFILE" ]; then
  echo "error: $CADDYFILE not found (set CADDYFILE=/path/to/Caddyfile)" >&2
  exit 1
fi

cat > "$SNIPPET_FILE" <<EOF
# Bladetide — managed by deploy/setup-caddy.sh; safe to delete.
${API_DOMAIN} {
	encode zstd gzip
	reverse_proxy 127.0.0.1:18080
}
${ROOM_DOMAIN} {
	reverse_proxy 127.0.0.1:18787
}
EOF
chmod 644 "$SNIPPET_FILE"
echo "[bladetide] wrote $SNIPPET_FILE"

BACKUP=""
if grep -q "bladetide.caddy" "$CADDYFILE"; then
  echo "[bladetide] $CADDYFILE already imports the Bladetide snippet"
else
  BACKUP="${CADDYFILE}.bladetide.bak.$(date +%s)"
  cp -a "$CADDYFILE" "$BACKUP"
  printf '\n# Bladetide sites (added by deploy/setup-caddy.sh)\nimport %s\n' "$SNIPPET_FILE" >> "$CADDYFILE"
  echo "[bladetide] added 'import $SNIPPET_FILE' (backup: $BACKUP)"
fi

if command -v caddy >/dev/null 2>&1; then
  if ! caddy validate --config "$CADDYFILE" >/tmp/bladetide-caddy-validate.log 2>&1; then
    echo "error: caddy validate failed — rolling back" >&2
    cat /tmp/bladetide-caddy-validate.log >&2
    if [ -n "$BACKUP" ]; then cp -a "$BACKUP" "$CADDYFILE"; fi
    exit 1
  fi
  echo "[bladetide] config validated"
fi

if systemctl reload caddy 2>/dev/null; then
  echo "[bladetide] caddy reloaded (systemd)"
elif command -v caddy >/dev/null 2>&1; then
  caddy reload --config "$CADDYFILE"
  echo "[bladetide] caddy reloaded (cli)"
else
  echo "error: could not reload caddy" >&2
  exit 1
fi

echo
echo "[bladetide] HTTPS endpoints (certificates issue on first request):"
echo "  https://${API_DOMAIN}/healthz"
echo "  https://${ROOM_DOMAIN}/healthz"
