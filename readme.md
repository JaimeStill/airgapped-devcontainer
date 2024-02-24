# Air-Gapped Dev Container

> Development is in-progress. Details are subject to change.

This repo is setup to build a dev container that can be transferred for use on an air-gapped network.

## Steps

The following steps assume you are running [Docker](https://www.docker.com/products/docker-desktop/) and have installed the [devcontainers CLI](https://github.com/devcontainers/cli?tab=readme-ov-file#context).

1. [Pre-build](https://containers.dev/guide/prebuild) the `airgapped-dev` dev container by running:

    ```pwsh
    devcontainer build --workspace-folder .\src\ --image-name airgapped-dev:latest
    ```

2. To test, press <kbd>F1</kbd> to open the command palette and select **Dev Containers: Reopen in Container**.

    * You can install the [`mssql']() extension after the container is built by running the following:

        ```bash
        code --install-extension $HOME/mssql-ubuntu-x64.vsix
        ```

3. To cache the image for offline use, run:

    ```pwsh
    docker save airgapped-dev:latest -o [output-path]
    ```

## Helpful Links

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