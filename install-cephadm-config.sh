#!/usr/bin/env bash

# Add the other hosts and configure it
ceph orch host label add ceph-0 osd,mgr
ceph orch host add ceph-1 192.168.57.11 --labels=osd,rgw
ceph orch host add ceph-2 192.168.57.12 --labels=osd,rgw
ceph orch host add ceph-3 192.168.57.13 --labels=osd
ceph orch host add ceph-4 192.168.57.14 --labels=osd
ceph orch host add ceph-5 192.168.57.15 --labels=osd,mgr

ceph orch host add ceph-mon-0 192.168.57.20 --labels=mon
ceph orch host add ceph-mon-1 192.168.57.21 --labels=mon
ceph orch host add ceph-mon-2 192.168.57.22 --labels=mon

ceph orch host add ceph-mds-0 192.168.57.30 --labels=mds
ceph orch host add ceph-mds-1 192.168.57.31 --labels=mds

# normally we would run the line below but we don't want all drives added,
# we need to prevent it from adding the 10mb config drive
# ceph orch apply osd --all-available-devices

# this is for debugging, this takes for ever!
# ceph orch apply osd --all-available-devices --dry-run

# gives:
# WARNING! Dry-Runs are snapshots of a certain point in time and are bound
# to the current inventory setup. If any of these conditions change, the
# preview will be invalid. Please make sure to have a minimal
# timeframe between planning and applying the specs.
# ####################
# SERVICESPEC PREVIEWS
# ####################
# +---------+------+--------+-------------+
# |SERVICE  |NAME  |ADD_TO  |REMOVE_FROM  |
# +---------+------+--------+-------------+
# +---------+------+--------+-------------+
# ################
# OSDSPEC PREVIEWS
# ################
# Preview data is being generated.. Please re-run this command in a bit.
#
# Created osd(s) 0,1,2,3,4,5,6,7,8,9 on host 'ceph-0'
# Created osd(s) 10,11,12,13,14,15,16 on host 'ceph-1'
# Created osd(s) 17,18,19,20,21,22,23 on host 'ceph-2'
# Created osd(s) 24,25,26,27,28,29,30 on host 'ceph-3'
# Created osd(s) 31,32,33,34,35,36,37 on host 'ceph-4'
# Created osd(s) 38,39,40,41,42,43,44 on host 'ceph-5'



# advanced setup - https://docs.ceph.com/en/reef/cephadm/services/osd/#creating-new-osds
ceph orch daemon add osd ceph-0:data_devices=/dev/sdc,/dev/sdd,/dev/sde,/dev/sdf,/dev/sdg,/dev/sdh,/dev/sdi,/dev/nvme0n1,/dev/nvme0n2,db_devices=/dev/nvme0n3,/dev/nvme0n4

for i in {1..5}
do
  ceph orch daemon add osd ceph-$i:/dev/sdc,/dev/sdd,/dev/sde,/dev/sdf,/dev/sdg,/dev/sdh,/dev/sdi,/dev/nvme0n1,/dev/nvme0n2,/dev/nvme0n3,/dev/nvme0n4
  # ceph orch daemon add osd ceph-$i:data_devices=/dev/sdc,/dev/sdd,/dev/sde,/dev/sdf,/dev/sdg,db_devices=/dev/sdh,/dev/sdi,osds_per_device=2
done

for i in {0..2}
do
  ceph orch daemon add osd ceph-mon-$i:/dev/nvme0n1,/dev/nvme0n2,/dev/nvme0n3,db_devices=/dev/nvme0n4
done

# Ceph Object Storage does NOT use the Ceph Metadata Server.
for i in {0..1}
do
  ceph orch daemon add osd ceph-mds-$i:/dev/nvme0n1,/dev/nvme0n2,/dev/nvme0n3,db_devices=/dev/nvme0n4
done

###########
### RGW ###
###########
# https://docs.ceph.com/en/reef/cephadm/services/rgw/#trivial-setup

# Enable RGW for bucket storage
ceph dashboard set-rgw-credentials

# Disable SSL verify for RGW since we won't have a valid SSL cert
ceph dashboard set-rgw-api-ssl-verify False

# deploy 2 RGW daemons (the default) for a single-cluster RGW deployment under the arbitrary service id rgw-example
# Apply it to all hosts that has the RGW label and run them twice
ceph orch apply rgw rgw-example '--placement=label:rgw count-per-host:2' --port=8000


###########
### MDS ###
###########
# https://docs.ceph.com/en/reef/cephadm/services/mds/#mds-service
ceph fs volume create mfs-fs-example --placement="label:mds"

#############
### iSCSI ###
#############
# Disable SSL verify for iSCSI since we won't have a valid SSL cert
ceph dashboard set-iscsi-api-ssl-verification false


###############
### radosgw ###
### zoning  ###
###############
# https://docs.ceph.com/en/quincy/radosgw/multisite/

# Show details
ceph orch host ls --detail
