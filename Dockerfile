FROM centos:7 as build

WORKDIR /tmp

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER
ENV SERIAL_NUMBER ${SERIAL_NUMBER:-20210825.1500}

ARG GIT_BRANCH
ENV GIT_BRANCH ${GIT_BRANCH:-master}

# Install mpi-common to pick up tools
RUN yum -y install file git gcc gcc-c++ make openmpi3 openmpi && \
    curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/mpi-common/$GIT_BRANCH/install-mpi-common.sh \
        | bash

COPY scripts/setup_openmpi.sh /usr/local/bin/
COPY buildscripts/build-osu-benchmarks.sh .
RUN /tmp/build-osu-benchmarks.sh


################# Multistage Build, stage 2 ###################################
FROM centos:7
LABEL maintainer="Nimbix, Inc."

WORKDIR /tmp

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER
ENV SERIAL_NUMBER ${SERIAL_NUMBER:-20210824.1200}

ARG GIT_BRANCH
ENV GIT_BRANCH ${GIT_BRANCH:-master}


COPY --from=build /usr/local/mpi-common /usr/local/mpi-common
COPY --from=build /usr/local/libexec/osu-micro-benchmarks /usr/local/libexec/osu-micro-benchmarks

# Install image-common
RUN yum -y install epel-release git gcc gcc-c++ make openmpi-devel openmpi3-devel && \
    curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/image-common/$GIT_BRANCH/install-nimbix.sh \
        | bash

COPY scripts/* /usr/local/bin/

#COPY NAE/screenshot.png /etc/NAE/screenshot.png

COPY NAE/AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://cloud.nimbix.net/api/jarvice/validate

RUN mkdir -p /etc/NAE && touch /etc/NAE/{screenshot.png,screenshot.txt,license.txt,AppDef.json}