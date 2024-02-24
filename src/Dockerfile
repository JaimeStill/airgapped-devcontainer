FROM mcr.microsoft.com/devcontainers/base:ubuntu
USER vscode
WORKDIR /home/vscode/build
COPY ./build.sh .

RUN bash ./build.sh

WORKDIR /
RUN rm -rf /home/vscode/build