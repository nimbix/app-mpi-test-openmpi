#!/usr/bin/env bash

# Find the Open MPI root we'll be using
[[ -r /usr/local/bin/setup_openmpi.sh ]] && source /usr/local/bin/setup_openmpi.sh

env

cd $MPI_COMMON/osu-benchmarks
./configure CC=$OMPIROOT/bin/mpicc CXX=$OMPIROOT/bin/mpicxx
make && make install