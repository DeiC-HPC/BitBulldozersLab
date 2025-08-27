import sys
import random
from mpi4py import MPI

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

try:
    assert(size <= 2)
except AssertionError:
    raise ValueError("This example runs with 2 processes; {} used".format(size))

dst = 1
src = 0

min_xp = 0
max_xp = 20

warmup = 10
itermax = 100

buffer = [random.random() for i in range(2**max_xp)]

if rank == 0:
    print("# Msg size\tComm time [s]\tBandwidth [MB/s]")
for xp in range(min_xp, max_xp):
    length = 2**xp
    # warm-up
    for iter in range(warmup):
        if rank == 0:
            comm.send(buffer[0:length], dest=dst)
        elif rank == 1:
            rcv_buffer = comm.recv(source=src)

    # bandwidth measure
    t0 = MPI.Wtime()
    for iter in range(itermax):
        if rank == 0:
            comm.send(buffer[0:length], dest=dst)
        elif rank == 1:
            rcv_buffer = comm.recv(source=src)
    t1 = MPI.Wtime()

    if rank == 0:
        bw = 2*sys.getsizeof(buffer[0:length])/(t1 - t0)/itermax/1e6
        print(f"{length:d}\t\t{(t1-t0)/itermax:f}\t{bw:f}")
