# Reproducible kernel build container for aquaris-E4.5 (krillin)
# Notes:
# - many old MTK toolchains are 32-bit => install i386 compat libs
# - kernel builds often need: bc, bison, flex, openssl, ncurses, etc.

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y --no-install-recommends \
      bash ca-certificates git \
      build-essential make gcc g++ \
      bc bison flex \
      perl python3 python-is-python3 \
      rsync file unzip xz-utils \
      libssl-dev \
      libncurses5-dev libncursesw5-dev \
      ccache \
      # 32-bit compatibility for old prebuilts toolchains
      libc6:i386 libstdc++6:i386 zlib1g:i386 libgcc-s1:i386 \
      libncurses5:i386 libtinfo5:i386 \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user (better for CI and local)
RUN useradd -m builder
USER builder
WORKDIR /work

# Optional: speed up rebuilds
ENV CCACHE_DIR=/work/.ccache
ENV PATH="/usr/lib/ccache:${PATH}"

# Default command (can be overridden)
CMD ["/bin/bash"]
