#!/usr/bin/env bash
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

# Find the Open MPI root we'll be using
[[ -r /usr/local/bin/setup_openmpi.sh ]] && source /usr/local/bin/setup_openmpi.sh

echo
echo "+++++++++++++++++++++++++++++ Setting up benchmarks build area ++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
# Prepare the install dir
BENCH_DIR=/usr/local/libexec/osu-micro-benchmarks/mpi
sudo mkdir -p $BENCH_DIR
sudo chmod -R a+w $BENCH_DIR

# source added by mpi-common, installed to /usr/local/libexec
cd $MPI_COMMON/osu-benchmarks || exit 1

echo
echo "++++++++++++++++++++++++++++ Compiling the benchmarks and installing  ++++++++++++++++++++++++++++++++++++++++++"
echo
./configure CC=$OMPIROOT/bin/mpicc CXX=$OMPIROOT/bin/mpicxx
make -j && make install
