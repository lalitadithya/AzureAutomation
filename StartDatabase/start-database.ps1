[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName, 

    [Parameter(Mandatory=$true)]
    [string]
    $DatabaseServerName, 

    [Parameter(Mandatory=$true)]
    [string]
    $DatabaseName,

    [Parameter(Mandatory=$true)]
    [string]
    $AdminPassword,

    [Parameter(Mandatory=$true)]
    [string]
    $AdminUsername,

    [Parameter(Mandatory=$true)]
    [string]
    $StorageConnectionString,

    [Parameter(Mandatory=$true)]
    [string]
    $DatabaseStorageContainerName,

    [Parameter(Mandatory=$true)]
    [string]
    $TemplateStorageContainerName
)

Write-Host "Attempting Azure login"

az login --identity

Write-Host "Fetching ARM template"

az storage blob download -c $TemplateStorageContainerName --file template.json --name template.json  --connection-string "$StorageConnectionString"

Write-Host "Fetching template parameters"

az storage blob download -c $TemplateStorageContainerName --file parameters.json --name parameters.json  --connection-string "$StorageConnectionString"

Write-Host "Creating resource group"

az group create --name $ResourceGroupName --location eastus

Write-Host "Database create started"

$deploymentName = Get-Date -Format "MMddyyyyHHmmss"
az group deployment create --name $deploymentName --resource-group $ResourceGroupName --template-file template.json --parameters `@parameters.json

Write-Host "Database restore started"

az storage blob download -c $DatabaseStorageContainerName --file backup.sql --name backup.sql  --connection-string "$StorageConnectionString"

$content = (Get-Content '.\backup.sql')
$content[105..($content.Length-3)] | Set-Content backup.sql

/opt/mssql-tools/bin/sqlcmd -U $AdminUsername -S $DatabaseServerName -P $AdminPassword -i "./backup.sql" -d $DatabaseName

Write-Host "Deleting backup"

az storage blob delete -c $DatabaseStorageContainerName --name backup.sql --connection-string "$StorageConnectionString"