# Recovery Design

## Layers

Use multiple independent recovery paths:

1. WireGuard management through the business tunnel.
2. Tailscale rescue to the OpenWrt itself.
3. Wired DHCP uplink.
4. Wi-Fi fallback uplink.
5. Long-press reset to restore a golden overlay snapshot.

## Tailscale Rescue Rules

Recommended behavior:

- No route advertisement.
- No accepted routes.
- No DNS override.
- No exit-node behavior.
- Firewall input allowed only to the OpenWrt itself.
- Forwarding rejected.

The rescue channel is for LuCI/SSH maintenance, not traffic forwarding.

## Watchdog Rules

The watchdog should be conservative:

- Check default gateway.
- Check WireGuard peer reachability.
- Check WireGuard handshake age.
- First restart the tunnel.
- Then reload networking.
- Reboot only after repeated failures and a cooldown.

Avoid fast reboot loops.

## Golden Reset

Instead of factory reset, long reset should restore a known-good overlay archive.

Recommended archive location:

```text
/mnt/persistent/golden/overlay-upper.tar.gz
/mnt/persistent/golden/overlay-upper.tar.gz.sha256
```

Recommended behavior:

- Verify checksum.
- Replace `/overlay/upper`.
- Reboot.
- Keep the restore script and button handler inside the golden archive.

Refresh the golden archive after any meaningful network, rescue, theme, package, or watchdog change.
