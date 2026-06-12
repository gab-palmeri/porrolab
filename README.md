# PorroLab

PorroLab is a self-hosted homelab setup based on Docker.

It contains multiple services for media, photos, files and a dashboard.  
Each service lives in its own folder and has its own README with setup notes and instructions.

This setup is designed to be used with **Tailscale**, and it also allows you to use a custom domain.
Some services, especially **Porrodrive** based on Seafile, are mainly configured with private Tailscale access in mind, and may not work without it.

## Services

Current main sections:

- **media-server** — media server stack based on Jellyfin and an Arr stack
- **drive** — file sync and storage based on Seafile
- **photos** — photo and video management based on Immich
- **homepage** — dashboard to monitor and access the other services, based on **[Homepage](https://www.gethomepage.dev)**

More services may be added over time.

## Tailscale Services Script

This repository is used with Tailscale Services to assign MagicDNS domains, and sometimes they are mandatory (see [Porrodrive](https://github.com/gab-palmeri/porrolab/tree/main/drive)). A helper script named `start-services.sh` is included to publish the current machine on Tailscale as the provider for the created services.

All incoming requests from Tailscale services are bound and routed through local port `80` directly to Caddy, which handles the final virtual-host routing.

First, you will have to create them in the [Tailscale's dashboard](https://login.tailscale.com), under **Services**.

It supports the following actions:

```bash
./start-services.sh start
./start-services.sh stop
./start-services.sh restart

```

By default, the script applies the selected action to all configured services.

Configured services:

| Service | Description |
| --- | --- |
| `svc:home` | Homepage / Dashboard |
| `svc:flix` | Media server |
| `svc:jellyseerr` | Movie and TV show request interface |
| `svc:bazarr` | Subtitle management |
| `svc:radarr` | Movie management |
| `svc:sonarr` | TV series management |
| `svc:prowlarr` | Indexer manager |
| `svc:qbittorrent` | Torrent client |
| `svc:pics` | Immich photo server |
| `svc:drive` | Seafile file server |

You can also target specific services:

```bash
./start-services.sh restart svc:flix svc:radarr

```

The script requires `tailscale` and `jq` to be installed on the host.

## Reverse Proxy

This setup uses **Caddy** as a unified reverse proxy. It routes incoming requests to containers connected to a shared external `proxy` network, supporting both custom public domains (`<DOMAIN>`) and Tailscale MagicDNS domains (`<TS_DOMAIN>`).

### Exposed Endpoints

| Service | Endpoint | Tailscale Endpoint | Internal Target |
| :--- | :--- | :--- | :--- |
| Homepage | `home.<DOMAIN>` | `home.<TS_DOMAIN>` | `homepage:3000` |
| Jellyfin | `flix.<DOMAIN>` | `flix.<TS_DOMAIN>` | `jellyfin:8096` |
| Jellyseerr | `jellyseerr.<DOMAIN>` | `jellyseerr.<TS_DOMAIN>` | `jellyseerr:5055` |
| Bazarr | `bazarr.<DOMAIN>` | `bazarr.<TS_DOMAIN>` | `bazarr:6767` |
| Radarr | `radarr.<DOMAIN>` | `radarr.<TS_DOMAIN>` | `radarr:7878` |
| Sonarr | `sonarr.<DOMAIN>` | `sonarr.<TS_DOMAIN>` | `sonarr:8989` |
| Prowlarr | `prowlarr.<DOMAIN>` | `prowlarr.<TS_DOMAIN>` | `prowlarr:9696` |
| qBittorrent | `qbittorrent.<DOMAIN>` | `qbittorrent.<TS_DOMAIN>` | `torrent-client:8080` |
| Immich | `pics.<DOMAIN>` | `pics.<TS_DOMAIN>` | `immich_server:2283` |
| Seafile | `drive.<DOMAIN>` | `drive.<TS_DOMAIN>` | `seafile:80` / `seafile-collabora:9980` |

### Configuration Example

Routes are defined inside the `Caddyfile`. For example, a standard service is mapped as follows:

```caddy
http://flix.{env.DOMAIN}, http://flix.{env.TS_DOMAIN} {
    reverse_proxy jellyfin:8096
}

```

> **Note on Drive Routing:** The `drive` endpoint splits traffic dynamically using Caddy's `@collabora` path matcher. Office document requests (`/browser/*`, `/cool/*`, `/hosting/*`) are proxied to `seafile-collabora:9980` (stripping CSP headers), while all remaining traffic drops down to the main `seafile:80` backend. Both contexts enforce `X-Forwarded-Proto https`.

> **Note on Direct IP Access:** All services are still reachable using the host's IP and the service's original port. For instance, to reach Jellyfin, you could use <your-machine-ip>:8096

---
