# 🚀 Azure Runtime Environment PowerShell Module

## Overview
This PowerShell module provides cmdlets to manage Azure Automation Account Runtime Environments, enabling users to automate the management tasks conveniently. With this module, you can perform various operations such as creating, retrieving, updating, and removing Runtime Environments within your Azure environment.

## Commands

### :mag_right: Get-AzRuntimeEnvironment
- **Brief Description**: Retrieves details of a specific Azure Automation Account Runtime Environment.
- **Detailed Description**: This command allows users to fetch information about a particular Runtime Environment within an Azure Automation Account. Users can use this command to get details such as name, status, version, and other relevant metadata associated with the specified Runtime Environment.

### :file_folder: Get-AzRuntimeEnvironments 
- **Brief Description**: Retrieves a list of all Azure Automation Account Runtime Environments.
- **Detailed Description**: This command provides users with a comprehensive list of all Runtime Environments available within the specified Azure Automation Account. It returns essential information about each Runtime Environment, enabling users to view and manage multiple environments efficiently.

### 📦 Get-AzRuntimeEnvironmentPackages
- **Brief Description**: Retrieves a list of packages associated with a specific Azure Automation Account Runtime Environment.
- **Detailed Description**: This command allows users to fetch a list of all packages associated with a particular Runtime Environment in an Azure Automation Account. The command returns information about each package, including the package name, version, and other relevant metadata, which helps in managing the runtime environment's dependencies.

### :rocket: New-AzRuntimeEnvironment
- **Brief Description**: Creates a new Azure Automation Account Runtime Environment.
- **Detailed Description**: With this command, users can instantiate a new Runtime Environment within their Azure Automation Account. Users can specify parameters such as name, version, and other configuration settings to tailor the new environment according to their requirements.

### :x: Remove-AzRuntimeEnvironment
- **Brief Description**: Deletes a specified Azure Automation Account Runtime Environment.
- **Detailed Description**: This command enables users to remove an existing Runtime Environment from their Azure Automation Account. Users need to provide the name or ID of the Runtime Environment they wish to delete, and the command takes care of the deletion process, including any associated resources.

### 📦 Set-AzRuntimeEnvironmentPackage
- **Brief Description**: Updates the package associated with a specific Azure Automation Account Runtime Environment.
- **Detailed Description**: This command facilitates the update of the package associated with a particular Runtime Environment within an Azure Automation Account. Users can upload a new package, specify versioning information, and configure other relevant settings to ensure smooth operation of the Runtime Environment with the updated package.

## Example Usages
- **Get-AzRuntimeEnvironment:**
  ```powershell
  Get-AzRuntimeEnvironment -SubscriptionId "XXX" -ResourceGroupName "RG-Test" -AutomationAccountName "AA-Test" -RuntimeEnvironmentName "Custom-PS"
  ```
- **Get-AzRuntimeEnvironments:**
  ```powershell
  Get-AzRuntimeEnvironments -SubscriptionId "XXX" -ResourceGroupName "RG-Test" -AutomationAccountName "AA-Test"
  ```
- **Get-AzRuntimeEnvironmentPackages:**
  ```powershell
  Get-AzRuntimeEnvironmentPackages -SubscriptionId "XXX" -ResourceGroupName "RG-Test" -AutomationAccountName "AA-Test" -RuntimeEnvironmentName "Custom-PS"
  ```
- **New-AzRuntimeEnvironment:**
  ```powershell
  New-AzRuntimeEnvironment -SubscriptionId "XXX" -ResourceGroupName "RG-Test" -AutomationAccountName "AA-Test" -RuntimeEnvironmentName "Custom-PS" -Location "westeurope" -Language Powershell -Version 7.2
  ```
- **Remove-AzRuntimeEnvironment:**
  ```powershell
  Remove-AzRuntimeEnvironment -SubscriptionId "XXX" -ResourceGroupName "RG-Test" -AutomationAccountName "AA-Test" -RuntimeEnvironmentName "Custom-PS"
  ```
- **Set-AzRuntimeEnvironmentPackage:**
  ```powershell
  Set-AzRuntimeEnvironmentPackage -SubscriptionId "XXX" -ResourceGroupName "RG-Test" -AutomationAccountName "AA-Test" -RuntimeEnvironmentName "Custom-PS" -PackageName "CustomPSModule" -ContentLink "XXX"
  ```
