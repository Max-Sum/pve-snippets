#!/bin/bash
# This script restart the NIC after it's been return to host.
# Noted that only OVS support this trick.
# Linux Bridge requires systemctl restart networking to work.
# Set to VM: qm set <vmid> --hookscript local:snippets/restart-nic.sh

VMID=$1
PHASE=$2

PWD=$(dirname "$(realpath $0)")

if [ "$PHASE" = "post-stop" ]; then
  $PWD/return-hostpci.pl $@
  ip link set enp2s0 up
fi
