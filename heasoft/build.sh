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

# clean non-utf-8 characters; rattler does not like that in source code

for file in `find ftools/asca suzaku -type f ! -executable -exec file --mime-type {} + \
        | grep 'text/' | cut -d: -f1`; do
    iconv -f utf-8 -t utf-8 -c $file -o $file.utf8
    mv $file.utf8 $file
done


configure_args=(
    --prefix=$PREFIX/$HEA_SUBDIR
    --enable-collapse=all
    --x-includes=$PREFIX/include
    --x-libraries=$PREFIX/lib
)

if [ "$ostype" = "Darwin" ]; then
    mv $PREFIX/lib/libtk8.6.dylib $PREFIX/lib/libtk8.6.dylib.off
fi

cd BUILD_DIR
./configure "${configure_args[@]}" 2>&1 | tee config.log.txt || false
make 2>&1 | tee build.log.txt || false
make install 2>&1 | tee install.log.txt || false
rm -rf $PREFIX/$HEA_SUBDIR/BUILD_DIR/hd_install.o

if [ "$ostype" = "Darwin" ]; then
    mv $PREFIX/lib/libtk8.6.dylib.off $PREFIX/lib/libtk8.6.dylib
fi

# we need all libraries to be writable so conda-build can
# modify the rpath, etc. (e.g. libxpa.so.1.0)
find $PREFIX/$HEA_SUBDIR/lib -type f ! -type l -name "*$SHLIB_EXT*" -exec chmod 755 {} \;


# write initialization scripts
# 1. write them to bin/heainit.[c]sh
# 2. Write a script bin/.xspe-post-link.sh that copies bin/heainit.[c]sh
#    to $PREFIX/etc/conda/activate.d so they are executed after installation
#    and when the conda environment is activavted.
cat <<EOF >$PREFIX/bin/heainit.sh
#!/bin/bash
export HEADAS=\$CONDA_PREFIX/$HEA_SUBDIR
echo "activating heasoft in \$HEADAS"
source \$HEADAS/BUILD_DIR/headas-init.sh
EOF
chmod +x $PREFIX/bin/heainit.sh
cat <<EOF >$PREFIX/bin/heainit.csh
#!/bin/bash
setenv HEADAS \$CONDA_PREFIX/$HEA_SUBDIR
echo "activating heasoft in \$HEADAS"
source \$HEADAS/BUILD_DIR/headas-init.csh
EOF
chmod +x $PREFIX/bin/heainit.csh

cat <<EOF >$PREFIX/bin/.heasoft-post-link.sh
mkdir -p \$CONDA_PREFIX/etc/conda/activate.d
cp \$CONDA_PREFIX/bin/heainit.*sh \$CONDA_PREFIX/etc/conda/activate.d/
EOF
cat <<EOF >$PREFIX/bin/.heasoft-pre-unlink.sh
rm \$CONDA_PREFIX/etc/conda/activate.d/heainit.*sh > /dev/null 2>&1
EOF
