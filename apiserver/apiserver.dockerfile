FROM registry.suse.com/bci/openjdk:latest

MAINTAINER malte.wildt

ARG FILE_SHA256_SUM=e30731cd1915d3a1578cf5d8c8596d247fb11a82a3fe4c1ba2fb9fad01667aef
ARG APP_DIR=/opt/owasp/dependency-track/
ARG REL_VERSION=4.10.1
ARG DATA_DIR=/data/
ARG UID=1000
ARG GID=1000
ARG JAR_FILENAME=dependency-track-apiserver.jar

ENV TZ=Etc/UTC
ENV JAR_FILENAME=${JAR_FILENAME}
ENV CONTEXT="/"
ENV JAVA_OPTIONS="-XX:+UseParallelGC -XX:MaxRAMPercentage=90.0"

RUN mkdir -p ${APP_DIR} ${DATA_DIR}
RUN groupadd --system --gid ${GID} dtrack
RUN useradd --system --groups dtrack --no-create-home --home ${DATA_DIR} --shell /bin/false --uid ${UID} dtrack
RUN chown -R ${UID}:0  ${DATA_DIR} ${APP_DIR}
RUN chmod -R g=u ${DATA_DIR} ${APP_DIR}

WORKDIR ${APP_DIR}
USER ${UID}

RUN curl -O -L --fail  https://github.com/DependencyTrack/dependency-track/releases/download/${REL_VERSION}/${JAR_FILENAME}

RUN echo "${FILE_SHA256_SUM} ${JAR_FILENAME}" | sha256sum --check --status

RUN ls -l

CMD exec java ${JAVA_OPTIONS} ${EXTRA_JAVA_OPTIONS} \
    --add-opens java.base/java.util.concurrent=ALL-UNNAMED \
    -jar ${JAR_FILENAME} \
    -context ${CONTEXT}

EXPOSE 8080