# A simple PowerShell script

# Display a welcome message
Write-Output "Welcome to the PowerShell script!"

# Get the current date and time
$currentDateTime = Get-Date
Write-Output "Current Date and Time: $currentDateTime"

# List all files in the current directory
Write-Output "Files in the current directory:"
Get-ChildItem -Path . -File

# End of script
Write-Output "Script execution completed."