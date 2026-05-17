#!/bin/bash

set -x

cd /data

WORLD_DIR="/data/world/${LEVEL:-world}"
mkdir -p "$WORLD_DIR"

# Apply ConfigMap files to /data
# server.properties is copied (editable), others are symlinked
if [ -f "/data/server-config/server.properties" ] && [ ! -f "/data/.server-properties-applied" ]; then
    cp "/data/server-config/server.properties" /data/server.properties
    touch /data/.server-properties-applied
fi
for cfg_file in ops.json whitelist.json banned-ips.json banned-players.json; do
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

# Set level-name to the world PVC mount
sed -i "s/level-name=.*/level-name=${WORLD_DIR//\//\\/}/" /data/server.properties

# Apply MOTD override
if [[ -n "$MOTD" ]]; then
    escaped_motd=$(printf '%s\n' "$MOTD" | sed 's/[\/&]/\\&/g')
    sed -i "s/motd\s*=.*/motd=$escaped_motd/" /data/server.properties
fi

# Ensure server port
sed -i 's/server-port.*/server-port=25565/' /data/server.properties

# Launch NeoForge server
exec java @user_jvm_args.txt @libraries/net/neoforged/neoforge/21.1.172/unix_args.txt nogui "$@"
