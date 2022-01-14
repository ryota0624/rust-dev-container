FROM ubuntu:20.04

RUN apt update
RUN apt install -y tzdata
RUN apt install -y curl build-essential git clang cmake libstdc++-10-dev libssl-dev libxxhash-dev zlib1g-dev
RUN curl https://sh.rustup.rs -sSfy | sh
RUN git clone https://github.com/rui314/mold.git
RUN cd mold/ && git checkout v1.0.1 && make -j$(nproc) CXX=clang++make -j$(nproc) CXX=clang++ && make install
ENV SCCACHE_CACHE_SIZE="1G"
ENV export SCCACHE_DIR="/root/.cache/sccache"
ARG SCCACHE_VERSION=0.2.15
RUN LINK=https://github.com/mozilla/sccache/releases/download && \
    SCCACHE_FILE=sccache-v$SCCACHE_VERSION-x86_64-unknown-linux-musl && \
    curl -L "$LINK/v$SCCACHE_VERSION/$SCCACHE_FILE.tar.gz" | tar xz && \
    mv -f $SCCACHE_FILE/sccache /usr/local/bin/sccache && \
    chmod +x /usr/local/bin/sccache

COPY cargo_config.toml /root/.cargo/config.toml

RUN rustup component add clippy
RUN rustup component add rustfmt
RUN rustup component add rust-analysis
RUN rustup component add rust-src
RUN rustup component add rls
RUN cargo install cargo-edit
