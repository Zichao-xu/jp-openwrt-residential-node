#!/bin/sh
set -eu

: "${TAILSCALE_AUTH_KEY:?set TAILSCALE_AUTH_KEY first}"
: "${TAILSCALE_HOSTNAME:=openwrt-rescue}"

tailscale up \
  --authkey="$TAILSCALE_AUTH_KEY" \
  --hostname="$TAILSCALE_HOSTNAME" \
  --accept-dns=false \
  --accept-routes=false \
  --advertise-routes= \
  --advertise-exit-node=false \
  --netfilter-mode=off
