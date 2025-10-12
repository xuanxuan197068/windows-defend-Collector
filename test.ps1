# 一个简单的 PowerShell 脚本

# 显示欢迎信息
Write-Output "Welcome to the PowerShell script!"

# 获取当前日期和时间
$currentDateTime = Get-Date
Write-Output "Current Date and Time: $currentDateTime"

# 列出当前目录中的所有文件
Write-Output "Files in the current directory:"
Get-ChildItem -Path . -File

# 脚本结束
Write-Output "Script execution completed."