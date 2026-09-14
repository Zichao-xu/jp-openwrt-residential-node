#!/bin/sh
set -eu

SRC_PREFIX="${SRC_PREFIX:-fd77:77:77::/64}"
OUT_IF="${OUT_IF:-br-lan}"

command -v ip6tables >/dev/null 2>&1 || exit 0

ip6tables -t nat -C POSTROUTING -s "$SRC_PREFIX" -o "$OUT_IF" -j MASQUERADE 2>/dev/null || \
	ip6tables -t nat -A POSTROUTING -s "$SRC_PREFIX" -o "$OUT_IF" -j MASQUERADE
