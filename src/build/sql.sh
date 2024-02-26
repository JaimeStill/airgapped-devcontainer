#!/bin/bash

echo "Installing mssql-tools"
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | (OUT=$(sudo apt-key add - 2>&1) || echo $OUT)
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-${DISTRO}-${CODENAME}-prod ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/microsoft.list > /dev/null
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get -y install unixodbc-dev msodbcsql17 libunwind8 mssql-tools

echo "Installing sqlpackage"
curl -sSL -o sqlpackage.zip "https://aka.ms/sqlpackage-linux"
sudo mkdir /opt/sqlpackage
sudo unzip sqlpackage.zip -d /opt/sqlpackage 
sudo rm sqlpackage.zip
sudo chmod a+x /opt/sqlpackage/sqlpackage

sudo apt-get clean -y
sudo rm -rf /var/lib/apt/lists/* /tmp/library-scripts