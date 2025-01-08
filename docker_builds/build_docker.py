from io import BytesIO
import docker
from docker.errors import DockerException
import os
from rich.console import Console
import json

def show_progress(line, console):
    if 'stream' in line:
        if 'Step' in line['stream']:
            step_end = line['stream'].find(":")
            log_message = "[bold cyan]" + line['stream'][:step_end] + "[/bold cyan]" + line['stream'][step_end:]
        else:
            return
    elif 'errorDetail' in line:
        log_message = "[bold red]" + str(line['errorDetail']) + "[/bold red]"
    else:
        return

    console.log(log_message, markup=True)



docker_files_path_prefix = "common_docker_defs"

# Define which docker files to use
docker_files = ["Dockerfile.header",
                "Dockerfile.define_versions",
                "Dockerfile.install_basic_dependencies",
                "Dockerfile.install_rocm",
                "Dockerfile.fake_rocm_gpu_info",
                "Dockerfile.install_libfabric",
                "Dockerfile.install_rccl",
                "Dockerfile.install_mpich",
                "Dockerfile.install_rccl_tests"]

# Generate the docker fileobject
dockerfile_path = 'additional_docker_files/Dockerfile'
with open('additional_docker_files/Dockerfile', 'w') as outfile:
    for docker_file in docker_files:
        with open(os.path.join(docker_files_path_prefix, docker_file)) as infile:
            for line in infile:
                outfile.write(line)


#Path to dockerfile location
old_dir = os.getcwd()
path = os.path.join(old_dir, 'additional_docker_files')

console = Console()
with console.status("[bold green]Working on tasks...") as status:
    client = docker.from_env()
    try:
        resp = client.api.build(rm=True, quiet=False, tag="lumi_images:test", path=path) #fileobj=f,
        for line in resp:
            line_dict = json.loads(line.decode('utf-8'))
            show_progress(line_dict, console)
    except DockerException as e:
        print(f"An error occurred: {e}")

os.remove(dockerfile_path)