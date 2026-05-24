# Porropics - Photo Server

Porropics is the photo and video management section of **PorroLab**.

It is based on **Immich** and includes the Immich server, machine learning service, Redis/Valkey and PostgreSQL.

## Containers

| Container | Image | Endpoint | Description |
|---|---|---|---|
| `immich_server` | `ghcr.io/immich-app/immich-server:${IMMICH_VERSION}` | `http://<your-service-name>:2283` | Main Immich web and API server |
| `immich_machine_learning` | `ghcr.io/immich-app/immich-machine-learning:${IMMICH_VERSION}-openvino` | Internal only | Machine learning service for search, recognition and smart features |
| `immich_redis` | `valkey/valkey:9` | Internal only | Redis-compatible cache service |
| `immich_postgres` | `ghcr.io/immich-app/postgres:14-vectorchord...` | Internal only | PostgreSQL database with vector extensions |

## Environment

Create the `.env` file from the example:

```bash
cp .env.example .env
```

Required values are documented in `.env.example`.

Main values to configure:

| Variable | Description |
|---|---|
| `UPLOAD_LOCATION` | Path to the photos and videos storage folder |
| `DB_DATA_LOCATION` | Path to the PostgreSQL database storage folder |
| `TZ` | Time zone used by the stack |
| `IMMICH_VERSION` | Immich version used by the containers |
| `DB_PASSWORD` | PostgreSQL database password |
| `DB_USERNAME` | PostgreSQL database username |
| `DB_DATABASE_NAME` | PostgreSQL database name |

## Machine Learning / Hardware Acceleration Files

This setup uses hardware acceleration:

```yaml
extends:
  file: hwaccel.transcoding.yml
  service: quicksync
```

and:

```yaml
extends:
  file: hwaccel.ml.yml
  service: openvino
```

Because of this, the following files are required in the same folder as `docker-compose.yml`:

```text
hwaccel.transcoding.yml
hwaccel.ml.yml
```

Either download them from the official Immich website before starting the stack, or remove that part.