# Slim Images for Dependency-Track

This project creates OCI images for the frontend and the API server of the dependency track (https://github.com/DependencyTrack) based on the suse BCI images.

The background is that the leanest possible base images should be used for operation. An SBOM in cyclonedx format is also created for both the frontend image and the API server image.

| :warning: WARNING          |
|:---------------------------|
| The frontend (and API gateway) is currently not able to establish TLS connections. A simple reverse proxy for handling TLS (e.g. Traefik [https://doc.traefik.io/traefik/]) should therefore be connected upstream. |

## Docker Hardened Images (DHI) variants

In addition to the SUSE BCI based images, variants based on [Docker Hardened Images](https://www.docker.com/products/hardened-images/) (DHI) are available:

- `apiserver/apiserver.dhi.dockerfile` - API server, runtime on `dhi.io/alpine-base:3.24` with the JRE from `dhi.io/eclipse-temurin:25-alpine3.24`
- `frontend/frontend.dhi.dockerfile` - frontend, built with `dhi.io/golang:1.26-alpine3.24-dev`, runtime on `dhi.io/static:20261020-alpine3.24`

Pulling the `dhi.io` base images requires a (free) Docker account:

```
docker login dhi.io
```

Build examples:

```
docker build -f apiserver/apiserver.dhi.dockerfile -t dependency-track-apiserver:dhi apiserver
docker build -f frontend/frontend.dhi.dockerfile -t dependency-track-frontend:dhi frontend
```

Both DHI variants run as the non-root user `65532` by default (override with the `UID` build arg; the data directory is group-writable via GID 0 for arbitrary UIDs, e.g. OpenShift).


