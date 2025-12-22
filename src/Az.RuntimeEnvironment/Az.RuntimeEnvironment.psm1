<#
.SYNOPSIS
    Retrieves the Azure header for authentication.

.DESCRIPTION
    The Get-AzHeader function retrieves the Azure header required for authentication. It obtains an access token using the Get-AzAccessToken function and constructs the header with the token.

.OUTPUTS
    System.Collections.Hashtable
        Returns a hashtable representing the Azure header.

.EXAMPLE
    $header = Get-AzHeader
    # Use the $header hashtable for authentication in Azure API calls.

.NOTES
    Author: [Your Name]
    Date: [Current Date]
#>
function Get-AzHeader {
    try {
        $SecureToken = Get-AzAccessToken -AsSecureString | Select-Object -ExpandProperty Token
        $Token = $SecureToken | ConvertFrom-SecureString -AsPlainText
        $Header = @{Authorization = "Bearer $token"}
        return $Header
    }
    catch {
        throw $_
    }
}
function Invoke-AzAPI {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Uri,
        
        [Parameter(Mandatory=$true)]
        [string]$Method,
        
        [Parameter(Mandatory=$true)]
        [System.Object]$Headers,

        [Parameter(Mandatory=$false)]
        [System.Object]$Body,

        [Parameter(Mandatory=$false)]
        [string]$ApiVersion="2024-10-23"
    )

    $ErrorActionPreference="Stop"

    try {
        
        $Params = @{
            Uri = ($Uri + "?api-version=$ApiVersion")
            Method = $Method
            ContentType = "application/json"
            Headers = $Headers
        }

        if ($Body){
            $Params.Add("Body", ($Body | ConvertTo-Json))
        }

        return Invoke-RestMethod @Params

    }
    catch {
        throw $_
    }
    
}
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
        $Request = Invoke-AzAPI @Params
        Write-Output $Request
    }
    catch {
        throw $_
    }
}
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
        $Request = Invoke-AzAPI @Params
        Write-Output $Request
    }
    catch {
        throw $_
    }
}
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
function New-AzRuntimeEnvironment {
    [Alias("New-RuntimeEnvironment")]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory = $true)]
        [string]$AutomationAccountName,
        
        [Parameter(Mandatory = $true)]
        [string]$RuntimeEnvironmentName,

        [Parameter(Mandatory = $false)]
        [string]$Location = "westeurope",

        [Parameter(Mandatory = $true)]
        [ValidateSet("Powershell", "Python")]
        [string]$Language = "Powershell",

        [Parameter(Mandatory = $false)]
        [switch]$NoDefaultPackages
    )

    DynamicParam {
        
        # Create a dictionary to hold the dynamic parameters
        $LanguageVersion = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # Define the dynamic parameter
        $Fields = New-Object System.Management.Automation.ParameterAttribute
        $Fields.Mandatory = $true

        # Creating the attribute collection
        $CollectionFields = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
        
        if ($PSBoundParameters['Language'].Equals("Powershell")) {
            # Creating the ValidateSet attribute
            $ValidationSet = New-Object System.Management.Automation.ValidateSetAttribute('7.4', '7.2', '5.1')
        }
        elseif ($PSBoundParameters['Language'].Equals("Python")) {
            # Creating the ValidateSet attribute
            $ValidationSet = New-Object System.Management.Automation.ValidateSetAttribute('3.10', '3.8')
        }

        # Adding the Parameter and ValidateSet attributes
        $CollectionFields.Add($Fields)
        $CollectionFields.Add($ValidationSet)

        # Adding dynamic parameter to dictionary
        $ParameterFields = New-Object System.Management.Automation.RuntimeDefinedParameter('Version', [string], $CollectionFields)
        $LanguageVersion.Add('Version', $ParameterFields)

        return $LanguageVersion
    }

    process {
        try {
            # Create Body Object
            $Body = [PSCustomObject]@{}
            
            # Add Location (Mandatory)
            $Body | Add-Member -MemberType NoteProperty -Name "location" -Value $Location
           
            # Create Properties Object
            $Properties = [PSCustomObject]@{}

            # Add Runtime Object
            $Runtime = @{
                language = $Language
                version  = $PSBoundParameters['Version']
            }
            $Properties | Add-Member -MemberType NoteProperty -Name "runtime" -Value $Runtime

            # Add Default Packages Object if Language is Powershell
            if ($Language -eq "Powershell") {
                if (!($NoDefaultPackages)) {
                    $defaultPackages = @{
                        "Az" = "12.3.0"
                        "Azure CLI" = "2.64.0"
                    }
                    $Properties | Add-Member -MemberType NoteProperty -Name "defaultPackages" -Value $defaultPackages
                }
            }
            
            # Add Properties to Body
            $Body | Add-Member -MemberType NoteProperty -Name "properties" -Value $Properties
            
            # Create Parameters
            $Params = @{
                Uri     = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/runtimeEnvironments/$($RuntimeEnvironmentName)"
                Method  = "PUT"
                Headers = (Get-AzHeader)
                Body    = $Body
            }

            # Invoke Rest Method
            $Request = Invoke-AzAPI @Params
            Write-Output $Request
        }
        catch {
            throw $_
        }

    }
}
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
            Uri         = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/runtimeEnvironments/$($RuntimeEnvironmentName)"
            Method      = "DELETE"
            Headers     = (Get-AzHeader)
        }
        return Invoke-AzAPI @Params
    }
    catch {
        throw $_
    }
}
function Remove-AzRuntimeEnvironmentPackage {
    [Alias("Remove-RuntimeEnvironmentPackage")]
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
            Method      = "DELETE"
            Headers     = (Get-AzHeader)
        }
        $Request = Invoke-AzAPI @Params
        Write-Output $Request
    }
    catch {
        throw $_
    }
}
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
