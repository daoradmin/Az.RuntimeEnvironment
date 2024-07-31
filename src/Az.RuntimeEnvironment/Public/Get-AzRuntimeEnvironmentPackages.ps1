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
            Uri         = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/runtimeEnvironments/$RuntimeEnvironmentName/packages?api-version=2023-05-15-preview"
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