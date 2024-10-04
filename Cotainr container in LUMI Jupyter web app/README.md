# Cotainr container in LUMI Jupyter web app

- **Keywords:** cotainr, Singularity, Jupyter, OOD
- **Date:** 2024-10-03

An example of using a Singularity container built using [cotainr](https://cotainr.readthedocs.io/en/stable/) with the JupyterLab app provided by the [LUMI web interface](https://www.lumi.csc.fi/public/).

## How to

This is a step-by-step guide to building a container with a custom conda environment on LUMI using cotainr and running the LUMI web interface Jupyter app with the built container on LUMI-C.

### Specify the conda environment

First you must create a [conda environment YAML file](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#creating-an-environment-file-manually) specifying the conda/pip packages you want to use. As part of your list of packages, you must include the following:

- jupyterlab >= 3.0.0
- nbclassic

A minimal example of such a conda environment YAML file is [conda_env.yml](conda_env.yml).

### Build the container using cotainr

To build a container you first need to login to LUMI. You can either [login to LUMI via ssh](https://docs.lumi-supercomputer.eu/firststeps/loggingin/) or use the [Login node shell](https://docs.lumi-supercomputer.eu/runjobs/webui/#shell) available once you have [logged in to the LUMI web interface](https://docs.lumi-supercomputer.eu/firststeps/loggingin-webui/).

Next, you need to copy or otherwise create your conda environment file on LUMI. To use the [conda_env.yml](conda_env.yml) provided in this example, on LUMI, you can clone the this git repository running:

```bash
git clone https://github.com/DeiC-HPC/BitBulldozersLab.git
```

Then to build a container based on [conda_env.yml](conda_env.yml) for use with LUMI-C, run the following commands:

```bash
module load CrayEnv cotainr
cotainr build my_container.sif --system=lumi-c --conda-env=BitBulldozersLab/conda_env.yml
```

Note, This can take a few minutes to finish. In the beginning you will be prompted to accept the Miniconda license, answer `yes` and hit ENTER to proceed. Finally, you can see (and remember) the location the `my_container.sif` by running:

```bash
pwd
```

### Launch Jupyterlab based on the built container

In a browser, log in to the [LUMI web interface](https://www.lumi.csc.fi/public/). Next, choose the `Jupyter` app. Specify project, SLURM partition (e.g. `interactive` for LUMI-C), and resources as seen in an example below. Under `Settings`, choose `Advanced` and set `Custom init` to `Text`. In the text box paste the following:

```bash
python="singularity exec --bind=/pfs,/scratch,/projappl,/project,/flash,/appl </path/to/my_container.sif> python3"
```

where you replace `</path/to/my_container.sif>` with the path your noted previously from running `pwd`, for example `/users/myname/my_container.sif.

You configuration should look something like this (with `project_465000227` replaced by your project number):
![Jupyter App configuration](lumi_jupyter_app_configuration.png)

Press the `Launch` button and wait for the interactive session to start. Once it has started, press the `Connect to Jupyter` button.

Using this approach, the JupyterLab instance is started within the container using the conda environment installed in the container based on [conda_env.yml](conda_env.yml), and with all the LUMI user file systems (/scratch, /project, and /flash) mounted in the container.

Once you have connected to the JupyterLab instance, you can use the [cotainr_LUMI_jupyter_demo.ipynb](cotainr_LUMI_jupyter_demo.ipynb) notebook in the BitBulldozersLab folder to verify that you are indeed running in the container, you have built.

## References

More details may be found in:

- [The LUMI web interface docs](https://docs.lumi-supercomputer.eu/runjobs/webui/) and [the LUMI web interface login guide](https://docs.lumi-supercomputer.eu/firststeps/loggingin-webui/)
- [The LUMI Jupyter app docs](https://docs.lumi-supercomputer.eu/runjobs/webui/jupyter/)
- [The LUMI cotainr docs](https://docs.lumi-supercomputer.eu/software/containers/singularity/#building-containers-using-the-cotainr-tool)
- [The official cotainr documentation](https://cotainr.readthedocs.io/en/stable/)
