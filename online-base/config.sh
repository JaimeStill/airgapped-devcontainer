#!/bin/bash

# install dotnet tools
dotnet --list-sdks
dotnet tool install -g dotnet-ef

# install global npm packages
npm i -g @angular-devkit/schematics-cli @angular/cli @devcontainers/cli

base=/workspaces/airgapped-devcontainer/airgapped-dev
origin=$(pwd)
nodepath=/usr/local/share/nvm/versions/node
version=$(ls $nodepath)
cd "$nodepath/$version"

if [ -d $base/node.tar.gz ]; then
    rm $base/node.tar.gz;
fi

tar -zcvf $base/node.tar.gz .

cd $HOME/.dotnet/tools

if [ -d $base/dotnet-tools.tar.gz ]; then
    rm $base/dotnet-tools.tar.gz;
fi

tar -zcvf $base/dotnet-tools.tar.gz .
