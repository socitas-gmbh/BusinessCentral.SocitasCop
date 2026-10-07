# Expand-PlatformArtifact.ps1
Param (
    [Parameter(Mandatory = $true)]
    [string] $archivePath,

    [Parameter(Mandatory = $true)]
    [string] $destinationPath
)

# .NET methods resolve relative paths against the process directory, not the PowerShell location
$archivePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($archivePath)
$destinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($destinationPath)

$requiredFiles = @(
    'Microsoft.Dynamics.Nav.CodeAnalysis.dll',
    'Microsoft.Dynamics.Nav.Analyzers.Common.dll',
    'System.Collections.Immutable.dll' # only shipped (and needed) by the .NET Standard versions
)

New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem

$archive = [System.IO.Compression.ZipFile]::OpenRead($archivePath)
try {
    # Up to AL Language 17.x the analyzer assemblies are in extension/bin/Analyzers, from 18.0 on directly in extension/bin
    $folder = if ($archive.Entries.FullName -like 'extension/bin/Analyzers/*') { 'extension/bin/Analyzers/' } else { 'extension/bin/' }

    foreach ($fileName in $requiredFiles) {
        $entry = $archive.GetEntry($folder + $fileName)
        if ($entry) {
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, (Join-Path $destinationPath $fileName), $true)
            Write-Host "Extracted $($entry.FullName)"
        }
    }
}
finally {
    $archive.Dispose()
}

if (-not (Test-Path (Join-Path $destinationPath 'Microsoft.Dynamics.Nav.CodeAnalysis.dll'))) {
    throw "Microsoft.Dynamics.Nav.CodeAnalysis.dll not found in '$folder' of '$archivePath'."
}
