#!/bin/bash -l
#
# Copyright (c) 2021, Nimbix, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are
# those of the authors and should not be interpreted as representing official
# policies, either expressed or implied, of Nimbix, Inc.
#
#set -x

. $(dirname $0)/setenv.sh

echo
echo "=========  Begin Open MPI benchmarking...   ======="
echo

############  parse command line  ###############
HOSTFILE=""
while [[ -n "$1" ]]; do
  case "$1" in
  -bench)
    shift
    BENCHMARK=$1
    ;;
  *)
    echo "Invalid argument: $1" >&2
    exit 1
    ;;
  esac
  shift
done

# Build the benchmarks if not already prese
if [[ ! -f $BENCH_DIR/$BENCHMARK ]]; then
  echo "++++++++++++++++++++++++++++++++ Building benchmarking files locally ++++++++++++++++++++++++++++++++++++++++++++"
  echo
  # Build the benchmark files with the local environ
  /usr/local/buildscripts/build-osu-benchmarks.sh
  echo
fi

# Setup arguments specific to each benchmark
case $BENCHMARK in

  "startup/osu_hello")
    PROCS="-n $NP"
    ;;
  "pt2pt/osu_latency" | "one-sided/osu_get_latency" | "one-sided/osu_get_bw")
    PROCS="-n 2"
    ;;
  *)
    PROCS="-n $NP"
    ;;
esac

# Push the benchmark binary out to each node
if [[ $NN -gt 1 ]]; then
  echo
  echo "++++++++++++++++++++++++++++++++++++ Distributing benchmarks to each node +++++++++++++++++++++++++++++++++++++"
  echo

  while IFS= read -r node;
  do
    if [[ $(hostname) != "$node" ]] ; then
      echo "node: $node"
      ssh -n $node sudo mkdir -p $BENCH_DIR
      ssh -n $node sudo chmod a+w $BENCH_DIR
      scp -r $BENCH_DIR $node:$BENCH_DIR/..
    fi
  done < /etc/JARVICE/nodes
  HOSTFILE="--hostfile /etc/JARVICE/nodes"
fi

# Run the benchmark with the hostfile for all nodes
echo
echo "+++++++++++++ Running selected benchmark: $BENCHMARK on $JARVICE_MPI_PROVIDER +++++++++++++++++++++++++++++++++++"
#--timeout <seconds> mca_base_verbose opal_common_ofi_verbose
$OMPIROOT/bin/mpirun -v --mca mca_base_verbose stdout,level:9 $PROCS $HOSTFILE $BENCH_DIR/$BENCHMARK

# collective
#  osu_allgather
#  osu_allgatherv
#  osu_allreduce
#  osu_alltoall
#  osu_alltoallv
#  osu_barrier
#  osu_bcast
#  osu_gather
#  osu_gatherv
#  osu_iallgather
#  osu_iallgatherv
#  osu_iallreduce
#  osu_ialltoall
#  osu_ialltoallv
#  osu_ialltoallw
#  osu_ibarrier
#  osu_ibcast
#  osu_igather
#  osu_igatherv
#  osu_ireduce
#  osu_iscatter
#  osu_iscatterv
#  osu_reduce
#  osu_reduce_scatter
#  osu_scatter
#  osu_scatterv
# one-sided
#  osu_acc_latency
#  osu_cas_latency
#  osu_fop_latency
#  osu_get_acc_latency
#  osu_get_bw
#  osu_get_latency
#  osu_put_bibw
#  osu_put_bw
#  osu_put_latency
# pt2pt
#  osu_bibw
#  osu_bw
#  osu_latency
#  osu_latency_mp
#  osu_latency_mt
#  osu_mbw_mr
#  osu_multi_lat
# startup
#     osu_hello
#     osu_init
#
#4 directories, 44 files