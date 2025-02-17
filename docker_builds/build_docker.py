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
docker_header = "Dockerfile.header"
docker_define_versions = "Dockerfile.define_versions"
docker_install_basic_dependencies = "Dockerfile.install_basic_dependencies"
docker_install_additional_dependencies = "Dockerfile.install_additional_dependencies"
docker_install_rocm = "Dockerfile.install_rocm"
docker_fake_rocm_gpu_info = "Dockerfile.fake_rocm_gpu_info"
docker_install_cxi = "Dockerfile.install_cxi"
docker_install_libfabric = "Dockerfile.install_libfabric"
docker_install_libfabric_cxi = "Dockerfile.install_libfabric_cxi"
docker_install_aws_ofi_rccl = "Dockerfile.install_aws-ofi-rccl"
docker_install_mpich = "Dockerfile.install_mpich"
docker_install_mpich_ch4ofi = "Dockerfile.install_mpich_ch4ofi"
docker_install_rccl_tests = "Dockerfile.install_rccl_tests"
docker_install_osu = "Dockerfile.install_osu"
docker_remove_libfabric = "Dockerfile.remove_libfabric"
docker_remove_mpich = "Dockerfile.remove_mpich"
docker_run_script = "Dockerfile.run_script"

# For building multiple images
# images_to_build = {"base_image_mpich314_libfabric" : []}
# images_to_build = {"base_image_mpich314_libfabric" : [], "base_image_mpich343_libfabric_cxi": []}
images_to_build = {"base_image_mpich343_libfabric_cxi_opendsource": []}

# Base image with all libraries and tests. Not removing libfabric or mpich
# images_to_build["base_image_mpich314_libfabric"] += [docker_header,
#                                         docker_define_versions,
#                                         docker_install_basic_dependencies,
#                                         docker_install_rocm,
#                                         docker_fake_rocm_gpu_info,
#                                         docker_install_libfabric,
#                                         docker_install_aws_ofi_rccl,
#                                         docker_install_mpich,
#                                         docker_install_rccl_tests,
#                                         docker_install_osu,
#                                         docker_run_script,
                                        # docker_remove_libfabric,
                                        # docker_remove_mpich
                                        # ]

# images_to_build["base_image_mpich343_libfabric"] += [docker_header,
#                                         docker_define_versions,
#                                         docker_install_basic_dependencies,
#                                         docker_install_rocm,
#                                         docker_fake_rocm_gpu_info,
#                                         docker_install_libfabric,
#                                         docker_install_aws_ofi_rccl,
#                                         docker_install_mpich_ch4ofi,
#                                         docker_install_rccl_tests,
#                                         docker_install_osu,
#                                         docker_run_script,
# #                                         # docker_remove_libfabric,
# #                                         # docker_remove_mpich
#                                         ]

# dont have cxi atm
images_to_build["base_image_mpich343_libfabric_cxi_opendsource"] += [docker_header,
                                        docker_define_versions,
                                        docker_install_basic_dependencies,
                                        docker_install_additional_dependencies,
                                        docker_install_rocm,
                                        docker_fake_rocm_gpu_info,
                                        docker_install_cxi,
                                        docker_install_libfabric_cxi,
                                        docker_install_aws_ofi_rccl,
                                        docker_install_mpich_ch4ofi,
                                        docker_install_rccl_tests,
                                        docker_install_osu,
                                        # docker_run_script,
#                                         # docker_remove_libfabric,
#                                         # docker_remove_mpich
                                        ]


# Build all images one go
for current_image_name, current_image_files in images_to_build.items():
    # Generate the docker fileobject
    dockerfile_path = 'additional_docker_files/Dockerfile'
    with open('additional_docker_files/Dockerfile', 'w') as outfile:
        for docker_file in current_image_files:
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
            resp = client.api.build(rm=True, quiet=False, tag="lumi_images:" + current_image_name, path=path) #fileobj=f, , nocache=True
            for line in resp:
                line_dict = json.loads(line.decode('utf-8'))
                show_progress(line_dict, console)
        except DockerException as e:
            print(f"An error occurred: {e}")

    os.remove(dockerfile_path)