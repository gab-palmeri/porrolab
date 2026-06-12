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

This setup is used with Tailscale Services to assign custom domains, and sometimes they are mandatory (see [Porrodrive](https://github.com/gab-palmeri/porrolab/tree/main/drive)).
So, a script named `start-services.sh` is included in the repository.

First, you will have to create them in the [Tailscale's dashboard](https://login.tailscale.com), under **Services**.

Then, this script will publish the current machine on Tailscale as the provider for the created services.
All requests are routed through port `80` to Caddy, which handles the routing for both Tailscale domains and custom domains.

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