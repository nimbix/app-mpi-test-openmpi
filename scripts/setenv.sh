#!/usr/bin/env bash

[[ -r /etc/JARVICE/jobenv.sh ]] && source /etc/JARVICE/jobenv.sh
[[ -r /usr/local/bin/setup_openmpi.sh ]] && source /usr/local/bin/setup_openmpi.sh

# Wait for worker nodes...max of 60 seconds
WORKER_CHECK_TIMEOUT=60
TOOLSDIR="/usr/local/JARVICE/tools/bin"
${TOOLSDIR}/python_ssh_test ${WORKER_CHECK_TIMEOUT}
ERR=$?
if [[ ${ERR} -gt 0 ]]; then
  echo "One or more worker nodes failed to start" 1>&2
  exit ${ERR}
fi

# start SSHd
if [[ -x /usr/sbin/sshd ]]; then
  sudo /usr/sbin/sshd-keygen && sudo /usr/sbin/sshd
fi

# Count the cores available for the job
NP=$(wc -l /etc/JARVICE/cores | awk '{print $1}')
export NP

# Origin for files dropped in via MPI common repo
export MPI_COMMON=/usr/local/mpi-common

echo "+++++++++++++++++++++++++++++++++++++++++++ Identify Fabrics ++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo "Checking for CMA (cross memory attach) to support shared memory transport"
if [[ "$JARVICE_MPI_CMA" == true ]]; then
  echo "INFO: CMA support is enabled, shm fabric is available"
else
  echo "INFO: No CMA support, shm fabric not available"
fi
echo

echo "Checking for JARVICE-detected MPI provider information"
  if [[ -n $JARVICE_MPI_PROVIDER ]]; then
    echo "INFO: MPI fabric provider is:  $JARVICE_MPI_PROVIDER"
  else
    echo "INFO: No MPI fabric detected, libfabric may still be present for autodetection..."
  fi
echo

# Location of the MPI Hello World tutorial files
if [[ -d $MPI_COMMON/mpitutorial/tutorials/mpi-hello-world/code ]]; then
  export HELLO_DIR=$MPI_COMMON/mpitutorial/tutorials/mpi-hello-world/code
fi

# Location of the OSU Micro-benchmark files
if [[ -d /usr/local/libexec/osu-micro-benchmarks/mpi ]]; then
  export BENCH_DIR=/usr/local/libexec/osu-micro-benchmarks/mpi
fi
