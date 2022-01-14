FROM ubuntu:20.04

RUN apt update
RUN apt install -y tzdata
RUN apt install -y curl pkg-config build-essential git clang cmake libstdc++-10-dev libssl-dev libxxhash-dev zlib1g-dev
RUN git clone https://github.com/rui314/mold.git
RUN cd mold/ && git checkout v1.0.1 && make -j$(nproc) CXX=clang++make -j$(nproc) CXX=clang++ && make install
ENV SCCACHE_CACHE_SIZE="1G"
ENV SCCACHE_DIR="/root/.cache/sccache"
ARG SCCACHE_VERSION=0.2.15
RUN LINK=https://github.com/mozilla/sccache/releases/download && \
    SCCACHE_FILE=sccache-v$SCCACHE_VERSION-x86_64-unknown-linux-musl && \
    curl -L "$LINK/v$SCCACHE_VERSION/$SCCACHE_FILE.tar.gz" | tar xz && \
    mv -f $SCCACHE_FILE/sccache /usr/local/bin/sccache && \
    chmod +x /usr/local/bin/sccache

ARG RUST_VERSION="1.58.0"
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain ${RUST_VERSION}
COPY .cargo/config.toml /root/.cargo/config.toml
ENV PATH="/root/.cargo/bin:$PATH"

RUN rustup component add clippy
RUN rustup component add rustfmt
RUN rustup component add rust-analysis
RUN rustup component add rust-src
RUN rustup component add rls
ENV RUSTC_WRAPPER=sccache
WORKDIR /root
