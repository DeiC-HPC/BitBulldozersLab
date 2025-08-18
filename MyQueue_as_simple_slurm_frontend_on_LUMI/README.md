# MyQueue as simple slurm frontend on LUMI

- **Keywords:** MyQueue, LUMI, Slurm, EasyBuild, Python
- **Date**: 2025-08-13
## Description

The BitBulldozersLab builds an EasyConfig to install the Slurm frontend tool "MyQueue" on LUMI, and generates a systems.json-like site-config file to enable plug-and-play job submission. Furthermore, it illustrates how one can easily pick up a valid project name of the user to further customize the configuration.

The EasyConfig `MyQueue-25.4.0-cpeGNU-24.03.eb` illustrates the installation of a simple `PythonPackage` easyblock using pip, with `cray-python` being the only dependency. Additionally, we create a file `site-config.py` similar to the `systems.json` in `cotainr`, that has most of the necessary parameters to submit job scripts. In order for MyQueue to pick up this config file, the patch `myqueue-25.4.0-siteconfig.patch` is applied during installation.

The patch `myqueue-25.4.0-siteconfig.patch` accomplished two things. First it adds functionality to the `mq init` command in order to read the dictionary in the `site-config.py` and copy it to the user home folder. Secondly, it automatically picks up a list of valid project names and chooses the most recent one and inserts it in the local `site-config.py`. 

## Automatic system configuration
First we reproduce the setup in a local EasyBuild repository and install the EasyConfig using the `EasyBuild-user` module on LUMI.
```
$ export EBU_USER_PREFIX=$HOME/LUMI-user
$ mkdir $EBU_USER_PREFIX
$ module load LUMI EasyBuild-user
$ eb --install-latest-eb-release
$ export EC_DIR=$EBU_USER_PREFIX/UserRepo/easybuild/easyconfigs/m/MyQueue/
$ mkdir $EC_DIR -p
$ cp MyQueue-25.4.0-cpeGNU-24.03.eb	myqueue-25.4.0-siteconfig.patch $EC_DIR
$ eb $EC_DIR/MyQueue-25.4.0-cpeGNU-24.03.eb
$ export INSTALL_DIR=$EBU_USER_PREFIX/SW/LUMI-24.03/L/MyQueue/25.4.0-cpeGNU-24.03
```
Note that the patch applied during EasyBuild installation is the primary output in the repo. We are now ready to load and use `MyQueue` in the BitBulldozersLab folder.
```
$ module load MyQueue
$ mq init
> Creating $HOME/BitBulldozersLab/MyQueue as simple slurm frontend on LUMI/.myqueue
> Copying $INSTALL_DIR/lib/python3.11/site-packages/myqueue/site-config.py to $HOME/.myqueue/config.py
> Adding project_465001699 to local $HOME/.myqueue/config.py
> Copying $HOME/.myqueue/config.py to $HOME/BitBulldozersLab/MyQueue_as_simple_slurm_frontend_on_LUMI/.myqueue/config.py
```
Where the first and last message are standard `MyQueue` behavior to copy a config file from the user `$HOME/.myqueue` repository to the working directory, in this case the BitBulldozer repo. The new functionality is in the two middle messages which copies from the (central) LUMI installation to the user `$HOME/.myqueue` and then adds the project information. This resulting `./myqueue/config.py` config file looks like this
```
config = {
    'scheduler': 'slurm',
    'extra_args': ['--account=project_465001699'],
    'mpiexec': 'srun',
    'nodes': [
        ('standard', {'cores': 128}),
        ('small', {'cores': 128}),
        ('debug', {'cores': 128}),
        ('largemem', {'cores': 128}),
        ('standard-g', {'cores': 56}),
        ('small-g', {'cores': 56}),
        ('dev-g', {'cores': 56})]}
```
where the static parameters such as scheduler, mpiexec and node sizes are defined in the EasyBuild recipe, and the LUMI-specific account extra_args is added via the hard-coded hook in the patch. In this case `project_465001699` was discovered automatically as the most recent project, however the patch also adds the option `mq init --account=project_46XXXXXXX` that will let the user specify it explicitly.
## Basic CLI usage
(Note: From now on is just a basic introduction to standard `myqueue` with this particular configuration, no changes has been applied in this BitBulldozer in the rest of this section)
We are now ready to run hello-world
```
$ echo 'print("Hello world")' > hello.py
$ mq submit hello.py
$ squeue --me
     JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
  12354822 standard- hello.py joachims CG       0:02      1 nid006683
$ mq ls
id       folder name     res.   age state time
──────── ────── ──────── ───── ──── ───── ────
12391877 ./     hello.py 1:10m 0:06 done  0:00
──────── ────── ──────── ───── ──── ───── ────
done: 1, total: 1
$ cat hello.py.12354822.out 
Hello world
```
In the nicely formatted `mq ls` queue history we see that by default we ask for 1 core with 10 minutes wall-time, and from the `squeue` output we see that we submit to the `standard-g` partitions. This partition choice is because `myqueue` will go down the config and choose the _first_ and _smallest_ node compatible with the requested core count, which is 1 by default. 

We can choose a specific partition to submit to by giving the following resources flag `-R`
```
$ mq submit hello.py -R 1:debug:1m
$ mq ls
id       folder name     res.        age state time
──────── ────── ──────── ────────── ──── ───── ────
12391877 ./     hello.py 1:10m      0:26 done  0:01
12391881 ./     hello.py 1:debug:1m 0:11 done  0:00
──────── ────── ──────── ────────── ──── ───── ────
done: 2, total: 2
```
which results in a permanent growing history of jobs. The resource flag has two mandatory fields and five optional fields, to reach most job requirements. The mandatory fields are number of cores and wall-time. The optional ones are number of processes, number of gpus per node, partition-name, MPI boolean and job weight. The first three are generally useful, while the last two are for more specialized tasks. They are given as \[mpi:\]cores\[:processes\]\[:gpus\]\[:nodename\]:walltime\[:weight\] are described [here](https://myqueue.readthedocs.io/cli.html#submit-submit-task-s-to-queue). For example
- `-R 256:standard:30s` will launch a 2-node job with 30 seconds wall-time
- `-R 8:8G:small-g:20m` will launch a single node job with 8 cpu cores and 8 gpus with 20 minutes wall-time
- `-R s:4:4:4G:small-g:1h` will launch a job with 4 serial processes distributed on 4 cores as well as use 4 gpus on a small-g node for 10 minutes
- `-R 224:8G:standard-g:24h` will launch a job with 4 standard-g nodes with 8 gpus each with 24 hours wall-time.
Notably, we do not have flexibility to assign the number of nodes because in most real-world applications, there are no reason to launch multi-node jobs without using all cores in a node first.
For an advanced user the `myqueue` generated batch script can easily be inspected with `mq submit --dry-run --verbose hello.py` or `mq submit -z -v hello.py` for short.

Clearly the tool is primarily made for submitting python jobs; you can execute python scripts, python modules and function in a module. But you can also execute shell commands and shell-scripts. Let us for example test `rocm-smi` to ensure we get the gpus that we expect
```
$ mq submit "shell:srun rocm-smi" -R 1:2G:dev-g:5s
12396806 ./ shell:srun rocm-smi +1 1:2G:dev-g:5s
1 task submitted
$ mq ls
id       folder name           args     info res.              age state time 
──────── ────── ────────────── ──────── ──── ───────────────── ──── ──── ──── 
12391877 ./     hello.py                     1:10m             2:08 done 0:01
12391881 ./     hello.py                     1:debug:1m        1:53 done 0:00
12396806 ./     shell:srun     rocm-smi +1   1:2G:dev-g:5s     0:08 done 0:00
──────── ────── ────────────── ──────── ──── ───────────────── ──── ──── ──── 
done: 3, total: 3
$ cat shell\:srun.12396806.out
====================================== ROCm System Management Interface...
================================================= Concise Info ========...
Device  [Model : Revision]    Temp    Power  Partitions      SCLK      ...
        Name (20 chars)       (Edge)  (Avg)  (Mem, Compute)            
=======================================================================...
0       [0x0b0c : 0x00]       43.0°C  N/A    N/A, N/A        800Mhz  16...
        AMD INSTINCT MI200 (                                           
1       [0x0b0c : 0x00]       41.0°C  89.0W  N/A, N/A        800Mhz  16...
        AMD INSTINCT MI200 (                                           
=======================================================================...
============================================= End of ROCm SMI Log =====...
```
## Advanced CLI usage
So far we have only covered how `myqueue` can accomplish the same as Slurm but with a smaller barrier of entry, however `myqueue` also has some quality of life improvements as well for some job submission patterns. Suppose we have a script that we want to run on different configurations
```
$ cat hello-name.py
from json import load

with open('cfg.json', 'r') as fd:
    dct = load(fd)

print(f"Hello {dct['name']}")
```
However, the configurations might be too complicated to describe in a command-line input or in an slurm array job, then we can structure the configs in a folder tree structure such as
```
advanced-cli/
 |-folder1/
 | |-cfg.json {"name": "Julius"}
 | |-hello-name.py
 |-folder2/
 | |-cfg.json {"name": "Tor"}
 | |-hello-name.py
```
and then use `myqueue` to submit jobs from both folder
```
$ mq submit hello-name.py advanced-cli/*
Submitting tasks: ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 2/2
12398551 ./experiments/folder1/ hello-name.py 1:10m
12398552 ./experiments/folder2/ hello-name.py 1:10m
2 tasks submitted
$ cat experiments/folder1/hello-name.py.12398551.out 
Hello Julius
$ cat experiments/folder2/hello-name.py.12398552.out 
Hello Tor
```
Thereby easily submitting multiple independent jobs to Slurm. Note that this way of job submission can easily overwhelm the Slurm daemon if you submit thousands of jobs. This has a non-zero chance of pissing off your local system administrator. In order to avoid this `myqueue` can be configured with `maximum_total_task_weight` and `default_task_weight` to create limits to the number of concurrent job submission. This is also where the job weight is used in the resource flag.
## Outlook
In order to move this minimal viable product into a production-ready state, and contribute to upstream MyQueue we would require a few changes:
- Make the hook in MyQueue generic
- Make the EasyConfig generate a Python script that attaches to the generic hook
- (option 1) The `mq init` argument should also be changed to accept arbitrary keyword arguments, to be parsed to the hook 
- (option 2) An alternative to the arbitrary `mq init` keyword argument could be to require input from the user and let them choose from the list of project. This could keep everything in the hook.
- If the user is working in `/project/project_46XXXXXXX` or similar folder, this project should obviously be chosen automatically
The logic would generally be `if site-config.is_file: copy site-config -> local-config; execute site-hook(args)`
The advantages would be to ensure long term stability and maintenance in MyQueue itself, as well as making the EasyConfig fully self-contained without need for a `.patch` file.

The hook mechanism that updates `site-config.py` could be nicer, where instead of string manipulation we read in the dictionary and properly updates and write it back. Although this would change the formatting.

MyQueue can also easily be configured to launch jobs in a container using `singularity exec` as is done at DTU energy https://github.com/dtu-energy/myqueue-configs/blob/main/LUMI/config.py using `'serial_python': 'singularity exec /users/mpeterse/base.sif python3'`, so with a generic hook tied to `mq init`, one could add a hook that would make `mq init container.sif` configure myqueue to launch all script in that folder through the container.
