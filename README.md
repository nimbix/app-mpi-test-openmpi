# app-mpi-test-openmpi

_JARVICE app for testing [Open MPI](https://www.open-mpi.org/) distributions and associated fabrics_

The JARVICE platform will provide the Open MPI binaries and libraries (currently 4.1.1) to apps along with a [libfabric
framework](https://ofiwg.github.io/libfabric/), _ldconfig_'d into the environment.

Run this app on a JARVICE installation to demonstrate basic operating MPI and the environment with the Validation endpoint
and then choose one of the OSU benchmarks to performance with a given infrastructure and fabric/provider allocated to a
chosen machine type.

Both endpoints will quickly build the source on the fly prior to running the tests, distributing the binaries to each
MPI host for the job.

## Validation endpoint

The Validation script uses the well known MPI tutorial site Hello World source:[](https://)
https://mpitutorial.com/tutorials/mpi-hello-world/

It simply runs useful Open MPI and fabric-related commands, dumping output. At the end it will run the Hello World app
on all cores.

## Benchmark endpoint

Benchmarks are run using the OSU Micro-benchmarks:
https://mvapich.cse.ohio-state.edu/benchmarks/

The following representative group of benchmarks are available to run in the endpoint:

* Startup: osu_hello
* Point to Point: osu_latency
* One-sided: osu_get_latency
* One-sided: osu_get_bw
* Collective: osu_allgather
* Collective: osu_allreduce
* Collective non-blocking: osu_iallgather
* Collective non-blocking: osu_iallreduce

Current version is 5.7.1, provided by https://github.com/nimbix/mpi-common.git
