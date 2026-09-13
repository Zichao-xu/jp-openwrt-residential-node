# Security Notes

Never commit:

- WireGuard private keys
- Tailscale auth keys
- SSH passwords
- Wi-Fi SSID/passwords from private homes
- Real DDNS names or public IPs
- Real internal management IPs
- MAC addresses
- LuCI session cookies
- overlay backups
- router backup archives

Use placeholders in public documentation:

```text
vpn.example.net
10.77.0.1
10.77.0.2
<REMOTE_WG_PRIVATE_KEY>
<HOME_WG_PUBLIC_KEY>
<TAILSCALE_AUTH_KEY>
<FRIEND_WIFI_PASSWORD>
```

If a secret was ever committed, rotate it. Removing it from a later commit is not enough.
