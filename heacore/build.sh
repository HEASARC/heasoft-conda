#!/bin/bash

set -ex
configure_args=(
    --prefix=$PREFIX
    --enable-collapse=all
    --x-includes=$PREFIX/include
    --x-libraries=$PREFIX/lib
)


cd BUILD_DIR
./configure "${configure_args[@]}" 2>&1 | tee config.log.txt
make
make install
# needed to install_name_tool on osx works
rm $PREFIX/BUILD_DIR/hd_install.o > /dev/null 2>&1


if [ ${CONDA_BUILD_CROSS_COMPILATION:-0} -eq 0 ] ; then
    # Test-ish programs; Need more comprehensive tests
    $PREFIX/bin/cookbook
    $PREFIX/bin/speed
fi

rm -f $PREFIX/bin/cookbook $PREFIX/bin/speed $PREFIX/bin/testprog
