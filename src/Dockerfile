FROM mcr.microsoft.com/devcontainers/base:ubuntu
USER vscode
WORKDIR /home/vscode/build
COPY ./build.sh .

RUN bash ./build.sh

WORKDIR /
RUN rm -rf /home/vscode/build
ENV DOTNET_ROOT /home/vscode/.dotnet
ENV PATH $PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools