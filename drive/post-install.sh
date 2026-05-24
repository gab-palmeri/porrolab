#!/usr/bin/env bash
set -euo pipefail

ENV_FILE=".env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE"
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

: "${SEAFILE_SERVER_HOSTNAME:?SEAFILE_SERVER_HOSTNAME missing in .env}"
: "${SEAFILE_VOLUME:?SEAFILE_VOLUME missing in .env}"
: "${SEAFILE_MYSQL_VOLUME:?SEAFILE_MYSQL_VOLUME missing in .env}"
: "${SEAFILE_CADDY_VOLUME:?SEAFILE_CADDY_VOLUME missing in .env}"
: "${SEADOC_VOLUME:?SEADOC_VOLUME missing in .env}"

DOMAIN="$SEAFILE_SERVER_HOSTNAME"

# If the script is launched with sudo, use the original user.
# Otherwise, use the current user.
RUN_USER="${SUDO_USER:-$(id -un)}"

echo "==> Creating folders"
sudo mkdir -p \
  "$SEAFILE_VOLUME/seafile" \
  "$SEAFILE_MYSQL_VOLUME" \
  "$SEAFILE_CADDY_VOLUME" \
  "$SEADOC_VOLUME"

echo "==> Fixing permissions for NON_ROOT=true"
sudo chown -R "$RUN_USER:$RUN_USER" "$SEAFILE_VOLUME" "$SEADOC_VOLUME"
sudo chmod -R a+rwx "$SEAFILE_VOLUME" "$SEADOC_VOLUME"

echo "==> Starting stack"
docker compose up -d

echo "==> Waiting for seahub_settings.py, could take some minutes"
SEAHUB_SETTINGS=""

for i in {1..90}; do
  SEAHUB_SETTINGS="$(sudo find "$SEAFILE_VOLUME" -name seahub_settings.py 2>/dev/null | head -n 1 || true)"

  if [[ -n "$SEAHUB_SETTINGS" ]]; then
    break
  fi

  sleep 3
done

if [[ -z "$SEAHUB_SETTINGS" ]]; then
  echo "Could not find seahub_settings.py inside $SEAFILE_VOLUME"
  echo
  echo "Check Seafile logs with:"
  echo "docker ps --format '{{.Names}}' | grep seafile"
  echo "docker logs <seafile-container-name> --tail=120"
  exit 1
fi

echo "==> Found seahub_settings.py:"
echo "$SEAHUB_SETTINGS"

echo "==> Patching CSRF/proxy settings"
sudo cp "$SEAHUB_SETTINGS" "${SEAHUB_SETTINGS}.bak.$(date +%Y%m%d-%H%M%S)"

sudo sed -i '/# BEGIN TAILSCALE SEADOC CONFIG/,/# END TAILSCALE SEADOC CONFIG/d' "$SEAHUB_SETTINGS"

sudo tee -a "$SEAHUB_SETTINGS" > /dev/null <<EOF

# BEGIN TAILSCALE SEADOC CONFIG
CSRF_TRUSTED_ORIGINS = [
    "https://${DOMAIN}",
]

SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
USE_X_FORWARDED_HOST = True

SERVICE_URL = "https://${DOMAIN}"
FILE_SERVER_ROOT = "https://${DOMAIN}/seafhttp"
SEADOC_SERVER_URL = "https://${DOMAIN}/sdoc-server"
# END TAILSCALE SEADOC CONFIG
EOF

echo "==> Restarting services"
docker compose up -d --force-recreate seafile seadoc caddy

echo "Done."
echo
echo "To expose Porrodrive through Tailscale, run from the repository root:"
echo "./start-services.sh start svc:porrodrive"
echo
echo "Open: https://${DOMAIN} after the Tailscale service is started."