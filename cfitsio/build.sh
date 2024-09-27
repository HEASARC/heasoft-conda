#! /bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* .

set -ex

if [ $(uname) = Darwin ] ; then
    # Needed to get 'union semun' definition used in drvrsmem.c:
    export CFLAGS="$CFLAGS -D_DARWIN_C_SOURCE"
    export LDFLAGS="$LDFLAGS -Wl,-reexport_library,$PREFIX/lib/libz.dylib"
fi
#cd cfitsio-4.5.0
cp $BUILD_PREFIX/share/libtool/build-aux/config.* .
./configure --prefix=$PREFIX --with-bzip2 --enable-reentrant || { cat config.log ; exit 1 ; }

make
make install

if [ ${CONDA_BUILD_CROSS_COMPILATION:-0} -eq 0 ] ; then
    # Test-ish programs:
    $PREFIX/bin/cookbook
    $PREFIX/bin/speed
    # Actual test suite as described in docs/cfitsio.doc
    cp testprog $PREFIX/bin/
    $PREFIX/bin/testprog > testprog.lis
    diff testprog.lis testprog.out
    cmp testprog.fit testprog.std
fi

rm -f $PREFIX/bin/cookbook $PREFIX/bin/speed $PREFIX/bin/testprog

# check symbol exports on osx
if [ $(uname) = Darwin ]; then
    ${OTOOL} -l $PREFIX/lib/libcfitsio.dylib | grep "LC_REEXPORT_DYLIB"
fi