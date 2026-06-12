#!/usr/bin/env bash
set -euo pipefail

read -r -d '' SERVICES_JSON <<'EOF' || true
[
  "svc:home",
  "svc:flix",
  "svc:jellyseerr",
  "svc:bazarr",
  "svc:radarr",
  "svc:sonarr",
  "svc:prowlarr",
  "svc:qbittorrent",
  "svc:pics",
  "svc:drive"
]
EOF

ACTION="${1:-}"
shift || true
SELECTED_SERVICES=("$@")

if [[ -z "$ACTION" ]]; then
    echo "Usage: $0 <start|stop|restart> [svc:porroflix svc:radarr ...]"
    exit 1
fi

if [[ "$ACTION" != "start" && "$ACTION" != "stop" && "$ACTION" != "restart" ]]; then
    echo "Unknown action: $ACTION"
    echo "Valid actions: start, stop, restart"
    exit 1
fi

for selected in "${SELECTED_SERVICES[@]}"; do
    if ! echo "$SERVICES_JSON" | jq -e --arg svc "$selected" 'any(. == $svc)' >/dev/null; then
        echo "Unknown service: $selected"
        echo
        echo "Available services:"
        echo "$SERVICES_JSON" | jq -r '.[]'
        exit 1
    fi
done

start_service() {
    local svc="$1"

    echo "Starting $svc..."
    sudo tailscale serve --service="$svc" --https=443 "http://127.0.0.1:80"
}

stop_service() {
    local svc="$1"

    echo "Stopping $svc..."
    sudo tailscale serve --service="$svc" --https=443 off
}

for svc in $(echo "$SERVICES_JSON" | jq -r '.[]'); do
    if [[ ${#SELECTED_SERVICES[@]} -gt 0 ]]; then
        if [[ ! " ${SELECTED_SERVICES[*]} " =~ " ${svc} " ]]; then
            continue
        fi
    fi

    case "$ACTION" in
        start)
            start_service "$svc"
            ;;
        stop)
            stop_service "$svc"
            ;;
        restart)
            echo "Restarting $svc..."
            stop_service "$svc"
            sleep 1
            start_service "$svc"
            ;;
    esac
done