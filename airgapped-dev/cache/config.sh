# install cached vs code server
echo "Restoring vs code server..."
sudo tar -xf /cache/vscode-server.tar.gz --directory /

# install nvm and configure node + npm
echo "Installing and configuring nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install --lts
npm i -g @angular-devkit/schematics-cli @angular/cli @devcontainers/cli

echo "Downloading and configuring .NET SDK..."
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh

export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
rm -f ./dotnet-install.sh

dotnet tool install -g dotnet-ef