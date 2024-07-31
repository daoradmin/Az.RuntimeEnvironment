<#
.SYNOPSIS
Removes a runtime environment from an Azure Automation account.

.DESCRIPTION
The Remove-RuntimeEnvironment function removes a specified runtime environment from an Azure Automation account. It sends a DELETE request to the Azure Management API to delete the runtime environment.

.PARAMETER SubscriptionId
The ID of the Azure subscription that contains the resource group and automation account.

.PARAMETER ResourceGroupName
The name of the resource group that contains the automation account.

.PARAMETER AutomationAccountName
The name of the Azure Automation account.

.PARAMETER RuntimeEnvironmentName
The name of the runtime environment to be removed.

.EXAMPLE
Remove-RuntimeEnvironment -SubscriptionId "12345678-1234-1234-1234-1234567890ab" -ResourceGroupName "MyResourceGroup" -AutomationAccountName "MyAutomationAccount" -RuntimeEnvironmentName "MyRuntimeEnvironment"

This example removes a runtime environment named "MyRuntimeEnvironment" from the Azure Automation account "MyAutomationAccount" in the resource group "MyResourceGroup" under the specified subscription.

#>
function Remove-AzRuntimeEnvironment {
    [Alias("Remove-RuntimeEnvironment")]
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
            Uri         = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/runtimeEnvironments/$($RuntimeEnvironmentName)?api-version=2023-05-15-preview"
            Method      = "DELETE"
            ContentType = "application/json"
            Headers     = Get-AzHeader
        }
        $Output = Invoke-RestMethod @Params
        return $Output
    }
    catch {
        throw $_
    }
}