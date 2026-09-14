# Preflight Checklist

## Before Installing Packages

- Confirm overlay storage is large enough.
- Confirm opkg feeds work from the current region.
- Keep a local backup of current `/etc/config/*`.
- Record the physical port mapping.

## OpenWrt Service Scope

Keep:

- `dropbear`
- `uhttpd` / LuCI
- `firewall`
- `wireguard-tools`
- `kmod-wireguard`
- `tailscale` and `tailscaled`
- `iperf3` for diagnostics

Remove or disable unrelated services:

- ad blockers
- transparent proxy plugins not used in this node
- file sharing
- Docker
- UPnP
- DDNS on the remote node
- media services
- printer services
- unused VPN servers

## Network Shape

Remote OpenWrt:

- All physical Ethernet ports in one DHCP-client bridge.
- No DHCP server.
- No DNS listener for clients.
- No Wi-Fi AP.
- Optional STA Wi-Fi uplinks in a separate low-priority `wifiwan` zone.

Home gateway:

- Dedicated WireGuard interface for the remote exit.
- Existing tunnels and normal default route left unchanged.
- Route only selected proxy traffic through the remote exit.
- If enabling IPv6, validate it as a separate path after IPv4 passes.
- IPv4 watchdogs, management access, and proxy rules must continue working when IPv6 is unavailable.

## Must-Test Before Shipping

- Reboot returns online.
- WireGuard handshake recovers.
- IPv4 proxy path works before any IPv6 changes.
- Tailscale rescue address is reachable from a separate network.
- Wired DHCP has priority over Wi-Fi.
- Wi-Fi fallback associates when wired is unavailable.
- Optional IPv6 does not break IPv4 when upstream IPv6 is missing, filtered, or renumbered.
- Long reset restores the golden configuration.
- Login page works from desktop and mobile width.
- Short iperf test does not overheat or exhaust memory.
