FROM ubuntu:18.04

MAINTAINER junderw

WORKDIR /root

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
      software-properties-common \
      git \
      curl \
      wget \
      python \
      build-essential \
      libzmq3-dev \
      libsnappy-dev

# Install Bitcoin
RUN add-apt-repository -y ppa:bitcoin/bitcoin && \
    apt-get install -y bitcoind

# Install nvm and node
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" && \
    nvm install v10

# Install LevelDB
RUN export VER="1.20" && \
    wget https://github.com/google/leveldb/archive/v${VER}.tar.gz && \
    tar xvf v${VER}.tar.gz && \
    rm -f v${VER}.tar.gz && \
    cd leveldb-${VER} && \
    make && \
    scp -r out-static/lib* out-shared/lib* "/usr/local/lib" && \
    cd include && \
    scp -r leveldb /usr/local/include && \
    ldconfig && \
    cd ../.. && \
    rm -rf leveldb-${VER}/

# Clone and install regtest server
RUN git clone https://github.com/bitcoinjs/regtest-server.git && \
    cd regtest-server/ && \
    git checkout bd1a99d59cfa077699fe9d8b84036d9350cce02a && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" && \
    npm i && \
    echo "satoshi" > ../KEYS

COPY start.sh /root/

ENTRYPOINT /root/start.sh
