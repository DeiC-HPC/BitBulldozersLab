# Building LUMI containers using Velocity

- **Keywords:** Velocity, Containers, apptainer, Lumi
- **Date:** 2025-11-12

Velocity is a tool that helps maintain and build various containers. It is used at Frontier.

Links:
- https://olcf.github.io/velocity/index.html
- https://github.com/olcf/velocity

# Setup
Make sure you have apptainer installed.
Then:
```
pip install olcf-velocity
```

Set the following three environment variables:
```
export VELOCITY_BUILD_DIR=~/containers/velocity
export VELOCITY_DISTRO=opensuse
export VELOCITY_IMAGE_PATH=/BitBulldozersLab/Velocity4LumiContainers
```

And add the following do your `bashrc` or `.bash_aliases`:
alias velocity="python3 -m velocity"

# Usage
To see available software:
```
velocity avail
```

To build an image:
```
velocity build <packages_you_want>
```
 And include all the packages you would like.

## Lumi Recipes 

For Lumi the following three image 'recipes' are a good starting point.

- stable
  - `velocity build rocm@6.0.2 fakeGpu libcxi libfabric@1.9.0 mpich@4.2.3 xcclPlugin@0.1 tests -v`
- latest
  - `velocity build rocm@6.2.4 fakeGpu libcxi libfabric@2.3.0 mpich@4.2.3 xcclPlugin@0.3 tests -v`
- future
  - `velocity build rocm@7.0.2 fakeGpu libcxi libfabric@2.3.0 mpich@4.3.2 xcclPlugin@0.3 tests -v`

To build a pytorch container with the `latest` version of the lumi container one could do:
- `velocity build opensuse@15.5 rocm@6.2.4 fakeGpu libcxi libfabric@2.3.0 mpich@4.2.3 xcclPlugin@0.3 tests pythonMiniforge python@3.12 pythonPytorch@2.7.1 -v`

This will build the container with all the Lumi communication bits needed as well as install a conda venv with Pytorch pre-installed. 

# Versions

Some packages do not have versions but use git hashes. 
`Velocity` currently does not support version numbers that are not in a typical Major.Minor(.Patch) format. 

- xcclPlugin
  - 0.1 --> stable `aws-ofi-rccl` as is included in the standard Lumi containers
  - 0.2 --> latest `aws-ofi-rccl`
  - 0.3 --> `open-ofi-xccl` v1.14.x-xxx; first version that supports ROCm.

- libcxi
  - 0.1 --> stable as is included in the standard Lumi containers. Git hashes for: `libcxi`, `cxi_driver` and `cassini_headers`

- libfabric
  - 1.9 --> stable as is included in the standard Lumi containers based on git hash
  - 2.3 --> enables the lnx provider to combine multiple providers

- fakeGPU
  - 0.1 --> version to fake LUMI GPUs

- tests
  - 0.1 --> installs both OSU benchmarks and RCCL tests

- packages
  - 1.0 --> various normal packages that are required for the other installations (gcc, cmake, autoconf, tar, patch git etc.)

# Issues
- Cannot make versions with name "X.X.X_dev" or "working" etc. This would be handy if its an experimental version from e.g. a git commit
- The error messages are a bit limited; e.g., if your version isn't some sort of number it'll just say "No available build".
- Error message if using `=` when setting envar with `!envar` is cryptic.
- Folders cannot contain `_`
- Mapping values are not allowed (?) i.e. `libfabric@2.0.0:`
- `Python 3.10` becomes `Python 3.1`
- The graph or hashes are not stable so layers are rebuilt even if that's not necessary. 


# Nice to have
- Top level folder that groups packages. e.g.: Python related stuff, communication, different MPI (MPICH, OpenMPI) etc.
- Configuration File --> allow to specify a full container toolchain for a config. e.g., `velocity build lumi_latest` should build a container according to the config file. 
- Show depedency tree for a given package & version