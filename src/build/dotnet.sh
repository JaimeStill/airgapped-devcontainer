#!/bin/bash

echo "Installing .net sdk to $HOME/.dotnet"
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh

export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
rm -f ./dotnet-install.sh

dotnet tool install -g dotnet-ef