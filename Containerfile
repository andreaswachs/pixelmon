# syntax=docker/dockerfile:1

FROM eclipse-temurin:8-jre

LABEL org.opencontainers.image.version="9.1.13"
LABEL org.opencontainers.image.title="The Pixelmon Modpack 9.1.13"
LABEL org.opencontainers.image.description="Minecraft Pixelmon Modpack server"
LABEL org.opencontainers.image.url="https://github.com/andreaswachs/pixelmon"
LABEL org.opencontainers.image.source="https://github.com/andreaswachs/pixelmon"

RUN apt-get update && apt-get install -y curl unzip && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -f --gid 1250 minecraft && \
    useradd --uid 1250 --gid 1250 --home /data --shell /bin/bash minecraft && \
    mkdir -p /data/world /data/config /data/server-config && \
    chown -R minecraft:minecraft /data

COPY launch.sh /launch.sh
RUN chmod +x /launch.sh

USER minecraft

VOLUME ["/data/world", "/data/server-config"]
WORKDIR /data

EXPOSE 25565/tcp

ENV MOTD="Pixelmon Server"
ENV LEVEL="world"

CMD ["/launch.sh"]
