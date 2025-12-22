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
        $Request = Invoke-AzAPI @Params
        Write-Output $Request
    }
    catch {
        throw $_
    }
}