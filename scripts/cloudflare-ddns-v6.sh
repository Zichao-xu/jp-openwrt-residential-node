#!/bin/sh
set -u

ENV_FILE="${ENV_FILE:-/etc/cloudflare-ddns.env}"
STATE_FILE="${STATE_FILE:-/tmp/cf-ddns-v6.last}"
LOG_TAG="${LOG_TAG:-cf-ddns-v6}"
API="https://api.cloudflare.com/client/v4"

[ -f "$ENV_FILE" ] || exit 0
. "$ENV_FILE"

: "${CF_API_TOKEN:=}"
: "${CF_ZONE_NAME:=}"
: "${CF_RECORD_NAME:=}"
: "${CF_IPV6_IFACE:=br-lan}"
: "${CF_PROXIED:=false}"
: "${CF_TTL:=120}"

if [ -z "$CF_API_TOKEN" ] || [ -z "$CF_ZONE_NAME" ] || [ -z "$CF_RECORD_NAME" ]; then
	logger -t "$LOG_TAG" "disabled: missing Cloudflare token, zone, or record name"
	exit 0
fi

IPV6="$(ip -6 addr show dev "$CF_IPV6_IFACE" scope global 2>/dev/null | awk '
	/inet6/ {
		split($2, a, "/"); ip=a[1];
		if (ip !~ /^fe80:/ && ip !~ /^fd/ && ip !~ /^fc/ && ip !~ /^::1$/) { print ip; exit }
	}')"

if [ -z "$IPV6" ]; then
	logger -t "$LOG_TAG" "no global IPv6 found on $CF_IPV6_IFACE"
	exit 0
fi

LAST="$(cat "$STATE_FILE" 2>/dev/null || true)"
[ "$LAST" = "$IPV6" ] && exit 0

AUTH_HEADER="Authorization: Bearer $CF_API_TOKEN"
JSON_HEADER="Content-Type: application/json"

ZONE_ID="$(curl -fsS -H "$AUTH_HEADER" "$API/zones?name=$CF_ZONE_NAME" | jq -r '.result[0].id // empty')"
if [ -z "$ZONE_ID" ]; then
	logger -t "$LOG_TAG" "failed to resolve zone $CF_ZONE_NAME"
	exit 1
fi

RECORD_ID="$(curl -fsS -H "$AUTH_HEADER" "$API/zones/$ZONE_ID/dns_records?type=AAAA&name=$CF_RECORD_NAME" | jq -r '.result[0].id // empty')"
BODY="$(jq -cn --arg type AAAA --arg name "$CF_RECORD_NAME" --arg content "$IPV6" --argjson ttl "$CF_TTL" --argjson proxied "$CF_PROXIED" '{type:$type,name:$name,content:$content,ttl:$ttl,proxied:$proxied}')"

if [ -n "$RECORD_ID" ]; then
	RESP="$(curl -fsS -X PUT -H "$AUTH_HEADER" -H "$JSON_HEADER" --data "$BODY" "$API/zones/$ZONE_ID/dns_records/$RECORD_ID")"
else
	RESP="$(curl -fsS -X POST -H "$AUTH_HEADER" -H "$JSON_HEADER" --data "$BODY" "$API/zones/$ZONE_ID/dns_records")"
fi

OK="$(printf "%s" "$RESP" | jq -r '.success')"
if [ "$OK" = "true" ]; then
	echo "$IPV6" > "$STATE_FILE"
	logger -t "$LOG_TAG" "updated $CF_RECORD_NAME AAAA to $IPV6"
else
	logger -t "$LOG_TAG" "Cloudflare API update failed"
	exit 1
fi
