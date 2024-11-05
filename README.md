# Current Recipes

This repository contains the recipes for building conda packages.

The following packages are currently included in this repository:
- `healib` is a basic hello world example of creating a conda package.
- `cfitsio`, linking to a test tarball of the CFITSIO package
- `ccfits`, linking to a test tarball of the CCfits package

# Required tools
Conda/mamba may be installed via miniforge. If you don't have conda/mamba installed, it is recommended that you install them through [micromamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html): 

```sh
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
```

These builds use [rattler-build](https://github.com/prefix-dev/rattler-build/). If it's not alreaddy isntalled, it can be installed with:
```sh
mamba install rattler-build
```

`rattler-build` is similar to `conda-build`, written in rust, which appears to be more robust and easy to use than conda-build.

# Building Packages

To build a package, call the `run_build.sh` script from inside the relevant folder. For `cfitsio`, this will be:
```sh
cd cfitsio
../scripts/run_build.sh
```

This will write the conda package in a the `output` folder. For example, after creating the healib and cfitsio packages on a Mac, the `output` dir has the following contents:

```sh
ls -l ./output
bld:
drwxr-xr-x 2 klrutkow staff 64 Oct 15 00:44 rattler-build_cfitsio_1728967256/
drwxr-xr-x 2 klrutkow staff 64 Oct 14 21:36 rattler-build_healib_1728956112/

noarch:
-rw-r--r-- 1 klrutkow staff 109 Oct 14 21:35 repodata.json

osx-64:
-rw-r--r-- 1 klrutkow staff 974K Oct 15 00:43 cfitsio-4.5.0-h0dc7051_0.conda
-rw-r--r-- 1 klrutkow staff 2.1K Oct 14 21:36 healib-0.1-h0dc7051_0.conda
-rw-r--r-- 1 klrutkow staff 1.2K Oct 15 00:43 repodata.json

src_cache:
drwxr-xr-x 126 klrutkow staff 4.0K Oct 15 00:40 cfitsio-4_5_0_81db33b9/
-rw-r--r--   1 klrutkow staff  14M Oct 15 00:40 cfitsio-4_5_0_81db33b9.tar
```

Note that the contents of the `output` folder should not be kept under version control.

# Hosting Packages

The packages can be copied to the heasarc webpages. For example, the `output/noarch` and `output/osx-64` directories can be copied to: https://heasarcdev.gsfc.nasa.gov/klrutkow/pkg_mgrs/.


# Installing the Packages 

To use the packages that were built in the output dir, you can install the package with:
```sh
mamba install cfitsio -c ./output
```

To use them after hosting on the website, install with the following command:
```sh
conda install healib -k -c https://heasarcdev.gsfc.nasa.gov/klrutkow/pkg_mgrs/
```

The `-k` option is required to allow insecure connections. (TODO: investigate and solve)