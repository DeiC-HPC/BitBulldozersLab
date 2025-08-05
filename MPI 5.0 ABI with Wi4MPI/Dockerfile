FROM ubuntu:latest AS base

LABEL maintainer="joachim.sodequist@deic.dk"
LABEL version="0.1"
LABEL description="Docker with spack-installed openmpi, mpich and wi4mpi"

SHELL [ "/bin/bash", "-c" ]
RUN apt-get update && apt-get -y install git python3-pip gcc-11 g++-11 gfortran-11 wget

RUN groupadd -g 1234 customgroup && \
    useradd -m -u 1234 -g customgroup myuser
USER myuser
WORKDIR /home/myuser

FROM base AS mpi_installation

# Install Spack, Wi4MPI and MPI implementations
RUN git clone https://github.com/spack/spack.git
RUN source spack/share/spack/setup-env.sh && \
    spack compiler find && \
    spack install wi4mpi && \
    spack install mpich && \
    spack install openmpi

FROM mpi_installation AS full_installation

# Install Miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-4.7.12-Linux-x86_64.sh -O /tmp/miniconda.sh
RUN /bin/bash /tmp/miniconda.sh -b -p /home/myuser/conda && \
    rm /tmp/miniconda.sh
ENV PATH=/home/myuser/conda/bin:$PATH

#Install uv
RUN wget -qO- https://astral.sh/uv/install.sh | sh

FROM full_installation AS configured

RUN source spack/share/spack/setup-env.sh && \
    spack load wi4mpi && \
    spack load openmpi && \
    echo "OPENMPI_DEFAULT_ROOT='${MPICC%bin*}'" >> $WI4MPI_ROOT/etc/wi4mpi.cfg

RUN source spack/share/spack/setup-env.sh && \
    spack load wi4mpi && \
    spack load mpich && \
    echo "MPICH_DEFAULT_ROOT='${MPICC%bin*}'" >> $WI4MPI_ROOT/etc/wi4mpi.cfg

RUN echo "source /home/myuser/spack/share/spack/setup-env.sh" >> /home/myuser/.bashrc
ENTRYPOINT [ "/bin/bash"]

FROM configured AS final

ADD --chown=1234:1234 . /home/myuser/
