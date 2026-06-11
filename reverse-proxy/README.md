# Caddy Reverse Proxy

**Porrolab** reverse proxy used to expose self-hosted services through a single entry point.

It is based on Caddy and routes requests to containers connected to the shared `proxy` network.

## Container

| Container | Image              | Description                       |
| --------- | ------------------ | --------------------------------- |
| `caddy`   | `caddy:2.8-alpine` | Reverse proxy and TLS termination |

## Exposed Services

| Service     | Endpoint               |
| ----------- | ---------------------- |
| Homepage    | `home.<DOMAIN>`        |
| Jellyfin    | `flix.<DOMAIN>`        |
| Jellyseerr  | `jellyseerr.<DOMAIN>`  |
| Bazarr      | `bazarr.<DOMAIN>`      |
| Radarr      | `radarr.<DOMAIN>`      |
| Sonarr      | `sonarr.<DOMAIN>`      |
| Prowlarr    | `prowlarr.<DOMAIN>`    |
| qBittorrent | `qbittorrent.<DOMAIN>` |
| Immich      | `pics.<DOMAIN>`        |

All services are also available through `.<TS_DOMAIN>`.

## Environment

Create the `.env` file from the example:

```bash
cp .env.example .env
```

Main values to configure:

| Variable    | Description               |
| ----------- | ------------------------- |
| `DOMAIN`    | Public domain             |
| `TS_DOMAIN` | Tailscale MagicDNS domain |

## Network

This stack uses the shared `proxy` network to route requests to other containers. Make sure to connect all relevant containers to this network.

## Configuration

Routes are defined in the `Caddyfile`:

```caddy
http://flix.{env.DOMAIN}, http://flix.{env.TS_DOMAIN} {
    reverse_proxy jellyfin:8096
}
```