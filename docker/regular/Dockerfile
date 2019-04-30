# Build Constellation and go in a stock Ubuntu builder container
FROM ubuntu:16.04 as builder

RUN apt-get update && \
    apt-get install -y \
            build-essential \
            git \
            libdb-dev \
            libsodium-dev \
            libtinfo-dev \
            sysvbanner \
            unzip \
            wget \
            wrk \
            zlib1g-dev

WORKDIR /work

ENV CONSTELLATIONREL constellation-0.3.2-ubuntu1604

RUN wget -q https://github.com/jpmorganchase/constellation/releases/download/v0.3.2/$CONSTELLATIONREL.tar.xz && \
    unxz $CONSTELLATIONREL.tar.xz && \
    tar -xf $CONSTELLATIONREL.tar.xz && \
    cp $CONSTELLATIONREL/constellation-node /usr/local/bin && \
    chmod 0755 /usr/local/bin/constellation-node && \
    cp $CONSTELLATIONREL/constellation-enclave-keygen /usr/local/bin/ && \
    chmod 0755 /usr/local/bin/constellation-enclave-keygen && \
    rm -rf $CONSTELLATIONREL.zip $CONSTELLATIONREL

ENV GOREL go1.9.5.linux-amd64.tar.gz
ENV PATH $PATH:/usr/local/go/bin

RUN wget -q https://storage.googleapis.com/golang/$GOREL && \
    tar xfz $GOREL && \
    mv go /usr/local/go && \
    rm -f $GOREL

RUN git clone https://github.com/jpmorganchase/quorum.git && \
    cd quorum && \
    git checkout 99a83767ccf0384a3b58d9caffafabb5b49bd73c && \
    make all && \
    cp build/bin/geth /usr/local/bin && \
    cp build/bin/bootnode /usr/local/bin && \
    cd .. && \
    rm -rf quorum

### Create the regular node image

FROM ubuntu:16.04

# Install add-apt-repository
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common build-essential netbase && \
    add-apt-repository ppa:ethereum/ethereum && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        libdb-dev \
        libsodium-dev \
        libtinfo-dev \
        solc && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder \
        /usr/local/bin/constellation-node \
        /usr/local/bin/constellation-enclave-keygen \
        /usr/local/bin/geth \
        /usr/local/bin/bootnode \
    /usr/local/bin/

EXPOSE 9000 21000 22000 30303 30303/udp

CMD ["/lacchain/start-node.sh"]
