param (
    [string]$functionappName,
    [string]$applicationClientID,
    [string]$applicationTenantID,
    [string]$workDirectory,
    [string]$zipFileName,
    [string]$subscriptionID,
    [string]$storageAccountName,
    [string]$containerName,
    [string]$resourceGroupName
)

# Set error action preference to stop on error
$ErrorActionPreference = "Stop"

$archivePath = "$env:PIPELINE_WORKSPACE/drop/$zipFileName"

Write-Output "functionappName: $functionappName"
Write-Output "zip file path: $archivePath"

dir
Install-Module -Name Az.Accounts -AllowClobber -Scope CurrentUser -Force
Install-Module -Name Az.Storage -AllowClobber -Scope CurrentUser -Force
Install-Module -Name Az.Websites -AllowClobber -Scope CurrentUser -Force
Install-Module -Name Az.Functions -AllowClobber -Scope CurrentUser -Force
Connect-AzAccount -ServicePrincipal -ApplicationId $applicationClientID -TenantId $applicationTenantID -CertificatePath ./AzDo-Piplines.pfx  -SendCertificateChain
Set-AzContext -Subscription $subscriptionID
 
# Get the storage account context
$context = New-AzStorageContext -StorageAccountName $storageAccountName
 
# Upload the ZIP file
Set-AzStorageBlobContent -Container $containerName -File $archivePath -Blob $zipFileName -Context $context.Context
Write-Output "File $archivePath uploaded to container $containerName in storage account $storageAccountName."

# Construct the full zip file URL
$fullZipFilePath = "https://$($storageAccountName).blob.core.windows.net/$($containerName)/$($zipFileName)"

# Output the update information
Write-Output "The function $functionappName in resource group $resourceGroupName is updated with zip file $fullZipFilePath"

# Update the Function App setting
Update-AzFunctionAppSetting -Name $functionappName -ResourceGroupName $resourceGroupName -AppSetting @{"WEBSITE_RUN_FROM_PACKAGE" = $fullZipFilePath}

# restart the function to refelct new zip file code
Write-Output "The function $functionappName in resource group $resourceGroupName will be restarted"
Start-Sleep -Seconds 30
Restart-AzFunctionApp -Name $functionappName -ResourceGroupName $resourceGroupName -Force
