# Building LUMI containers using Velocity

- **Keywords:** Velocity, Containers, apptainer, Lumi
- **Date:** 2025-10-20

Velocity is a tool that helps maintain and build various containers. It is used at Frontier.
Links:
https://olcf.github.io/velocity/index.html
https://github.com/olcf/velocity

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
velocity build rocm@6.2.4 fakeGpu libcxi libfabric@2.0.0 mpich@4.2.3 xcclPlugin@0.1 tests -v
```


# Issues
- cannot make versions with name "X.X.X_dev" or "working" etc. if its experimental from e.g. a git commit
- The error messages are a bit limited; e.g., if your version isn't some sort of number it'll just say "No available build".
- Error message if using `=` when setting envar with `!envar` is cryptic.
- Folders cannot contain `_`
- Mapping values are not allowed (?) i.e. `libfabric@2.0.0:`
- `Python 3.10` becomes `Python 3.1`