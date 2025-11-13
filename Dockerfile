FROM ubuntu:22.04

LABEL maintainer="rdemko2332@gmail.com"

WORKDIR /usr/bin/

RUN apt-get update && \
    apt-get install -y \
        git \
        make \
        gcc \
        g++ \
        zlib1g-dev \
        samtools=1.13-4 \
        bedtools=2.30.0+dfsg-2 \	
    && rm -rf /var/lib/apt/lists/*

RUN git clone --recursive https://github.com/mzytnicki/srnaMapper.git \
    && cd srnaMapper \
    && make \
    && cd Libs/bwa \
    && make \
    && cp bwa /usr/local/bin/

ENV PATH=$PATH:/usr/bin/srnaMapper

WORKDIR /work