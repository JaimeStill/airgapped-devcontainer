FROM mcr.microsoft.com/devcontainers/base:ubuntu
WORKDIR /cache
COPY install-sql.sh install-sql.sh
COPY dotnet-tools.tar.gz dotnet-tools.tar.gz
COPY node.tar.gz node.tar.gz
COPY config.sh config.sh
RUN bash ./install-sql.sh \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts