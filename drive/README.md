# Porrodrive - File Server

Porrodrive is the file sync and storage section of **PorroLab**.

It is based on **Seafile**, **Caddy**, **SeaDoc** and **Tailscale**.

This setup is designed for private access through a Tailscale domain:

```text
https://<your-service-name>.<your-ts-id>.ts.net
```

## Containers

| Container | Image | Endpoint | Description |
|---|---|---|---|
| `seafile` | `seafileltd/seafile-mc:13.0-latest` | `https://<your-service-name>.<your-ts-id>.ts.net` | Main Seafile server |
| `seafile-mysql` | `mariadb:10.11` | Internal only | Database used by Seafile |
| `seafile-redis` | `redis` | Internal only | Cache backend |
| `seadoc` | `seafileltd/sdoc-server:2.0-latest` | Internal only | Online document editing |
| `seafile-caddy` | `lucaslorentz/caddy-docker-proxy:2.12-alpine` | Internal proxy | Reverse proxy for Seafile and SeaDoc |

## Environment

Create the `.env` file from the example:

```bash
cp .env.example .env
```

Required values are documented in `.env.example`.

Main values to configure:

| Variable | Description |
|---|---|
| `SEAFILE_VOLUME` | Path to the Seafile persistent data folder |
| `SEADOC_VOLUME` | Path to the SeaDoc persistent data folder |
| `SEAFILE_MYSQL_VOLUME` | Path to the MariaDB persistent data folder |
| `SEAFILE_CADDY_VOLUME` | Path to the Caddy persistent data folder |
| `TIME_ZONE` | Time zone used by the stack |
| `INIT_SEAFILE_MYSQL_ROOT_PASSWORD` | MariaDB root password |
| `SEAFILE_MYSQL_DB_PASSWORD` | MariaDB password used by Seafile |
| `SEAFILE_SERVER_HOSTNAME` | Tailscale hostname used to access Porrodrive |
| `JWT_PRIVATE_KEY` | Private key used by Seafile services |

## Tailscale Service

Create a service in Tailscale under **Services** before starting the containers.

The service must match the hostname configured in `.env`:

```env
SEAFILE_SERVER_HOSTNAME=<your-service-name>.<your-ts-id>.ts.net
```

Then expose it from the repository root using `start.services.sh`:

```bash
./start-services.sh start svc:service-name
```

This command publishes the current machine as the provider for the `svc:service-name` and binds it to the local Seafile/Caddy port.

For Porrodrive (my config), the configured service is:

| Service | Local Port | Description |
|---|---:|---|
| `svc:porrodrive` | `80` | Seafile file server |

## Post-install

This setup requires running the `post-install.sh` script after configuring the `.env` file.

The script:

- creates the required persistent folders;
- fixes permissions for `NON_ROOT=true`;
- starts the Docker stack;
- waits for Seafile to generate `seahub_settings.py`;
- patches Seafile URLs and CSRF for Tailscale, HTTPS and SeaDoc;
- recreates Seafile, SeaDoc and Caddy;
- prepares Seafile to work behind Tailscale HTTPS.

Run it with:

```bash
chmod +x post-install.sh
./post-install.sh
```

To expose Porrodrive through Tailscale, run from the repository root:

```bash
./start-services.sh start svc:porrodrive
```

After completion, Porrodrive should be available at:

```text
https://<your-service-name>.<your-ts-id>.ts.net
```