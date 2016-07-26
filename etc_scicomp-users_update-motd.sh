#! /bin/bash

set -e

cd /etc/scicomp-users

if curl -s --fail --insecure -O https://porter:Cahk4voh@porter.cs.illinois.edu:1020/motd; then
  cp motd /etc/motd
else
  echo "*** FAILED TO UPDATE MOTD"
fi
