# syntax=docker/dockerfile:1

# Dependency-Track API server based on Docker Hardened Images (DHI).
# Pulling the dhi.io base images requires: docker login dhi.io

ARG REL_VERSION=4.11.4
ARG JAR_FILENAME=dependency-track-apiserver.jar
ARG FILE_SHA256_SUM=9a09259ba4c19d02b81a39fb5894df758f19ff1bb43538d4b999b4a5789a9d9b
ARG APP_DIR=/opt/owasp/dependency-track/
ARG DATA_DIR=/data/
ARG UID=65532
ARG GID=65532

FROM dhi.io/alpine-base:3.24-dev AS fetch

ARG REL_VERSION
ARG JAR_FILENAME
ARG FILE_SHA256_SUM
ARG APP_DIR
ARG DATA_DIR
ARG UID

WORKDIR /download

RUN apk add --no-cache curl ca-certificates \
 && curl -O -L --fail "https://github.com/DependencyTrack/dependency-track/releases/download/${REL_VERSION}/${JAR_FILENAME}" \
 && echo "${FILE_SHA256_SUM}  ${JAR_FILENAME}" | sha256sum --check --status \
 && mkdir -p "${APP_DIR}" "${DATA_DIR}" \
 && chown -R "${UID}:0" "${DATA_DIR}" \
 && chmod -R g=u "${DATA_DIR}"

FROM dhi.io/eclipse-temurin:25-alpine3.24 AS jre

FROM dhi.io/alpine-base:3.24

MAINTAINER malte.wildt

ARG APP_DIR
ARG DATA_DIR
ARG UID
ARG JAR_FILENAME

ENV TZ=Etc/UTC
ENV JAR_FILENAME=${JAR_FILENAME}
ENV CONTEXT="/"
ENV JAVA_HOME=/usr/lib/jvm/temurin-25
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV HOME=${DATA_DIR}
ENV JAVA_OPTIONS="-XX:+UseParallelGC -XX:MaxRAMPercentage=90.0"

COPY --from=jre "${JAVA_HOME}" "${JAVA_HOME}"
COPY --from=fetch "${DATA_DIR}" "${DATA_DIR}"
COPY --from=fetch "/download/${JAR_FILENAME}" "${APP_DIR}${JAR_FILENAME}"

WORKDIR ${APP_DIR}
USER ${UID}

CMD exec java ${JAVA_OPTIONS} ${EXTRA_JAVA_OPTIONS} \
    --add-opens java.base/java.util.concurrent=ALL-UNNAMED \
    -jar ${JAR_FILENAME} \
    -context ${CONTEXT}

EXPOSE 8080
