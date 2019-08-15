#! /bin/bash

set -e

cd /shared/config

function with_echo()
{
  echo "$@"
  $@
}

function cp_from_config()
{
  ROOT_FS_NAME="$1"
  CONFIG_MANGLED_NAME="${ROOT_FS_NAME#/}"
  CONFIG_MANGLED_NAME="$(echo "$CONFIG_MANGLED_NAME" | tr / _ )"
  with_echo cp "$CONFIG_MANGLED_NAME" "$ROOT_FS_NAME"
}

with_echo mkdir -p /root/.ssh
cp_from_config /root/.ssh/authorized_keys

cp_from_config /etc/apt/apt.conf
cp_from_config /etc/apt/sources.list

cp_from_config /etc/apt/apt.conf.d/02periodic
cp_from_config /etc/apt/apt.conf.d/50unattended-upgrades
rm -f /etc/apt/preferences.d/prevent-broken-gmsh

# /shared/software/gmsh/unscrew-gmsh.sh
with_echo apt update
with_echo apt install -y aptitude \
  etckeeper logrotate \
  htop iotop iftop tcpdump ncdu rsync unison-all \
  tmux sudo apt-listbugs apt-listchanges \
  zsh csh tcsh fish \
  moreutils \
  tig subversion mercurial \
  unattended-upgrades \
  curl python3-yaml \
  libnss-extrausers \
  mlocate \
  exim4 \
  libgmp-dev libmpfr-dev \
  vim-nox emacs \
  python3-psutil \
  prometheus-node-exporter \
  net-tools \
  python{,3}-scipy python{,3}-matplotlib \
  python{,3}-pyside python-qt4 python{,3}-pyqt5 \
  flake8 python3-pep8-naming \
  python3-venv python{,3}-virtualenv python{,3}-setuptools python{,3}-pip \
  silversearcher-ag \
  texlive-xetex texlive-publishers texlive-science texlive-bibtex-extra biber \
  mc fzf \
  gmsh occt-draw occt-misc \
  libopenmpi-dev openmpi-common \
  systemd-coredump \
  likwid \
  ffmpeg \
  ocl-icd-opencl-dev ocl-icd-libopencl1 oclgrind \
  build-essential llvm-dev libclang-dev gdb strace ltrace valgrind \
  libblas-dev liblapack-dev libopenblas-dev \
  opensc-pkcs11

# (not currently due to https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=931337)
# maxima 
# (not currently due to https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=932707)
# pocl-opencl-icd 
apt-get remove --purge \
	pocl-opencl-icd libpocl2 libpocl2-common \
	maxima

echo "Clearing gitlab runner cache"
rm -Rf /var/lib/gitlab-runner/.cache/
echo "Clearing gitlab runner cache: done"


mkdir -p /etc/scicomp-users
if [[ "$(hostname)" != "porter" ]]; then
  cp_from_config /etc/scicomp-users/update.sh
  cp_from_config /etc/scicomp-users/update-motd.sh
fi
cp_from_config /etc/cron.d/scicomp-users

cp_from_config /etc/sysctl.d/80-allow-unpriv-perf.conf
sysctl -p /etc/sysctl.d/80-allow-unpriv-perf.conf

cp_from_config /etc/openmpi/openmpi-mca-params.conf
cp_from_config /etc/cron.daily/clean-up-stuck-ci-jobs

/shared/config/install-intel-icd.sh

(cd /etc/cron.daily; rm -f run-smart-tests.sh; ln -s /shared/tools/run-smart-tests.sh)

# (cd /etc/cron.daily; rm -f snapshot-filesystems; ln -s /shared/tools/snapshot-filesystems)

echo "COMPLETED SUCCESSFULLY"
