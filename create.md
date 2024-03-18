# Creating an Air-Gapped Dev Container

* [**`.devcontainer.json`**](#devcontainerjson)
* [Determining Tool Installation Strategy](#determining-tool-installation-strategy)
* [**`Dockerfile`**](#dockerfile)
* [Build Scripts](#build-scripts)
* [VS Code Server Notes](#vs-code-server-notes)
    * [Extensions](#extensions)

This section will discuss some of the guidelines and caveats that are important to understand if you want to configure and build your own air-gapped Dev Container.

This section will not provide an exhaustive demonstration for how to build Dev Containers in general. The [Visual Studio Code - Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) documentation already does a great job of this, and the [Dev Containers](https://containers.dev/) spec is a great reference.

The first and most important detail you need to establish is what infrastructure you need on your local Dev Container. This can be any of the following tools or artifacts:

* SDKs and CLI tools
* Global tools, packages, and configuration for any of these tools
* VS Code Extensions
* OS installed packages
* OS configuration

If you are developing against a service that can be run in its own Docker container, SQL Server for instance, you should not try to build out those resources in your Dev Container. See [Composing Your Dev Environment](./readme.md#composing-your-dev-environment) for details.

The sections that follow will analyze how Dev Container image is configured and why it is configured that way. This should hopefully provide insight into how you might approach solving the requirements of your own air-gapped Dev Container image.

This repository is split into two primary sections:

* [**`src`**](./src/) - contains the infrastructure necessary for building out the `airgapped-dev` Dev Container image.

* [**`.devcontainer`**](./.devcontainer) - a Dev Container setup using `airgapped-dev` in conjunction with `mssql/server:2022-latest` through Docker compose.

All of the internet-based infrastructure that you need to generate is encapsulated into the `airgapped-dev` image. This allows you to create simple Dev Container configurations that are purely concerned with joining your Dev Container environment with the additional development services you will need to integrate with.

For details about the root **`.devcontainer`** directory, see [Composing Your Dev Environment](./readme.md#composing-your-dev-environment).

## `.devcontainer.json`
[Back to Top](#creating-an-air-gapped-dev-container)

The [**`src/.devcontainer.json`**](./src/.devcontainer.json) file is extremely simple:

```json
{
    "name": "airgapped-dev",
    "build": { "dockerfile": "Dockerfile" },
    "features": {
        "ghcr.io/devcontainers/features/azure-cli:1": {},
        "ghcr.io/devcontainers/features/docker-in-docker:2": {},
        "ghcr.io/devcontainers/features/powershell:1": {}
    }
}
```

It provides:

* the name of the Dev Container image
* the Dockerfile used to build the image
* the [Dev Container features](https://containers.dev/features) installed with the Dev Container.

## Determining Tool Installation Strategy
[Back to Top](#creating-an-air-gapped-dev-container)

The features configured in **`.devcontainer.json`** bring up the first possible solution in providing a tool you need to provide in your Dev Container. The following rules should be used to determine your strategy for installing any tools in your Dev Container:

* Check if a tool you need is already being provided by your base Dev Container image. For instance, the [`base:ubuntu`](https://github.com/devcontainers/images/blob/main/src/base-ubuntu/.devcontainer/devcontainer.json#L14) image already includes `git`, so there is no need to install it again elsewhere.

* If you do not need to use a tool during the Dev Container image build and a Dev Container feature can provide that tool, install it as a feature in **`.devcontainer.json`**.

* If you need to use the tool at any point during image creation, you will need to script the installation of the tool as part of the image build process as shown in the [Build Scripts](#build-scripts) section below.

## `Dockerfile`
[Back to Top](#creating-an-air-gapped-dev-container)

The heart of the Dev Container image build is the [**`src/Dockerfile`**](./src/Dockerfile):

```docker
FROM mcr.microsoft.com/devcontainers/base:ubuntu
USER vscode
WORKDIR /home/vscode/build
COPY ./build .

RUN bash ./dotnet.sh \
    && ./nvm.sh \
    && ./sql.sh \
    && ./vscode-server.sh

WORKDIR /
RUN rm -rf /home/vscode/build
ENV DOTNET_ROOT /home/vscode/.dotnet
ENV PATH $PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
```

The Dockerfile starts by specifying the [base Dev Container image](https://github.com/devcontainers/images/tree/main/src) it will use.

The image build must be run as the user specified by the [`remoteUser`](https://github.com/devcontainers/images/blob/main/src/base-ubuntu/.devcontainer/devcontainer.json#L26) setting configured in the base Dev Container image. In this case, `base:ubuntu` configures a user named **vscode**.

All of the scripts defined in [*src/build*](./src/build/) are executed in a single [`RUN`](https://docs.docker.com/reference/dockerfile/#run) to reduce the number of cache layers created for the `airgapped-dev` image.

## Build Scripts
[Back to Top](#creating-an-air-gapped-dev-container)

The scripts executed in [Dockerfile](./src/Dockerfile#L6) are:

* [**`dotnet.sh`**](./src/build/dotnet.sh) - installs the [.NET SDK](https://learn.microsoft.com/en-us/dotnet/core/install/linux-scripted-manual#scripted-install) and the global [`dotnet-ef` tool](https://learn.microsoft.com/en-us/ef/core/get-started/overview/install#get-the-net-core-cli-tools).

    ```bash
    #!/bin/bash

    echo "Installing .net sdk to $HOME/.dotnet"
    wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
    chmod +x ./dotnet-install.sh
    ./dotnet-install.sh

    export DOTNET_ROOT=$HOME/.dotnet
    export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
    rm -f ./dotnet-install.sh

    dotnet tool install -g dotnet-ef
    ```

* [**`nvm.sh`**](./src/build/nvm.sh) - Installs [`nvm`](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating) (Node Version Manager), installs the LTS version of Node.js, and installs the following global npm packages: `@angular-devkit/schematics-cli`, `@angular/cli`, `@devcontainers/cli`.

    ```bash
    #!/bin/bash

    echo "Installing nvm to $HOME/.nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    nvm install --lts

    npm i -g @angular-devkit/schematics-cli @angular/cli @devcontainers/cli
    ```

* [**`sql.sh`**](./src/build/sql.sh) - Installs the [SQL Server Tools](https://github.com/microsoft/vscode-remote-try-sqlserver/blob/main/.devcontainer/mssql/installSQLtools.sh) for Linux. Note that these are just the tools for interfacing with SQL Server, not SQL Server itself, which you would run in its own container.

    ```bash
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
    ```

* [**`vscode-server.sh`**](./src/build/vscode-server.sh) - Install [VS Code Server](https://code.visualstudio.com/docs/remote/vscode-server) along with the extensions you will need.

    ```bash
    #!/bin/bash

    echo "Installing vscode server to $HOME/.vscode-server"
    commit="863d2581ecda6849923a2118d93a088b0745d9d6"
    serverdir="$HOME/.vscode-server/bin/${commit}"
    curl -sSL https://update.code.visualstudio.com/commit:${commit}/server-linux-x64/stable -o vscode-server-linux-x64.tar.gz
    mkdir -p $serverdir
    sudo tar zxvf vscode-server-linux-x64.tar.gz -C $serverdir --strip 1
    sudo touch "${serverdir}/0"
    sudo rm -f vscode-server-linux-x64.tar.gz

    curl -sL https://github.com/microsoft/vscode-mssql/releases/download/v1.22.1/mssql-1.22.1-ubuntu.16.04-x64.vsix -o $HOME/mssql-ubuntu-x64.vsix

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
    ```

## VS Code Server Notes
[Back to Top](#creating-an-air-gapped-dev-container)

Whenever a Dev Container is opened in Visual Studio Code through the [Dev Containers Extension](https://code.visualstudio.com/docs/remote/remote-overview), VS Code will attempt to install the [VS Code Server](https://code.visualstudio.com/docs/remote/vscode-server) at `/home/[remoteUser]/.vscode-server` where [`remoteUser`](https://containers.dev/implementors/json_reference/#general-properties) refers to the user configured in the base Dev Container image (**vscode** in this case).

If the proper **`$HOME/.vscode-server`** version is already configured on the Dev Container image, it will skip the installation and use the cached configuration.

The proper version is determined by matching the commit ID of the local Visual Studio Code installation with the commit ID directory located on the Dev Container image at **`$HOME/.vscode-server/bin/[commit-id]`**. This can be found by running the following in PowerShell:

```pwsh
(code --version)[1]
```

The matching VS Code Server version can be downloaded at: https://update.code.visualstudio.com/commit:[commit-id]/server-linux-x64/stable, where `commit-id` is the value returned by `code --version`.

### Extensions
[Back to Top](#creating-an-air-gapped-dev-container)