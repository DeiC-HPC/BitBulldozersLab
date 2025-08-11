

Osu tests dont run on more than 2 MPI processes. 

# Nr Nodes

- 2,4,8,(16,32),64,(128,256),512
- 5 nodes

# Nr GPUs per Node
- 8
- that way we see inter-node and intra-node communication speed
  - I think intra-node comms increases the bus bandwidth 

# Tests
- all_reduce_perf
- all_gather_perf
- alltoall_perf
- broadcast_perf
- reduce_scatter_perf
- alltoallv_perf
- reduce_perf

--> 7 tests; select some??
--> Bus bandwidth depends on test selected

--> do we want average, min, max across all nodes? 

==> 140 different tests

# Test sizes

Min
- 128

Max
- 512MB

# Env settings to test:
- NCCL_NCHANNELS_PER_PEER=(4,8,16,32)
- HSA_ENABLE_SDMA=0
- HSA_NO_SCRATCH_RECLAIM=1

