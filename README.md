# The Pixelmon Modpack 9.3.16

NeoForge 1.21.1 · Java 21 · Kubernetes/Container

<!-- toc -->

- [Description](#description)
- [Requirements](#requirements)
- [Volumes](#volumes)
  * [World PVC: /data/world](#world-pvc-dataworld)
  * [ConfigMap: /data/server-config](#configmap-dataserver-config)
- [Options](#options)
- [Troubleshooting](#troubleshooting)
  * [Accept the EULA](#accept-the-eula)
  * [Permissions of Files](#permissions-of-files)
- [Source](#source)

<!-- tocstop -->

## Description

Container image for a NeoForge 1.21.1 Minecraft server running The Pixelmon Modpack 9.3.16. Mods and server files are pre-installed in the image — no runtime downloads required. Designed for Kubernetes with ConfigMap-based configuration and PVC world persistence.

## Requirements

* Volume mounted to `/data/world` (PVC for persistent world data)
* Volume mounted to `/data/server-config` (ConfigMap for server configuration, read-only)
* Port `25565/tcp` exposed
* Environment variable `EULA` set to `true`

You are responsible for accepting the Mojang EULA.

## Volumes

### World PVC: `/data/world`

Persistent volume for world data. Mount a PersistentVolumeClaim here.

```
/data/world/
  world/          # Default world directory (overridable via $LEVEL)
    region/       # Region files
    playerdata/   # Player data
    ...
```

### ConfigMap: `/data/server-config`

Read-only mount for server configuration files. The launch script applies these at startup. All files are optional — defaults are used if not provided.

| File | Purpose | Format |
|------|---------|--------|
| `server.properties` | Server configuration | Java properties |
| `ops.json` | Server operators | JSON array of operator objects |
| `whitelist.json` | Whitelisted players | JSON array of player objects |
| `banned-ips.json` | Banned IP addresses | JSON array |
| `banned-players.json` | Banned players | JSON array of player objects |
| `eula.txt` | Accept the EULA via file | `eula=true` |

The default `server.properties` template includes modded-server tuning (watchdog disabled, async chunk writes) and can be fully overridden via this ConfigMap.

## Options

Environment variables override their defaults at runtime.

| Variable | Default | Description |
|----------|---------|-------------|
| `EULA` | *(required)* | Must be `true` to start the server |
| `MOTD` | `Pixelmon Server` | Server message of the day |
| `LEVEL` | `world` | World directory name under `/data/world/` |

JVM arguments are configured via `/data/server-config/user_jvm_args.txt` in the ConfigMap. Operators are managed via `ops.json` in the ConfigMap (no `$OPS` env var).

## Troubleshooting

### Accept the EULA

Set the environment variable `EULA=true`, or mount a ConfigMap with `eula.txt` containing `eula=true`.

### Permissions of Files

The container runs as user `minecraft` with UID `1250` and GID `1250`. Ensure your PVC storage class supports `fsGroup: 1250` in the pod security context.

## Source

GitHub: https://github.com/andreaswachs/pixelmon

Container: `ghcr.io/andreaswachs/pixelmon:9.3.16-1`