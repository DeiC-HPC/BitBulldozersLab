#!/usr/bin/env bash
#
#
#SBATCH --job-name=libfabric_hybrid_bandwidth_and_latency_tests
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --partition=dev-g
#SBATCH --time=00:05:00
#SBATCH --account=project_465001699
#SBATCH --exclusive

export MIOPEN_USER_DB_PATH=/tmp/${USER}-miopen-cache-${SLURM_JOB_ID}
export MIOPEN_CUSTOM_CACHE_DIR=${MIOPEN_USER_DB_PATH}

export SINGULARITYENV_LD_LIBRARY_PATH=\
'/opt/mpich/lib:'\
"/opt/cray/libfabric/1.15.2.0/lib64:"\
'/opt/cray/pe/pmi/6.1.14/lib:'\
'/opt/cray/pals/1.3.2/lib:'\
'/opt/rocm-6.0.3/llvm/lib:'\
'/usr/lib64:'\
'/opt/rocm-6.0.3/lib:'

export SINGULARITY_BIND=\
'/opt/cray,'\
'/var/spool/slurmd,'\
'/usr/lib64/libcxi.so.1,'

# Optional??
#'/var/spool,'\
#'/etc/host.conf,'\
#'/etc/hosts,'\
#'/etc/nsswitch.conf,'\
#'/etc/resolv.conf,'\
#'/etc/ssl/openssl.cnf,'\
#'/usr/lib64/libatomic.so.1,'\
#'/usr/lib64/libbrotlicommon.so.1,'\
#'/usr/lib64/libbrotlidec.so.1,'\
#'/usr/lib64/libcrypto.so.1.1,'\
#'/usr/lib64/libcurl.so.4,'\
#'/usr/lib64/libdrm_amdgpu.so.1,'\
#'/usr/lib64/libdrm.so.2,'\
#'/usr/lib64/libelf.so.1,'\
#'/opt/cray/pe/gcc-libs/libgcc_s.so.1:/usr/lib64/libgcc_s.so.1,'\
#'/opt/cray/pe/gcc-libs/libgfortran.so.5:/usr/lib64/libgfortran.so.5,'\
#'/usr/lib64/libgssapi_krb5.so.2,'\
#'/usr/lib64/libidn2.so.0,'\
#'/usr/lib64/libjansson.so.4,'\
#'/usr/lib64/libjitterentropy.so.3,'\
#'/usr/lib64/libjson-c.so.3,'\
#'/usr/lib64/libk5crypto.so.3,'\
#'/usr/lib64/libkeyutils.so.1,'\
#'/usr/lib64/libkrb5.so.3,'\
#'/usr/lib64/libkrb5support.so.0,'\
#'/usr/lib64/liblber-2.4.so.2,'\
#'/usr/lib64/libldap_r-2.4.so.2,'\
#'/usr/lib64/liblnetconfig.so.4,'\
#'/usr/lib64/liblustreapi.so,'\
#'/usr/lib64/libnghttp2.so.14,'\
#'/usr/lib64/libnl-3.so.200,'\
#'/usr/lib64/libnl-route-3.so.200,'\
#'/usr/lib64/libnuma.so.1,'\
#'/usr/lib64/libpcre.so.1,'\
#'/usr/lib64/libpsl.so.5,'\
#'/usr/lib64/libsasl2.so.3,'\
#'/usr/lib64/libssh.so.4,'\
#'/usr/lib64/libssl.so.1.1,'\
#'/opt/cray/pe/gcc-libs/libstdc++.so.6:/usr/lib64/libstdc++.so.6,'\
#'/usr/lib64/libunistring.so.2,'\
#'/usr/lib64/libyaml-0.so.2,'\
#'/usr/lib64/libz.so.1,'\
#'/usr/lib64/libzstd.so.1,'\

#export SINGULARITYENV_MPICH_GPU_SUPPORT_ENABLED=1
export SINGULARITYENV_MPIR_CVAR_CH4_OFI_ENABLE_HMEM=1
export SINGULARITYENV_MPICH_OFI_NIC_POLICY=GPU
export SINGULARITYENV_FI_PROVIDER=cxi

# Debug options
#export SINGULARITYENV_MPICH_OFI_VERBOSE=1
#export SINGULARITYENV_MPICH_OFI_NIC_VERBOSE=1
#export SINGULARITYENV_FI_LOG_LEVEL=debug

srun --output=libfabric_hybrid_bandwidth_host_host.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw H H
srun --output=libfabric_hybrid_bandwidth_host_device.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw H D
srun --output=libfabric_hybrid_bandwidth_device_host.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw D H
srun --output=libfabric_hybrid_bandwidth_device_device.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw -d rocm D D
#
srun --output=libfabric_hybrid_latency_host_host.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1  /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency H H
srun --output=libfabric_hybrid_latency_host_device.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1 /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency H D
srun --output=libfabric_hybrid_latency_device_host.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1  /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency D H
srun --output=libfabric_hybrid_latency_device_device.txt --exclusive --mpi=pmi2 singularity exec -B /project/project_465001699/ $1  /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency D D
