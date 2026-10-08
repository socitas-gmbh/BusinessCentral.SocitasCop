Write-Host "Downloading the AL Language compiler"
./.vscode/LoadALLanguage.ps1;

Write-Host "Creating AL Project for debugging"
$Path = (Get-Item $PSScriptRoot -force).parent.parent
$targetFramework = Get-Content ALLanguage/TargetFramework.txt

# The files are overwritten, so the script can run again after an AL Language update changed the target framework
New-Item -ItemType Directory "$Path/AlDebugProject/.vscode" -Force | Out-Null

Set-Content "$Path/AlDebugProject/app.json" @'
{
  "id": "d700542d-5688-4e64-aecb-648fa385a652",
  "name": "ALProject1",
  "publisher": "Default Publisher",
  "version": "1.0.0.0"
}
'@

Set-Content "$Path/AlDebugProject/test.al" @'
table 1 MyTable
{
    fields
    {
        field(1; MyField; Integer) { }
        field(2; MyField2; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = lookup(MyTable.MyField);
        }
    }
}
'@

[ordered]@{
    'al.codeAnalyzers' = @("$(((Get-Item $PSScriptRoot -force).parent).FullName)/bin/Debug/$targetFramework/BusinessCentral.SocitasCop.dll")
    'al.enableCodeAnalysis' = $true
    'al.compilationOptions' = [ordered]@{
        maxDegreeOfParallelism = 1
        parallel = $false
    }
} | ConvertTo-Json | Set-Content "$Path/AlDebugProject/.vscode/settings.json"
