function Get-AzRuntimeEnvironmentPackages {
    [Alias("Get-RuntimeEnvironmentPackages")]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory = $true)]
        [string]$AutomationAccountName,

        [Parameter(Mandatory = $true)]
        $RuntimeEnvironmentName
    )
    
    $ErrorActionPreference = "Stop"

    try {
        $Params = @{
            Uri         = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/runtimeEnvironments/$RuntimeEnvironmentName/packages"
            Method      = "GET"
            Headers     = (Get-AzHeader)
        }
        return Invoke-AzAPI @Params
    }
    catch {
        throw $_
    }
}