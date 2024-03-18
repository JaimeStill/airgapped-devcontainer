#!/bin/bash

echo "Installing vscode server to $HOME/.vscode-server"
commit="863d2581ecda6849923a2118d93a088b0745d9d6"
sqlextversion="1.22.1"
serverdir="$HOME/.vscode-server/bin/${commit}"
curl -sSL https://update.code.visualstudio.com/commit:${commit}/server-linux-x64/stable -o vscode-server-linux-x64.tar.gz
mkdir -p $serverdir
sudo tar zxvf vscode-server-linux-x64.tar.gz -C $serverdir --strip 1
sudo touch "${serverdir}/0"
sudo rm -f vscode-server-linux-x64.tar.gz

curl -sL https://github.com/microsoft/vscode-mssql/releases/download/v${sqlextversion}/mssql-${sqlextversion}-ubuntu.16.04-x64.vsix -o $HOME/mssql-ubuntu-x64.vsix

extensions=(
    "angular.ng-template"
    "ms-azuretools.vscode-docker"
    "ms-dotnettools.csharp"
    "ms-dotnettools.vscode-dotnet-runtime"
    "ms-vscode.powershell"
    "rangav.vscode-thunder-client"
    "spmeesseman.vscode-taskexplorer"
    "$HOME/mssql-ubuntu-x64.vsix"
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

rm -f $HOME/mssql-ubuntu-x64.vsix
