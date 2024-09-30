
- If you don't have conda/mamba installed, it is recommended that you install them through [micromamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html): 

```sh
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
```

- These builds use [rattler-build](https://github.com/prefix-dev/rattler-build/), which can be installed with:
```sh
mamba install rattler-build
```
 `rattler-build` is similar to `conda-build`, written in rust, which appears to be more robust and easy to use than conda-build.

 - `healib` is a basic hello world example of creating a conda package.

 - To build a package, call the `run_build.sh` script from inside the relevant folder, so for `cfitsio`, this will be:
 ```sh
 cd cfitsio
 ../scripts/run_build.sh
 ```
 This will write the conda package in a the `output` folder. To use it, you can install the package with:
 ```sh
 mamba install cfitsio -c ./output
 ```

Note that the content of the `output` folder should not be kept under version control.