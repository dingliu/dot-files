# =============================================================================
# This file is used to customize the PowerShell profile for Visual Studio Code.
#
# It is loaded when starting a new PowerShell session in VS Code.
#
# To use this file, create a symlink to it in your PowerShell profile path.
# For example, you can run the following command in PowerShell:
#    New-Item `
#        -ItemType SymbolicLink `
#        -Path "$([Environment]::GetFolderPath('MyDocuments'))\PowerShell\Microsoft.VSCode_profile.ps1" `
#        -Value <path to this file>
# =============================================================================

# Load the regular PowerShell profile for Visual Studio Code
. "$([Environment]::GetFolderPath('MyDocuments'))\PowerShell\Microsoft.PowerShell_profile.ps1"
