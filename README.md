
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
