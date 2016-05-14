#!/bin/bash
#
# Use virsh to call the qemu-guest-agent to sync the guest's time
#
# usage: /usr/local/lib/virsh-sync-guest-time.sh $GUEST_NAME

if [[ $# -eq 1 ]]; then
    guest=$1
else
    echo "Syntax: $0 <guest_name>"
    exit 1
fi

logger -p local0.notice "$0 syncing time of guest '$guest'"

virsh qemu-agent-command "$guest" '{"execute": "guest-set-time"}'
