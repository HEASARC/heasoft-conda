#!/bin/bash

set -ex

./configure --prefix=$PREFIX --with-bzip2 --enable-reentrant || { cat config.log ; exit 1 ; }

make
make install

if [ ${CONDA_BUILD_CROSS_COMPILATION:-0} -eq 0 ] ; then
    # Test-ish programs:
    $PREFIX/bin/cookbook
    $PREFIX/bin/speed
    # Actual test suite as described in docs/cfitsio.doc
    ./testprog > testprog.lis
    diff testprog.lis testprog.out
    cmp testprog.fit testprog.std
fi

rm -f $PREFIX/bin/cookbook $PREFIX/bin/speed $PREFIX/bin/testprog
