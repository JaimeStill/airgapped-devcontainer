# initialize variables
toolspath="$HOME/.dotnet/tools/"
nodepath="/usr/local/share/nvm/versions/node"
nodeversion=$(ls $nodepath)
nodecache="$nodepath/$nodeversion"

# ensure directories exist
if [ ! -d $toolspath ]; then
    mkdir -p $toolspath;
fi

if [ ! -d $nodecache ]; then
    mkdir -p $nodecache;
fi

# install dotnet tools
sudo tar -xf /cache/dotnet-tools.tar.gz --directory $toolspath

# install global npm packages
sudo tar -xf /cache/node.tar.gz --directory $nodecache