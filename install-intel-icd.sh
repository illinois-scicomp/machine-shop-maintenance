#! /bin/bash

set -e
set -x

rm -f /etc/OpenCL/vendors/intel*.icd

cd /opt

# https://github.com/intel/llvm/releases/tag/oclcpuexp-2019.8.7.0.0725_rel
VERSION=oclcpuexp-2019.8.7.0.0725_rel
RELEASE="$VERSION"
TBB_VERSION=""

# https://github.com/intel/llvm/releases/tag/2020-12
# buggy, e.g. https://gitlab.tiker.net/inducer/grudge/-/jobs/239562
#RELEASE=2020-12
#VERSION=oclcpuexp-2020.11.11.0.04_rel
#TBB_VERSION=2021.1.1

OCLPATH="/opt/intel-$VERSION"

if test -d "$OCLPATH" ; then
	rm -Rf "$OCLPATH"
fi

curl -L -O "https://github.com/intel/llvm/releases/download/$RELEASE/$VERSION.tar.gz"
mkdir -p "$OCLPATH"
tar xvz -C "$OCLPATH" -f $VERSION.tar.gz
chmod go+rX -R "$OCLPATH"

if test "$TBB_VERSION"; then 
  TBB_FILENAME="oneapi-tbb-$TBB_VERSION-lin.tgz"
  curl -L -O "https://github.com/intel/llvm/releases/download/$RELEASE/$VERSION.tar.gz"
  tar xv --strip-components=4 -C $OCLPATH/x64  -f "$TBB_FILENAME" oneapi-tbb-$TBB_VERSION/lib/intel64/gcc4.8/
  rm "$TBB_FILENAME"
fi

echo "$OCLPATH/x64/libintelocl.so" > /etc/OpenCL/vendors/intel-$VERSION.icd
rm -Rf $OCLPATH/x64/libOpenCL.so*

echo "export LD_LIBRARY_PATH=$OCLPATH/x64:"'$LD_LIBRARY_PATH' > /opt/enable-intel-cl.sh

rm "$VERSION.tar.gz"

# vim: sw=2
