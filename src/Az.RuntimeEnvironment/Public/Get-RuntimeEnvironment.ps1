function Get-RuntimeEnvironment {
    param (
        [Parameter(Mandatory = $true)]
        $SubscriptionId,
        
        [Parameter(Mandatory = $true)]
        $ResourceGroupName,
        
        [Parameter(Mandatory = $true)]
        $AutomationAccountName,
        
        [Parameter(Mandatory = $true)]
        $RuntimeEnvironmentName
    )

    $ErrorActionPreference = "Stop"

    try {
        $Params = @{
            Uri         = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/runtimeEnvironments/$($RuntimeEnvironmentName)?api-version=2023-05-15-preview"
            Method      = "GET"
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