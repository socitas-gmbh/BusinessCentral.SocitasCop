Remove-Item -Path ALLanguage/ -Recurse -Force -ErrorAction SilentlyContinue;
Set-Variable ProgressPreference SilentlyContinue;
$listing = Invoke-WebRequest -Method POST -UseBasicParsing -Uri https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery?api-version=3.0-preview.1 -Body '{"filters":[{"criteria":[{"filterType":8,"value":"Microsoft.VisualStudio.Code"},{"filterType":12,"value":"4096"},{"filterType":7,"value":"ms-dynamics-smb.al"}],"pageNumber":1,"pageSize":50,"sortBy":0,"sortOrder":0}],"assetTypes":[],"flags":147}' -ContentType application/json | ConvertFrom-Json;
$vsixUrl_Current = $listing.results.extensions.versions | Where-Object properties -ne $null | Where-Object { $_.properties.key -notcontains 'Microsoft.VisualStudio.Code.PreRelease' } | Select-Object -First 1 -ExpandProperty files | Where-Object { $_.assetType -eq 'Microsoft.VisualStudio.Services.VSIXPackage' } | Select-Object -ExpandProperty source;
Invoke-WebRequest $vsixUrl_Current -OutFile ALLanguage.zip;
./.github/actions/platform-artifacts/Expand-PlatformArtifact.ps1 ALLanguage.zip ALLanguage;
./.github/actions/platform-artifacts/Get-TargetFramework.ps1 ALLanguage/Microsoft.Dynamics.Nav.CodeAnalysis.dll | Set-Content ALLanguage/TargetFramework.txt;
Remove-Item -Path ALLanguage.zip -Force -ErrorAction SilentlyContinue;