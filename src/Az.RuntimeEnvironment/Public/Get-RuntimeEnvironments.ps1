<#
.SYNOPSIS
Retrieves the runtime environments for an Azure Automation account.

.DESCRIPTION
The Get-RuntimeEnvironments function retrieves the runtime environments for a specified Azure Automation account. It makes a GET request to the Azure Management API to fetch the runtime environments.

.PARAMETER SubscriptionId
The ID of the Azure subscription where the Automation account is located.

.PARAMETER ResourceGroupName
The name of the resource group where the Automation account is located.

.PARAMETER AutomationAccountName
The name of the Azure Automation account.

.EXAMPLE
Get-RuntimeEnvironments -SubscriptionId "12345678-90ab-cdef-ghij-klmnopqrstuv" -ResourceGroupName "MyResourceGroup" -AutomationAccountName "MyAutomationAccount"

This example retrieves the runtime environments for the specified Azure Automation account.

#>
function Get-RuntimeEnvironments {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory = $true)]
        [string]$AutomationAccountName
    )
    
    $ErrorActionPreference = "Stop"

    try {
        
        $Params = @{
            Uri         = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/runtimeEnvironments?api-version=2023-05-15-preview"
            Method      = "GET"
            ContentType = "application/json"
            Headers     = Get-AzHeader
        }
        $Output = Invoke-RestMethod @Params
        return $Output.value
    }
    catch {
        throw $_
    }
}