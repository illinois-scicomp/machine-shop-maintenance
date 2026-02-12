#! /bin/bash

set -e

cd /etc/scicomp-users

if curl -s --fail --insecure -O https://porter:Cahk4voh@porter.cs.illinois.edu:1020/userdb.yml; then
  pipx install uv
  export PATH="$PATH:$HOME/.local/bin"
  /opt/extrausers-maint/extrausers-maint --db /etc/scicomp-users/userdb.yml update --with-shared
else
  echo "*** FAILED TO UPDATE USER DATABASE"
fi

