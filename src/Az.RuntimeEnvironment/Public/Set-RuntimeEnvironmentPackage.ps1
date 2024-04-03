<#
.SYNOPSIS
Sets the package for a runtime environment in an Azure Automation account.

.DESCRIPTION
The Set-RuntimeEnvironmentPackage function sets the package for a specific runtime environment in an Azure Automation account. The package is specified by providing the subscription ID, resource group name, automation account name, runtime environment name, package name, and content link.

.PARAMETER SubscriptionId
The ID of the Azure subscription.

.PARAMETER ResourceGroupName
The name of the resource group containing the Azure Automation account.

.PARAMETER AutomationAccountName
The name of the Azure Automation account.

.PARAMETER RuntimeEnvironmentName
The name of the runtime environment.

.PARAMETER PackageName
The name of the package. It must be the same as the module name.

.PARAMETER ContentLink
The SAS URL with reader permission for the package content.

.EXAMPLE
Set-RuntimeEnvironmentPackage -SubscriptionId "12345678-1234-1234-1234-1234567890ab" -ResourceGroupName "MyResourceGroup" -AutomationAccountName "MyAutomationAccount" -RuntimeEnvironmentName "MyRuntimeEnvironment" -PackageName "MyPackage" -ContentLink "https://example.com/mypackage.sas"

This example sets the package for the "MyRuntimeEnvironment" runtime environment in the "MyAutomationAccount" Azure Automation account. The package name is "MyPackage" and the content link is "https://example.com/mypackage.sas".

#>
function Set-RuntimeEnvironmentPackage {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string]$AutomationAccountName,

        [Parameter(Mandatory = $true)]
        [string]$RuntimeEnvironmentName,

        [Parameter(Mandatory = $true)]
        [string]$PackageName, # Have to be the same as the module name

        [Parameter(Mandatory = $true)]
        [string]$ContentLink # Have to be a SAS URL with reader permission
    )

    $ErrorActionPreference = "Stop"

    try {
        $Body = @{
            properties = @{
                contentLink = @{
                    uri = $ContentLink
                }
            }
        }

        $Params = @{
            Uri         = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/runtimeEnvironments/$RuntimeEnvironmentName/packages/$($PackageName)?api-version=2023-05-15-preview"
            Method      = "PUT"
            ContentType = "application/json"
            Headers     = Get-AzHeader
            Body        = $Body | ConvertTo-Json
        }

        return Invoke-RestMethod @Params
    }
    catch {
        throw $_
    }
}