#!/bin/bash
set -e -u

ARCHIVE=openssl-0.9.8l.tar.gz
ARCHIVEDIR=openssl-0.9.8l
. $KOBO_SCRIPT_DIR/build-common.sh

# When attempting to build a manpage for a certain "smime", pod2man detects a
# series of errors inside doc/apps/smime.pod. This issue is discussed here:
#     https://github.com/hashdist/hashstack/issues/244
# (Note that the above issue was related to a different program, but the latter
# used the openssl library as well.)
# The bugfix described in that issue is applied to our source code as well,
# using this patch.
patch -p0 < $PATCHESDIR/openssl-0.9.8l.patch

pushd ${ARCHIVEDIR}
	perl ./Configure linux-generic32 -DL_ENDIAN --install_prefix=/${DEVICEROOT} --openssldir=/usr --shared
	sed -i \
		-e s/^CC=.*$/CC=${CROSSTARGET}-gcc/g \
		-e s/^RANLIB=.*$/RANLIB=${CROSSTARGET}-ranlib/g \
		-e s/^AR=.*$/AR=${CROSSTARGET}-ar\ \$\(ARFLAGS\)\ r/g \
		Makefile
	# OpenSSL's Makefile is buggy; avoid parallel make
	$MAKE
	$MAKE install
popd
markbuilt
