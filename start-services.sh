#!/usr/bin/env bash
set -euo pipefail

read -r -d '' SERVICES_JSON <<'EOF' || true
{
  "svc:home": 80,
  "svc:flix": 80,
  "svc:jellyseerr": 80,
  "svc:bazarr": 80,
  "svc:radarr": 80,
  "svc:sonarr": 80,
  "svc:prowlarr": 80,
  "svc:qbittorrent": 80,
  "svc:pics": 80,
  "svc:drive": 80
}
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
    if ! echo "$SERVICES_JSON" | jq -e --arg svc "$selected" 'has($svc)' >/dev/null; then
        echo "Unknown service: $selected"
        echo
        echo "Available services:"
        echo "$SERVICES_JSON" | jq -r 'keys[]'
        exit 1
    fi
done

start_service() {
    local svc="$1"
    local port="$2"

    echo "Starting $svc on local port $port..."
    sudo tailscale serve --service="$svc" --https=443 "http://127.0.0.1:$port"
}

stop_service() {
    local svc="$1"

    echo "Stopping $svc..."
    sudo tailscale serve --service="$svc" --https=443 off
}

for svc in $(echo "$SERVICES_JSON" | jq -r 'keys[]'); do
    PORT=$(echo "$SERVICES_JSON" | jq -r --arg svc "$svc" '.[$svc]')

    if [[ ${#SELECTED_SERVICES[@]} -gt 0 ]]; then
        if [[ ! " ${SELECTED_SERVICES[*]} " =~ " ${svc} " ]]; then
            continue
        fi
    fi

    case "$ACTION" in
        start)
            start_service "$svc" "$PORT"
            ;;
        stop)
            stop_service "$svc"
            ;;
        restart)
            echo "Restarting $svc..."
            stop_service "$svc"
            sleep 1
            start_service "$svc" "$PORT"
            ;;
    esac
done