function Get-AzRuntimeEnvironments {
    [Alias("Get-RuntimeEnvironments")]
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
            Uri         = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/runtimeEnvironments"
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