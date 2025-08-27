from mpi4py import MPI

# Initialize MPI
comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

# Define source and destination for pt2pt comm
dest = (rank+1)%size
source = (rank-1)%size

# Define data
data = {'rank': rank, 'rank x answer': 42*rank, 'rank x pi': 3.141592*rank}

# MPI comm
comm.send(data, dest=dest)
data = comm.recv(source=source)

print('On process {}, data is {}'.format(rank, data))
