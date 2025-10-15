FROM opensuse/leap:15.5
LABEL authors="julius"

ENTRYPOINT ["top", "-b"]

#we need to copy files needed to DOCKER
COPY rocminfo rocm_agent_enumerator amdgpu-arch.cpp aws.patch /

# Versions
#ENV ROCM_RELEASE=6.0.2
#ENV AMDGPU_INSTALLER_RELEASE=6.0.60002-1

ENV ROCM_RELEASE=6.2.4
ENV AMDGPU_INSTALLER_RELEASE=6.2.60204-1

ENV GCC_RELEASE=12
ENV OSU_VERSION=7.5
ENV SLE_RELEASE=15.5

#ARG RCCL_VERSION=ed65777dd53a1426ddf82c4af9b288b3b15881fe
ENV RCCL_VERSION=85eb1f1
ENV CASSINI_HEADERS_VERSION=9a8a738a879f007849fbc69be8e3487a4abf0952
ENV CXI_DRIVER_VERSION=c284516fa8d0027b8f84e8ca818e8c6bbe320bd8
ENV LIBCXI_VERSION=0f3609b5e224636abffc7ceffe6f4e9c83244c08
ENV LIBFABRIC_VERSION=e08d3161b8038ebfa50a4eb5bf76132e4eaeb137
ENV AWS_PLUGIN_VERSION=17d41cb



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
RUN zypper refresh
RUN zypper update -y
RUN set -eux ; \
  zypper --no-gpg-checks -n install -y --force-resolution \
    git cmake gcc${GCC_RELEASE} gcc${GCC_RELEASE}-c++ gcc${GCC_RELEASE}-fortran zlib-devel numactl awk patch tar autoconf automake libtool libjson-c-devel graphviz ncurses-devel nano which perl wget lbzip2  libjansson4 libnl3-200; \
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


# Repo contains perl libraries (?) that are needed for the rocm install. If the repos arent added the amdgpu-installer cannot resolve the dependencies.
RUN set -eux ; \
   zypper -n addrepo https://download.opensuse.org/repositories/devel:/languages:/perl/SLE_15_SP5 myrepo5 ; \
   echo 'gpgcheck=0' >> /etc/zypp/repos.d/myrepo5.repo

ENV ROCM_RPM=https://repo.radeon.com/amdgpu-install/$ROCM_RELEASE/sle/$SLE_RELEASE/amdgpu-install-$AMDGPU_INSTALLER_RELEASE.noarch.rpm

# Try to remove GPG key check
RUN set -eux ; \
  sed -i 's#gpgcheck=1#gpgcheck=0#g' /etc/zypp/repos.d/*.repo

# Add AMD key
RUN set -eux ; \
    wget -O rocm.gpg.key https://repo.radeon.com/rocm/rocm.gpg.key ; \
    rpm --import rocm.gpg.key ; \
    rm rocm.gpg.key

# Install amdgpu-install
RUN set -eux ; \
  zypper --no-gpg-checks -n install $ROCM_RPM

#What are these for?
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
# latest RCCL version --> maybe try

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

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rccl/lib/

#ENV LIBFABRIC_VERSION=2.1.0
# Channel 4 only works on v >= 3.4.3
ENV MPICH_VERSION=4.2.3
# install additional dependencies for the full opensource version. may be partially required for the libfabric hybrid approach as well.
RUN zypper refresh
RUN zypper update -y
RUN set -eux ; \
  zypper --no-gpg-checks -n install -y --force-resolution \
    libconfig-devel libuv-devel libfuse2 libyaml-devel fuse-devel libnl3-devel libnuma-devel bison flex libcurl-devel libsensors4-devel gzip; \
  zypper clean


# --> latest commit on main
RUN set -eux ; \
    cd /opt/ ;\
    git clone https://github.com/HewlettPackard/shs-cassini-headers;\
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
    export CPATH=/include ; \
    cd /opt/ ; \
    git clone http://github.com/HewlettPackard/shs-libcxi ;\
    git -C /opt/shs-libcxi checkout -b mydev $LIBCXI_VERSION ; \
    cd shs-libcxi; \
#    git checkout 0f3609b5e224636abffc7ceffe6f4e9c83244c08;\
    sed -i 's+/usr/share/cassini-headers/csr_defs.json+/share/cassini-headers/csr_defs.json+g' utils/cxi_dump_csrs.py ;\
    ./autogen.sh;\
    CC=gcc-$GCC_RELEASE CXX=g++-$GCC_RELEASE CFLAGS='-Wno-unused-but-set-variable' \
      ./configure --prefix=$LIBCXI_PATH --with-rocm=$ROCM_PATH \
        --without-systemd \
        --with-systemdsystemunitdir=/opt/shs-libcxi/systemdsystemunitdir \
        --with-udevrulesdir=/opt/shs-libcxi/udevrulesdir ; \
    make VERBOSE=1 V=1 -j ; \
    make VERBOSE=1 V=1 -j install

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LIBCXI_PATH/lib
ENV LD_RUN_PATH=$LD_RUN_PATH:$LIBCXI_PATH/lib
# Download and install libfabric. CXI provider doesnt get installed atm.
# CXI provider has to be available.

# libfabric environment
ENV LIBFABRIC_PATH=/opt/libfabric

# need version higher than 1.15.2. 1.15 does not have a cxi provider
# sed is needed to delete the CXI_MAP_IOVA_ALLOC as it was removed. https://github.com/search?q=repo%3AHewlettPackard%2Fshs-libcxi+CXI_MAP_IOVA_ALLOC&type=commits

### LIBFABRIC from releases
#RUN set -eux ; \
#    wget https://github.com/ofiwg/libfabric/releases/download/v$LIBFABRIC_VERSION/libfabric-$LIBFABRIC_VERSION.tar.bz2 ; \
#    tar -xf libfabric-$LIBFABRIC_VERSION.tar.bz2; \
#    rm libfabric-$LIBFABRIC_VERSION.tar.bz2; \
#    cd libfabric-$LIBFABRIC_VERSION; \
#    sed -i 's/| CXI_MAP_IOVA_ALLOC//g' prov/cxi/include/cxip.h ;\
#    CC=gcc-$GCC_RELEASE ./configure --enable-cxi=$LIBCXI_PATH --prefix=$LIBFABRIC_PATH CFLAGS='-I /include' --with-rocr=$ROCM_PATH --enable-rocr-dlopen; \
#    make -j;\
#    make install;\
#    ldconfig ;\
#    cd /; \
#    rm -rf libfabric-$LIBFABRIC_VERSION

RUN set -eux ; \
  export CPATH=/include:$LIBCXI_PATH/lib ; \
  export LIBRARY_PATH=$LIBCXI_PATH/lib ; \
  git clone --recursive https://github.com/ofiwg/libfabric /opt/libfabric-src ; \
  git -C /opt/libfabric-src checkout -b mydev $LIBFABRIC_VERSION ; \
  cd /opt/libfabric-src ; \
  ./autogen.sh ; \
  mkdir /opt/libfabric-src/build ; \
  cd /opt/libfabric-src/build ; \
  ../configure CC=gcc-$GCC_RELEASE --prefix=$LIBFABRIC_PATH \
    LDFLAGS=-Wl,--build-id --enable-only \
    --enable-restricted-dl --enable-tcp --enable-udp --enable-rxm --enable-rxd --enable-hook_debug \
    --enable-hook_hmem --enable-dmabuf_peer_mem --enable-cxi=$LIBCXI_PATH --enable-gdrcopy-dlopen --with-rocr=$ROCM_PATH ; \
  cd /opt/libfabric-src/build ; \
  nice make V=1 VERBOSE=1 -j  ; \
  nice make V=1 VERBOSE=1 -j install ; \
  cd / ; rm -rf /opt/libfabric-src

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$LIBFABRIC_PATH/lib
ENV LD_RUN_PATH $LD_RUN_PATH:$LIBFABRIC_PATH/lib

#ENV HWLOC_TAR=https://download.open-mpi.org/release/hwloc/v2.12/hwloc-2.12.0.tar.gz
#
#RUN set -eux ; \
#    cd / ;\
#    wget $HWLOC_TAR; \
#    tar -xzf hwloc-2.12.0.tar.gz ;\
#    cd hwloc-2.12.0 ;\
#    CC=gcc-$GCC_RELEASE ./configure --prefix=/opt/hwloc  --localstatedir=/var ;\
#    make install ;\
#    ldconfig
#
#ENV PATH=/opt/hwloc/bin:$PATH
#ENV LD_LIBRARY_PATH=/opt/hwloc/lib:$LD_LIBRARY_PATH

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
            --disable-fortran  \
            --enable-fast=all,O3  \
            --with-device=ch4:ofi \
             --with-pm=none \
            --disable-silent-rules \
            --enable-debuginfo \
#            --with-hwloc=/opt/hwloc \
            --enable-shared ;\
    make -j 12;\
    make install;\
    ldconfig


ENV PATH=$MPICH_PATH/bin:$PATH
ENV LD_LIBRARY_PATH=$MPICH_PATH/lib:$LD_LIBRARY_PATH

#RUN set -eux ;\
#    unset MPIR_CVAR_OFI_USE_PROVIDER ;
#
#ENV FI_PROVIDER=cxi
#ENV MPIR_CVAR_ENABLE_GPU=1
#ENV FI_MR_HMEM=1



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


#
# Mark RCCL as non-debug - this can me overriden by RCCL debug build.
#
ENV RCCL_DEBUG=0

#Seems to be incompatible with latest libfabric version 2.0.0
RUN set -eux ; \
  git clone -b cxi https://github.com/ROCmSoftwarePlatform/aws-ofi-rccl /opt/mybuild_aws_ofi ; \
  cd /opt/mybuild_aws_ofi ; \
  git checkout -b mydev $AWS_PLUGIN_VERSION ; \
  git apply < /aws.patch ; \
  ./autogen.sh ; \
  cd /opt/mybuild_aws_ofi ; \
  export CPATH=$LIBFABRIC_PATH/include ; \
  export LIBRARY_PATH=$LD_LIBRARY_PATH ; \
  LDFLAGS='-L/opt/libcxi/lib -lcxi' CC=gcc-12 ./configure --with-libfabric=$LIBFABRIC_PATH --enable-trace --with-hip=$ROCM_PATH --with-rccl=$ROCM_PATH --disable-tests ; \
  LDFLAGS='-L/opt/libcxi/lib -lcxi' CC=gcc-12 nice make -j ; \
  mkdir /opt/aws-ofi-rccl ; \
  mv src/.libs/librccl-net.so* /opt/aws-ofi-rccl ; \
  rm -rf /opt/mybuild

### My old stuff
#  cd /opt/mybuild_aws_ofi ; \
#  export CPATH=$LIBFABRIC_PATH/include ; \
#  export LIBRARY_PATH=$LD_LIBRARY_PATH ; \
#  CC=gcc-$GCC_RELEASE ./configure --with-libfabric=$LIBFABRIC_PATH --enable-trace --with-hip=$ROCM_PATH --with-rccl=$ROCM_PATH --disable-tests ; \
#  CC=gcc-$GCC_RELEASE nice make -j ; \
#  \
#  mkdir /opt/aws-ofi-rccl ; \
#  mv src/.libs/librccl-net.so* /opt/aws-ofi-rccl; \
#  cd /
#  rm -rf /opt/mybuild_aws_ofi

#
# Add relevant libs to execution environment
#
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/opt/aws-ofi-rccl
ENV FI_CXI_DISABLE_CQ_HUGETLB=1

## THESE LEAD TO PROBLEMS with PyTorch DDP!!!
#ENV CXI_FORK_SAFE=1
#ENV CXI_FORK_SAFE_HP=1


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


ENV OSU_PATH=/opt/osu

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
  rm -rf /opt/builds;


#COPY run_script.sh /singularity/
#
#RUN set -eux ; \
#    chmod +x /singularity/run_script.sh;\

