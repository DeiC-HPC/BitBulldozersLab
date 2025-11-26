# Building LUMI containers using Velocity

- **Keywords:** Velocity, Containers, apptainer, Lumi
- **Date:** 2025-11-12

In this BitBulldozer we explore the container builder & management tool `Velocity` for building multiple containers with different software components and versions. For us, it is important that such a container build management tool meets the following requirements:

- Easy to setup & use
- Flexible: easy to add new packages, libraries, versions 
- Flexible: easy to combine different versions of libraries etc.
- Dependency management between the different libraries, packages & versions
- Clear error messages
- Preferably easy to use for new users who are not used to containers

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

Set the following three environment variables from this `/Velocity4LumiContainers` folder:
```
export VELOCITY_BUILD_DIR=$PWD/containers/velocity
export VELOCITY_DISTRO=opensuse
export VELOCITY_IMAGE_PATH=$PWD/images
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

# Results

## Pros

- Easy to setup
- Creates sif containers from predefined setup scripts
- Adding new libraries etc. is easy - it's basically just bash scripts for your specific linux distro (e.g., zypper with opensuse).
- Dependency resolution seems to work well
- It is easy to combine different versions and set dependencies between versions of different packages. 
- Resulting containers work on Lumi (as long as the packages are compatible with Lumi)
- Network speeds are similar to other open source containers

## Cons
- Cannot make versions with name "X.X.X_dev" or "working" etc. This would be handy if it's an experimental version from e.g. a git commit
- The error messages are limited; e.g., if your version isn't some sort of number it'll just say "No available build".
- Error message if using `=` when setting envar with `!envar` is cryptic.
- Folders cannot contain `_`
- Mapping values are not allowed (?) i.e. `libfabric@2.0.0:`
- `Python 3.10` becomes `Python 3.1`
- The caching is currently only stable in the `develop` branch due to issues with the hashes.


## Nice to have features
- Top level folder that groups packages. e.g.: Python related stuff, communication, different MPI (MPICH, OpenMPI) etc.
- Configuration File --> allow to specify a full container toolchain for a config. e.g., `velocity build lumi_latest` should build a container according to the config file. 
- Show dependency tree for a given package & version

# Conclusion

`Velocity` seems like a good starting point to simplify/automate container building with some downsides. The pros are that it works well once the initial definition files are written and if the user defines compatible versions. However, the error messages are not self-explanatory. The naming & versioning is currently limited. Additionally, there are also some features that would be nice to have.  