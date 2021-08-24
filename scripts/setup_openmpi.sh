#!/usr/bin/env bash

# Origin for files dropped in via MPI common repo
export MPI_COMMON=/usr/local/mpi-common

#Standard CentOS install paths, these are not in PATH
export DIST_OMPI1=/usr/lib64/openmpi
export DIST_OMPI3=/usr/lib64/openmpi3

echo "+++++++++++++++++++++++++++++++++ Identify Open MPI release +++++++++++++++++++++++++++++++++++++++++++++++++++++"
# Find the Open MPI installation
echo "Dumping Open MPI info..."
if [[ -n $OPENMPI_DIR ]]; then
  echo "INFO: Found Open MPI installation via OPENMPI_DIR at: $OPENMPI_DIR"
  export OMPIROOT=$OPENMPI_DIR
else
  echo "Looking for default installs of Open MPI in /usr/lib64/openmpi(3)..."
  if [[ -d $DIST_OMPI3 ]]; then
    echo "INFO: Found Open MPI 3 from distro RPM at $DIST_OMPI3"
    export OMPIROOT=$DIST_OMPI3
  elif [[ -d $DIST_OMPI1 ]]; then
    echo "INFO: Found Open MPI 1 from distro RPM at $DIST_OMPI1"
    export OMPIROOT=$DIST_OMPI1
  else
    echo "ERROR: No known Open MPI distribution was found, exiting..."
    exit 1
  fi
fi
