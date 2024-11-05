#!/bin/bash

set -ex

PYTHON=$PREFIX/bin/python
cd BUILD_DIR
./configure --prefix=$PREFIX --enable-collapse=all || { cat config.log ; exit 1 ; }

make
make install

if [ ${CONDA_BUILD_CROSS_COMPILATION:-0} -eq 0 ] ; then
    # Test-ish programs; Need more comprehensive tests
    $PREFIX/bin/cookbook
    $PREFIX/bin/speed
fi

rm -f $PREFIX/bin/cookbook $PREFIX/bin/speed $PREFIX/bin/testprog
