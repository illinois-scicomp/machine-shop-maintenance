#! /bin/bash

set -e
set -x

cd /shared/config

mkdir -p /root/.ssh
cp root_.ssh_authorized_keys /root/.ssh/authorized_keys

cp etc_apt_apt.conf /etc/apt/apt.conf
cp etc_apt_sources.list /etc/apt/sources.list

apt update
apt install aptitude \
  etckeeper htop tmux sudo apt-listbugs apt-listchanges zsh \
  moreutils \
  unattended-upgrades \
  curl python3-yaml \
  libnss-extrausers \
  mlocate

cp etc_apt_apt.conf.d_02periodic /etc/apt/apt.conf.d/02periodic
cp etc_apt_apt.conf.d_50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades

mkdir -p /etc/scicomp-users
if [[ "$(hostname)" != "porter" ]]; then
  cp etc_scicomp-users_update.sh /etc/scicomp-users/update.sh
  cp etc_scicomp-users_update-motd.sh /etc/scicomp-users/update-motd.sh
fi
cp etc_cron.d_scicomp-users /etc/cron.d/scicomp-users

cp etc_sysctl.d_80-allow-unpriv-perf.conf /etc/sysctl.d/80-allow-unpriv-perf.conf

(cd /etc/cron.daily; rm -f snapshot-filesystems; ln -s /shared/tools/snapshot-filesystems)

echo "COMPLETED SUCCESSFULLY"
