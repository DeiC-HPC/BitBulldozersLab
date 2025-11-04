cmake_minimum_required(VERSION 3.9) # find_package(hip) requires 3.5
cmake_policy(VERSION 3.9...3.27)
project(rccl-comm LANGUAGES CXX)

find_package(hip REQUIRED)
find_package(OpenMP REQUIRED)
find_package(rccl REQUIRED)

add_subdirectory(src)
