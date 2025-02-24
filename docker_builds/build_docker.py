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

docker_versions_libfabric1152_mpich314 = "Dockerfile.versions_libfabric1152_mpich314"
docker_versions_libfabric1152_mpich343 = "Dockerfile.versions_libfabric1152_mpich343"
docker_versions_libfabric1211_mpich343 = "Dockerfile.versions_libfabric1211_mpich343"
docker_versions_libfabric1220_mpich343 = "Dockerfile.versions_libfabric1220_mpich343"
docker_versions_libfabric1152_mpich422 = "Dockerfile.versions_libfabric1152_mpich422"
docker_versions_libfabric1211_mpich422 = "Dockerfile.versions_libfabric1211_mpich422"
docker_versions_libfabric1220_mpich422 = "Dockerfile.versions_libfabric1220_mpich422"

docker_install_basic_dependencies = "Dockerfile.install_basic_dependencies"
docker_install_additional_dependencies = "Dockerfile.install_additional_dependencies"
docker_install_rocm = "Dockerfile.install_rocm"
docker_fake_rocm_gpu_info = "Dockerfile.fake_rocm_gpu_info"
docker_install_cxi = "Dockerfile.install_cxi"
docker_install_libfabric = "Dockerfile.install_libfabric"
docker_install_libfabric_cxi = "Dockerfile.install_libfabric_cxi"
docker_install_libfabric1152_cxi = "Dockerfile.install_libfabric1152_cxi"

docker_install_aws_ofi_rccl = "Dockerfile.install_aws-ofi-rccl"
docker_install_mpich = "Dockerfile.install_mpich"
docker_install_mpich_ch4ofi = "Dockerfile.install_mpich_ch4ofi"
docker_install_rccl_tests = "Dockerfile.install_rccl_tests"
docker_install_osu = "Dockerfile.install_osu"
docker_remove_libfabric = "Dockerfile.remove_libfabric"
docker_remove_mpich = "Dockerfile.remove_mpich"
docker_run_script = "Dockerfile.run_script"

# For building multiple images
images_to_build = {"base_image_libfabric1152_mpich314" : [], #base, lumi bind mount
                   "base_image_libfabric1152_mpich343" : [], #base, lumi bind mount
                   "base_image_libfabric1211_mpich343" : [], #???
                   "base_image_libfabric1220_mpich343" : [], #???
                   "base_image_libfabric1152_mpich422": [],  #base, libfabric_hybrid ??
                   "base_image_libfabric1211_mpich422": [],  #base, libfabric_hybrid ??
                   "base_image_libfabric1220_mpich422": [],  #base, libfabric_hybrid ??
                   "base_image_libcxi_libfabric1152_mpich422": [], #opensource
                   "base_image_libcxi_libfabric1152_mpich343": [], #opensource
                   "base_image_libcxi_libfabric1211_mpich422": [], #opensource
                   "base_image_libcxi_libfabric1220_mpich422": []} #opensource

base_install = [docker_header,
                docker_define_versions,
                docker_install_basic_dependencies,
                docker_install_rocm,
                docker_fake_rocm_gpu_info]

tail_install = [docker_install_libfabric,
                docker_install_aws_ofi_rccl,
                docker_install_mpich,
                # # docker_install_rccl_tests,
                docker_install_osu,
                docker_run_script]

tail_install_cxi = [docker_install_additional_dependencies,
                    # docker_install_cxi,
                    # docker_install_libfabric_cxi,
                    # docker_install_aws_ofi_rccl,
                    # docker_install_mpich_ch4ofi,
                    # # docker_install_rccl_tests,
                    # docker_install_osu,
                    docker_run_script]

tail_install_cxi_libfabric1152 = [docker_install_additional_dependencies,
                    docker_install_cxi,
                    docker_install_libfabric1152_cxi,
                    docker_install_aws_ofi_rccl,
                    docker_install_mpich_ch4ofi,
                    # docker_install_rccl_tests,
                    docker_install_osu,
                    docker_run_script]

# # BUILDS
# # Works: Full Container; Full Bind Mount, libfabric hybrid
# # Doesnt work: Opensource
# images_to_build["base_image_libfabric1152_mpich314"] = (base_install
#                                                         + [docker_versions_libfabric1152_mpich314]
#                                                         + tail_install)
#
# # BUILDS
# # Works: Full Container; Full Bind Mount
# # Doesnt work: libfabric hybrid; Opensource
# images_to_build["base_image_libfabric1152_mpich343"] = (base_install
#                                                         + [docker_versions_libfabric1152_mpich343]
#                                                         + tail_install)
#
# # BUILDS
# # Works: Full Container; Full Bind Mount
# # Doesnt work: libfabric hybrid; Opensource
# images_to_build["base_image_libfabric1211_mpich343"] = (base_install
#                                                         + [docker_versions_libfabric1211_mpich343]
#                                                         + tail_install)
#
# # BUILDS
# # Works: Full Container; Full Bind Mount
# # Doesnt work: libfabric hybrid; Opensource
# images_to_build["base_image_libfabric1220_mpich343"] = (base_install
#                                                         + [docker_versions_libfabric1220_mpich343]
#                                                         + tail_install)
#
# # BUILDS
# # Works: Full Container; Full Bind Mount; libfabric hybrid
# # Doesnt work: Opensource
# images_to_build["base_image_libfabric1152_mpich422"] = (base_install
#                                                         + [docker_versions_libfabric1152_mpich422]
#                                                         + tail_install)
#
# # BUILDS
# # Works: Full Container; Full Bind Mount
# # Doesnt work: libfabric hybrid; Opensource
# images_to_build["base_image_libfabric1211_mpich422"] = (base_install
#                                                         + [docker_versions_libfabric1211_mpich422]
#                                                         + tail_install)
#
# # BUILDS
# # Works: Full Container; Full Bind Mount
# # Doesnt work: libfabric hybrid; Opensource
# images_to_build["base_image_libfabric1220_mpich422"] = (base_install
#                                                         + [docker_versions_libfabric1220_mpich422]
#                                                         + tail_install)
#
# # ------------------------------------------------------------------
# # ------------------------------------------------------------------
#
# # BUILDS
# # Works:
# # Doesnt work: libfabric hybrid,  Opensource
# images_to_build["base_image_libcxi_libfabric1152_mpich343"] = (base_install
#                                                         + [docker_versions_libfabric1152_mpich343]
#                                                         + tail_install_cxi_libfabric1152)
#
# # BUILDS
# # Works: libfabric hybrid
# # Doesnt work:  Opensource
# images_to_build["base_image_libcxi_libfabric1152_mpich422"] = (base_install
#                                                         + [docker_versions_libfabric1152_mpich422]
#                                                         + tail_install_cxi_libfabric1152)
#
# # BUILDS
# # Works: Opensource
# # Doesnt work: libfabric hybrid
# images_to_build["base_image_libcxi_libfabric1211_mpich422"] = (base_install
#                                                         + [docker_versions_libfabric1211_mpich422]
#                                                         + tail_install_cxi)

# BUILDS
# Works:  Opensource
# Doesnt work: libfabric hybrid
images_to_build["base_image_libcxi_libfabric1220_mpich422"] = (base_install
                                                        + [docker_versions_libfabric1220_mpich422]
                                                        + tail_install_cxi)



# Build all images one go
for current_image_name, current_image_files in images_to_build.items():
    print(current_image_name)
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