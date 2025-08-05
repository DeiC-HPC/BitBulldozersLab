#include <mpi.h>
#include <stdio.h>

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);

    int size, rank;
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    char processor_name[MPI_MAX_PROCESSOR_NAME];
    int name_len;
    MPI_Get_processor_name(processor_name, &name_len);

    char library_version[MPI_MAX_LIBRARY_VERSION_STRING];
    MPI_Get_library_version(library_version, &name_len);

    printf("Hello world from processor %s, rank %d out of %d processors with MPI library %s\n",
           processor_name, rank, size, library_version);

    MPI_Finalize();
}
