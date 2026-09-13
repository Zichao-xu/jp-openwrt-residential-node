#!/bin/sh
set -eu

GOLDEN_DIR="${GOLDEN_DIR:-/mnt/persistent/golden}"
ARCHIVE="$GOLDEN_DIR/overlay-upper.tar.gz"
SUM="$ARCHIVE.sha256"

[ -f "$ARCHIVE" ] || { echo "missing $ARCHIVE" >&2; exit 1; }
[ -f "$SUM" ] || { echo "missing $SUM" >&2; exit 1; }

sha256sum -c "$SUM"

rm -rf /overlay/upper.restore
mkdir -p /overlay/upper.restore
tar -xzf "$ARCHIVE" -C /overlay/upper.restore

mv /overlay/upper /overlay/upper.before-golden-restore.$(date +%s)
mv /overlay/upper.restore /overlay/upper
sync
reboot
