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

base_path = "../Docker build pipeline for 4 different container approaches on LUMI/common_docker_defs/"

# Define which docker files to use
docker_header = base_path + "Dockerfile.header"
docker_define_versions = base_path + "Dockerfile.define_versions"

docker_versions_libfabric2000_mpich423 = base_path + "Dockerfile.versions_libfabric2000_mpich423"
# docker_versions_libfabric2200_mpich423 = base_path + "Dockerfile.versions_libfabric2200_mpich423"

docker_install_basic_dependencies = base_path + "Dockerfile.install_basic_dependencies"
docker_install_additional_dependencies = base_path + "Dockerfile.install_additional_dependencies"
docker_install_rocm = base_path + "Dockerfile.install_rocm"
docker_fake_rocm_gpu_info = base_path + "Dockerfile.fake_rocm_gpu_info"

docker_install_cxi = base_path + "Dockerfile.install_cxi"
docker_install_libfabric_cxi = base_path +  "Dockerfile.install_libfabric_cxi"
docker_install_aws_ofi_rccl = base_path +  "Dockerfile.install_aws-ofi-rccl"
docker_install_mpich_ch4ofi = base_path +  "Dockerfile.install_mpich_ch4ofi"
docker_install_rccl_tests =  "dockerfiles/Dockerfile.rccl_tests"

# For building multiple images
images_to_build = {"base_image_libcxi_libfabric2000_mpich423": [], #opensource
                   "base_image_libcxi_libfabric2200_mpich423": []} #opensource

base_install = [docker_header,
                docker_define_versions,
                docker_install_basic_dependencies,
                docker_install_rocm,
                docker_fake_rocm_gpu_info]


tail_install_cxi = [docker_install_additional_dependencies,
                    docker_install_cxi,
                    docker_install_libfabric_cxi,
                    docker_install_aws_ofi_rccl,
                    docker_install_mpich_ch4ofi,
                    docker_install_rccl_tests,
                    ]


# # Recommended: Opensource
# Works: Opensource
# Doesnt work: libfabric hybrid, Full Bind Mount
images_to_build["base_image_libcxi_libfabric2000_mpich423"] = (base_install
                                                        + [docker_versions_libfabric2000_mpich423]
                                                        + tail_install_cxi)

# ------------------------------------------------------------------------------------------
# defaults to build
# ------------------------------------------------------------------------------------------

# images_to_build["base_image_libcxi_libfabric1220_mpich423"] = (base_install
#                                                         + [docker_versions_libfabric2200_mpich423]
#                                                         + tail_install_cxi)



# Build all images one go
for current_image_name, current_image_files in images_to_build.items():
    print(current_image_name)
    # Generate the docker fileobject
    dockerfile_path = 'additional_docker_files/Dockerfile'
    with open(dockerfile_path, 'w') as outfile:
        for docker_file in current_image_files:
            with open(docker_file) as infile:
                for line in infile:
                    outfile.write(line)


    #Path to dockerfile location
    old_dir = os.getcwd()
    path = os.path.join(old_dir, 'additional_docker_files')

    console = Console()
    with console.status("[bold green]Working on tasks...") as status:
        client = docker.from_env()
        try:
            resp = client.api.build(rm=True, quiet=False, tag="rccl_tests:" + current_image_name,
                                    path=path)  # fileobj=f, , nocache=True
            for line in resp:
                line_dict = json.loads(line.decode('utf-8'))
                show_progress(line_dict, console)
        except DockerException as e:
            print(f"An error occurred: {e}")

    os.remove(dockerfile_path)
