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
        [string]$ApiVersion="2023-05-15-preview"
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