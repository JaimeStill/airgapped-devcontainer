# Notes

## Workspace Folder

If working with a directory hierarchy that contains more than one dev container and you want the workspace folder to be the root directory, either specify `workspaceMount` and `workspaceFolder` in *devcontainer.json*, or initiate git tracking at the root of the directory. See [workspaceFolder and workspaceMount](https://containers.dev/implementors/spec/#workspace-folder) and [Dev Container metadata reference - image or dockerfile specific properties](https://containers.dev/implementors/json_reference/#image-specific).