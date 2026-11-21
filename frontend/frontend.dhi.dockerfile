# syntax=docker/dockerfile:1

# Dependency-Track frontend based on Docker Hardened Images (DHI).
# Pulling the dhi.io base images requires: docker login dhi.io

ARG ARCHIVE_NAME=frontend-dist.zip
ARG REL_VERSION=4.11.4
ARG FILE_SHA256_SUM=ea747f848de6a6def6f73209d7f43424c6314d09bc8ea37be621be50dbac755b
ARG APP_DIR=/opt/owasp/dependency-track/
ARG UID=65532
ARG GID=65532

FROM dhi.io/golang:1.26-alpine3.24-dev AS build

MAINTAINER malte.wildt

ARG ARCHIVE_NAME
ARG REL_VERSION
ARG FILE_SHA256_SUM

ADD ./ /src
WORKDIR /src

RUN apk add --no-cache curl ca-certificates unzip \
 && curl -O -L --fail "https://github.com/DependencyTrack/frontend/releases/download/${REL_VERSION}/${ARCHIVE_NAME}" \
 && echo "${FILE_SHA256_SUM}  ${ARCHIVE_NAME}" | sha256sum --check --status \
 && unzip -q ${ARCHIVE_NAME} \
 && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server ./main.go

FROM dhi.io/static:20261020-alpine3.24

ARG APP_DIR
ARG UID

COPY --from=build --chown=${UID}:0 --chmod=500 /src/server ${APP_DIR}server
COPY --from=build --chown=${UID}:0 /src/dist ${APP_DIR}dist

USER ${UID}

WORKDIR ${APP_DIR}
ENTRYPOINT ["/opt/owasp/dependency-track/server"]
