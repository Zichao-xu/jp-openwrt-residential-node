# Optional Dual-Stack Design

IPv6 should be an optional layer on top of a working IPv4 design. Do not make IPv4 proxying, WireGuard liveness, reset recovery, or rescue management depend on IPv6.

## Recommended Order

1. Build and validate IPv4-only first.
2. Add IPv6 addresses inside the WireGuard tunnel.
3. Add IPv6 forwarding and firewall rules.
4. Decide whether the remote residential uplink actually has usable IPv6.
5. Route IPv6 only for selected proxy traffic.
6. Test IPv4 again after every IPv6 change.

## Tunnel Addressing

Use a ULA prefix inside the WireGuard tunnel:

```text
home wg_exit:    fd77:77:77::1/64
remote wg_exit:  fd77:77:77::2/128
```

This only gives IPv6 inside the tunnel. It does not automatically provide IPv6 internet egress.

## Egress Options

### Option A: IPv4 Egress Only, IPv6 Tunnel Management

Safest default.

- IPv4 proxy egress works normally.
- IPv6 tunnel addresses can be used for diagnostics or future routing.
- No IPv6 internet forwarding is enabled.

### Option B: Native Remote IPv6 Egress

Use only if the friend's ISP provides stable IPv6.

Requirements:

- Remote OpenWrt receives a global IPv6 address or prefix from upstream.
- Firewall allows selected tunnel IPv6 forwarding.
- The home gateway routes only selected IPv6 proxy traffic to the remote peer.
- If upstream IPv6 disappears, IPv4 still works.

If the remote OpenWrt receives a source-specific IPv6 default route, disable source filtering on the upstream IPv6 client interface. Otherwise packets sourced from the WireGuard ULA prefix may be treated as unreachable before firewall/NAT rules see them.

### Option C: Narrow NAT66

Use only for selected WireGuard-originated IPv6 egress when native prefix delegation to the tunnel is not available.

Recommended scope:

```text
source: fd77:77:77::/64
out:    upstream bridge or WAN device
target: MASQUERADE
```

Do not apply broad IPv6 masquerading to every interface. Keep IPv4 independent and keep the home gateway without a global IPv6 default route unless you intentionally add policy routing.

## WireGuard Template Delta

Add IPv6 addresses and peer allowed IPs separately:

```text
remote interface address: fd77:77:77::2/128
remote peer allowed_ips:  fd77:77:77::1/128

home interface address:   fd77:77:77::1/64
home peer allowed_ips:    fd77:77:77::2/128
```

Do not add `::/0` until you have a deliberate IPv6 policy route or explicit proxy outbound.

For a home gateway peer that must be capable of sending selected IPv6 traffic to the remote node, `::/0` may be added to the peer's AllowedIPs only when automatic route installation is disabled. This makes WireGuard cryptokey routing possible without changing the gateway's global IPv6 route table.

## Health Checks

IPv4 health checks should remain authoritative:

- IPv4 default gateway exists.
- IPv4 WireGuard peer responds.
- WireGuard handshake age is fresh.

IPv6 checks may be informational:

- `ping6 fd77:77:77::1`
- remote has a global IPv6 route
- selected IPv6 egress test shows the expected residential ISP

If IPv6 fails but IPv4 is healthy, the watchdog should not reboot the node.

## Validation

Minimum tests:

- Remote OpenWrt can `ping6` a public IPv6 address through its upstream.
- Home gateway can `ping6` the remote tunnel ULA.
- A temporary single-destination IPv6 route on the home gateway can pass through the remote node.
- The temporary route is removed after testing.
- Home gateway IPv4 default route remains unchanged.
