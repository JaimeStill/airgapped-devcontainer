Get-NetAdapter | ForEach-Object { Enable-NetAdapter -Name $_.Name -Confirm:$false }