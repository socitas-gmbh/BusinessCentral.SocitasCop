# Get-TargetFramework.ps1
Param (
    [Parameter(Mandatory = $true)]
    [string] $path
)

# .NET methods resolve relative paths against the process directory, not the PowerShell location
$path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)

# Build against the framework the AL Language compiled its CodeAnalysis.dll for,
# read from its TargetFrameworkAttribute (e.g. ".NETCoreApp,Version=v10.0" -> net10.0)
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::Latin1)
$match = [regex]::Match($content, '\.NETCoreApp,Version=v(\d+\.\d+)')

if ($match.Success) {
    Write-Output "net$($match.Groups[1].Value)"
}
else {
    Write-Output "netstandard2.1"
}
