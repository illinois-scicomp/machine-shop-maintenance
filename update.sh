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
# {{{ install/update extrausers-maint

function install_extrausers_maint()
{
        cd /opt/
        if test -d extrausers-maint; then
                rm -Rf /opt/extrausers-maint
        fi
        git clone https://github.com/inducer/extrausers-maint
}

( install_extrausers_maint )

# }}}

with_echo mkdir -p /root/.ssh
cp_from_config /root/.ssh/authorized_keys

cp_from_config /etc/apt/apt.conf
cp_from_config /etc/apt/sources.list
cp_from_config /etc/apt/sources.list.d/kepler-cuda-toolkit.list

cp_from_config /etc/apt/apt.conf.d/02periodic
cp_from_config /etc/apt/apt.conf.d/50unattended-upgrades
cp_from_config /etc/sudoers.d/scicomp-extrasudo

rm -f /etc/apt/preferences.d/prevent-broken-gmsh

if test -L /usr/bin/maxima; then
        # old symlink from a bug workaround
        rm -f /usr/bin/maxima
fi

with_echo apt update
with_echo apt install -y aptitude \
  spectre-meltdown-checker smartmontools docker systemd-resolved \
  netcat-traditional elinks \
  iucode-tool \
  rsync \
  etckeeper logrotate gnupg2 \
  htop iotop iftop tcpdump mtr ncdu rsync unison-all unison-all-gtk \
  tmux screen tmate sudo apt-listbugs apt-listchanges reptyr \
  zsh csh tcsh fish \
  moreutils \
  tig subversion mercurial git-lfs gh \
  unattended-upgrades \
  curl \
  libnss-extrausers \
  mlocate \
  exim4 \
  libgmp-dev libmpfr-dev \
  libpq-dev libjemalloc-dev \
  vim-nox emacs exuberant-ctags micro \
  python3-psutil python3-yaml python3-websockets \
  prometheus-node-exporter \
  net-tools acl \
  pypy3 pypy3-dev \
  python3-scipy python3-matplotlib \
  swig \
  python3-pyqt5 \
  flake8 python3-pep8-naming \
  python3-dbg python3-venv python3-virtualenv python3-pip-whl \
  python3.11-dbg python3.11-dev python3.11-venv \
  silversearcher-ag ripgrep fzf \
  texlive-xetex texlive-publishers texlive-science texlive-bibtex-extra biber \
  texlive-fonts-extra cm-super dvipng \
  mc \
  graphviz \
  gmsh occt-draw occt-misc libxi-dev rapidjson-dev \
  libocct-{ocaf,data-exchange,draw,foundation,modeling-algorithms,modeling-data,visualization}-dev \
  libopenmpi-dev openmpi-common mpich libmpich-dev \
  systemd-coredump \
  likwid kcachegrind cpufrequtils linux-perf time numactl libunwind-dev \
  ffmpeg \
  ocl-icd-opencl-dev ocl-icd-libopencl1 oclgrind \
  build-essential packaging-dev pkgconf \
  gcc-multilib \
  llvm-dev libclang-dev gdb strace ltrace valgrind \
  libblas-dev liblapack-dev libopenblas-dev \
  opensc-pkcs11 \
  libboost-all-dev \
  kitty imagemagick \
  maxima \
  bison flex \
  npm yarnpkg \
  octave \
  libelf-dev dwarves

# version restriction for https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1023312
with_echo apt install -y --allow-downgrades 'ipmitool=1.8.18-11+b1'
with_echo apt-mark hold 'ipmitool'

# {{{ pocl

mkdir -p /etc/OpenCL/vendors
rm -f /etc/OpenCL/vendors/pocl*.icd

# (not currently due to https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=932707)
# pocl-opencl-icd
# https://github.com/pocl/pocl/issues/757
# cat <<EOF > /etc/apt/preferences.d/prevent-broken-pocl
# Package: pocl-opencl-icd
# Pin: version 1.3*
# Pin-Priority: -1
#
# Package: libpocl2
# Pin: version 1.3*
# Pin-Priority: -1
#
# Package: libpocl2-common
# Pin: version 1.3*
# Pin-Priority: -1
#
# Package: pocl-opencl-icd
# Pin: version 1.2*
# Pin-Priority: 1001
#
# Package: libpocl2
# Pin: version 1.2*
# Pin-Priority: 1001
#
# Package: libpocl2-common
# Pin: version 1.2*
# Pin-Priority: 1001
# EOF
rm -f /etc/apt/preferences.d/prevent-broken-pocl

#apt-get install --allow-downgrades -y pocl-opencl-icd libpocl2 libpocl2-common

/shared/config/pocl/build-pocl-branch

# }}}

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

# {{{ Nvidia GPU: enable profiling for non-admins

# https://developer.nvidia.com/nvidia-development-tools-solutions-ERR_NVGPUCTRPERM-permission-issue-performance-counters
NVMODCONF=/etc/modprobe.d/uiuc-enable-profiling-for-non-admins.conf
if test -c /dev/nvidiactl; then
        echo 'options nvidia "NVreg_RestrictProfilingToAdminUsers=0"' > "$NVMODCONF"
else
        rm -f "$NVMODCONF"
fi

# }}}

(cd /etc/cron.daily; rm -f run-smart-tests{,.sh})
(cd /etc/cron.weekly; rm -f run-smart-tests; ln -s /shared/config/run-smart-tests)

# (cd /etc/cron.daily; rm -f snapshot-filesystems; ln -s /shared/tools/snapshot-filesystems)

(cd /etc/cron.weekly; rm -f clean-up-after-gitlab-runner; ln -s /shared/config/clean-up-after-gitlab-runner)

(cd /etc/cron.hourly; rm -f monitor-ipmi-log; ln -s /shared/config/monitor-ipmi-log)

/shared/config/docker-cleanup.sh

echo "COMPLETED SUCCESSFULLY"

# vim: foldmethod=marker
