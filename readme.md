# Air-Gapped Dev Container

> Development is in-progress. Details are subject to change.

This repo is setup to build a dev container that can be transferred for use on an air-gapped network.

## Steps

The following steps assume you are running [Docker](https://www.docker.com/products/docker-desktop/) and have installed the [devcontainers CLI](https://github.com/devcontainers/cli?tab=readme-ov-file#context).

1. Run the [`Generate-CodeExtensions.ps1`](./Generate-CodeExtensions.ps1) script to generate extensions in [*airgapped-dev*](./airgapped-dev/)

2. Spin up the [*online-base*](./online-base/) dev container using the following command:

    ```pwsh
    devcontainer up --workspace-folder .\online-base\
    ```

    * The `postCreationCommand` will generate all of the cached resources in the root [*airgapped-dev*](./airgapped-dev/).

    * There is currently [no `stop` or `down` command](https://github.com/devcontainers/cli/issues/386) for the devcontainer CLI. Once this is finished, you can remove the generated container, images, and volumes safely

        ```pwsh
        docker stop [container-name]
        docker rm [container-name]

        docker volume prune -a -f

        docker rmi [image-name]
        ```

3. [Pre-build](https://containers.dev/guide/prebuild) the `airgapped-dev` dev container by running:

    ```pwsh
    devcontainer build --workspace-folder .\airgapped-dev\ --image-name airgapped-dev:latest
    ```

4. To test, open the [*test*](./test) directory in a new VS Code window dev container.

5. To cache the image for offline use, run:

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