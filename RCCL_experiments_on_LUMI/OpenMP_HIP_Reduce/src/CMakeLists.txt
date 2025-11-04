add_executable(rccl-hip rccl-hip-comm.cpp)
target_link_libraries(rccl-hip PRIVATE hip::host rccl)
if(OpenMP_CXX_FOUND)
  target_link_libraries(rccl-hip PUBLIC OpenMP::OpenMP_CXX)
endif()

set_target_properties(rccl-hip PROPERTIES
		      ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
		      LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
		      RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")


add_executable(rccl-openmp rccl-openmp.cpp)
target_link_libraries(rccl-openmp PRIVATE hip::host rccl)
if(OpenMP_CXX_FOUND)
  target_link_libraries(rccl-openmp PUBLIC OpenMP::OpenMP_CXX)
endif()

set_target_properties(rccl-openmp PROPERTIES
		      ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
		      LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
		      RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
