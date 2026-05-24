# PorroLab

PorroLab is a self-hosted homelab setup based on Docker.

It contains multiple services for media, photos, files and a dashboard.  
Each service lives in its own folder and has its own README with setup notes and instructions.

This setup is designed to be used with **Tailscale**.  
Some services, especially **Porrodrive** based on Seafile, are configured with private Tailscale access in mind, and may not work without it.

## Services

Current main sections:

- **media-server** — media server stack based on Jellyfin and an Arr stack
- **drive** — file sync and storage based on Seafile
- **photos** — photo and video management based on Immich
- **homepage** — dashboard to monitor and access the other services, based on **[Homepage](https://www.gethomepage.dev)**

More services may be added over time.

## Tailscale Services Script

The repository is used with Tailscale Services to assign custom domains, and sometimes they are mandatory (see [Porrodrive](https://github.com/gab-palmeri/porrolab/tree/main/drive)).
So, a script named `start-services.sh` is included in the repository.

First, you will have to create them in the [Tailscale's dashboard](https://login.tailscale.com), under **Services**.

Then, this script will publish the current machine on Tailscale as the provider for the created services.

It supports the following actions:

```bash
./start-services.sh start
./start-services.sh stop
./start-services.sh restart
```

By default, the script applies the selected action to all configured services.

Configured services:

| Service | Local Port | Description |
|---|---:|---|
| `svc:porroflix` | `8096` | porroflix media server |
| `svc:jellyseerr` | `5055` | Movie and TV show request interface |
| `svc:bazarr` | `6767` | Subtitle management |
| `svc:radarr` | `7878` | Movie management |
| `svc:sonarr` | `8989` | TV series management |
| `svc:prowlarr` | `9696` | Indexer manager |
| `svc:qbittorrent` | `8080` | Torrent client |
| `svc:porropics` | `2283` | Immich photo server |
| `svc:porrodrive` | `80` | Seafile file server (through Caddy) |

You can also target specific services:

```bash
./start-services.sh restart svc:porroflix svc:radarr
```

The script requires `tailscale` and `jq` to be installed on the host.