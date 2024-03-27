function Get-AzHeader {
    try {
        $Token = Get-AzAccessToken | Select-Object -ExpandProperty Token
        $Header = @{Authorization = "Bearer $token"}
        return $Header
    }
    catch {
        throw $_
    }
}
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
function Get-RuntimeEnvironments {
    param (
        [Parameter(Mandatory = $true)]
        $SubscriptionId,
        
        [Parameter(Mandatory = $true)]
        $ResourceGroupName,
        
        [Parameter(Mandatory = $true)]
        $AutomationAccountName
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
function New-RuntimeEnvironment {
    [CmdletBinding()]
    param (
        # Uri Parameters
        [Parameter(Mandatory = $true)]
        $SubscriptionId,
        
        [Parameter(Mandatory = $true)]
        $ResourceGroupName,
        
        [Parameter(Mandatory = $true)]
        $AutomationAccountName,
        
        [Parameter(Mandatory = $true)]
        $RuntimeEnvironmentName,

        # Body Parameters
        [Parameter(Mandatory = $false)]
        $Location = "westeurope",

        [Parameter(Mandatory = $true)]
        [ValidateSet("Powershell", "Python")]
        [string]$Language = "Powershell",

        [Parameter(Mandatory=$false)]
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
            $ValidationSet = New-Object System.Management.Automation.ValidateSetAttribute('7.2', '5.1')
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
            $runtime = @{
                language = $Language
                version  = $PSBoundParameters['Version']
            }
            $Properties | Add-Member -MemberType NoteProperty -Name "runtime" -Value $runtime

            # Add Default Packages Object if Language is Powershell
            if ($Language -eq "Powershell") {
                if (!($NoDefaultPackages)){
                    $defaultPackages = @{
                        "Az" = "11.2.0"
                    }
                    $Properties | Add-Member -MemberType NoteProperty -Name "defaultPackages" -Value $defaultPackages
                }
            }
            
            # Add Properties to Body
            $Body | Add-Member -MemberType NoteProperty -Name "properties" -Value $Properties
            
            # Create Parameters
            $Params = @{
                Uri         = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/runtimeEnvironments/$($RuntimeEnvironmentName)?api-version=2023-05-15-preview"
                Method      = "PUT"
                ContentType = "application/json"
                Headers     = Get-AzHeader
                Body        = $Body | ConvertTo-Json
            }

            # Invoke Rest Method
            $Output = Invoke-RestMethod @Params
            
            return $Output
        }
        catch {
            throw $_
        }

    }
}
function Remove-RuntimeEnvironment {
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
            Method      = "DELETE"
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
