# SHOUTcast 2 / Icecast Docker Project

This repository packages SHOUTcast DNAS (`sc_serv`) and Icecast with a startup script that fills the selected config from environment variables and starts the server.

## Project Files

- `Dockerfile`: Container image build definition
- `setup.sh`: Startup script that validates ENV values, updates the selected config, and starts the selected server
- `sc_serv.conf`: SHOUTcast config template with token placeholders
- `icecast.xml`: Icecast config template with token placeholders
- `.github/workflows/docker-publish.yml`: GitHub Actions workflow to build and push images

## Requirements

- Docker 24+ (recommended)
- Linux/macOS shell or Windows terminal with Docker support

## Build Locally

```bash
docker build -t shoutcast2:local .
```

## Run Locally (Docker)

Minimum required runtime values are `DJPASSWORD` and `ADMINPASSWORD`. `SERVERTYPE` defaults to `shoutcast2` and can be set to `icecast`.

```bash
docker run --rm \
  -p 8000:8000 \
  -e SERVERTYPE=shoutcast2 \
  -e DJPASSWORD=sourcepass \
  -e ADMINPASSWORD=adminpass \
  shoutcast2:local
```

Supported server types:

- `shoutcast2` uses `sc_serv.conf`
- `icecast` uses `icecast.xml`

Optional overrides (defaults are already defined in the image):

- `SERVERTYPE` default: `shoutcast2`
- `STREAMPORT` default: `8000`
- `LISTENERS` default: `512`
- `BITRATELOW` default: `64000`
- `BITRATEHIGH` default: `320000`

Example with all overrides:

```bash
docker run --rm \
  -p 8000:8000 \
  -e SERVERTYPE=shoutcast2 \
  -e DJPASSWORD=sourcepass \
  -e ADMINPASSWORD=adminpass \
  -e STREAMPORT=8000 \
  -e LISTENERS=512 \
  -e BITRATELOW=64000 \
  -e BITRATEHIGH=320000 \
  shoutcast2:local
```

Example with Icecast:

```bash
docker run --rm \
  -p 8000:8000 \
  -e SERVERTYPE=icecast \
  -e DJPASSWORD=sourcepass \
  -e ADMINPASSWORD=adminpass \
  -e STREAMPORT=8000 \
  -e LISTENERS=512 \
  shoutcast2:local
```

## Run Without Docker

Make sure `sc_serv` and `icecast2` are available and provide required env values:

```bash
chmod +x sc_serv setup.sh
SERVERTYPE=shoutcast2 DJPASSWORD=sourcepass ADMINPASSWORD=adminpass ./setup.sh
```

## Configuration Tokens

`setup.sh` replaces these tokens in the active config at startup:

- `[[DJPASSWORD]]`
- `[[ADMINPASSWORD]]`
- `[[STREAMPORT]]`
- `[[LISTENERS]]`
- `[[BITRATELOW]]`
- `[[BITRATEHIGH]]`

## GitHub Actions: Auto Build and Push

Workflow file:

- `.github/workflows/docker-publish.yml`

Triggers:

- Push to `main`
- Version tags like `v1.0.0`
- Manual run (`workflow_dispatch`)

### Required Repository Secrets

Set these in GitHub: Settings -> Secrets and variables -> Actions:

- `DOCKER_REGISTRY` (example: `docker.io`)
- `DOCKER_IMAGE_NAME` (example: `youruser/shoutcast2`)
- `DOCKER_USERNAME`
- `DOCKER_TOKEN`

The workflow publishes tags for branch, git tag, commit SHA, and `latest` on the default branch.

## Notes

- `SERVERTYPE` must be either `shoutcast2` or `icecast`.
- `ADMINPASSWORD` must be different from `DJPASSWORD`.
- Numeric values are enforced for `STREAMPORT` and `LISTENERS` on both server types, and for `BITRATELOW` and `BITRATEHIGH` on `shoutcast2`.
- Exposed container port is `8000` by default; adjust port mapping if you override `STREAMPORT`.
