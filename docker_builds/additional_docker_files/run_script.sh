#! /bin/sh

export LD_PRELOAD=/opt/cray/pe/lib64/libmpi_gtl_hsa.so
echo $@
$@
