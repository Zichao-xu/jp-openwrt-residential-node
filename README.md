# OpenWrt Residential Exit Node Playbook

一个“寄给朋友后只要插电开机”的 OpenWrt 住宅出口节点方案。核心目标是：远端设备主动连回自有网关，提供一个可被 mihomo/Clash/sing-box 等上层代理栈按规则选择的单独出口，而不是把所有流量全局丢到远端。

本仓库是脱敏公开版，只包含方案、检查清单和配置模板。真实密码、密钥、DDNS、内网地址、Tailscale auth key、Wi-Fi SSID/密码、设备 MAC、overlay 备份包都不应提交。

## 设计目标

- 朋友无需进后台、无需端口转发、无需维护。
- 远端 OpenWrt 永远主动连出，适配对称 NAT/CGNAT。
- WireGuard 做业务出口底座，Tailscale 做低带宽救援管理。
- 有线 DHCP 优先；有线不可用时自动尝试预置 Wi-Fi 上行。
- reset 长按恢复到“黄金配置”，不是恢复到原厂空配置。
- BPI/主网关不切默认路由，只把指定代理流量送进远端出口。

## 推荐拓扑

```text
authorized clients
  -> home gateway / BPI / VPS frontend
  -> proxy core: mihomo / sing-box / xray
  -> policy route or explicit outbound
  -> WireGuard tunnel
  -> remote OpenWrt
  -> NAT to friend's residential broadband
  -> internet
```

## 仓库内容

- `docs/architecture.md`：整体架构和流量边界。
- `docs/preflight-checklist.md`：寄出前检查清单。
- `docs/recovery.md`：Tailscale 救援、watchdog、reset 黄金恢复。
- `openwrt/`：脱敏 UCI 配置模板。
- `scripts/`：可按需改造的安装和恢复脚本。
- `examples/`：mihomo/sing-box 接入思路示例。

## 安全边界

这个方案用于自有设备、授权网络和个人远程访问。不要把它用于未授权访问、规避服务条款、攻击、滥发流量或第三方滥用。

## 快速落地顺序

1. 清理 OpenWrt，只保留网络、LuCI、防火墙、WireGuard、Tailscale、必要诊断工具。
2. 扩容 overlay，避免安装软件时写满。
3. 所有有线口合并成 DHCP client 桥，关闭本机 DHCP/DNS/AP。
4. 配置 `wg_exit`：远端 OpenWrt 主动连回主网关。
5. 主网关只对代理进程/指定流量走 `wg_exit`，不要改全局默认路由。
6. 配置 Tailscale 为救援通道：不接管 DNS、不接收路由、不做 exit node。
7. 配置有线优先、Wi-Fi 兜底。
8. 部署 watchdog 和 reset 黄金恢复。
9. 做短时打流、重启、断网恢复、reset 恢复演练。
