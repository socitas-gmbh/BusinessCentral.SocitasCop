# Runs the "Prep Codespace" and "build_dotnet" tasks and checks that the AL project for debugging points at an
# analyzer built for the runtime of the downloaded AL Language. Run it from the repository root.
$ErrorActionPreference = 'Stop'
$alProject = Join-Path (Get-Item $PSScriptRoot -Force).Parent.Parent 'AlDebugProject'

./.devcontainer/ContainerPrep.ps1

# Prep runs again after every AL Language update; it must work on the existing AL project and keep changes made while debugging
Add-Content (Join-Path $alProject 'test.al') '// changed while debugging'
./.devcontainer/ContainerPrep.ps1
if ((Get-Content (Join-Path $alProject 'test.al') -Raw) -notmatch 'changed while debugging') { throw "The second Prep run replaced test.al." }

dotnet build BusinessCentral.SocitasCop.csproj
if ($LASTEXITCODE) { throw "dotnet build failed with exit code $LASTEXITCODE." }

Get-Content (Join-Path $alProject 'app.json') -Raw | ConvertFrom-Json | Out-Null
$analyzer = (Get-Content (Join-Path $alProject '.vscode/settings.json') -Raw | ConvertFrom-Json).'al.codeAnalyzers'[0]
if (-not (Test-Path $analyzer -PathType Leaf)) { throw "The AL project points at $analyzer, which the build did not produce." }

$expected = ./.github/actions/platform-artifacts/Get-TargetFramework.ps1 ALLanguage/Microsoft.Dynamics.Nav.CodeAnalysis.dll
$actual = ./.github/actions/platform-artifacts/Get-TargetFramework.ps1 $analyzer
if ($actual -ne $expected) { throw "The analyzer targets $actual, the AL Language $expected." }
Write-Host "The AL project points at $analyzer, built for $actual like the AL Language."
