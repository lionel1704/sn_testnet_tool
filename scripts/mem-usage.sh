#!/bin/bash

# https://betterdev.blog/minimal-safe-bash-script-template/
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
TESTNET_CHANNEL=$(terraform workspace show)

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

echo "Mem usage in mbs for $TESTNET_CHANNEL nodes at ip:"
mkdir -p logs
for ip in $(<${TESTNET_CHANNEL}-ip-list xargs); do
    mb=$(ssh root@${ip} 'process=$(pgrep sn_node -n) && xargs pmap $process | awk "/total/ { b=int(\$2/1024); printf b};"' ) && echo "$ip:    ${mb}MB" &

done

cleanup