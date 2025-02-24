#! /bin/sh
export LD_PRELOAD=/opt/cray/pe/mpich/8.1.29/gtl/lib/libmpi_gtl_hsa.so
echo $@
$@