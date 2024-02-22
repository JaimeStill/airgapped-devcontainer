#!/bin/bash
origin=$(pwd)
base=/workspaces/airgapped-devcontainer/airgapped-dev/cache
serverpath=~/.vscode-server

echo "Downloading mssql-ubuntu-x64 code extension..."
curl -sL https://github.com/microsoft/vscode-mssql/releases/download/v1.22.1/mssql-1.22.1-ubuntu.16.04-x64.vsix -o mssql-ubuntu-x64.vsix
echo "Installing mssql-ubuntu-x64..."
code --install-extension ./mssql-ubuntu-x64.vsix
rm -f ./mssql-ubuntu-x64.vsix

cd /

if [ -d $base/vscode-server.tar.gz ]; then
    rm $base/vscode-server.tar.gz;
fi

sudo tar --exclude='./data/logs' \
    --exclude='./data/CachedProfilesData' \
    -zcvf \
    $base/vscode-server.tar.gz $serverpath

cd $origin