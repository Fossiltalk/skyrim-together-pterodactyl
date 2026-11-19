#!/bin/sh
# Tailscale sidecar for the Skyrim Together server: DNAT tailnet UDP 10578 to the
# Pterodactyl allocation on the host (via the pterodactyl_nw gateway).
set -e
H=172.30.0.1
P=${GAME_PORT:-10578}
iptables -t nat -A PREROUTING -i tailscale0 -p udp --dport 10578 -j DNAT --to-destination $H:$P
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
exec /usr/local/bin/containerboot
