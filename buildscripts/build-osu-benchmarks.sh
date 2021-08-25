#!/usr/bin/env bash

# Find the Open MPI root we'll be using
[[ -r /usr/local/bin/setup_openmpi.sh ]] && source /usr/local/bin/setup_openmpi.sh

# Prepare the install dir
BENCH_DIR=/usr/local/libexec/osu-micro-benchmarks/mpi
sudo mkdir -p $BENCH_DIR
sudo chmod -R a+w $BENCH_DIR

# source added by mpi-common, installed to /usr/local/libexec
cd $MPI_COMMON/osu-benchmarks || exit 1

./configure CC=$OMPIROOT/bin/mpicc CXX=$OMPIROOT/bin/mpicxx
make && make install
