ARG FROM=docker.io/ubuntu:focal
FROM ${FROM}

RUN export DEBIAN_FRONTEND=noninteractive ;\
  echo 'deb [trusted=yes] https://apt.fury.io/triliodata-4-1/ /' | tee /etc/apt/sources.list.d/fury.list ;\
  apt update && \
  apt install --no-install-recommends -y \
    linux-image-virtual \
    contego \
    workloadmgr \
    python3-nova \
    python3-dmapi \
    python3-s3-fuse-plugin \
    python3-tvault-contego \
    python3-workloadmgrclient \
    python3-contegoclient \
    python3-glanceclient \
    python3-neutronclient \
    python3-apt && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*
