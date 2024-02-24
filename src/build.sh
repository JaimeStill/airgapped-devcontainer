#!/bin/bash

echo "Installing .net sdk to $HOME/.dotnet"
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh

export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
rm -f ./dotnet-install.sh

echo "Installing nvm to $HOME/.nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install --lts

echo "Installing global tools"
npm i -g @angular-devkit/schematics-cli @angular/cli @devcontainers/cli

dotnet tool install -g dotnet-ef

echo "Installing vscode server to $HOME/.vscode-server"
commit="903b1e9d8990623e3d7da1df3d33db3e42d80eda"
serverdir="$HOME/.vscode-server/bin/${commit}"
curl -sSL https://update.code.visualstudio.com/commit:${commit}/server-linux-x64/stable -o vscode-server-linux-x64.tar.gz
mkdir -p $serverdir
sudo tar zxvf vscode-server-linux-x64.tar.gz -C $serverdir --strip 1
sudo touch "${serverdir}/0"

curl -sL https://github.com/microsoft/vscode-mssql/releases/download/v1.22.1/mssql-1.22.1-ubuntu.16.04-x64.vsix -o mssql-ubuntu-x64.vsix

extensions=(
    "angular.ng-template"
    "ms-azuretools.vscode-docker"
    "ms-dotnettools.csharp"
    "ms-dotnettools.vscode-dotnet-runtime"
    "ms-vscode.powershell"
    "rangav.vscode-thunder-client"
    "spmeesseman.vscode-taskexplorer"
    "./mssql-ubuntu-x64.vsix"
)

installer=(
    "${serverdir}/bin/code-server"
)

for ext in "${extensions[@]}"
do
    installer+=("--install-extension" "${ext}")
done

installer+=("--accept-server-license-terms")

"${installer[@]}"

rm -f ./mssql-ubuntu-x64.vsix

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

echo "Cleaning up install"
sudo apt-get clean -y
sudo rm -rf /var/lib/apt/lists/* /tmp/library-scripts