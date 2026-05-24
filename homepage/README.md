# Homepage

**Porrolab** dashboard to monitor and manage its services.

It is based on **[Homepage](https://www.gethomepage.dev)**.
The stack exposes the dashboard on port `3000` and loads its configuration from the local `config/` folder.

## Container

| Container | Image | Endpoint | Description |
|---|---|---|---|
| `homepage` | `ghcr.io/gethomepage/homepage:latest` | `<your-machine-name>.<your-ts-id>.ts.net:3000`<br>`<your-machine-name>:3000`<br>`localhost:3000` | Main Homepage dashboard |

## Environment

Create the `.env` file from the example:

```bash
cp .env.example .env
```

Required values are documented in `.env.example`.

Main values to configure:

| Variable | Description |
|---|---|
| `HOMEPAGE_ALLOWED_HOSTS` | Allowed hostnames for accessing Homepage |
| `EXTERNAL_STORAGE` | Path to the external storage mounted in the container |
| `LOCATION` | Location used by Homepage widgets |


You can find the others in `.env.example`.