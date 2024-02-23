FROM mcr.microsoft.com/devcontainers/base:ubuntu
WORKDIR /build
COPY ./build .

RUN bash ./sql.sh
RUN bash ./nvm.sh
RUN bash ./dotnet.sh
RUN bash ./vscode-server.sh

RUN apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

WORKDIR /
RUN rm -rf ./build