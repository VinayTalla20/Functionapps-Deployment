param (
    [string]$resourceGroupName,
    [string]$functionappName,
    [string]$applicationClientID,
    [string]$applicationTenantID,
    [string]$subscriptionID
)

$archivePath = "$env:PIPELINE_WORKSPACE/drop/$env:BUILD_BUILDID" + ".zip"
Write-Output "Zip file path: $archivePath"
Write-Output "resourceGroup: $resourceGroupName"
Write-Output "functionappName: $functionappName"
Install-Module -Name Az.Accounts -AllowClobber -Scope CurrentUser -Force
Install-Module -Name Az.Websites -AllowClobber -Scope CurrentUser -Force
Connect-AzAccount -ServicePrincipal -ApplicationId $applicationClientID -TenantId $applicationTenantID -CertificatePath $env:KEYVAULTCERTIFICATE_SECUREFILEPATH  -SendCertificateChain
Set-AzContext -Subscription $subscriptionID
Publish-AzWebApp -ResourceGroupName $resourceGroupName -Name $functionappName -ArchivePath $archivePath -Force
