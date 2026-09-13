#!/bin/sh
set -eu

WG_IF="${WG_IF:-wg_exit}"
WG_PEER_IP="${WG_PEER_IP:-10.77.0.1}"
MAX_HANDSHAKE_AGE="${MAX_HANDSHAKE_AGE:-180}"
FAIL_FILE="${FAIL_FILE:-/tmp/jp-node-watchdog.failures}"
REBOOT_AFTER="${REBOOT_AFTER:-12}"

now="$(date +%s)"
failures="$(cat "$FAIL_FILE" 2>/dev/null || echo 0)"

mark_failure() {
	failures=$((failures + 1))
	echo "$failures" > "$FAIL_FILE"
	logger -t jp-node-watchdog "failure count=$failures reason=$1"
	if [ "$failures" -eq 3 ]; then
		ifdown "$WG_IF" 2>/dev/null || true
		ifup "$WG_IF" 2>/dev/null || true
	elif [ "$failures" -eq 6 ]; then
		/etc/init.d/network reload 2>/dev/null || true
	elif [ "$failures" -ge "$REBOOT_AFTER" ]; then
		logger -t jp-node-watchdog "rebooting after repeated failures"
		reboot
	fi
	exit 1
}

ip route | grep -q '^default ' || mark_failure "no-default-route"
ping -c 1 -W 3 "$WG_PEER_IP" >/dev/null 2>&1 || mark_failure "wg-peer-unreachable"

latest="$(wg show "$WG_IF" latest-handshakes 2>/dev/null | awk '{print $2}' | sort -nr | head -n 1)"
[ -n "$latest" ] || mark_failure "no-handshake"

age=$((now - latest))
[ "$age" -le "$MAX_HANDSHAKE_AGE" ] || mark_failure "handshake-age-$age"

echo 0 > "$FAIL_FILE"
logger -t jp-node-watchdog "healthy"
