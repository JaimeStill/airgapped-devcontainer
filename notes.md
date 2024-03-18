# Notes

## Docs Updates

Capturing scratchpad notes with the intent of doing a better write up of the entire process, including air gapping and updating images.

### NuGet Cache Volume for Docker Compose

The following volume mount configuration will mount `C:\nuget` to  `/nuget` in the Dev Container.

```yml
services:
  app:
    volumes:
      - C:/nuget:/nuget
```

In the Dev Container Dockerfile:

```docker
FROM airgapped-dev:latest
RUN dotnet nuget add source /nuget -n local
RUN dotnet nuget remove source nuget.org
```

### Update Database After Container Creation

In *devcontainer.json*

```json
"postCreateCommand": "pwsh ${containerWorkspaceFolder}/.devcontainer/config.ps1"
```

*config.ps1*:

```pwsh
$origin = $pwd

try {
    Set-Location [path-to-dbcontext-project]
    dotnet ef database update
} finally {
    Set-Location $origin
}
```

## Workspace Folder

If working with a directory hierarchy that contains more than one Dev Container and you want the workspace folder to be the root directory, either specify `workspaceMount` and `workspaceFolder` in *devcontainer.json*, or initiate git tracking at the root of the directory. See [workspaceFolder and workspaceMount](https://containers.dev/implementors/spec/#workspace-folder) and [Dev Container metadata reference - image or dockerfile specific properties](https://containers.dev/implementors/json_reference/#image-specific).

## View Linux Environment Variables

```bash
(set -o posix ; set)
```

## Install Extension from VSIX

Given an extension located at [`extensions/mssql-1.22.1-ubuntu-x64.vsix`](https://github.com/microsoft/vscode-mssql?tab=readme-ov-file#offline-installation):

```json
"extensions": [
    "${containerWorkspaceFolder}/extensions/mssql-1.22.1-ubuntu-x64.vsix"
]
```

## Use devcontainer CLI to Build Dev Container Image

```pwsh
devcontainer build --workspace-folder [path-to-workspace] --image-name [image-name]:[tag]

devcontainer build --workspace-folder ./airgapped-dev --image-name airgapped-dev:latest
```

### Download VSIX with CLI

**PowerShell**  

```pwsh
Invoke-RestMethod -Uri [Package-Uri] -OutFile [File]

# example
Invoke-RestMethod `
    -Uri https://github.com/microsoft/vscode-mssql/releases/download/v1.22.1/mssql-1.22.1-ubuntu.16.04-x64.vsix `
    -OutFile mssql-1.22.1-ubuntu-x64.vsix
```

**Bash**  

```bash
curl -sL [package-uri] -o [file]

# example
curl -sL https://github.com/microsoft/vscode-mssql/releases/download/v1.22.1/mssql-1.22.1-ubuntu.16.04-x64.vsix -o mssql-ubuntu-x64.vsix
```

## GZip Cached Resources

Run from within the [online-base](./online-base/) container.

**Global NPM Packages**  

```bash
# change to global package cache
cd /usr/local/share/nvm/versions/node/[version]/

# extract to cached-base
tar -zcvf /workspaces/airgapped-devcontainer/airgapped-dev/node.tar.gz .
```

**dotnet tools**

```bash
# change to dotnet tools install location
cd $HOME/.dotnet/tools

# extract to cached-base
tar -zcvf /workspaces/airgapped-devcontainer/airgapped-dev/dotnet-tools.tar.gz .
```

## Extract GZipped Cached Resources

**Global NPM Packages**

```bash
sudo tar -xf /cache/node.tar.gz --directory /usr/local/share/nvm/versions/node/[version]
```

**dotnet tools**

```bash
sudo tar -xf /cache/dotnet-tools.tar.gz --directory $HOME/.dotnet/tools
```

## Open By URL in VS Code

```pwsh
vscode://ms-vscode-remote.remote-containers/cloneInVolume?url={url}

# example
vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/microsoft/vscode-remote-try-node
```

## Create an Image from a Container

```pwsh
docker commit [container-name] [image-name]:[tag]

docker commit learning-devcontainers_devcontainer-app-1 airgapped-dev:latest
```

## Cache a Docker Image

```pwsh
docker save [image-name]:[image-tag] -o [output-path]
```

## Docker Artifact Cleanup Management Commands

In lieu of not having a `devcontainer down` or `devcontainer stop` commands, could potentially script the entire build if [assigning a container name](https://github.com/microsoft/vscode-remote-release/issues/2485#issuecomment-1156342780) works.

Cleanup commands:

```pwsh
docker stop [container-name]
docker rm [container-name]

docker volume prune

docker rmi [image-name]
```