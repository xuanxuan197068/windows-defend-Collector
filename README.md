# <center>脚本集说明文档</center>
## 1、分类建模


## 2、脚本集

1. **Get-ACLonPath.ps1**
	
	功能描述：检查指定文件或路径的 ACL（DACL/SACL），输出 icacls 与 Get-Acl 审计信息，便于权限与审计配置审查。

	收集目的：评估对象访问控制是否满足最小权限，识别过宽权限与审计配置缺口。

	调用方法：`.\Get-ACLonPath.ps1 -Path <filename|path>`

    参数说明：
    
	+ filename|path定义了将要读取ACL的文件夹或者文件
***

2. **Get-AuditPolicy.ps1**

	功能描述：获取系统审计策略（使用 auditpol），列出各审计类别与子项的当前配置，便于取证与合规检查。

	收集目的：判断审计覆盖面是否满足合规/取证要求，发现未启用的关键审计项。

	调用方法：`.\Get-AuditPolicy.ps1`

***


3. **Get-BitLockerStatus.ps1**

	功能描述：查询 BitLocker 卷的加密与保护状态（优先使用 Get-BitLockerVolume，失败时回退到 manage-bde 输出）。

	收集目的：确认数据盘加密与保护器配置，评估数据泄露风险与合规性。

	调用方法：`.\Get-BitLockerStatus.ps1 [A-Z:]`

    参数说明：
    
	+ A-Z:定义了将要查询bitlocker状态的盘符。

***


4. **Get-CertificateStores.ps1**

	功能描述：列出本地计算机证书存储（例如 Root/CA/TrustedPeople），显示主题、指纹与到期时间，便于信任链核查。

	收集目的：审核受信任证书/根证书，发现可疑或过期证书，降低中间人攻击与信任链风险。

	调用方法：`.\Get-CertificateStores.ps1`

***


5. **Get-EventsLog.ps1**

	功能描述：导出指定事件日志（Application/System/Security 等）的最新若干条记录，便于快速审阅近期事件。

	收集目的：回溯关键系统/安全事件，为问题定位、取证与异常分析提供证据链。

	调用方法：`.\Get-EventsLog.ps1 <LogName> <Count>`

    参数说明：
    
	+ LogName定义了将要收集的日志的分类。
    
	+ Count定义了将要收集日志的件数。

***


6. **Get-FirewallRules.ps1**

	功能描述：列出本机防火墙规则（优先使用 PowerShell NetSecurity 模块，失败时回退到 netsh 输出）。

	收集目的：盘点入/出站策略，识别过度放行或异常规则，评估边界防护有效性与暴露面。

	调用方法：`.\Get-FirewallRules.ps1`

***


7. **Get-GPOs.ps1**

	功能描述：列出域/本地的 GPO，并可生成 HTML 报告（Get-GPO/Get-GPOReport，或使用 gpresult 回退）。

	收集目的：清点生效及链接策略、输出差异，支撑基线核对、变更审计与合规检查。

	调用方法：`.\Get-GPOs.ps1 [-GpoReportPath <path>] [-GpResultHtmlPath <path>]`

    参数说明：
    
	+ -GpoReportPath path定义了生成gporeport文件的路径。
    
	+ -GpResultHtmlPath path定义了生成GpResult文件的路径。
    
	***补充：该脚本路径需要是绝对路径。***

***


8. **Get-InstalledPatches.ps1**

	功能描述：列出已安装补丁（优先 Get-HotFix，失败时用 DISM 或 WMIC 回退）。

	收集目的：核查补丁合规与缺口，评估已知漏洞暴露面与修复及时性。

	调用方法：`.\Get-InstalledPatches.ps1`

***


9. **Get-LAPSSettings.ps1**

	功能描述：读取 Windows LAPS / AdmPwd 的相关注册表策略键，检查 LAPS 是否配置，同时使用wevtutil来查询相关日志。

	收集目的：确认本地管理员口令轮换是否启用及策略强度，降低口令复用与横向移动风险。

	调用方法：`.\Get-LAPSSettings.ps1`

***


10. **Get-LocalUserAccounts.ps1**

	功能描述：获取本地用户账号详情（优先 Get-LocalUser，失败时回退到 net user / ADSI）。

	收集目的：发现异常或高风险本地账户（禁用、过期、空口令等），辅助最小化账户面。

	调用方法：`.\Get-LocalUserAccounts.ps1`

***


11. **Get-PasswordPolicy.ps1**

	功能描述：获取密码策略（Domain 或 Local 范围），包含 net accounts、secedit 导出等信息。

	收集目的：校验密码复杂度/历史/锁定等参数是否满足基线与合规要求。

	调用方法：`.\Get-PasswordPolicy.ps1 -Scope <Domain|Local>`

    参数说明：
    
	+ -Scope定义了你将要收集本地密码策略还是域密码策略。

***


12. **Get-ServicesSecurity.ps1**

	功能描述：列出系统服务及其配置/状态（使用 Win32_Service / Get-CimInstance）。

	收集目的：识别高权限或异常启动类型服务，评估持久化手段与横向移动潜在风险。

	调用方法：`.\Get-ServicesSecurity.ps1`

***


13. **Get-UACSettings.ps1**

	功能描述：读取 UAC / Policies\System 下的常用设置项（如 EnableLUA、ConsentPromptBehavior* 等）。

	收集目的：判断提权交互与安全阈值是否被弱化，降低绕过 UAC 的风险。

	调用方法：`.\Get-UACSettings.ps1`

***


14. **Get-UpdateLog.ps1**

	功能描述：导出/生成 Windows Update 日志（调用 Get-WindowsUpdateLog 并保存到指定路径）。

	收集目的：支持对更新失败/补丁安装问题的溯源与排障，定位失败阶段与原因。

	调用方法：`.\Get-UpdateLog.ps1 [<path\filename>]`

    参数说明：
    
	+ path\filename 定义了Get-WindowsUpdateLog命令输出文件的所在路径。

***


15. **Get-WindowsDefenderStatus.ps1**

	功能描述：收集 Windows Defender 状态与偏好设置（Get-MpComputerStatus / Get-MpPreference / 注册表读取）。

	收集目的：审核防护引擎状态、签名、排除项与策略偏好，确认防护有效性与潜在误配。

	调用方法：`.\Get-WindowsDefenderStatus.ps1`

***


16. **Get-WindowsUpdateRegistry.ps1**

	功能描述：读取与 Windows Update / AU 相关的注册表路径并可输出，便于自动化分析。

	收集目的：核对更新通道、延期与强制策略等关键项，评估补丁及时性与策略一致性。

	调用方法：`.\Get-WindowsUpdateRegistry.ps1`

***


17. **Get-LAPSOperationalLogs.ps1**

	功能描述：读取 Windows LAPS 操作事件日志通道（Microsoft-Windows-LAPS/Operational），按时间倒序获取最近指定条数并以文本格式输出。

	收集目的：审计与排查 LAPS 部署/口令轮换/检索等事件，定位失败原因并验证策略生效情况。

	调用方法：`.\Get-LAPSOperationalLogs.ps1 [-Count <n>]`

    参数说明：
    
	+ -Count 定义了读取的最新日志条数，默认 50（倒序）。

***

## 3、开发计划
+ 主程序采用python开发，对采集的数据进行进一步处理。同时，可以实现进度条和断点功能。
