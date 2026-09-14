# Architecture

## Roles

### Home gateway

Usually a router or small Linux gateway with a public endpoint or stable relay path.

Responsibilities:

- Listen for WireGuard from the remote OpenWrt node.
- Run or forward proxy services such as mihomo, sing-box, Trojan, VLESS, or AnyTLS.
- Keep the normal default route unchanged.
- Send only selected proxy traffic into the remote WireGuard peer.

### Remote OpenWrt node

The device placed at the friend's home.

Responsibilities:

- Act as a WireGuard client.
- NAT traffic from the tunnel to the local upstream.
- Prefer wired DHCP uplink.
- Fall back to known Wi-Fi uplinks only when wired is not usable.
- Keep a separate rescue-management channel.
- Recover to a known-good configuration on long reset press.

## Addressing Example

Use documentation-only placeholders here. Replace them in your private deployment files.

```text
home wg_exit:       10.77.0.1/24
remote wg_exit:     10.77.0.2/32
optional IPv6 ULA:  fd77:77:77::1/64 and fd77:77:77::2/128
home endpoint:      vpn.example.net:51821
remote LAN DHCP:    assigned by upstream router
tailscale rescue:   assigned by tailnet
```

The home gateway peer may use `AllowedIPs = 0.0.0.0/0` for the remote peer, but route installation must be disabled. This lets explicitly selected traffic use the remote peer without changing the gateway's system default route.

IPv6 is optional. Keep the IPv4 tunnel and IPv4 policy route working first. Add IPv6 as a separate address family after IPv4 validation, and do not make IPv4 health checks depend on IPv6.

## Traffic Boundary

The important rule is:

```text
normal gateway traffic:  stays on normal WAN
selected proxy traffic:  policy route -> wg_exit -> remote OpenWrt -> residential uplink
optional IPv6 traffic:   separate IPv6 policy or explicit proxy outbound
rescue management:       Tailscale only to the OpenWrt itself
```

Do not mix the rescue channel with the business exit path. Tailscale should not advertise routes, accept routes, change DNS, or become an exit node unless you intentionally redesign the system.
