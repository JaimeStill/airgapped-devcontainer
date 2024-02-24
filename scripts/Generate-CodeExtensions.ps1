param(
    [Parameter()]
    $Extensions = './extensions.json'
)

function Get-Json([string] $path) {
    Get-Content $path -Raw | ConvertFrom-Json
}

function Get-Extension([PSObject] $ext, [string] $base) {
    $path = Join-Path $base $ext.name

    try {
        if (!(Test-Path $path)) {
            Write-Host "Downloading extension $($ext.name)" -ForegroundColor Blue
            Invoke-WebRequest -Uri $ext.url -OutFile $path
        }
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 429) {
            $RateLimitReset = $_.Exception.Response.Headers | Where-Object -Property "Key" -eq "X-RateLimit-Reset" | Select-Object -ExpandProperty "Value"
            $RetrySeconds = $RateLimitReset - $([datetimeoffset]::Now.ToUnixTimeSeconds())
            $RetrySeconds += 10
            Write-Host "Rate limit exceeded. Sleeping $RetrySeconds seconds due to HTTP 429 response" -ForegroundColor Yellow
            Start-Sleep -Seconds $RetrySeconds
            Get-Extension @PSBoundParameters
        }
        else {
            Write-Host @PSBoundParameters
            Write-Error -Exception $_.Exception -Message "Failed to download code extension $_"
        }
    }
}

$base = '../src/extensions/'

if (!(Test-Path $base)) {
    New-Item $base -ItemType Directory -Force | Out-Null
}

Get-Json $Extensions | ForEach-Object {
    Get-Extension $_ $base
}

Write-Host "Extension cache successfully generated" -ForegroundColor Green