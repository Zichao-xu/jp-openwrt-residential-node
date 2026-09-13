#!/bin/sh
set -eu

GOLDEN_DIR="${GOLDEN_DIR:-/mnt/persistent/golden}"
mkdir -p "$GOLDEN_DIR"
tmp="$GOLDEN_DIR/overlay-upper.tar.gz.tmp"

cd /overlay/upper
tar -czf "$tmp" .
sha256sum "$tmp" > "$tmp.sha256"
mv "$tmp" "$GOLDEN_DIR/overlay-upper.tar.gz"
sed 's/overlay-upper.tar.gz.tmp/overlay-upper.tar.gz/' "$tmp.sha256" > "$GOLDEN_DIR/overlay-upper.tar.gz.sha256"
rm -f "$tmp.sha256"
chmod 600 "$GOLDEN_DIR/overlay-upper.tar.gz" "$GOLDEN_DIR/overlay-upper.tar.gz.sha256"
sha256sum -c "$GOLDEN_DIR/overlay-upper.tar.gz.sha256"
