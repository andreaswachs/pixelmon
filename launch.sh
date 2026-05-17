#!/bin/bash

set -x

cd /data

WORLD_DIR="/data/world/${LEVEL:-world}"
mkdir -p "$WORLD_DIR"

# Symlink server config files from ConfigMap mount (read-only)
for cfg_file in server.properties ops.json ops.txt whitelist.json banned-ips.json banned-players.json; do
    if [ -f "/data/server-config/$cfg_file" ] && [ ! -L "/data/$cfg_file" ]; then
        rm -f "/data/$cfg_file"
        ln -sf "/data/server-config/$cfg_file" "/data/$cfg_file"
    fi
done

# EULA: prefer ConfigMap, fallback to writable /data
if ! [[ "$EULA" = "false" ]]; then
    if [ -f /data/server-config/eula.txt ]; then
        ln -sf /data/server-config/eula.txt /data/eula.txt
    else
        echo "eula=true" > /data/eula.txt
    fi
else
    echo "You must accept the EULA to install."
    exit 99
fi

if ! [[ -f serverpack9113.zip ]]; then
    rm -fr configs defaultconfigs kubejs libraries mods forge-*.jar server-setup-config.yaml server-start.* serverstarter-*.jar Enigmatica6Server-*.zip
    rm -fr config defaultconfigs global_data_packs global_resource_packs mods packmenu libraries
    curl -Lo serverpack9113.zip 'https://edge.forgecdn.net/files/5954/585/serverpack9113.zip' && unzip -u -o 'serverpack9113.zip' -d /data
    if [[ -d serverpack ]]; then
        mv -f serverpack/* /data/
        rm -fr serverpack
    fi
    chmod u+x Install.sh
    ./Install.sh
fi

# Set level-name to the world PVC mount
sed -i "s/level-name=.*/level-name=${WORLD_DIR//\//\\/}/" /data/server.properties

if [[ -n "$MAX_RAM" ]]; then
    sed -i "s/maxRam:.*/maxRam: $MAX_RAM/" /data/server-setup-config.yaml
fi
if [[ -n "$MOTD" ]]; then
    sed -i "s/motd\s*=/ c motd=$MOTD" /data/server.properties
fi

# Write ops to /data (writable)
if [[ -n "$OPS" ]]; then
    echo $OPS | awk -v RS=, '{print}' > /data/ops.txt
fi

sed -i 's/server-port.*/server-port=25565/g' server.properties

. ./settings.sh

java -server ${JVM_OPTS} ${JAVA_PARAMETERS} -jar ${SERVER_JAR} nogui
