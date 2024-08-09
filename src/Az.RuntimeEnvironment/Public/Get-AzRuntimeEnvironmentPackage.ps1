function Get-AzRuntimeEnvironmentPackage {
    [Alias("Get-RuntimeEnvironmentPackage")]
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
        [string]$PackageName
    )
    
    $ErrorActionPreference = "Stop"

    try {
        $Params = @{
            Uri         = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/runtimeEnvironments/$RuntimeEnvironmentName/packages/$($PackageName)"
            Method      = "GET"
            Headers     = (Get-AzHeader)
        }
        return Invoke-AzAPI @Params
    }
    catch {
        throw $_
    }
}