# mihomo Integration Notes

The OpenWrt node should appear to mihomo as one selectable outbound path, not as a global default route.

Recommended shape:

```text
client -> mihomo proxy group -> home gateway service -> wg_exit -> remote OpenWrt -> residential ISP
```

Practical choices:

- Run mihomo on the home gateway and create a dedicated outbound for the remote exit.
- Or run sing-box/xray on the home gateway and let mihomo select that node.
- Keep DNS/Fake-IP behavior on the home gateway; do not let the remote OpenWrt become a general DNS server.

Validation:

- A rule-selected request should show the remote residential ISP.
- A direct request from the home gateway should still show the home gateway's normal ISP.
- Existing tunnels should not be rerouted through the remote node unless explicitly selected.
