# Optional Cloudflare Layer

Cloudflare can be useful as a low-bandwidth rescue and discovery layer, but it should not replace the primary WireGuard path.

## AAAA DDNS

Use AAAA DDNS when the remote OpenWrt receives a usable global IPv6 address from the upstream router.

Recommended behavior:

- Update a DNS-only AAAA record such as `jp6.example.com`.
- Read the IPv6 address from the upstream bridge or WAN interface.
- Do not proxy this record unless the target service is HTTP(S) and intentionally exposed.
- Keep the API token outside public configs.

Minimal token permissions:

```text
Zone:DNS:Edit
Zone:Zone:Read
```

Prefer a token scoped to one zone.

Validation should include both the provider API and DNS resolution from the remote node or controller. If the local workstation uses fake-IP DNS, do not treat local `dig` output as authoritative; prefer DoH or a clean resolver path.

## Cloudflare Tunnel

Cloudflare Tunnel can expose LuCI or a maintenance page without inbound ports. Use it only with Cloudflare Access or another authentication layer.

Recommended hostname shape:

```text
jp-op.example.com -> cloudflared -> http://127.0.0.1:80
```

Do not enable the tunnel service until:

- the tunnel token or credentials file exists
- Access policy is configured
- the exposed origin is confirmed
- WireGuard/Tailscale rescue still works independently

Recommended Access policy:

```text
Application: jp-openwrt-rescue
Destination: jp-op.example.com
Action: Allow
Include: Emails -> owner@example.com
```

Validate from a client without Cloudflare Access cookies:

```sh
curl -I -L --max-redirs 3 https://jp-op.example.com/
```

The first response should redirect to `*.cloudflareaccess.com`. It should not return the LuCI login page directly.

On older OpenWrt packages, token-mode init scripts may pass the tunnel token as a process argument. That is usable for a sealed appliance, but a credentials-file setup is cleaner when supported by the package version.

## Operational Boundary

- WireGuard remains the business path.
- Tailscale remains the private rescue path.
- Cloudflare Tunnel is an optional web rescue path.
- Cloudflare DDNS is only a pointer to the current IPv6 address.
