#!/bin/bash

set -e
set -o pipefail

HEA_SUBDIR=heasoft

ostype=$(uname)
if [ "$ostype" = "Darwin" ]; then
    # use headers from libx11 not the ones shipped with tk
    # with this, xserver works on mac, but not tkpgplot
    # This can be done at the user end by: mamba install xorg-libx11 --clobber
    find $PREFIX/include/X11 -name "*.h__clobber-from-xorg-libx11*" \
        -exec sh -c 'mv "$0" "${0%%__clobber-from-xorg-libx11}"' {} \;
    find $PREFIX/include/X11 -name "*.h__clobber-from-xorg-xorgproto*" \
        -exec sh -c 'mv "$0" "${0%%__clobber-from-xorg-xorgproto}"' {} \;

    # remove extra @rpath
    for conf in `find . -type f -name "configure" -path "*BUILD_DIR*"`; do
        sed -i '' 's|-Wl,-rpath,\\$HD_TOP_EXEC_PFX/lib||g' $conf
    done

    # fix python library in mac x86_64
    hware=$(uname -m)
    if [ "$hware" = "x86_64" ]; then
        for conf in `find . -type f -name "configure" -path "*BUILD_DIR*"`; do
            sed -i '' 's/^.*PYTHON_LIBRARY=.*$/PYTHON_LIBRARY=-Wl,-undefined,dynamic_lookup/' $conf
        done
    fi
fi


configure_args=(
    --prefix=$PREFIX/$HEA_SUBDIR
    --enable-collapse=all
    --x-includes=$PREFIX/include
    --x-libraries=$PREFIX/lib
)

mask_files="libtk8.6.dylib libreadline.8.dylib libtcl8.6.dylib"
if [ "$ostype" = "Darwin" ]; then
    for file in $mask_files; do
        mv $PREFIX/lib/$file $PREFIX/lib/${file}.off
    done
fi

mv headas-un* BUILD_DIR
chmod +x BUILD_DIR/headas-unset

cd BUILD_DIR
./configure "${configure_args[@]}" 2>&1 | tee config.log.txt || false
#make 2>&1 | tee build.log.txt || false
#make install 2>&1 | tee install.log.txt || false
source $HEADAS/headas-init.sh
make test || false 
make install-test || false
rm -rf $PREFIX/$HEA_SUBDIR/BUILD_DIR/hd_install.o

if [ "$ostype" = "Darwin" ]; then
    for file in $mask_files; do
        mv $PREFIX/lib/${file}.off $PREFIX/lib/${file}
    done
fi