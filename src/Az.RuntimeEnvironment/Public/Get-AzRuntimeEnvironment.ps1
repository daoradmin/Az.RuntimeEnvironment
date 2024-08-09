<#
.SYNOPSIS
Retrieves information about a specific runtime environment in an Azure Automation account.

.DESCRIPTION
The Get-RuntimeEnvironment function retrieves information about a specific runtime environment in an Azure Automation account. It makes a GET request to the Azure Management API to fetch the details of the specified runtime environment.

.PARAMETER SubscriptionId
The ID of the Azure subscription that contains the automation account.

.PARAMETER ResourceGroupName
The name of the resource group that contains the automation account.

.PARAMETER AutomationAccountName
The name of the Azure Automation account.

.PARAMETER RuntimeEnvironmentName
The name of the runtime environment to retrieve information for.

.EXAMPLE
Get-RuntimeEnvironment -SubscriptionId "12345678-1234-1234-1234-1234567890ab" -ResourceGroupName "MyResourceGroup" -AutomationAccountName "MyAutomationAccount" -RuntimeEnvironmentName "MyRuntimeEnvironment"

This example retrieves information about a runtime environment named "MyRuntimeEnvironment" in the Azure Automation account "MyAutomationAccount" located in the "MyResourceGroup" resource group of the specified Azure subscription.

#>

function Get-AzRuntimeEnvironment {
    [Alias("Get-RuntimeEnvironment")]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory = $true)]
        [string]$AutomationAccountName,
        
        [Parameter(Mandatory = $true)]
        [string]$RuntimeEnvironmentName
    )

    $ErrorActionPreference = "Stop"

    try {
        $Params = @{
            Uri         = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/runtimeEnvironments/$($RuntimeEnvironmentName)"
            Method      = "GET"
            Headers     = (Get-AzHeader)
        }
        return Invoke-AzAPI @Params
    }
    catch {
        throw $_
    }
}