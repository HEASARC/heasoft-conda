#!/bin/bash

set -ex

ostype=$(uname)
if [ "$ostype" = "Darwin" ]; then
    # use headers from libx11 not the ones shiped with tk
    # with this, xserver works on mac, but not tkpgplot
    # This can be done at the user end by: mamba install xorg-libx11 --clobber
    find $PREFIX/include/X11 -name "*.h__clobber-from-xorg-*" \
        -exec sh -c 'mv "$0" "${0%%__clobber-from-xorg-libx11}"' {} \;

    # remove extra @rpath
    for conf in `find . -type f -name "configure" -path "*BUILD_DIR*"`; do
        sed -i '' 's|-Wl,-rpath,\\$HD_TOP_EXEC_PFX/lib||g' $conf
    done
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
