# SHOUTcast 2 Docker Project

This repository packages SHOUTcast DNAS (`sc_serv`) with a startup script that fills `sc_serv.conf` from environment variables and starts the server.

## Project Files

- `Dockerfile`: Container image build definition
- `setup.sh`: Startup script that validates ENV values, updates `sc_serv.conf`, and starts `sc_serv`
- `sc_serv.conf`: Config template with token placeholders
- `.github/workflows/docker-publish.yml`: GitHub Actions workflow to build and push images

## Requirements

- Docker 24+ (recommended)
- Linux/macOS shell or Windows terminal with Docker support

## Build Locally

```bash
docker build -t shoutcast2:local .
```

## Run Locally (Docker)

Minimum required runtime values are `DJPASSWORD` and `ADMINPASSWORD`.

```bash
docker run --rm \
  -p 8000:8000 \
  -e DJPASSWORD=sourcepass \
  -e ADMINPASSWORD=adminpass \
  shoutcast2:local
```

Optional overrides (defaults are already defined in the image):

- `STREAMPORT` default: `8000`
- `LISTENERS` default: `512`
- `BITRATELOW` default: `64000`
- `BITRATEHIGH` default: `320000`

Example with all overrides:

```bash
docker run --rm \
  -p 8000:8000 \
  -e DJPASSWORD=sourcepass \
  -e ADMINPASSWORD=adminpass \
  -e STREAMPORT=8000 \
  -e LISTENERS=512 \
  -e BITRATELOW=64000 \
  -e BITRATEHIGH=320000 \
  shoutcast2:local
```

## Run Without Docker

Make sure `sc_serv` is executable and provide required env values:

```bash
chmod +x sc_serv setup.sh
DJPASSWORD=sourcepass ADMINPASSWORD=adminpass ./setup.sh
```

## Configuration Tokens in `sc_serv.conf`

`setup.sh` replaces these tokens at startup:

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

- `ADMINPASSWORD` must be different from `DJPASSWORD`.
- Numeric values are enforced for `STREAMPORT`, `LISTENERS`, `BITRATELOW`, and `BITRATEHIGH`.
- Exposed container port is `8000` by default; adjust port mapping if you override `STREAMPORT`.
