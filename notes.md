# Notes

## Docs Updates

Capturing scratchpad notes with the intent of doing a better write up of the entire process, including air gapping and updating images.

### VS Code Server Caching

https://update.code.visualstudio.com/commit:[COMMIT_ID]/server-linux-x64/stable

COMMIT_ID should align with the version of VS Code being used in the air gapped environment. If it differs, bring in an updated version of VS Code. You can programmatically obtain the version of VS Code  with the following PowerShell command:

```pwsh
$commit - (code --version)[1]
```

See [vscode-server](./src/build/vscode-server.sh).

### GZip Docker Image

Initial builds of the image are in the range of ~4.5 GB. To minimize the size of the image prior to transfer, you can gzip the image tarball as follows:

```bash
# save the image
docker save [image]:[tag] -o [image]-[tag].tar

# gzip the image tarball
tar -czvf [path].tar.gz [path].tar
```

After transfer, the image can be extracted with:

```bash
tar -xvf [path].tar.gz
```

### NuGet Cache Volume for Docker Compose

The following volume mount configuration will mount `C:\nuget` to  `/nuget` in the dev container.

```yml
services:
  app:
    volumes:
      - C:/nuget:/nuget
```

In the dev container Dockerfile:

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

### Container API Configuration

The following configuration settings are necessary to setup the `Container` environment and isolate it from other environments in an ASP.NET Core Web API Project.

**Launch Profile** in *Properties/launchSettings.json*

```json
"profiles": {
    "development": {
        "commandName": "Project",
        "dotnetRunMessages": true,
        "launchBrowser": true,
        "launchUrl": "swagger",
        "applicationUrl": "http://localhost:5000",
        "environmentVariables": {
            "ASPNETCORE_ENVIRONMENT": "Development"
        }
    },
    "container": {
        "commandName": "Project",
        "dotnetRunMessages": true,
        "launchBrowser": true,
        "launchUrl": "swagger",
        "applicationUrl": "http://localhost:5000",
        "environmentVariables": {
            "ASPNETCORE_ENVIRONMENT": "Container"
        }
    }
}
```

To connect to the container instance of SQL Server, **appsettings.Container.json**:

```json
{
    "ConnectionStrings": {
        "App": "Server=localhost,1433;Encrypt=Mandatory;TrustServerCertificate=True;User=sa;Password=P@ssw0rd;Database=sample-app"
    }    
}
```

When running the API, use the following:

```pwsh
dotnet run --launch-profile container
```

Should be able to alias to a VS Code task.

## Workspace Folder

If working with a directory hierarchy that contains more than one dev container and you want the workspace folder to be the root directory, either specify `workspaceMount` and `workspaceFolder` in *devcontainer.json*, or initiate git tracking at the root of the directory. See [workspaceFolder and workspaceMount](https://containers.dev/implementors/spec/#workspace-folder) and [Dev Container metadata reference - image or dockerfile specific properties](https://containers.dev/implementors/json_reference/#image-specific).

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