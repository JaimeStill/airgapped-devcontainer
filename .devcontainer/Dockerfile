FROM mcr.microsoft.com/devcontainers/base:ubuntu

COPY install-sql.sh install-sql.sh
RUN bash ./install-sql.sh \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts