function Set-RuntimeEnvironmentPackage {
    param (
        [Parameter(Mandatory = $true)]
        $SubscriptionId,

        [Parameter(Mandatory = $true)]
        $ResourceGroupName,

        [Parameter(Mandatory = $true)]
        $AutomationAccountName,

        [Parameter(Mandatory = $true)]
        $RuntimeEnvironmentName,

        [Parameter(Mandatory = $true)]
        $PackageName, # Have to be the same as the module name

        [Parameter(Mandatory = $true)]
        $ContentLink # Have to be a SAS URL with reader permission
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