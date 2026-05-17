# syntax=docker/dockerfile:1

FROM eclipse-temurin:21-jre

LABEL org.opencontainers.image.version="9.3.16"
LABEL org.opencontainers.image.title="The Pixelmon Modpack 9.3.16"
LABEL org.opencontainers.image.description="Minecraft Pixelmon Modpack server"
LABEL org.opencontainers.image.url="https://github.com/andreaswachs/pixelmon"
LABEL org.opencontainers.image.source="https://github.com/andreaswachs/pixelmon"

RUN apt-get update && apt-get install -y curl unzip jq && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -f --gid 1250 minecraft && \
    useradd --uid 1250 --gid 1250 --home /data --shell /bin/bash minecraft && \
    mkdir -p /data/world /data/server-config /data/mods /data/config /data/defaultconfigs /data/resourcepacks

# Install NeoForge server
RUN curl -Lo /tmp/neoforge-installer.jar \
    'https://maven.neoforged.net/releases/net/neoforged/neoforge/21.1.172/neoforge-21.1.172-installer.jar' && \
    java -jar /tmp/neoforge-installer.jar --installServer /data && \
    rm /tmp/neoforge-installer.jar

# Download mods from Modrinth API
RUN MODRINTH_API="https://api.modrinth.com/v2/version" && \
    for id in \
      qv3qT6AO:journeymap-neoforge-1.21.1-6.0.0-beta.48.jar \
      zRGLFYRx:jei-1.21.1-neoforge-19.21.2.313.jar \
      stJDU839:konkrete_neoforge_1.9.9_MC_1.21.jar \
      tqkhEU8J:lithostitched-neoforge-1.21.1-1.4.8.jar \
      efcdRVZP:melody_neoforge_1.0.10_MC_1.21.jar \
      LqFrsWa8:Pixelmon-1.21.1-9.3.16-universal.jar \
      l75DmOwI:Structory_1.21.x_v1.3.10.jar \
      oteEZjc2:Structory_Towers_1.21.x_v1.0.11.jar \
      6yg3Vohy:tectonic-3.0.1-neoforge-1.21.1.jar \
      MuJMtPGQ:Terralith_1.21.x_v2.5.8.jar; do \
      version_id="${id%%:*}" filename="${id##*:}"; \
      url=$(curl -sS "$MODRINTH_API/$version_id" | jq -r '.files[0].url'); \
      echo "Downloading $filename from $url"; \
      curl -sSLo "/data/mods/$filename" "$url"; \
    done

# Copy default config files
COPY server-files/ /data/

# Set ownership
RUN chown -R minecraft:minecraft /data

COPY launch.sh /launch.sh
RUN chmod +x /launch.sh

USER minecraft

VOLUME ["/data/world", "/data/server-config"]
WORKDIR /data

EXPOSE 25565/tcp

ENV MOTD="Pixelmon Server"
ENV LEVEL="world"

CMD ["/launch.sh"]
