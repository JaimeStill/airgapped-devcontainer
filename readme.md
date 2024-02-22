# Air-Gapped Dev Container

> Development is in-progress. Details are subject to change.

This repo is setup to build a dev container that can be transferred for use on an air-gapped network.

## Steps

The following steps assume you are running [Docker](https://www.docker.com/products/docker-desktop/) and have installed the [devcontainers CLI](https://github.com/devcontainers/cli?tab=readme-ov-file#context).

1. Run the [*online-base*](./online-base/) dev container in VS Code with the dev containers extension installed:

    ```pwsh
    cd ./online-base
    code .
    ```

    Open the command palette, <kbd>F1</kbd>, and select **Dev Containers: Reopen in Container**.

2. After the `postCreationCommand` has executed, run the [`build-cache.sh`](./online-base/build-cache.sh) script:

    ```bash
    . ./build-cache.sh
    ```

    This will generate all of the cached resources in the [*airgapped-dev/cache*](./airgapped-dev/cache) directory.

    Once this is finished, you can remove the generated container, images, and volumes safely:

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