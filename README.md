# Content
This repo contains the code to generate conda packages for heasoft and related
packages.

It also contains code that create source tar files for the different packages.

# Current Recipes


The following packages are currently included in this repository:

The trivial packages that are basic or already included in conda-forge:
- `healib` is a basic hello world example of creating a conda package.
- `cfitsio`, linking to a test tarball of the CFITSIO package
- `ccfits`, linking to a test tarball of the CCfits package
- `heacore`, peant to package heacore as one package (NOT TESTED YET).

The main packages are:
- `heasoft` the full heasoft distribution without data files (for xspec and xstar)
- `heasoft-tests`: Build the test files only (`make test`). It has `heasoft` as a dependency
and that is where it gets the binaries and libraries from. This package is for internal
use only and is not meant to be distributed to users.
- `xspec-data`: Data files for xspec (`spectral/modelData/*`). It includes all files except
the very large ones (see `scripts/pacakge_config.json`). This is a dependency of `heasoft`
- `xspec-data-extra`: Large data files for xspec (`spectral/modelData/*`). It the large files
that are not included in `xspec-data` (see `scripts/pacakge_config.json`).

# Required tools
Conda/mamba may be installed via miniforge. If you don't have conda/mamba installed, it is recommended that you install them through [micromamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html): 

```sh
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
```

These builds use [rattler-build](https://github.com/prefix-dev/rattler-build/). If it's not alreaddy installed, it can be installed with:
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

The package folders of `noarch` (contains os-independent packages e.g. `xspec-data`), `linux64`,
`osx-arm` and `osx-64` should be put in the webserver. The latest are in `https://heasarcdev.gsfc.nasa.gov/azoghbi/conda-full/`.


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

# Testing the Packages
Ideally, each package has a a test suite that runs when the package is built. Until then,
the packages will need to be tested after they are built.

The heasoft package does not build the unit test tasks, those are available in the
`heasoft-tests` package, which is essentially `heasoft` plus the unit tests executables
`ut_*`, but not the test data. To access the test data, ask Bryan.

If you don't have conda setup, these are the steps:

1. Install miniforge (a the free version of conda). See 
[the website for instructions](https://github.com/conda-forge/miniforge).
This involves downloading the install script, running it to install it in some dir `CONDA_DIR`, then initializing it:
```sh
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -b -p "${CONDA_DIR}"
source "${CONDA_DIR}/etc/profile.d/conda.sh"
source "${CONDA_DIR}/etc/profile.d/mamba.sh" # for mamba support
conda activate
```
At this point, you see you prompt change to something like: `(base)[...]`

2. Install heasoft intro a new conda environment (called hea),
using this channel: `https://heasarcdev.gsfc.nasa.gov/azoghbi/conda-full/`
```sh
mamba create -n hea python=3.12 heasoft -k -c https://heasarcdev.gsfc.nasa.gov/azoghbi/conda-full/ -c conda-forge -y
```
and wait for the install to finish.

3. Activate the newly create conda environment (that has heasoft):
```sh
conda activate hea
```
The prompt should change to something like `(hea)[...]`.
Heasoft should be initialized and you should see a message like:
```sh
activating heasoft in $CONDA_DIR/envs/py312/heasoft
```
If it is not done automatically, please open and issue so it is fixed.

4. Start testing `heasoft`.

5. If you want the heasoft unit tests, install `heasoft-tests` in the same way:
```sh
mamba install heasoft-tests -k -c https://heasarcdev.gsfc.nasa.gov/azoghbi/conda-full/
```

6. If you are testing `xspec`, not that the xspec data files distributed in two separate packages:
`xspec-data` (~400 MB) and `xspec-data-extra` (~2BG). The first one (`xspec-data`) is installed automatically when
`heasoft` is installed, and contain all model data expect to file that are >~200MB. The large files
can be installed the same way by:
```sh
mamba install xspec-data-extra -k -c https://heasarcdev.gsfc.nasa.gov/azoghbi/conda-full/
```
