FROM ubuntu:22.04

LABEL maintainer="rdemko2332@gmail.com"

WORKDIR /usr/bin/

# Install all required system packages and Perl dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        git \
        make \
        gcc \
        g++ \
        zlib1g-dev \
        samtools=1.13-4 \
        bedtools=2.30.0+dfsg-2 \
        perl \
        curl \
        cpanminus \
        libexpat1-dev \
        libxml2-dev \
        libxml-libxml-perl \
        libxml-parser-perl \
        libwww-perl \
        libdbi-perl \
        libdbd-sqlite3-perl \
        libtext-csv-perl \
        libfile-slurp-perl \
        libio-stringy-perl \
        liburi-perl \
        libset-scalar-perl \
    && rm -rf /var/lib/apt/lists/*

# Install BioPerl and its root dependency
RUN cpanm --notest Bio::Root::Version && \
    cpanm --notest XML::LibXML && \
    cpanm --notest Bio::Perl

# Build and install srnaMapper and BWA
RUN git clone --recursive https://github.com/mzytnicki/srnaMapper.git \
    && cd srnaMapper \
    && make \
    && cd Libs/bwa \
    && make \
    && cp bwa /usr/local/bin/

# Add srnaMapper binaries to PATH
ENV PATH=$PATH:/usr/bin/srnaMapper

# Add your helper scripts
ADD /bin/* /usr/local/bin/

WORKDIR /work
