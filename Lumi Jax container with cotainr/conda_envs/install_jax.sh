#!/bin/bash

export ROCM_RELEASE=6.0.2
export ROCM_PATH=/opt/rocm-$ROCM_RELEASE
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ROCM_PATH/lib
export PATH=/opt/cotainr/conda/bin:$ROCM_PATH/bin/:$ROCM_PATH/llvm/bin/:$PATH
export LLVM_PATH=/opt/rocm-$ROCM_RELEASE/llvm/bin/amdclang
export CLANG_COMPILER_PATH=/opt/rocm-$ROCM_RELEASE/llvm/bin/amdclang
export CC=/opt/rocm-$ROCM_RELEASE/llvm/bin/amdclang
#export LD=/opt/rocm-6.0.2/llvm/bin/ld.lld
#export CPP=/opt/rocm-$ROCM_RELEASE/llvm/bin/amdclang++

export TEST_TMPDIR=/opt/bazel/.cache

# forward all gold linker requests to ld.lld. Symlinking the linker doesnt work
touch /usr/bin/ld.gold
echo -e '#!/bin/bash\n /opt/rocm-6.0.2/llvm/bin/ld.lld "$@"' > /usr/bin/ld.gold
chmod +x /usr/bin/ld.gold

source /opt/cotainr/conda/etc/profile.d/conda.sh
conda activate conda_container_env
git clone https://github.com/jax-ml/jax
cd jax
git fetch origin tag jax-v0.6.2

# trying to force lld instead of gold linker --> ignored
sed -i 's|CLANG_COMPILER_PATH="/usr/lib/llvm-18/bin/clang"|CLANG_COMPILER_PATH="/opt/rocm-6.0.2/llvm/bin/amdclang"|g' .bazelrc
#sed -i '220i build:rocm --linkopt="-fuse-ld=lld"' .bazelrc
#sed -i '221i build:rocm --linkopt="--ld-path=/opt/rocm-6.0.2/llvm/bin/ld.lld"' .bazelrc
#sed -i '222i build:rocm --action_env="LD=/opt/rocm-6.0.2/llvm/bin/ld.lld"' .bazelrc

python3 ./build/build.py build --wheels=jaxlib,jax-rocm-plugin,jax-rocm-pjrt \
    --rocm_version=602 --clang_path=$CLANG_COMPILER_PATH \
    --rocm_amdgpu_targets=gfx90a \
    --bazel_options='--action_env="CLANG_COMPILER_PATH=/opt/rocm-6.0.2/llvm/bin/amdclang"'\
    --bazel_options='--action_env="--host_crosstool_top=/opt/rocm-6.0.2/"'\
    --bazel_options='--action_env="TF_ROCM_AMDGPU_TARGETS=gfx90a"'\
    --bazel_options='--output_user_root=/opt/bazel/.cache'\
    --bazel_options='--local_config_rocm=/opt/rocm-6.0.2/'\
    --bazel_options='--rocm_toolkit_path=/opt/rocm-6.0.2/'\
    --bazel_options='--action_env="PATH=/opt/cotainr/conda/bin:/opt/rocm-6.0.2/bin/:/opt/rocm-6.0.2/llvm/bin/:/opt/cotainr/conda/condabin:/opt/mpich/bin:/opt/hwloc/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'

#    --bazel_options='--repo_env="CC=/opt/rocm-6.0.2/llvm/bin/amdclang"'\
#    --bazel_options='--repo_env="BAZEL_COMPILER=/opt/rocm-6.0.2/llvm/bin/amdclang"'\
#    --bazel_options='--action_env="LD=/opt/rocm-6.0.2/llvm/bin/ld.lld"'\
#    --bazel_options='--linkopt="-fuse-ld=lld"' \
#    --bazel_options='--linkopt="--ld-path=/opt/rocm-6.0.2/llvm/bin/ld.lld"'\
# --bazel_options='--cxxopt="-fuse-ld=lld"' --bazel_options='--copt="-fuse-ld=lld"'

python3 setup.py develop
pip3 install dist/*.whl
