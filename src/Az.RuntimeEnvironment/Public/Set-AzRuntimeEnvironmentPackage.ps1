function Set-AzRuntimeEnvironmentPackage {
    [Alias("Set-RuntimeEnvironmentPackage")]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [string]$AutomationAccountName,

        [Parameter(Mandatory = $true)]
        [string]$RuntimeEnvironmentName,

        [Parameter(Mandatory = $true, HelpMessage = "Name must be the same as the module name")]
        [string]$PackageName,

        [Parameter(Mandatory = $true, HelpMessage = "SAS URL to the module package")]
        [string]$ContentLink,

        [Parameter(Mandatory = $false, HelpMessage = "Wait for the operation to complete")]
        [switch]$Wait
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
            Uri     = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/runtimeEnvironments/$RuntimeEnvironmentName/packages/$($PackageName)"
            Headers = (Get-AzHeader)
        }
        $Request = Invoke-AzAPI @Params -Method "PUT" -Body $Body

        if ($Wait) {
            
            $PackageName = ($ContentLink.Split("/")[-1]).Split("?")[0]
                    
            Write-Verbose "`n[$(Get-Date -Format "HH:mm:ss")] : [INFO] : [$AutomationAccountName] : Uploading package: $PackageName"
                    
            $CommandData = Measure-Command {
                do {            
                    Start-Sleep -Seconds 5
                    $Request = Invoke-AzAPI @Params -Method "GET"

                    # If Package provisioning failed, throw an error
                    if ($Request.properties.provisioningState -eq "Failed") {
                        throw $_.ErrorDetails.Message
                    }
                        
                } until ($Request.properties.provisioningState -eq "Succeeded")
            }
                    
            Write-Verbose "`n[$(Get-Date -Format "HH:mm:ss")] : [COMPLETED] : [$AutomationAccountName] : Package provisioned successfully after $($CommandData.TotalSeconds) seconds!`n"
        }
        else {
            Write-Verbose "`n[$(Get-Date -Format "HH:mm:ss")] : [INFO] : [$AutomationAccountName] : Package upload started!"
        }
        Write-Output $Request
    }
    catch {
        throw $_
    }
}