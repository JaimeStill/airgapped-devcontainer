# Air-Gapped Dev Container

> Development is in-progress. Details are subject to change.

This repo is setup to build a dev container that can be transferred for use on an air-gapped network.

## Steps

1. Run the [`Generate-CodeExtensions.ps1`](./Generate-CodeExtensions.ps1) script to generate extensions in the root [*.devcontainer*](./.devcontainer/)

2. Open [*online-base*](./online-base/) in a new code window and build it as a dev container.

    * The `postCreationCommand` will generate all of the cached resources in the root [*.devcontainer*](./.devcontainer/).