#!/bin/bash -e

conda init
source ~/.bashrc
conda tos accept

echo "Creating Conda environments"

conda env create -n mpich -f mpich.yml --no-default-packages --yes
conda env create -n openmpi -f openmpi.yml --no-default-packages --yes

spack unload -a
spack load mpich
conda env create -n mpich-ext -f mpich-ext.yml --no-default-packages --yes

spack unload -a
spack load openmpi
conda env create -n openmpi-ext -f openmpi-ext.yml --no-default-packages --yes

echo "Creating Python venvs"
uv venv venv-mpi4py
source venv-mpi4py/bin/activate
uv pip install mpi4py
deactivate

uv venv venv-openmpi
source venv-openmpi/bin/activate
uv pip install mpi4py openmpi==5.0.8
deactivate

uv venv venv-mpich
source venv-mpich/bin/activate
uv pip install mpi4py mpich==4.2.3
deactivate

