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
