#!/bin/bash

set -ex

ostype=$(uname)
if [ "$ostype" = "Darwin" ]; then
    ../makemake .. darwin g77_gcc_X
    # use headers from libx11 not the ones shiped with tk
    # with this, xserver works on mac, but not tkpgplot
    # This can be done at the user end by: mamba install xorg-libx11 --clobber
    find $PREFIX/include/X11 -name "*.h__clobber-from-xorg-*" \
        -exec sh -c 'mv "$0" "${0%%__clobber-from-xorg-libx11}"' {} \;
fi


configure_args=(
    --prefix=$PREFIX
    --enable-collapse=all
    --x-includes=$PREFIX/include
    --x-libraries=$PREFIX/lib
)


cd BUILD_DIR
./configure "${configure_args[@]}" 2>&1 | tee config.log.txt
make 2>&1 | tee build.log.txt
make install 2>&1 | tee install.log.txt
