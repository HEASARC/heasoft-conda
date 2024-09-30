#!/bin/bash

set -ex

export SOVERSION=${PKG_VERSION}

./configure --prefix=$PREFIX --enable-shared=yes --enable-static=no || { cat config.log ; exit 1 ; }

make
make install
exit

if [ ${CONDA_BUILD_CROSS_COMPILATION:-0} -eq 0 ] ; then
    # Test-ish programs:
    ./cookbook
fi

rm -f $PREFIX/bin/cookbook
