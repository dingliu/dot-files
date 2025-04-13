# This is the PowerShell profile script that runs every time a new PowerShell session is started.
# It sets up the environment for PowerShell, including loading modules and configuring the prompt.

########################################################################
# History search
########################################################################
# Partial command history search
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Initialize oh-my-posh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/negligible.omp.json" | Invoke-Expression
