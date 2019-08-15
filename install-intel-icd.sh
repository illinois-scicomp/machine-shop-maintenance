#! /bin/bash

set -e
set -x

rm -f /etc/OpenCL/vendors/intel*.icd

VERSION=oclcpuexp-2019.8.7.0.0725_rel

OCLPATH="/opt/intel-$VERSION"

if test -d "$OCLPATH" ; then
	rm -Rf "$OCLPATH"
fi

mkdir -p "$OCLPATH"
cd "$OCLPATH"
tar xvfz /shared/software/$VERSION.tar.gz
chmod go+rX -R "$OCLPATH"

echo "$OCLPATH/x64/libintelocl.so" > /etc/OpenCL/vendors/intel-$VERSION.icd
rm -Rf "$OCLPATH/x64/libOpenCL.so*"

echo "export LD_LIBRARY_PATH=$OCLPATH/x64:"'$LD_LIBRARY_PATH' > /opt/enable-intel-cl.sh
