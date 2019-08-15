#! /bin/bash

set -e

function with_echo()
{
  echo "$@"
  "$@"
}

for i in /dev/sd[a-z]; do
	devname=$(basename $i)
	removable=$(cat /sys/block/$devname/removable)
	if test "$removable" = "0"; then
		with_echo smartctl -t long $i
		# don't test all disks at the same time
		sleep 3600
	fi
done
