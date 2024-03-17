ARG ARCHIVE_NAME=frontend-dist.zip
ARG UID=1001
ARG GID=1001


FROM registry.suse.com/bci/golang:1.22 as build

MAINTAINER malte.wildt

ARG FILE_SHA256_SUM=2f6f524c45afcc4a90128cab22a557bf41b88c716aaf0992eb6bb2239ce1469c
ARG APP_DIR=/opt/owasp/dependency-track/
ARG REL_VERSION=4.10.0
ARG ARCHIVE_NAME
ARG UID
ARG GID

ADD ./ /src
WORKDIR /src

RUN zypper install -y unzip
RUN curl -O -L --fail https://github.com/DependencyTrack/frontend/releases/download/${REL_VERSION}/${ARCHIVE_NAME}
RUN echo "${FILE_SHA256_SUM} ${ARCHIVE_NAME}" | sha256sum --check --status
RUN unzip ${ARCHIVE_NAME}

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server ./main.go

FROM registry.suse.com/bci/bci-micro:15.5
ARG ARCHIVE_NAME
ARG UID
ARG GID
COPY --from=build --chown=${UID}:0 --chmod=500 /src/server /opt/owasp/dependency-track/server
COPY --from=build --chown=${UID}:0 --chmod=500 /src/dist /opt/owasp/dependency-track/dist

USER ${UID}

WORKDIR /opt/owasp/dependency-track/
ENTRYPOINT ["/opt/owasp/dependency-track/server"]


