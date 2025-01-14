#!/usr/bin/env bash

# done in install-vm.sh
# cephadm add-repo --release squid

LOG_FILE=/vagrant/log-$(hostname)
FSID_REGEX='fsid\s([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})'
ENV_FILE="/vagrant/ENV"

cephadm install
cephadm install ceph-common
cephadm bootstrap --mon-ip 192.168.57.10 >> "$LOG_FILE"

cp /etc/ceph/ceph.pub /vagrant/ceph.pub
line=$(grep -E -i "$FSID_REGEX" "$LOG_FILE")
if [[ "$line" =~ $FSID_REGEX ]]; then
  echo "FSID=${BASH_REMATCH[1]}" > "$ENV_FILE"
else
  echo "Unable to find FSID" 1>&2;
  exit 1;
fi
