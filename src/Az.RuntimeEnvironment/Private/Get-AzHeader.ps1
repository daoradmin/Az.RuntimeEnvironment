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