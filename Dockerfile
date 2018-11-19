FROM debian:stretch

WORKDIR /root

# common packages
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    ca-certificates curl file git docker \
    build-essential \
    autoconf automake autotools-dev libtool xutils-dev && \
    rm -rf /var/lib/apt/lists/*

ENV SSL_VERSION=1.0.2p

RUN curl https://www.openssl.org/source/openssl-$SSL_VERSION.tar.gz -O && \
    tar -xzf openssl-$SSL_VERSION.tar.gz && \
    cd openssl-$SSL_VERSION && ./config && make depend && make install && \
    cd .. && rm -rf openssl-$SSL_VERSION*

ENV OPENSSL_LIB_DIR=/usr/local/ssl/lib \
    OPENSSL_INCLUDE_DIR=/usr/local/ssl/include \
    OPENSSL_STATIC=1

# install toolchain
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain none -y

# install fixed nightly version for now
ENV PATH=/root/.cargo/bin:$PATH
ENV PROJECT_RUST_VERSION=nightly-2018-11-14
RUN rustup toolchain install ${PROJECT_RUST_VERSION}
RUN rustup component add rustfmt-preview --toolchain=${PROJECT_RUST_VERSION}
RUN rustup component add clippy-preview --toolchain=${PROJECT_RUST_VERSION}
RUN echo ${PROJECT_RUST_VERSION} > rust-toolchain
RUN rustup component add rustfmt-preview
RUN cargo install --debug cargo-make
RUN (unset RUSTC_WRAPPER; cargo install sccache)

RUN rustc --version && \
    rustup --version && \
    cargo --version 
