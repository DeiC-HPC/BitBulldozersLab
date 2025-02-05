#!/usr/bin/env bash
#
# A LUMI SLURM batch script for the LUMI PyTorch multi GPU torchrun example from
# https://github.com/DeiC-HPC/cotainr
#
#SBATCH --job-name=libfabric_hybrid_bandwidth_and_latency_tests
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --partition=dev-g
#SBATCH --time=00:02:00
#SBATCH --account=project_465001699
#SBATCH --exclusive

export MIOPEN_USER_DB_PATH=/tmp/${USER}-miopen-cache-${SLURM_JOB_ID}
export MIOPEN_CUSTOM_CACHE_DIR=${MIOPEN_USER_DB_PATH}

export SINGULARITYENV_LD_LIBRARY_PATH=\
"/opt/libfabric/lib64:"\
'/opt/rocm-6.0.3/llvm/lib:'\
'/opt/rocm-6.0.3/lib:'\
'/opt/mpich/lib'\
'/usr/lib64:'\
"/lib64:"\
'/opt/cray/pe/pmi/6.1.14/lib:'\
'/opt/cray/pals/1.3.2/lib:'

export SINGULARITY_BIND=\
'/opt/cray/libfabric/1.15.2.0:/opt/libfabric,'\
'/opt/cray/pe,'\
'/opt/cray/pals,'\
'/var/spool,'\
'/etc/host.conf,'\
'/etc/hosts,'\
'/etc/nsswitch.conf,'\
'/etc/resolv.conf,'\
'/etc/ssl/openssl.cnf,'\
'/run/cxi,'\
'/usr/share/libdrm/amdgpu.ids,'\
'/usr/lib64/libcxi.so.1,'\
'/usr/lib64/libcurl.so.4,'\
'/usr/lib64/libjson-c.so.3,'\
'/usr/lib64/libatomic.so.1,'\
'/usr/lib64/libnl-3.so.200,'\
'/usr/lib64/libnghttp2.so.14,'\
'/usr/lib64/libidn2.so.0,'\
'/usr/lib64/libssh.so.4,'\
'/usr/lib64/libpsl.so.5,'\
'/usr/lib64/libssl.so.1.1,'\
'/usr/lib64/libcrypto.so.1.1,'\
'/usr/lib64/libgssapi_krb5.so.2,'\
'/usr/lib64/libldap_r-2.4.so.2,'\
'/usr/lib64/liblber-2.4.so.2,'\
'/usr/lib64/libzstd.so.1,'\
'/usr/lib64/libbrotlidec.so.1,'\
'/usr/lib64/libz.so.1,'\
'/usr/lib64/libunistring.so.2,'\
'/usr/lib64/libjitterentropy.so.3,'\
'/usr/lib64/libkrb5.so.3,'\
'/usr/lib64/libk5crypto.so.3,'\
'/usr/lib64/libkrb5support.so.0,'\
'/usr/lib64/libsasl2.so.3,'\
'/usr/lib64/libbrotlicommon.so.1,'\
'/usr/lib64/libkeyutils.so.1,'\
'/usr/lib64/libpcre.so.1,'

#'/opt/cray/pe,'\

# Figure out GTL
#export MPICH_GPU_SUPPORT_ENABLED=1
#export MPICH_OFI_NIC_POLICY=GPU


#export SINGULARITYENV_LD_PRELOAD="/opt/cray/pe/lib64/libmpi_gtl_hsa.so $LD_PRELOAD"
srun --output=libfabric_hybrid_bandwidth_host_host.txt --mpi=pmi2 singularity exec -B /project/project_465001699/ base_mpich3.1.4_libfabric1.15.2.sif /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw H H
#srun --output=libfabric_hybrid_bandwidth_host_device.txt singularity exec -B /project/project_465001699/ base_mpich3.1.4_libfabric1.15.2.sif /singularity/run_script.sh /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw H D
#srun --output=libfabric_hybrid_bandwidth_device_host.txt singularity exec -B /project/project_465001699/ base_mpich3.1.4_libfabric1.15.2.sif /singularity/run_script.sh /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw D H
#srun --output=libfabric_hybrid_bandwidth_device_device.txt --exclusive singularity exec -B /project/project_465001699/ base_mpich3.1.4_libfabric1.15.2.sif /singularity/run_script.sh /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw D D
#
#srun --output=libfabric_hybrid_latency_host_host.txt --exclusive singularity exec -B /project/project_465001699/ base_mpich3.1.4_libfabric1.15.2.sif /singularity/run_script.sh /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency H H
#srun --output=libfabric_hybrid_latency_host_device.txt --exclusive singularity exec -B /project/project_465001699/ base_mpich3.1.4_libfabric1.15.2.sif /singularity/run_script.sh /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency H D
#srun --output=libfabric_hybrid_latency_device_host.txt --exclusive singularity exec -B /project/project_465001699/ base_mpich3.1.4_libfabric1.15.2.sif /singularity/run_script.sh /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency D H
#srun --output=libfabric_hybrid_latency_device_device.txt --exclusive singularity exec -B /project/project_465001699/ base_mpich3.1.4_libfabric1.15.2.sif /singularity/run_script.sh /opt/osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency D D


#srun --nodes=1 --partition=dev-g  --exclusive --account=project_465001699 --time=00:02:00 --gpus-per-node=1 --ntasks-per-node=1 --mpi=pmi2 singularity run -B /project/project_465001699/ base_mpich3.1.4_libfabric1.15.2.sif bash


#/lib64/ld-linux-x86-64.so.2
#/lib64/libcom_err.so.2
#/lib64/libresolv.so.2
#/lib64/libselinux.so.1
#/lib64/librt.so.1
#/lib64/libpthread.so.0
#/lib64/libdl.so.2
#/lib64/libc.so.6
#/lib64/libm.so.6
