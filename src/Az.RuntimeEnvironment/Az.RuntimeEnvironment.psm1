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
        $Token = Get-AzAccessToken | Select-Object -ExpandProperty Token
        $Header = @{Authorization = "Bearer $token"}
        return $Header
    }
    catch {
        throw $_
    }
}
<#
.SYNOPSIS
Retrieves information about a specific runtime environment in an Azure Automation account.

.DESCRIPTION
The Get-RuntimeEnvironment function retrieves information about a specific runtime environment in an Azure Automation account. It makes a GET request to the Azure Management API to fetch the details of the specified runtime environment.

.PARAMETER SubscriptionId
The ID of the Azure subscription that contains the automation account.

.PARAMETER ResourceGroupName
The name of the resource group that contains the automation account.

.PARAMETER AutomationAccountName
The name of the Azure Automation account.

.PARAMETER RuntimeEnvironmentName
The name of the runtime environment to retrieve information for.

.EXAMPLE
Get-RuntimeEnvironment -SubscriptionId "12345678-1234-1234-1234-1234567890ab" -ResourceGroupName "MyResourceGroup" -AutomationAccountName "MyAutomationAccount" -RuntimeEnvironmentName "MyRuntimeEnvironment"

This example retrieves information about a runtime environment named "MyRuntimeEnvironment" in the Azure Automation account "MyAutomationAccount" located in the "MyResourceGroup" resource group of the specified Azure subscription.

#>

function Get-RuntimeEnvironment {
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
<#
.SYNOPSIS
Retrieves the runtime environments for an Azure Automation account.

.DESCRIPTION
The Get-RuntimeEnvironments function retrieves the runtime environments for a specified Azure Automation account. It makes a GET request to the Azure Management API to fetch the runtime environments.

.PARAMETER SubscriptionId
The ID of the Azure subscription where the Automation account is located.

.PARAMETER ResourceGroupName
The name of the resource group where the Automation account is located.

.PARAMETER AutomationAccountName
The name of the Azure Automation account.

.EXAMPLE
Get-RuntimeEnvironments -SubscriptionId "12345678-90ab-cdef-ghij-klmnopqrstuv" -ResourceGroupName "MyResourceGroup" -AutomationAccountName "MyAutomationAccount"

This example retrieves the runtime environments for the specified Azure Automation account.

#>
function Get-RuntimeEnvironments {
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
function New-RuntimeEnvironment {
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
<#
.SYNOPSIS
Removes a runtime environment from an Azure Automation account.

.DESCRIPTION
The Remove-RuntimeEnvironment function removes a specified runtime environment from an Azure Automation account. It sends a DELETE request to the Azure Management API to delete the runtime environment.

.PARAMETER SubscriptionId
The ID of the Azure subscription that contains the resource group and automation account.

.PARAMETER ResourceGroupName
The name of the resource group that contains the automation account.

.PARAMETER AutomationAccountName
The name of the Azure Automation account.

.PARAMETER RuntimeEnvironmentName
The name of the runtime environment to be removed.

.EXAMPLE
Remove-RuntimeEnvironment -SubscriptionId "12345678-1234-1234-1234-1234567890ab" -ResourceGroupName "MyResourceGroup" -AutomationAccountName "MyAutomationAccount" -RuntimeEnvironmentName "MyRuntimeEnvironment"

This example removes a runtime environment named "MyRuntimeEnvironment" from the Azure Automation account "MyAutomationAccount" in the resource group "MyResourceGroup" under the specified subscription.

#>
function Remove-RuntimeEnvironment {
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
<#
.SYNOPSIS
Sets the package for a runtime environment in an Azure Automation account.

.DESCRIPTION
The Set-RuntimeEnvironmentPackage function sets the package for a specific runtime environment in an Azure Automation account. The package is specified by providing the subscription ID, resource group name, automation account name, runtime environment name, package name, and content link.

.PARAMETER SubscriptionId
The ID of the Azure subscription.

.PARAMETER ResourceGroupName
The name of the resource group containing the Azure Automation account.

.PARAMETER AutomationAccountName
The name of the Azure Automation account.

.PARAMETER RuntimeEnvironmentName
The name of the runtime environment.

.PARAMETER PackageName
The name of the package. It must be the same as the module name.

.PARAMETER ContentLink
The SAS URL with reader permission for the package content.

.EXAMPLE
Set-RuntimeEnvironmentPackage -SubscriptionId "12345678-1234-1234-1234-1234567890ab" -ResourceGroupName "MyResourceGroup" -AutomationAccountName "MyAutomationAccount" -RuntimeEnvironmentName "MyRuntimeEnvironment" -PackageName "MyPackage" -ContentLink "https://example.com/mypackage.sas"

This example sets the package for the "MyRuntimeEnvironment" runtime environment in the "MyAutomationAccount" Azure Automation account. The package name is "MyPackage" and the content link is "https://example.com/mypackage.sas".

#>
function Set-RuntimeEnvironmentPackage {
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
        [string]$PackageName, # Have to be the same as the module name

        [Parameter(Mandatory = $true)]
        [string]$ContentLink # Have to be a SAS URL with reader permission
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
