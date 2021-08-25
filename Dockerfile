FROM centos:7
LABEL maintainer="Nimbix, Inc."

WORKDIR /tmp

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER
ENV SERIAL_NUMBER ${SERIAL_NUMBER:-20210825.1200}

ARG GIT_BRANCH
ENV GIT_BRANCH ${GIT_BRANCH:-master}

# Install image-common
RUN yum -y install epel-release file git gcc gcc-c++ make openmpi-devel openmpi3-devel && \
    curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/image-common/$GIT_BRANCH/install-nimbix.sh \
        | bash

# Install mpi-common to pick up tools
RUN curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/mpi-common/$GIT_BRANCH/install-mpi-common.sh \
        | bash

COPY buildscripts/build-osu-benchmarks.sh /usr/local/buildscripts/
COPY scripts/* /usr/local/bin/

#COPY NAE/screenshot.png /etc/NAE/screenshot.png

COPY NAE/AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://cloud.nimbix.net/api/jarvice/validate

RUN mkdir -p /etc/NAE && touch /etc/NAE/{screenshot.png,screenshot.txt,license.txt,AppDef.json}