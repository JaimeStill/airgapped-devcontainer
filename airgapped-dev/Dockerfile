FROM mcr.microsoft.com/devcontainers/base:ubuntu
WORKDIR /cache
COPY ./cache .

RUN bash ./install-sql.sh \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

RUN bash ./config.sh

WORKDIR /
RUN rm -rf ./cache