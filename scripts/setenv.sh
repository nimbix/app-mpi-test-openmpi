#!/usr/bin/env bash

[[ -r /etc/JARVICE/jobenv.sh ]] && source /etc/JARVICE/jobenv.sh

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

#Standard CentOS install paths, these are not in PATH
export DIST_OMPI1=/usr/lib64/openmpi
export DIST_OMPI3=/usr/lib64/openmpi3

export MPI_COMMON=/opt/mpi-common

if [[ -d $MPI_COMMON/helloworld ]]; then
  export RUNHELLO=$MPI_COMMON/helloworld
fi