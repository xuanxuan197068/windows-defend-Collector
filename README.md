# <center>脚本集说明文档</center>
## 1、分类建模


## 2、脚本集
1. **Get-ACLonPath.ps1**
	说明：检查指定文件或路径的 ACL（DACL/SACL），输出 icacls 与 Get-Acl 审计信息，便于权限与审计配置审查。
	调用方法：`.\Get-ACLonPath.ps1 -Path <filename|path>`

2. **Get-AuditPolicy.ps1**
	说明：获取系统审计策略（使用 auditpol），列出各审计类别与子项的当前配置，便于取证与合规检查。
	调用方法：`.\Get-AuditPolicy.ps1`

3. **Get-BitLockerStatus.ps1**
	说明：查询 BitLocker 卷的加密与保护状态（优先使用 Get-BitLockerVolume，失败时回退到 manage-bde 输出）。
	调用方法：`.\Get-BitLockerStatus.ps1 [A-Z:]`

4. **Get-CertificateStores.ps1**
	说明：列出本地计算机证书存储（例如 Root/CA/TrustedPeople），显示主题、指纹与到期时间，便于信任链核查。
	调用方法：`.\Get-CertificateStores.ps1`

5. **Get-EventsLog.ps1**
	说明：导出指定事件日志（Application/System/Security 等）的最新若干条记录，便于快速审阅近期事件。
	调用方法：`.\Get-EventsLog.ps1 <LogName> <Count>`

6. **Get-FirewallRules.ps1**
	说明：列出本机防火墙规则（优先使用 PowerShell NetSecurity 模块，失败时回退到 netsh 输出）。
	调用方法：`.\Get-FirewallRules.ps1`
7. **Get-GPOs.ps1**
	说明：列出域/本地的 GPO，并可生成 HTML 报告（Get-GPO/Get-GPOReport，或使用 gpresult 回退）。
	调用方法：`.\Get-GPOs.ps1 [-GpoReportPath <path>] [-GpResultHtmlPath <path>]`
    ***补充：该脚本路径需要是绝对路径。***

8. **Get-InstalledPatches.ps1**
	说明：列出已安装补丁（优先 Get-HotFix，失败时用 DISM 或 WMIC 回退）。
	调用方法：`.\Get-InstalledPatches.ps1`

9. **Get-LAPSSettings.ps1**
	说明：读取 Windows LAPS / AdmPwd 的相关注册表策略键，检查 LAPS 是否配置。
	调用方法：`.\Get-LAPSSettings.ps1`

10. **Get-LocalUserAccounts.ps1**
	说明：获取本地用户账号详情（优先 Get-LocalUser，失败时回退到 net user / ADSI）。
	调用方法：`.\Get-LocalUserAccounts.ps1`

11. **Get-PasswordPolicy.ps1**
	说明：获取密码策略（Domain 或 Local 范围），包含 net accounts、secedit 导出等信息。
	调用方法：`.\Get-PasswordPolicy.ps1 -Scope <Domain|Local>`

12. **Get-ServicesSecurity.ps1**
	说明：列出系统服务及其配置/状态（使用 Win32_Service / Get-CimInstance）。
	调用方法：`.\Get-ServicesSecurity.ps1`

13. **Get-UACSettings.ps1**
	说明：读取 UAC / Policies\System 下的常用设置项（如 EnableLUA、ConsentPromptBehavior* 等）。
	调用方法：`.\Get-UACSettings.ps1`

14. **Get-UpdateLog.ps1**
	说明：导出/生成 Windows Update 日志（调用 Get-WindowsUpdateLog 并保存到指定路径）。
	调用方法：`.\Get-UpdateLog.ps1 [<path\filename>]`

15. **Get-WindowsDefenderStatus.ps1**
	说明：收集 Windows Defender 状态与偏好设置（Get-MpComputerStatus / Get-MpPreference / 注册表读取）。
	调用方法：`.\Get-WindowsDefenderStatus.ps1`

16. **Get-WindowsUpdateRegistry.ps1**
	说明：读取与 Windows Update / AU 相关的注册表路径并可输出，便于自动化分析。
	调用方法：`.\Get-WindowsUpdateRegistry.ps1`
