Param(
    [Parameter(Mandatory = $false)]
    $Name = "Az.RuntimeEnvironment",

    [Parameter(Mandatory = $false)]
    $Path = $PSScriptRoot
)

$ErrorActionPreference = "Stop"

try {
    
    $ModulePath = "$Path/$Name"
    
    # Get Current Module Information
    $Module = Find-Module $Name -Repository PSGallery -ErrorAction SilentlyContinue

    # If module does not exist, then we will create a new module
    if ($null -eq $Module) {
        $NewVersion = 1.0.0
    }
    else {
        # Calculate new version
        $CurrentVersion = [Version]$Module.Version
    
        #Upping version
        if ($CurrentVersion.Minor -eq 99) {
            $NewVersion = New-Object System.Version(($CurrentVersion.Major + 1), 0, 0)
        }
        if ($CurrentVersion.Build -eq 9) {
            $NewVersion = New-Object System.Version($CurrentVersion.Major, ($CurrentVersion.Minor + 1), 0)
        }
        else {
            $NewVersion = New-Object System.Version($CurrentVersion.Major, $CurrentVersion.Minor, ($CurrentVersion.Build + 1))
        }

        Write-Host "[INFO] : New Version: $NewVersion"
    }

    #Getting Public Functions to Export
    $PublicFunctions = Get-ChildItem -Path "$ModulePath/Public" -Recurse -Filter "*.ps1"
    
    #Creating Module Manifest
    $Params = @{
        Author            = "daoradmin"
        CompanyName       = "daoradmin"
        Description       = "Powershell Module for Azure Runtime Environment"
        ModuleVersion     = $NewVersion
        PowerShellVersion = "7.2"
        Path              = "$ModulePath/$Name.psd1"
        FunctionsToExport = $PublicFunctions | Select-Object -ExpandProperty BaseName
        ProjectUri        = "https://github.com/daoradmin/$Name"
        LicenseUri        = "https://github.com/daoradmin/$Name/blob/master/LICENSE.txt"
        Tags              = @("PSMODULE", "$Name")
        RootModule        = "$Name.psm1"
    }
    
    # Creating Module Manifest
    New-ModuleManifest @Params
    
    # Creating module file
    New-Item -Path "$ModulePath/$Name.psm1" -ItemType File -Force | Out-Null
    
    $AllFunctions = @()
    $AllFunctions += (Get-ChildItem -Path "$ModulePath/Private" -Recurse -Filter "*.ps1")
    $AllFunctions += $PublicFunctions
    
    foreach ($Function in $AllFunctions) {
        $Content = Get-Content -Path $Function.ResolvedTarget
        #Adding content to OuraRing.psm1 file
        Add-Content -Path "$ModulePath/$Name.psm1" -Value $Content
    }

    Write-Host "[INFO] : Module $Name has been created successfully"
}
catch {
    $_
}