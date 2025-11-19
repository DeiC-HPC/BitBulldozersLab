# FeNNol benchmark using ReFrame

- **Keywords:** ReFrame, FeNNol
- **Date:** 2025-11-10

For the Epicure project we setup an environment to benchmark FeNNol on the workstations and LUMI.

## Setup - Installing ReFrame
ReFrame is a Python package called `reframe-hpc`, and can usually be pip-installed straightforwardly. Here we install and editable version to patch out a bug at the time of writing.
First we create a venv for ReFrame,
```
> uv venv
> source .venv/bin/activate
```
and then we install editable `reframe-hpc` and apply the patch,
```
> git submodule update --init --recursive
> cp reframe_ssh_sched_read.patch reframe/
> cd reframe && git apply reframe_ssh_sched_read.patch && cd ..
> uv pip install reframe/
```
We are now ready to run the FeNNol benchmark

## Running benchmark on Raxos and Primebox simultaneously
The ReFrame `config.py` defined the system configuration that we submit the benchmarking tests to. We have a single system called `workstations` under which we have defined two partitions `raxos` and `primebox`. The raxos partition just schedules and launches the benchmark locally and the primebox schedules the benchmark on primebox and launches the job remotely. Since we don't have any job scheduler like Slurm or any real partitions, what really happens is when a job is scheduled on primebox is that the "scheduler" copies over the `src/` folder and creates a `run_job.sh` bash script on the remote, and the launcher is the executable used inside this bash script.

We can thus launch the benchmark on both systems using
```
reframe -C config.py -c FeNNol/aspirin-check.py -r
```

The tests are further configurable through the CLI, for example, we can choose to execute only on primebox with cuda enabled
```
reframe -C config.py -c FeNNol/aspirin-check.py --system workstations:primebox -S device="cuda:0" -r
```