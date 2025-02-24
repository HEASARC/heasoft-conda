#!/bin/bash

set -e
set -o pipefail

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

    # fix python library in mac x86_64
    hware=$(uname -m)
    if [ "$hware" = "x86_64" ]; then
        for conf in `find . -type f -name "configure" -path "*BUILD_DIR*"`; do
            sed -i '' 's/^.*PYTHON_LIBRARY=.*$/PYTHON_LIBRARY=-Wl,-undefined,dynamic_lookup/' $conf
        done
    fi
fi


configure_args=(
    --prefix=$PREFIX
    --enable-collapse=all
    --x-includes=$PREFIX/include
    --x-libraries=$PREFIX/lib
)


cd BUILD_DIR
./configure "${configure_args[@]}" 2>&1 | tee config.log.txt || false
make 2>&1 | tee build.log.txt || false
make install 2>&1 | tee install.log.txt || false
mkdir -p $PREFIX/Xspec
cp -r ../Xspec/BUILD_DIR $PREFIX/Xspec
find $PREFIX -type f -name 'hd_install.o' -exec rm -f {} \;

# write initialization scripts
# 1. write them to bin/heainit.[c]sh
# 2. Write a script bin/.xspe-post-link.sh that copies bin/heainit.[c]sh
#    to $PREFIX/etc/conda/activate.d so they are executed after installation
#    and when the conda environment is activavted.
cat <<EOF >$PREFIX/bin/heainit.sh
#!/bin/bash
export HEADAS=\$CONDA_PREFIX
echo "activating heasoft in \$HEADAS"
source \$HEADAS/BUILD_DIR/headas-init.sh
EOF
chmod +x $PREFIX/bin/heainit.sh
cat <<EOF >$PREFIX/bin/heainit.csh
#!/bin/bash
setenv HEADAS \$CONDA_PREFIX
echo "activating heasoft in \$HEADAS"
source \$HEADAS/BUILD_DIR/headas-init.csh
EOF
chmod +x $PREFIX/bin/heainit.csh

cat <<EOF >$PREFIX/bin/.xspec-devel-post-link.sh
mkdir -p \$PREFIX/etc/conda/activate.d
cp \$PREFIX/bin/heainit.*sh \$PREFIX/etc/conda/activate.d/
EOF
cat <<EOF >$PREFIX/bin/.xspec-devel-pre-unlink.sh
rm \$PREFIX/etc/conda/activate.d/heainit.*sh > /dev/null 2>&1
EOF