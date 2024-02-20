# Air-Gapped Dev Container

> Development is in-progress. Details are subject to change.

This repo is setup to build a dev container that can be transferred for use on an air-gapped network.

## Steps

1. Run the [`Generate-CodeExtensions.ps1`](./Generate-CodeExtensions.ps1) script to generate extensions in [*airgapped-dev*](./airgapped-dev/)

2. Spin up the [*online-base*](./online-base/) dev container using the [`devcontainer up`](https://github.com/devcontainers/cli?tab=readme-ov-file#context) command.

    * The `postCreationCommand` will generate all of the cached resources in the root [*airgapped-dev*](./airgapped-dev/).

    * There is currently no `stop` or `down` command for the devcontainer CLI. Once this is finished, you can remove the generated container, images, and volumes safely.

3. [Pre-build](https://containers.dev/guide/prebuild) the `airgapped-dev` dev container by running:

    ```pwsh
    devcontainer build --workspace-folder .\airgapped-dev\ --image-name airgapped-dev:latest
    ```

4. To test, open the [*test*](./test) directory in a new VS Code window dev container.