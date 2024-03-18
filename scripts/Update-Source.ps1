function Get-VariableMatch([string] $variable, [string] $contents) {
    $contents | Select-String -Pattern "(?<=$variable=`").+?(?=`")"
}

function Get-ExtensionVersion([string] $url) {
    ([System.Net.HttpWebRequest]::Create($url).GetResponse().ResponseUri.AbsoluteUri).Split('/')[-1].Replace('v', '')
}

function Update-VariableSetting(
    [string] $contents,
    [string] $target,
    [Microsoft.PowerShell.Commands.MatchInfo] $match
) {
    if ($match.Matches.Count -gt 0) {
        $origin = $match.Matches[0].Value

        if ($origin -ne $target) {
            return @{
                Contents = $contents -replace $origin, $target;
                Origin = $origin;
                Changed = $true
            }
        } else {
            return @{
                Contents = $contents;
                Origin = $origin;
                Changed = $false
            }
        }
    }
}

$sqlurl = 'https://github.com/microsoft/vscode-mssql/releases/latest'
$file = '..\src\build\vscode-server.sh'
$contents = Get-Content -Path $file -Raw
$flag = $false

$commitmatch = Get-VariableMatch 'commit' $contents
$commit = (code --version)[1]
$result = Update-VariableSetting $contents $commit $commitmatch

if ($result.Changed) {
    Write-Host "Replacing $($result.Origin) with ${commit}"
    $contents = $result.Contents
    $flag = $true
}

$sqlmatch = Get-VariableMatch 'sqlextversion' $contents
$sqlversion = Get-ExtensionVersion $sqlurl
$result = Update-VariableSetting $contents $sqlversion $sqlmatch

if ($result.Changed) {
    Write-Host "Replacing $($result.Origin) with ${sqlversion}"
    $contents = $result.Contents
    $flag = $true
}

if ($flag) {
    Set-Content -Path $file -Value $contents
} else {
    Write-Host "$file is already up to date"
}