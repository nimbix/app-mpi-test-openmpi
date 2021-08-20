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
#set -x

. $(dirname $0)/setenv.sh

echo "Begin Open MPI validation..."

#Standard CentOS install paths, these are not in PATH
DIST_OMPI1=/usr/lib64/openmpi
DIST_OMPI3=/usr/lib64/openmpi3

# dump the environment we see at startup
echo "+++++++++++++++++++++++++++++++ Environment +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
env

echo "+++++++++++++++++++++++++++++++++ Identify Open MPI release +++++++++++++++++++++++++++++++++++++++++++++++++++++"
# Find the Open MPI installation
echo "Dumping Open MPI info..."
if [[ -n $OPENMPI_DIR ]]; then
  echo "Found Open MPI installation via OPENMPI_DIR at: $OPENMPI_DIR"
  OMPIROOT=$OPENMPI_DIR
else
  echo "Looking for default installs of Open MPI in /usr/lib64/openmpi(3)..."
  if [[ -d $DIST_OMPI3 ]]; then
    echo "Found Open MPI 3 from distro RPM at $DIST_OMPI3"
    OMPIROOT=$DIST_OMPI3
  elif [[ -d $DIST_OMPI1 ]]; then
    echo "Found Open MPI 1 from distro RPM at $DIST_OMPI1"
    OMPIROOT=$DIST_OMPI1
  fi
fi

echo "+++++++++++++++++++++++++++++++++Identify libfabric release +++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo "+++++++++++++++++++++++++++++++++++++++++++ Fabrics +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# determine the fabric(s) we can use #TODO: detect jarvice libfabric, toggle path
echo
echo "Dumping fabric info..."
echo "++++++++++++++++++++++++++++++++++++++  fabric list from fi_info +++++++++++++++++++++++++++++++++++++++++++++++"
hash fi_info && fi_info -l || echo "no fi_info"
echo "+++++++++++++++++++++++++++++++++++++++ fabric info from UCX +++++++++++++++++++++++++++++++++++++++++++++++++++"
hash ucx_info && ucx_info -d || echo "no ucx_info"

echo
echo "Dumping Open MPI info..."
echo "++++++++++++++++++++++++++++++++++++++++ Info Open MPI +++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
hash $OMPIROOT/bin/ompi_info && $OMPIROOT/bin/ompi_info -V || echo "no ompi_info"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
hash $OMPIROOT/bin/ompi_info && $OMPIROOT/bin/ompi_info | grep btl || echo "no ompi_info"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
hash $OMPIROOT/bin/mpirun && $OMPIROOT/bin/mpirun --allow-run-as-root --display-map hostname || echo "no mpirun"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
