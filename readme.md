# Air-Gapped Dev Container

* [Steps](#steps)
* [Update Dependencies](#update-dependencies)
* [Composing Your Dev Environment](#composing-your-dev-environment)
* [Helpful Links](#helpful-links)

This repo is setup to build a Dev Container that can be transferred for use on an air-gapped network.

For a comprehensive discussion on creating your own air-gapped Dev Container image, refer to the [**Creating an Air-Gapped Dev Container**](./create.md) document.

## Steps
[Back to Top](#air-gapped-dev-container)

The following steps assume you are running [Docker](https://www.docker.com/products/docker-desktop/) and have installed the [devcontainers CLI](https://github.com/devcontainers/cli?tab=readme-ov-file#context).

1. [Pre-build](https://containers.dev/guide/prebuild) the `airgapped-dev` Dev Container by running:

    ```pwsh
    devcontainer build --workspace-folder .\src\ --image-name airgapped-dev:latest
    ```

    ![devcontainer-build](https://github.com/JaimeStill/airgapped-devcontainer/assets/14102723/a2d7d0c4-2bf6-40ae-aad3-3751a423c013)

2. Make sure you have pulled the `mssql/server:2022-latest` image for use after disconnecting the network adapter:

    ```pwsh
    docker pull mcr.microsoft.com/mssql/server:2022-latest
    ```

3. Open an administrative PowerShell terminal and run the [Disable-AllAdapters](./scripts/Disable-AllAdapters.ps1) script.

4. Press <kbd>F1</kbd> to open the command palette and select **Dev Containers: Reopen in Container**.

    * You can install the [`mssql`](https://github.com/microsoft/vscode-mssql) extension after the container is built by running the following:

        ```bash
        code --install-extension $HOME/mssql-ubuntu-x64.vsix
        ```

5. To cache the image for offline use, run:

    ```bash
    # save the image
    docker save [image]:[tag] -o [image]-[tag].tar

    # gzip the image tarball
    tar -czvf [image]-[tag].tar.gz [image]-[tag].tar

    # example
    docker save airgapped-dev:latest -o airgapped-dev-latest.tar
    tar -czvf airgapped-dev-latest.tar.gz airgapped-dev-latest.tar
    ```

    Initial builds of the image are in the range of ~4.5 GB. GZipping the image tarball will minimize the file size down to ~1.5 GB prior to transfer to the air-gapped environment.

    After transfer, the image can be extracted with:

    ```bash
    tar -xvf [image]-[tag].tar.gz
    ```

6. Download the version of Visual Studio Code that corresponds to the commit in [**`vscode-server.sh`**](./src/build/vscode-server.sh#L4). 

    You can download by commit by using the following endpoint:

    ```
    https://code.visualstudio.com/sha/download?os=[os-preference]&commit=[commit]
    ```

    * **Windows x64 System Installer**: https://code.visualstudio.com/sha/download?os=win32-x64&commit=863d2581ecda6849923a2118d93a088b0745d9d6
    * **Windows x64 User Installer**: https://code.visualstudio.com/sha/download?os=win32-x64&commit=863d2581ecda6849923a2118d93a088b0745d9d6

    To simplify this process, ensure the image is [updated](#update-dependencies) with the latest version of [VS Code Server](./create.md#vs-code-server-notes).

## Update Dependencies
[Back to Top](#air-gapped-dev-container)

The [script](./src/build/vscode-server.sh) that generates the [VS Code Server](./create#vs-code-server-notes) infrastructure on the Dev Container image relies on:

* The commit string for the release of VS Code the server is being generated against.

* The version of the VS Code SQL Server extension.

To ensure that you have the latest version of these values, make sure your local VS Code instance is up to date then run the [**`Update-Source.ps1`**](./scripts/Update-Source.ps1) script out of the [**`scripts`**](./scripts/) directory.

![update-source](https://github.com/JaimeStill/airgapped-devcontainer/assets/14102723/34989bc0-4a7c-4830-80ed-d5517c7c73f5)

## Composing Your Dev Environment
[Back to Top](#air-gapped-dev-container)

Once you have the cached Dev Container image, you can build out development environments centered around that Dev Container.

The root [**`.devcontainer`**](./.devcontainer) directory provides a great example of this. It assumes that you will be developing with SQL Server 2022, so it uses [Docker Compose](./.devcontainer/docker-compose.yml) to host the official [SQL Server 2022](https://mcr.microsoft.com/en-us/product/mssql/server/about) image in a container alongside the Dev Container.

The [**`devcontainer.json`**](./.devcontainer/devcontainer.json) file specifies:

* The name of the Dev Container image
* Docker Compose metadata such as the docker compose file, the [service](./.devcontainer/docker-compose.yml#L4) that represents the Dev Container image, and the workspace folder.
* Environment variables to set on the Dev Container image.
* Forwarded ports and port attributes. In this case `1433` is configured for SQL Server.
* VS Code extension settings to configure in the Dev Container. In this case, the connection to SQL Server is configured for the SQL Server extension.

### ASP.NET Core Project Configuration

If you want to support an ASP.NET Core project, such as a Web API, that supports both local and Dev Container development, you can isolate a `Container` environment configuration.

In **`[Project]/Properties/launchSettings.json`**:

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

To connect to the container instance of SQL Server, create an **`appsettings.Container.json`** file, replacing the key and database name with your relevant values:

```json
{
    "ConnectionStrings": {
        "[key]": "Server=localhost,1433;Encrypt=Mandatory;TrustServerCertificate=True;User=sa;Password=P@ssw0rd;Database=[database-name]"
    }    
}
```

The `container` environment can be run with:

```pwsh
dotnet run --launch-profile "container"
```

which can be aliased to a VS Code task.

## Helpful Links
[Back to Top](#air-gapped-dev-container)

* [VS Code - Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
    * [Pre-building Dev Container Images](https://code.visualstudio.com/docs/devcontainers/containers#_prebuilding-dev-container-images)
    * [Always Installed Extensions](https://code.visualstudio.com/docs/devcontainers/containers#_always-installed-extensions)
    * [Port Forwarding](https://code.visualstudio.com/docs/devcontainers/containers#_forwarding-or-publishing-a-port)
* [Dev Container CLI](https://code.visualstudio.com/docs/devcontainers/devcontainer-cli)
* [Dev Containers CI Action](https://github.com/devcontainers/ci)
* [Container Features](https://containers.dev/implementors/features/)
    * [Published Features](https://containers.dev/features)
    * [Features Distribution](https://containers.dev/implementors/features-distribution/)
    * [Feature Starter Repo](https://github.com/devcontainers/feature-starter)