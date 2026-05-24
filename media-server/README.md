# Porroflix - Media Server

Porroflix is the media server section of **PorroLab**.

It runs a Jellyfin-based media stack with Docker Compose, including media streaming, requests, subtitles, indexer management and torrent downloads.

## Containers

| Container | Image | Endpoint | Description |
|---|---|---|---|
| `jellyfin` | See `docker-compose.yml` | `https://<jellyfin-service>.<your-ts-id>.ts.net` | Media streaming server |
| `jellyseerr` | See `docker-compose.yml` | `https://<jellyseerr-service>.<your-ts-id>.ts.net` | Movie and TV show request interface |
| `bazarr` | See `docker-compose.yml` | `https://<bazarr-service>.<your-ts-id>.ts.net` | Subtitle management |
| `radarr` | See `docker-compose.yml` | `https://<radarr-service>.<your-ts-id>.ts.net` | Movie management |
| `sonarr` | See `docker-compose.yml` | `https://<sonarr-service>.<your-ts-id>.ts.net` | TV series management |
| `prowlarr` | See `docker-compose.yml` | `https://<prowlarr-service>.<your-ts-id>.ts.net` | Indexer manager for the Arr stack |
| `qbittorrent` | See `docker-compose.yml` | `https://<qbittorrent-service>.<your-ts-id>.ts.net` | Torrent client |

## Environment

Create the `.env` file from the example:

```bash
cp .env.example .env
```

Required values are documented in `.env.example`.

Main values to configure:

| Variable | Description |
|---|---|
| `PUID` | User ID for Docker file permissions |
| `PGID` | Group ID for Docker file permissions |
| `TZ` | Your timezone |
| `CONFIG_DIR` | Path to store containers' configuration folders |
| `DATA_DIR` | Base directory for all media and torrent data |
| `MEDIA_FOLDER` | Folder name inside `DATA_DIR` for your media library |
| `TORRENTS_FOLDER` | Folder name inside `DATA_DIR` for torrent downloads |