#!/bin/bash

echo "Starting the build"
echo $CC
pwd
ls
echo $SRC_DIR


# Run make
make
# Copy compiled binaries to the Conda environment bin directory
mkdir -p $PREFIX/bin
cp hello_c $PREFIX/bin/
