#!/bin/bash -l
#
# Copyright (c) 2022, Nimbix, Inc.
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
echo "======   Begin Open MPI validation   ======"

# dump the environment we see at startup
echo
echo "+++++++++++++++++++++++++++++++ Environment +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
env
echo

# Dump info from the Open MPI commands to show fabric support and version, test out basic mpirun use
echo
echo "++++++++++++++++++++++++++++++++++++++++ Open MPI Info ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
hash $OMPIROOT/bin/ompi_info && $OMPIROOT/bin/ompi_info -V || echo "no ompi_info"

echo "+++++++++++++++++++++++++++++++++++++++++ Open MPI btl list +++++++++++++++++++++++++++++++++++++++++++++++++++++"
hash $OMPIROOT/bin/ompi_info && $OMPIROOT/bin/ompi_info | grep btl || echo "no ompi_info"

echo "+++++++++++++++++++++++++++++++++++++++++++ mpirun with map running hostname command ++++++++++++++++++++++++++++"
hash $OMPIROOT/bin/mpirun && $OMPIROOT/bin/mpirun -mca btl_openib_allow_ib 1 --allow-run-as-root --display-map hostname || echo "no mpirun"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo
echo
echo "Dumping fabric info..."
echo
echo "Checking libfabric location..."
LIBFABRICPATH=$(ldconfig -p |grep libfabric)
if [[ -n $LIBFABRICPATH ]]; then
  echo "INFO: libfabric present as $LIBFABRICPATH"
else
  echo "INFO: no libfabric in library paths"
fi
echo

echo "++++++++++++++++++++++++++++++++++++++  fabric list from fi_info +++++++++++++++++++++++++++++++++++++++++++++++"
hash fi_info && fi_info -l || echo "INFO: no fi_info"
echo "+++++++++++++++++++++++++++++++++++++++ fabric info from UCX +++++++++++++++++++++++++++++++++++++++++++++++++++"
hash ucx_info && ucx_info -d || echo "INFO: no ucx_info"

if [[ -n $HELLO_DIR ]]; then
  echo
  echo
  echo "+++++++++++++++++++++++++++++++++++ Run basic MPI Hello World test ++++++++++++++++++++++++++++++++++++++++++++++"
  # build the mpi-common hello world app, works better if built to local node, using the Open MPI compiler
  if [[ -f $OMPIROOT/bin/mpicc ]]; then
    export MPICC=$OMPIROOT/bin/mpicc
  else
    echo "WARNING: no MPI compiler wrapper (mpicc) available, skipping Hello World test"
    exit 0
  fi

  echo "Building the Hello World MPI Tutorial binary (https://mpitutorial.com/tutorials/mpi-hello-world/)..."
  cd $HELLO_DIR && make

  # Distribute the binary to each node
  while IFS= read -r node;
  do
    if [[ $(hostname) != $node ]] && [[ $node != "JARVICE" ]]; then
      scp $HELLO_DIR/mpi_hello_world $node:$HELLO_DIR/mpi_hello_world
    fi
  done < /etc/JARVICE/nodes

  echo
  echo

  echo "Running the Hello World across all job cores..."
  echo
  $OMPIROOT/bin/mpirun -mca btl_openib_allow_ib 1 -n $NP --hostfile /etc/JARVICE/nodes $HELLO_DIR/mpi_hello_world
fi
