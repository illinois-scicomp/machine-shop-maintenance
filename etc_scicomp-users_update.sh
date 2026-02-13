#! /bin/bash

set -e

cd /etc/scicomp-users

if curl -s --fail --insecure -O https://porter:Cahk4voh@porter.cs.illinois.edu:1020/userdb.yml; then
  export PATH="$PATH:$HOME/.local/bin"
  if ! command -v uv &> /dev/null ; then
    pipx install uv
  fi
  /opt/extrausers-maint/extrausers-maint --db /etc/scicomp-users/userdb.yml update --with-shared
else
  echo "*** FAILED TO UPDATE USER DATABASE"
fi

