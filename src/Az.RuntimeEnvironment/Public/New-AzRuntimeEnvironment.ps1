<#
.SYNOPSIS
Creates a new runtime environment in an Azure Automation account.

.DESCRIPTION
The New-RuntimeEnvironment function creates a new runtime environment in an Azure Automation account. It allows you to specify the subscription ID, resource group name, automation account name, runtime environment name, location, language, and whether to include default packages.

.PARAMETER SubscriptionId
The ID of the Azure subscription.

.PARAMETER ResourceGroupName
The name of the resource group.

.PARAMETER AutomationAccountName
The name of the Azure Automation account.

.PARAMETER RuntimeEnvironmentName
The name of the runtime environment.

.PARAMETER Location
The location where the runtime environment will be created. Default value is "westeurope".

.PARAMETER Language
The language of the runtime environment. Valid values are "Powershell" and "Python". Default value is "Powershell".

.PARAMETER NoDefaultPackages
Specifies whether to include default packages for the Powershell language. By default, default packages are included.

.EXAMPLE
New-RuntimeEnvironment -SubscriptionId "12345678-1234-1234-1234-1234567890ab" -ResourceGroupName "MyResourceGroup" -AutomationAccountName "MyAutomationAccount" -RuntimeEnvironmentName "MyRuntimeEnvironment" -Language "Powershell"

This example creates a new Powershell runtime environment in the specified Azure Automation account.

.EXAMPLE
New-RuntimeEnvironment -SubscriptionId "12345678-1234-1234-1234-1234567890ab" -ResourceGroupName "MyResourceGroup" -AutomationAccountName "MyAutomationAccount" -RuntimeEnvironmentName "MyRuntimeEnvironment" -Language "Python" -NoDefaultPackages

This example creates a new Python runtime environment in the specified Azure Automation account without including default packages.

#>
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
                Uri         = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/runtimeEnvironments/$($RuntimeEnvironmentName)"
                Method      = "PUT"
                Headers     = (Get-AzHeader)
                Body        = $Body
            }

            # Invoke Rest Method
            return Invoke-AzAPI @Params
        }
        catch {
            throw $_
        }

    }
}