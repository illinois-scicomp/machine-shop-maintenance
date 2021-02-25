#! /bin/bash

set -e
set -x

rm -f /etc/OpenCL/vendors/intel*.icd

#VERSION=oclcpuexp-2019.8.7.0.0725_rel
#VERSION=oclcpuexp-2020.10.6.0.4_rel
VERSION=oclcpuexp-2020.11.11.0.04_rel
TBB_VERSION=2021.1.1
TBB_FILENAME="oneapi-tbb-$TBB_VERSION-lin.tgz"

curl -L -O https://github.com/intel/llvm/releases/download/2020-12/$VERSION.tar.gz
curl -L -O "https://github.com/oneapi-src/oneTBB/releases/download/v$TBB_VERSION/$TBB_FILENAME"

OCLPATH="/opt/intel-$VERSION"

if test -d "$OCLPATH" ; then
	rm -Rf "$OCLPATH"
fi

mkdir -p "$OCLPATH"
tar xvz -C "$OCLPATH" -f $VERSION.tar.gz
chmod go+rX -R "$OCLPATH"

tar xv --strip-components=4 -C $OCLPATH/x64  -f "$TBB_FILENAME" oneapi-tbb-$TBB_VERSION/lib/intel64/gcc4.8/

echo "$OCLPATH/x64/libintelocl.so" > /etc/OpenCL/vendors/intel-$VERSION.icd
rm -Rf $OCLPATH/x64/libOpenCL.so*

echo "export LD_LIBRARY_PATH=$OCLPATH/x64:"'$LD_LIBRARY_PATH' > /opt/enable-intel-cl.sh

rm "$VERSION.tar.gz"
rm "$TBB_FILENAME"
