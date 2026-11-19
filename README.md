# Skyrim Together Reborn on Pterodactyl

A Pterodactyl yolk and egg for the [Skyrim Together Reborn](https://github.com/tiltedphoques/TiltedEvolution) dedicated server, built on the official `tiltedphoques/st-reborn-server` image.

- **Image:** `ghcr.io/fossiltalk/st-reborn-yolk`, rebuilt by CI every Monday.
- **Egg:** [`egg-skyrim-together-reborn.json`](egg-skyrim-together-reborn.json)
- **Port:** UDP 10578 only

## Image tags

| Tag | Tracks |
|---|---|
| `1.8.4` (and other version tags) | A pinned release. **Use this.** |
| `stable` | Upstream `latest`. Moves when a new release ships. |
| `weekly` | Upstream `weekly-latest` (dev builds, e.g. `1.8.4-23-g13ff0b5a`). |

Wings pulls the image on every start, so a moving tag (`stable`, `weekly`) can update the server under you. Every player's STR client must match the server version, so keep the egg on a pinned tag.

## How the image works

- The binaries live in `/opt/stserver` inside the image. They are read-only and always match the tag.
- The server runs with its working directory set to `/home/container`, which is the Pterodactyl volume. It creates `config/STServer.ini`, `Data/`, `logs/` and `resources/` there.
- On each start, Wings writes these Panel variables into `config/STServer.ini`: name, passwords, max players, mod check, PvP, difficulty, port, and `bAnnounceServer=false`.
- The server writes its config back to the INI **when it shuts down**. Any edit you make while it's running is overwritten. Stop the server first, or use the Panel variables.

## Setup

1. Panel → Admin → Nests → **Create** "Skyrim" → **Import Egg**, then choose the JSON file in this repo.
2. Create a server from the egg. Use a UDP allocation of 10578. Give it 2 GB RAM, 2 CPU and 2 GB disk.
3. Set the Server Password (at least 8 characters) and the Admin Password.
4. Optional, for mod check: put the group's `loadorder.txt` in `Data/` and set Mod Check to `true`.
5. Once you're in game, run `/AddAdmin <character name>` in the Panel console.

Console commands: `/help`, `/players`, `/mods`, `/admins`, `/AddAdmin <name>`, `/RemoveAdmin <name>`, `/quit`.

## Tailscale (no port forwarding)

The WAN is behind CGNAT. Each game server gets its own Tailscale sidecar node on `pterodactyl_nw`. The sidecar DNATs tailnet traffic to the host port. See [`sidecar/`](sidecar):

1. Copy `sidecar/fwd-skyrim.sh` to `/mnt/cache/appdata/pterodactyl/sidecars/`.
2. Add `sidecar/compose-service.yml` to the sidecars compose file.
3. Run `docker compose up -d skyrim` to start only the new service. The Palworld and V Rising sidecars aren't touched.
4. Approve the login URL from `docker logs skyrim-ts`.
5. Share the `skyrim` node with friends from the Tailscale admin console.

## Updating

1. Check the current STR version on Nexus.
2. Wait until `ghcr.io/fossiltalk/st-reborn-yolk:<version>` exists. CI runs every Monday, or run the workflow by hand.
3. Add that version to the egg's `docker_images`, or set it on the server under Startup → Docker Image.
4. Stop the server.
5. Back it up (see below).
6. Switch the image and start the server.
7. Test with one player.
8. Tell the group to update STR to the same version.

## Backups

Back up `config/`, `Data/` (including `loadorder.txt`) and `logs/`. The server volume is at `/mnt/cache/appdata/pterodactyl/wings/lib/volumes/<server-uuid>/` on Tower, so either use Pterodactyl's backup feature or add that path to the existing backup job.

## For friends: how to connect

1. Accept the Tailscale node share for `skyrim` and keep Tailscale running.
2. From Nexus, install **Skyrim Together Reborn** (the same version as the server) and **Address Library for SKSE Plugins** (All-in-one, for 1.6.x).
3. If mod check is on, use exactly the mod list and load order you were given.
4. In game, open Skyrim Together, choose Direct Connect, and enter `skyrim:10578` (or the node's 100.x IP) and the server password.
