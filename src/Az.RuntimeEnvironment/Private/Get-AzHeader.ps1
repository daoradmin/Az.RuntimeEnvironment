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
        $Token = $SecureToken | ConvertFrom-SecureString
        $Header = @{Authorization = "Bearer $token"}
        return $Header
    }
    catch {
        throw $_
    }
}