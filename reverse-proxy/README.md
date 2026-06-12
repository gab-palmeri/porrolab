# Caddy Reverse Proxy

**Porrolab** reverse proxy used to expose self-hosted services through a single entry point.

It is based on Caddy and routes requests to containers connected to the shared `proxy` network.

Both tailscale and custom domains are supported.

## Container

| Container | Image              | Description                       |
| --------- | ------------------ | --------------------------------- |
| `caddy`   | `caddy:2.8-alpine` | Reverse proxy and TLS termination |

## Exposed Services

| Service | Endpoint | Tailscale Endpoint |
| ----------- | ---------------------- | --------------------------------- |
| Homepage | `home.<DOMAIN>` | `home.<TS_DOMAIN>` |
| Jellyfin | `flix.<DOMAIN>` | `flix.<TS_DOMAIN>` |
| Jellyseerr | `jellyseerr.<DOMAIN>` | `jellyseerr.<TS_DOMAIN>` |
| Bazarr | `bazarr.<DOMAIN>` | `bazarr.<TS_DOMAIN>` |
| Radarr | `radarr.<DOMAIN>` | `radarr.<TS_DOMAIN>` |
| Sonarr | `sonarr.<DOMAIN>` | `sonarr.<TS_DOMAIN>` |
| Prowlarr | `prowlarr.<DOMAIN>` | `prowlarr.<TS_DOMAIN>` |
| qBittorrent | `qbittorrent.<DOMAIN>` | `qbittorrent.<TS_DOMAIN>` |
| Immich | `pics.<DOMAIN>` | `pics.<TS_DOMAIN>` |
| Seafile | `drive.<DOMAIN>` | `drive.<TS_DOMAIN>` |


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

Routes are defined in the `Caddyfile`, for instance:

```caddy
http://flix.{env.DOMAIN}, http://flix.{env.TS_DOMAIN} {
    reverse_proxy jellyfin:8096
}
```

 **Note on Drive:** The Seafile configuration handles both the main file server and the integrated Collabora Office suite within the same block. It uses Caddy's `@collabora` named matcher to intercept specific office paths and route them to the document server:
 
 ```caddy
 @collabora {
     path /browser/* /cool/* /hosting/*
 }
 reverse_proxy @collabora seafile-collabora:9980 {
     header_down -Content-Security-Policy
     header_up X-Forwarded-Proto https
 }
 ```
 
 All other traffic falls through to the main backend (`seafile:80`). Both proxies ensure proper header propagation (`X-Forwarded-Proto https`) for HTTPS compatibility.