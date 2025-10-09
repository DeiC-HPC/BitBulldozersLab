FROM opensuse/leap:15.5
LABEL authors="julius"

ENTRYPOINT ["top", "-b"]

# Versions
ENV GCC_RELEASE=12
ENV OSU_VERSION=7.5
ENV SLE_RELEASE=15.5

#// This is a heavily modified version of a file provided by Samuel F Antao
#// Original License and code from https://github.com/sfantao/lumi-containers/tree/lumi-sep2024
#//
#//MIT License
#//
#//Copyright (c) 2023 Advanced Micro Devices, Inc.
#//
#//Permission is hereby granted, free of charge, to any person obtaining a copy
#//of this software and associated documentation files (the "Software"), to deal
#//in the Software without restriction, including without limitation the rights
#//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#//copies of the Software, and to permit persons to whom the Software is
#//furnished to do so, subject to the following conditions:
#//
#//The above copyright notice and this permission notice shall be included in all
#//copies or substantial portions of the Software.
#//
#//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#//SOFTWARE.


# update & upgrade image and install some base packages
# Repo contains perl libraries (?) that are needed for the rocm install. If the repos arent added the amdgpu-installer cannot resolve the dependencies.
RUN set -eux ; \
   zypper -n addrepo https://download.opensuse.org/repositories/devel:/languages:/perl/SLE_15_SP5 myrepo5 ; \
   echo 'gpgcheck=0' >> /etc/zypp/repos.d/myrepo5.repo

RUN zypper refresh
RUN zypper update -y
RUN set -eux ; \
  zypper --no-gpg-checks -n install -y --force-resolution \
    git cmake gcc${GCC_RELEASE} gcc${GCC_RELEASE}-c++ gcc${GCC_RELEASE}-fortran zlib-devel numactl awk patch tar autoconf automake libtool libjson-c-devel graphviz ncurses-devel nano which perl wget lbzip2  libjansson4 libnl3-200 perl-File-Which; \
  zypper clean


#// This is a heavily modified version of a file provided by Samuel F Antao
#// Original License and code from https://github.com/sfantao/lumi-containers/tree/lumi-sep2024
#//
#//MIT License
#//
#//Copyright (c) 2023 Advanced Micro Devices, Inc.
#//
#//Permission is hereby granted, free of charge, to any person obtaining a copy
#//of this software and associated documentation files (the "Software"), to deal
#//in the Software without restriction, including without limitation the rights
#//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#//copies of the Software, and to permit persons to whom the Software is
#//furnished to do so, subject to the following conditions:
#//
#//The above copyright notice and this permission notice shall be included in all
#//copies or substantial portions of the Software.
#//
#//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#//SOFTWARE.

# Try to remove GPG key check
RUN set -eux ; \
  sed -i 's#gpgcheck=1#gpgcheck=0#g' /etc/zypp/repos.d/*.repo


ENV ROCM_RELEASE=6.2.4
ENV AMDGPU_INSTALLER_RELEASE=6.2.60204-1
ENV ROCM_RPM=https://repo.radeon.com/amdgpu-install/$ROCM_RELEASE/sle/$SLE_RELEASE/amdgpu-install-$AMDGPU_INSTALLER_RELEASE.noarch.rpm

# Add AMD key
RUN set -eux ; \
    wget -O rocm.gpg.key https://repo.radeon.com/rocm/rocm.gpg.key ; \
    rpm --import rocm.gpg.key ; \
    rm rocm.gpg.key

# Install amdgpu-install
RUN set -eux ; \
  zypper --no-gpg-checks -n install $ROCM_RPM

RUN set -eux ; \
  zypper --no-gpg-checks -n install --oldpackage libsystemd0-249.16 libudev1-249.16

# Use amdgpu-install to install rocm et al. Should also install rccl.
RUN set -eux ; \
  amdgpu-install -y --no-dkms --usecase=rocm --rocmrelease=$ROCM_RELEASE

RUN set -eux ; \
  zypper --no-gpg-checks -n install -y --force miopen-hip-gfx90akdb

RUN set -eux ; \
  zypper --no-gpg-checks -n install -y --force omniperf omnitrace

#
# ROCm environment
#
ENV ROCM_PATH /opt/rocm-$ROCM_RELEASE
ENV PATH $ROCM_PATH/bin:$ROCM_PATH/llvm/bin:$PATH
ENV LD_LIBRARY_PATH $ROCM_PATH/lib

#// This is a heavily modified version of a file provided by Samuel F Antao
#// Original License and code from https://github.com/sfantao/lumi-containers/tree/lumi-sep2024
#//
#//MIT License
#//
#//Copyright (c) 2023 Advanced Micro Devices, Inc.
#//
#//Permission is hereby granted, free of charge, to any person obtaining a copy
#//of this software and associated documentation files (the "Software"), to deal
#//in the Software without restriction, including without limitation the rights
#//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#//copies of the Software, and to permit persons to whom the Software is
#//furnished to do so, subject to the following conditions:
#//
#//The above copyright notice and this permission notice shall be included in all
#//copies or substantial portions of the Software.
#//
#//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#//SOFTWARE.

#we need to copy files needed to DOCKER
COPY rocminfo rocm_agent_enumerator amdgpu-arch.cpp aws.patch /

# Fake having the amd gpus? so that aws-ofi-rccl installs properly?
RUN set -eux ; \
  cd $ROCM_PATH/bin ; \
  for i in rocm_agent_enumerator rocminfo ; do \
    rm -rf $i ; \
    cp /$i . ; \
    chmod +x $i ; \
  done

RUN set -eux ; \
  cd $ROCM_PATH/llvm/bin ; \
  cp /amdgpu-arch.cpp . ;\
  rm amdgpu-arch offload-arch ; \
  g++-$GCC_RELEASE amdgpu-arch.cpp -DNUM_TARGETS=8 -o amdgpu-arch ; \
  g++-$GCC_RELEASE amdgpu-arch.cpp -DNUM_TARGETS=1 -o offload-arch ; \
  rm -rf amdgpu-arch.cpp ; \
  ./amdgpu-arch ; \
  ./offload-arch ; \
  true ; \
  cd;



# RCCL version --> 2.24.3-1 --> 6aae379
#ARG RCCL_VERSION=612add2 #--> 2.20 for ROCm 6.2.4
#--> From Samuel
ARG RCCL_VERSION=85eb1f1

RUN set -eux ; \
#  rm -rf /opt/mybuild ; \
  git clone https://github.com/rocm/rccl /opt/mybuild_rccl ; \
  cd /opt/mybuild_rccl ; \
  git checkout -b mydev $RCCL_VERSION ; \
  git submodule sync ; \
  git submodule update --init --recursive --jobs 0 ; \
  mkdir /opt/mybuild_rccl/build ; \
  cd  /opt/mybuild_rccl/build ; \
  CXX=$ROCM_PATH/bin/hipcc \
  cmake \
    -DBUILD_LOCAL_GPU_TARGET_ONLY=ON \
    -DCOMPILING_TARGETS=gfx90a \
    -DENABLE_MSCCLPP=OFF \
    -DCMAKE_INSTALL_PREFIX=/opt/rccl \
    -DCMAKE_BUILD_TYPE=Release \
    .. ; \
  nice make -j V=1 VERBOSE=1 ; \
  nice make -j install ; \
  cd /; \
  rm -rf /opt/mybuild_rccl

RUN set -eux ; \
  rm -rf $ROCM_PATH/lib/librccl.so* ; \
  ln -s /opt/rccl/lib/librccl.so* $ROCM_PATH/lib

RUN set -eux ; \
  cd $ROCM_PATH ; \
  find -iname '*.cmake' -o -iname '*.txt' | xargs grep -i librccl.so ; \
  find -iname '*.cmake' -o -iname '*.txt' | xargs sed -E -i 's#librccl.[0-9,a-z,\.]+#librccl.so.1.0#g' ; \
  find -iname '*.cmake' -o -iname '*.txt' | xargs grep -i librccl.so


#ENV LIBFABRIC_VERSION=2.3.0

# install additional dependencies for the full opensource version. may be partially required for the libfabric hybrid approach as well. 
RUN zypper refresh
RUN zypper update -y
RUN set -eux ; \
  zypper --no-gpg-checks -n install -y --force-resolution \
    libconfig-devel  \
    libuv-devel  \
    libfuse2  \
    libyaml-devel  \
    fuse-devel  \
    libnl3-devel  \
    libnuma-devel  \
    bison  \
    flex  \
    libcurl-devel  \
    libsensors4-devel  \
    gzip; \
  zypper clean

# From Samuel
ARG CASSINI_HEADERS_VERSION=9a8a738a879f007849fbc69be8e3487a4abf0952
ARG CXI_DRIVER_VERSION=c284516fa8d0027b8f84e8ca818e8c6bbe320bd8
ARG LIBCXI_VERSION=0f3609b5e224636abffc7ceffe6f4e9c83244c08

# --> latest commit on main
RUN set -eux ; \
    cd /opt/ ;\
    git clone https://github.com/HewlettPackard/shs-cassini-headers ;\
    git -C /opt/shs-cassini-headers checkout -b mydev $CASSINI_HEADERS_VERSION ; \
    mkdir -p /share/cassini-headers/;\
    mkdir -p /include;\
    cp shs-cassini-headers/share/cassini-headers/csr_defs.json /share/cassini-headers/;\
    cp -r shs-cassini-headers/include/* /include/

#Future: actually build the drivers??
#RUN #set -eux ; \
#    cd /opt/ ;\
#    wget https://github.com/HewlettPackard/ss-sbl ;\
#    cd ss-sbl ;\
#    SBL_EXTERNAL_BUILD=1 PLATFORM_CASSINI_SIM=1 make

# --> latest commit on main
RUN set -eux ; \
    cd /opt/ ;\
    git clone https://github.com/HewlettPackard/shs-cxi-driver ;\
    git -C /opt/shs-cxi-driver  checkout -b mydev $CXI_DRIVER_VERSION ; \
    cp -r shs-cxi-driver/include/* /include/
#    make

#0f3609b5e224636abffc7ceffe6f4e9c83244c08 --> latest commit on main
ENV LIBCXI_PATH=/opt/libcxi
RUN set -eux ; \
    cd /opt/ ;\
    git clone http://github.com/HewlettPackard/shs-libcxi ;\
    git -C /opt/shs-libcxi checkout -b mydev $LIBCXI_VERSION ; \
    cd shs-libcxi;\
    sed -i 's+/usr/share/cassini-headers/csr_defs.json+/share/cassini-headers/csr_defs.json+g' utils/cxi_dump_csrs.py ;\
    ./autogen.sh;\
    CC=gcc-$GCC_RELEASE CXX=g++-$GCC_RELEASE  CFLAGS='-Wno-unused-but-set-variable'  \
    ./configure --prefix=$LIBCXI_PATH CFLAGS='-I /include' --with-rocm=$ROCM_PATH         --without-systemd \
        --with-systemdsystemunitdir=/opt/shs-libcxi/systemdsystemunitdir \
        --with-udevrulesdir=/opt/shs-libcxi/udevrulesdir ; \
    make VERBOSE=1 V=1 -j install;\
    ldconfig

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LIBCXI_PATH/lib
ENV LD_RUN_PATH=$LD_RUN_PATH:$LIBCXI_PATH/lib
# Download and install libfabric. CXI provider doesnt get installed atm.
# CXI provider has to be available.

# libfabric environment
ENV LIBFABRIC_PATH /opt/libfabric

# From Samuel
ENV LIBFABRIC_VERSION "e08d3161b8038ebfa50a4eb5bf76132e4eaeb137"

# need version higher than 1.15.2. 1.15 does not have a cxi provider
# sed is needed to delete the CXI_MAP_IOVA_ALLOC as it was removed. https://github.com/search?q=repo%3AHewlettPackard%2Fshs-libcxi+CXI_MAP_IOVA_ALLOC&type=commits
RUN set -eux ; \
#    wget https://github.com/ofiwg/libfabric/releases/download/v$LIBFABRIC_VERSION/libfabric-$LIBFABRIC_VERSION.tar.bz2 ; \
#    tar -xf libfabric-$LIBFABRIC_VERSION.tar.bz2; \
#    rm libfabric-$LIBFABRIC_VERSION.tar.bz2; \
#    cd libfabric-$LIBFABRIC_VERSION; \
    git clone --recursive https://github.com/ofiwg/libfabric /opt/libfabric-src ; \
    git -C /opt/libfabric-src checkout -b mydev $LIBFABRIC_VERSION ; \
#    sed -i 's/| CXI_MAP_IOVA_ALLOC//g' prov/cxi/include/cxip.h ; \
    cd /opt/libfabric-src ; \
    ./autogen.sh ; \
#    mkdir /opt/libfabric-src/build ; \
    mkdir build ; \
    cd build;\
    CC=gcc-$GCC_RELEASE  ../configure  \
          LDFLAGS=-Wl,--build-id  \
          --enable-cxi=$LIBCXI_PATH  \
          --prefix=$LIBFABRIC_PATH CFLAGS='-I /include'  \
          --with-rocr=$ROCM_PATH  \
          --disable-opx \
          --disable-psm2 \
          --disable-efa \
          --disable-rxm \
          --disable-sockets \
          --enable-only  \
          --enable-rocr-dlopen  \
          --enable-restricted-dl  \
          --enable-tcp  \
          --enable-udp  \
          --enable-rxm  \
          --enable-shm  \
          --enable-rxd  \
          --enable-hook_debug  \
          --enable-hook_hmem  \
          --enable-dmabuf_peer_mem  \
          --enable-gdrcopy-dlopen; \
    make -j;\
    make install;\
    ldconfig ;\
    cd /; \
    rm -rf /opt/libfabric-src
#    rm -rf libfabric-$LIBFABRIC_VERSION


ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$LIBFABRIC_PATH/lib
ENV LD_RUN_PATH $LD_RUN_PATH:$LIBFABRIC_PATH/lib


#// This is a heavily modified version of a file provided by Samuel F Antao
#// Original License and code from https://github.com/sfantao/lumi-containers/tree/lumi-sep2024
#//
#//MIT License
#//
#//Copyright (c) 2023 Advanced Micro Devices, Inc.
#//
#//Permission is hereby granted, free of charge, to any person obtaining a copy
#//of this software and associated documentation files (the "Software"), to deal
#//in the Software without restriction, including without limitation the rights
#//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#//copies of the Software, and to permit persons to whom the Software is
#//furnished to do so, subject to the following conditions:
#//
#//The above copyright notice and this permission notice shall be included in all
#//copies or substantial portions of the Software.
#//
#//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#//SOFTWARE.



ENV HWLOC_TAR=https://download.open-mpi.org/release/hwloc/v2.12/hwloc-2.12.2.tar.gz

RUN set -eux ; \
    cd / ;\
    wget $HWLOC_TAR; \
    tar -xzf hwloc-2.12.2.tar.gz ;\
    cd hwloc-2.12.2 ;\
    CC=gcc-$GCC_RELEASE ./configure --with-rocm=$ROCM_PATH --disable-rsmi --prefix=/opt/hwloc  --localstatedir=/var ;\
    make install ;\
    ldconfig

ENV PATH=/opt/hwloc/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/hwloc/lib:$LD_LIBRARY_PATH

#ARG SLURM_VERSION=23-02-7-1
#RUN wget https://github.com/SchedMD/slurm/archive/slurm-${SLURM_VERSION}.tar.gz \
# && tar -xf slurm-${SLURM_VERSION}.tar.gz \
# && cd slurm-slurm-${SLURM_VERSION} \
# && ./configure --prefix=/opt/slurm \
# && cd contribs/pmi2 \
# && make -j$(getconf _NPROCESSORS_ONLN) install \
# && rm -Rf ../../../slurm*
#ENV LD_LIBRARY_PATH=/opt/slurm/lib:$LD_LIBRARY_PATH
#ENV LD_RUN_PATH=/opt/slurm/lib:$LD_RUN_PATH

# Channel 4 only works on v >= 3.4.3
ENV MPICH_VERSION=4.2.3

ENV MPICH_PATH=/opt/mpich
ENV MPICH_TAR=http://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz

#
# Add MPICH
RUN set -eux ; \
    cd / ;\
    wget $MPICH_TAR ; \
    tar -xzf mpich-$MPICH_VERSION.tar.gz; \
    rm mpich-$MPICH_VERSION.tar.gz;\
    cd mpich-$MPICH_VERSION ;\
    CC=gcc-$GCC_RELEASE CXX=g++-$GCC_RELEASE  \
        ./configure --prefix=$MPICH_PATH  \
            --with-hip-lib=$ROCM_PATH/lib/  \
            --with-hip-include=$ROCM_PATH/include/  \
            --with-libfabric=/opt/libfabric  \
            --disable-fortran \
            --enable-fast=all,O3  \
#            --disable-fast \
            --with-device=ch4:ofi:cxi \
#            --with-pmi=pmi2 \
#            --with-pmi-include==/opt/slurm/include/slurm/ \
#            --with-pmi-lib==/opt/slurm/lib/ \
#            --with-pmilib=install \
            --with-pm=no \
            --disable-silent-rules \
            --enable-debuginfo \
            --with-hwloc=/opt/hwloc \
            --enable-shared ;\
    make -j 12;\
    make install;\
    ldconfig


ENV PATH=$MPICH_PATH/bin:$PATH
ENV LD_LIBRARY_PATH=$MPICH_PATH/lib:$LD_LIBRARY_PATH

#RUN set -eux ;\
#    unset MPIR_CVAR_OFI_USE_PROVIDER ;
#
ENV FI_PROVIDER=cxi
#ENV MPIR_CVAR_ENABLE_GPU=1
ENV FI_MRwM_ROCM=1

#
# Mark RCCL as non-debug - this can me overriden by RCCL debug build.
#
#ENV RCCL_DEBUG=0
#ARG AWS_PLUGIN_VERSION=17d41cb
#ARG AWS_PLUGIN_VERSION=6dae1b0
# Latest ROCm v1.14.x-xccl
ARG XCCL_PLUGIN_VERSION=1ea938a
#Seems to be incompatible with latest libfabric version 2.0.0
RUN set -eux ; \
#  git clone -b cxi https://github.com/ROCmSoftwarePlatform/aws-ofi-rccl /opt/mybuild_aws_ofi ; \
  git clone https://github.com/HewlettPackard/open-ofi-xccl /opt/mybuild_aws_ofi ; \
  cd /opt/mybuild_aws_ofi ; \
#  git checkout -b mydev $AWS_PLUGIN_VERSION; \
  git checkout -b mydev $XCCL_PLUGIN_VERSION; \
#  git apply < /aws.patch ; \
#  cd /opt/mybuild_aws_ofi ; \
  rm -r .git ; \
  export CPATH=$LIBFABRIC_PATH/include ; \
  export LIBRARY_PATH=$LD_LIBRARY_PATH ; \
  ./autogen.sh ; \
#  LDFLAGS='-L/opt/shs-libcxi/lib -lcxi' CC=gcc-$GCC_RELEASE CXX=g++-$GCC_RELEASE ./configure --with-libfabric=$LIBFABRIC_PATH --enable-trace --with-hip=$ROCM_PATH --with-rccl=$ROCM_PATH --with-mpi=$MPICH_PATH --disable-tests; \
  LDFLAGS='-L/opt/shs-libcxi/lib -lcxi' CC=gcc-$GCC_RELEASE CXX=g++-$GCC_RELEASE ./configure --with-libfabric=$LIBFABRIC_PATH --with-mpi=$MPICH_PATH --with-hwloc=/opt/hwloc/ --enable-trace --with-rocm=$ROCM_PATH --disable-tests; \
  LDFLAGS='-L/opt/shs-libcxi/lib -lcxi' CC=gcc-$GCC_RELEASE nice make -j ; \
  \
  mkdir /opt/aws-ofi-rccl ; \
  mv src/.libs/librccl-net.so* /opt/aws-ofi-rccl
#  cd ;\
#  rm -rf /opt/mybuild_aws_ofi

#
# Add relevant libs to execution environment
#
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/opt/aws-ofi-rccl
ENV CXI_FORK_SAFE=1
ENV CXI_FORK_SAFE_HP=1
ENV FI_CXI_DISABLE_CQ_HUGETLB=1



#COPY run_script.sh /singularity/
#
#RUN set -eux ; \
#    chmod +x /singularity/run_script.sh;\

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/opt/rccl/lib/

ENV PYTORCH_ROCM_ARCH gfx90a
ARG PYTORCH_VERSION=2.7.1+rocm6.2.4
ARG PYTORCH_DEBUG
ARG PYTORCH_RELWITHDEBINFO


#
# Install miniconda
#
RUN set -eux ; \
  curl -LO https://repo.anaconda.com/miniconda/Miniconda3-py312_24.5.0-0-Linux-x86_64.sh ; \
  bash ./Miniconda3-* -b -p /opt/miniconda3 -s ; \
  rm -rf ./Miniconda3-*

ENV WITH_CONDA "source /opt/miniconda3/bin/activate base"
#
# Install conda environment
#
ENV PYTHON_VERSION=3.12
RUN $WITH_CONDA; set -eux ; \
  conda create -n pytorch python=$PYTHON_VERSION ; \
  conda activate pytorch ; \
  conda install -y ninja pillow cmake pyyaml pip; \
  conda install -c conda-forge typing-extensions; \
  pip install mkl-static mkl-include
ENV WITH_CONDA "source /opt/miniconda3/bin/activate pytorch"

RUN set -eux ; \
  zypper --no-gpg-checks -n install -y --force-resolution \
    libgomp1 ; \
  zypper clean

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/lib64/
ENV LD_RUN_PATH $LD_RUN_PATH:/usr/lib64/

RUN $WITH_CONDA; set -eux ; \
    conda install filelock fsspec jinja2 markupsafe mpmath networkx numpy pillow pip sympy typing-extensions psutil
#    pip install torchaudio==2.7.1+rocm6.2.4 --extra-index-url https://download.pytorch.org/whl/rocm6.2.4/ ;\
#    pip install torchvision==0.22.1+rocm6.2.4 --extra-index-url https://download.pytorch.org/whl/rocm6.2.4/;\
#    pip install /opt/my_pytorch_build/dist/torch-2.7.1a0+gite2d141d-cp312-cp312-linux_x86_64.whl

#RUN #$WITH_CONDA; set -eux ; \
#    git clone https://github.com/pytorch/pytorch /opt/my_pytorch_build;\
#    cd /opt/my_pytorch_build;\
#    git checkout -b mydev e2d141d;\
#    git submodule sync;\
#    git submodule update --init --recursive;\
#    sed -i '205i string(APPEND CMAKE_CXX_FLAGS " -Wno-vla-cxx-extension")' third_party/fbgemm/CMakeLists.txt;\
#    pip install -r requirements.txt;\
#    python3 tools/amd_build/build_amd.py;\
#    CC=gcc-12 CXX=g++-12 RCCL_DIR=/opt/rccl/lib/cmake/rccl/ PYTORCH_ROCM_ARCH=$PYTORCH_ROCM_ARCH USE_CUDA=OFF python3 setup.py bdist_wheel

RUN $WITH_CONDA; set -eux ; \
  pip3 install --pre torch==${PYTORCH_VERSION} --index-url https://download.pytorch.org/whl/ ; \
  cp /opt/rocm/lib/librccl.so $(dirname $(python -c 'import torch; print(torch.__file__)'))/lib

ARG TORCHVISION_VERSION=0.22.1+rocm6.2.4
RUN $WITH_CONDA; set -eux ; \
  pip3 install --pre torchvision==$TORCHVISION_VERSION --index-url https://download.pytorch.org/whl/


ARG TORCHAUDIO_VERSION
RUN $WITH_CONDA; set -eux ; \
  pip3 install --pre torchaudio==${PYTORCH_VERSION} --index-url https://download.pytorch.org/whl/


ENV CONDA_DEFAULT_ENV=pytorch
ENV CONDA_SHLVL=1
ENV CONDA_EXE="/opt/miniconda3/bin/conda"
ENV CONDA_PREFIX="/opt/miniconda3/envs/$CONDA_DEFAULT_ENV"
ENV _CE_M=''
ENV CONDA_PYTHON_EXE="/opt/miniconda3/bin/python"
ENV _CE_CONDA=''
ENV CONDA_PROMPT_MODIFIER="($CONDA_DEFAULT_ENV)"
ENV PATH="/opt/miniconda3/envs/$CONDA_DEFAULT_ENV/bin:/opt/miniconda3/condabin:$PATH"

# Disable the WITH_CONDA helper
ENV WITH_CONDA=true


RUN set -eux ; \
  git clone https://github.com/rocm/rccl-tests /opt/mybuild ; \
  cd /opt/mybuild ; \
  git checkout -b mydev ae3e635 ; \
  sed -i 's/-std=c++14/-std=c++14 --amdgpu-target=gfx90a:xnack- --amdgpu-target=gfx90a:xnack+/g' /opt/mybuild/src/Makefile ; \
  \
  cd /opt/mybuild ; \
  CC=gcc-12 \
    DEBUG=1 \
    CXX=g++-12 \
    MPI_HOME=$MPICH_PATH \
    ROCM_PATH=$ROCM_PATH \
    MPI=1 \
    NCCL_HOME=$ROCM_PATH/rccl \
    nice make -j ; \
  mkdir /opt/rccltests ; \
  mv /opt/mybuild/build/* /opt/rccltests ; \
  rm -rf /opt/mybuild


#RUN #set -eux; \
#    /opt/miniconda3/uninstall.sh

# patch needed for Clang compilation but the lines in the pathch
#    wget https://github.com/pytorch/pytorch/files/13932860/caffe2-2.1.2-rocm-fix-std-cpp17.patch;\
#    git apply caffe2-2.1.2-rocm-fix-std-cpp17.patch;\

# this is the commit for the additional -Wno-vla-cxx-extension flag
#    cd third_party/fbgemm;\
#    git checkout -b mydev a1c8ab3;\
#    cd ../..;\

ENV OSU_PATH="/opt/osu"

RUN set -eux ; \
  mkdir /opt/builds ; \
  cd /opt/builds ; \
  curl -LO  https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-$OSU_VERSION.tar.gz ; \
  tar -xf osu-*.tar.gz ; \
  rm -rf osu-*.tar.gz ; \
  \
  cd /opt/builds/osu-*/ ; \
  CC=$(which mpicc) CXX=$(which mpicxx) \
  CFLAGS="-I$MPICH_PATH/include -D__HIP_PLATFORM_AMD__=1" \
  ./configure --enable-rocm --with-rocm=$ROCM_PATH --enable-rcclomb --with-rccl=$ROCM_PATH --prefix=$OSU_PATH ; \
  make -j install; \
  cd / ;  \
  rm -rf /opt/builds
