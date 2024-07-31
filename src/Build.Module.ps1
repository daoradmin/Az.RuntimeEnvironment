$ErrorActionPreference = "Stop"
try {
    $Name = "Az.RuntimeEnvironment"
    $Version = "1.0.3"
    
    $CurrentDirectory = $PSScriptRoot
    $ModulePath = "$CurrentDirectory/$Name"
    
    #Changing Directory to the module root
    Set-Location $CurrentDirectory
    
    #Getting Current Manifest Info
    if (Test-Path "$ModulePath/$Name.psd1"){
        $ManifestInfo = Test-ModuleManifest -Path "$ModulePath/$Name.psd1"
    }
    
    #Getting Public Functions to Export
    $PublicFunctions = Get-ChildItem -Path "$ModulePath/Public" -Recurse -Filter "*.ps1"

    
    #Creating Module Manifest
    $Params = @{
        Author = "daoradmin"
        CompanyName = "daoradmin"
        Description = "Powershell Module for Azure Runtime Environment"
        ModuleVersion = $Version
        PowerShellVersion = "7.2"
        Path = "$ModulePath/$Name.psd1"
        FunctionsToExport = $PublicFunctions | Select-Object -ExpandProperty BaseName
        ProjectUri = "https://github.com/daoradmin/$Name"
        LicenseUri = "https://github.com/daoradmin/$Name/blob/master/LICENSE.txt"
        Tags = @("PSMODULE", "$Name")
        RootModule = "$Name.psm1"
    }
    
    #Checking if the module version is the same as the current version
    #If it is the same, then we will not update the module version
    if ($Params.ModuleVersion -eq $ManifestInfo.Version){
        Write-Warning "Module version is the same as the current version"
        Write-Warning "Please update the module version!"
        return
    }
    
    #Creating Module Manifest
    New-ModuleManifest @Params
    
    #Creating OuraRing.psm1 file
    New-Item -Path "$ModulePath/$Name.psm1" -ItemType File -Force | Out-Null
    
    $AllFunctions = @()
    $AllFunctions += (Get-ChildItem -Path "$ModulePath/Private" -Recurse -Filter "*.ps1")
    $AllFunctions += $PublicFunctions
    
    foreach ($Function in $AllFunctions){
        $Content = Get-Content -Path $Function.ResolvedTarget
        #Adding content to OuraRing.psm1 file
        Add-Content -Path "$ModulePath/$Name.psm1" -Value $Content
    }
}
catch {
    $_
}