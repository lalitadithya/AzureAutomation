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
    $StorageContainerName
)

Write-Host "Attempting Azure login"

az login --identity

Write-Host "Database export started"

mssql-scripter -S $DatabaseServerName -d $DatabaseName -U $AdminUsername -P $AdminPassword --schema-and-data --target-server-version "AzureDB" --display-progress > backup.sql

Write-Host "Uploading script to blob"

az storage blob upload -f backup.sql -c $StorageContainerName -n backup.sql --connection-string "$StorageConnectionString"

Write-Host "Stopping database in resource group $ResourceGroupName"

az group delete -n $ResourceGroupName --yes

Write-Host "Database stopped"