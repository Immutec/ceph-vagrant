#!/usr/bin/env bash

if [ ! -f /vagrant/ceph.pub ]; then
  echo "Ceph.pub missing" 1>&2;
  exit 1;
fi

cat /vagrant/ceph.pub >> /root/.ssh/authorized_keys