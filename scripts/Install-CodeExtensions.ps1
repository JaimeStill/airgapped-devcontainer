if (Test-Path '/extensions') {    
    $commit = "903b1e9d8990623e3d7da1df3d33db3e42d80eda"
    $code = "~/.vscode-server/bin/$commit/bin/remote-cli/code"

    $origin = $pwd

    try {
        Set-Location '/extensions'

        $extensions = Get-ChildItem -Filter '*.vsix' | ForEach-Object {
            '--install-extension', "./$($_.Name)"
        }

        Write-Host "Executing $code $($extensions -join ' ')"
        & 'code' $extensions
    }
    finally {
        Set-Location $origin
    }
}