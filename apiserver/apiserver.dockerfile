FROM registry.suse.com/bci/openjdk:latest

MAINTAINER malte.wildt

ARG FILE_SHA256_SUM=9a09259ba4c19d02b81a39fb5894df758f19ff1bb43538d4b999b4a5789a9d9b
ARG APP_DIR=/opt/owasp/dependency-track/
ARG REL_VERSION=4.11.4
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
RUN chown -R ${UID}:${GID} ${DATA_DIR} ${APP_DIR}
RUN chmod -R g=u ${DATA_DIR} ${APP_DIR}

WORKDIR ${APP_DIR}
USER ${UID}

RUN curl -O -L --fail  https://github.com/DependencyTrack/dependency-track/releases/download/${REL_VERSION}/${JAR_FILENAME}

RUN sha256sum dependency-track-apiserver.jar

RUN echo "${FILE_SHA256_SUM} ${JAR_FILENAME}" | sha256sum --check --status

CMD exec java ${JAVA_OPTIONS} ${EXTRA_JAVA_OPTIONS} \
    --add-opens java.base/java.util.concurrent=ALL-UNNAMED \
    -jar ${JAR_FILENAME} \
    -context ${CONTEXT}

EXPOSE 8080