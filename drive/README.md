# Porrodrive - File Server

Porrodrive is the file sync and storage section of **PorroLab**.

It is based on **Seafile**, **Caddy**, **SeaDoc** and **Tailscale**.

This setup is designed for private access through both a Tailscale and a custom domain through [Caddy](https://github.com/gab-palmeri/porrolab/tree/main/reverse-proxy):

```text
https://drive.<your-ts-id>.ts.net
http://drive.<your-domain>.com
```

## Containers

| Container | Image | Endpoint | Description |
|---|---|---|---|
| `seafile` | `seafileltd/seafile-mc:13.0-latest` | `https://<your-service-name>.<your-ts-id>.ts.net` | Main Seafile server |
| `seafile-mysql` | `mariadb:10.11` | Internal only | Database used by Seafile |
| `seafile-redis` | `redis` | Internal only | Cache backend |
| `seafile-collabora` | `collabora/code:26.04.1.4.1` | Internal only | Online document editing |

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
| `SEAFILE_MYSQL_VOLUME` | Path to the MariaDB persistent data folder |
| `TIME_ZONE` | Time zone used by the stack |
| `INIT_SEAFILE_MYSQL_ROOT_PASSWORD` | MariaDB root password |
| `SEAFILE_MYSQL_DB_PASSWORD` | MariaDB password used by Seafile |
| `SEAFILE_SERVER_HOSTNAME` | Tailscale hostname used to access Porrodrive |
| `JWT_PRIVATE_KEY` | Private key used by Seafile services |
| `COLLABORA_PORT` | Collabora port (internal) |
| `COLLABORA_USERNAME` | Collabora admin panel username |
| `COLLABORA_PASSWORD` | Collabora admin panel password |
| `COLLABORA_ENABLE_ADMIN_CONSOLE` | Enable Collabora admin console |
| `COLLABORA_ENABLE_FILE_LOGGING` | Enable Collabora file logging |

## Tailscale Service

As the other services, this one is based on a Tailscale service, so you have to create a new one.
The name must be the same as the one in `SEAFILE_SERVER_HOSTNAME` env variable.

Then, you can use the `start-services.sh` script to start the service and publish it on Tailscale.

## After Starting

After the first run, Seafile generates a file called `seahub_settings.py` at:

```text
<SEAFILE_VOLUME>/seafile/conf/seahub_settings.py
```

The following settings must be added manually to that file:

```python
CSRF_TRUSTED_ORIGINS = [
    'https://drive.<your-ts-id>.ts.net',
    'http://drive.<your-ts-id>.ts.net'
    'https://drive.<your-domain>.com',
    'http://drive.<your-domain>.com'
]

OFFICE_SERVER_TYPE = 'CollaboraOffice'
ENABLE_OFFICE_WEB_APP = True
ENABLE_OFFICE_WEB_APP_EDIT = True

# Browser → Collabora via Caddy
OFFICE_WEB_APP_BASE_URL = 'http://seafile-collabora:9980/hosting/discovery'

WOPI_ACCESS_TOKEN_EXPIRATION = 30 * 60
OFFICE_WEB_APP_FILE_EXTENSION = ('odp', 'ods', 'odt', 'xls', 'xlsb', 'xlsm', 'xlsx', 'ppsx', 'ppt', 'pptm', 'pptx', 'doc', 'docm', 'docx', 'rtf')
OFFICE_WEB_APP_EDIT_FILE_EXTENSION = ('odp', 'ods', 'odt', 'xls', 'xlsb', 'xlsm', 'xlsx', 'ppsx', 'ppt', 'pptm', 'pptx', 'doc', 'docm', 'docx', 'rtf')
```

Replace `<your-ts-id>` and `<your-domain>` with the actual values.

If you wish to use Seafile's WebDAV service, you must edit the `seafdav.conf` file at:

```text
<SEAFILE_VOLUME>/seafile/conf/seafdav.conf
```

Adding the following lines:

```text
[WEBDAV]

# Default is false. Change it to true to enable SeafDAV server.
enabled = true

port = 8086
debug = true

# If you deploy seafdav behind nginx/apache, you need to modify "share_name".
share_name = /seafdav

# SeafDAV uses Gunicorn as web server.
# This option maps to Gunicorn's 'workers' setting. https://docs.gunicorn.org/en/stable/settings.html?#workers
# By default it's set to 5 processes.
workers = 5

# This option maps to Gunicorn's 'timeout' setting. https://docs.gunicorn.org/en/stable/settings.html?#timeout
# By default it's set to 1200 seconds, to support large file uploads.
timeout = 1200
```


After editing, recreate Seafile:

```bash
docker compose up -d --force-recreate seafile
```