import subprocess
import sys
from pathlib import Path
from typing import List, Optional



#一个字典存储所有脚本的相对路径
SCRIPTS = {
    "bitlockerstatus": "Encryption/Get-BitLockerStatus.ps1",
    "certificatestores": "Encryption/Get-CertificateStores.ps1",
    "lapsoperationallogs": "Encryption/Get-LAPSOperationalLogs.ps1",
    "lapssettings": "Encryption/Get-LAPSSettings.ps1",
    "eventslog": "Log/Get-EventsLog.ps1",
    "firewallrules": "Protect-Update/Get-FirewallRules.ps1",
    "installedpatches": "Protect-Update/Get-InstalledPatches.ps1",
    "updatelog": "Protect-Update/Get-UpdateLog.ps1",
    "windowsdefenderstatus": "Protect-Update/Get-WindowsDefenderStatus.ps1",
    "windowsupdateregistry": "Protect-Update/Get-WindowsUpdateRegistry.ps1",
    "auditpolicy": "System-Audit/Get-AuditPolicy.ps1",
    "gpos": "System-Audit/Get-GPOs.ps1",
    "servicessecurity": "System-Audit/Get-ServicesSecurity.ps1",
    "aclonpath": "Users-Permissions/Get-ACLonPath.ps1",
    "localuseraccounts": "Users-Permissions/Get-LocalUserAccounts.ps1",
    "passwordpolicy": "Users-Permissions/Get-PasswordPolicy.ps1",
    "uacsettings": "Users-Permissions/Get-UACSettings.ps1",
}


# ===== 1. 基本配置 =====
if len(sys.argv) < 2:
    print("argv not enough")
    sys.exit(3)
elif SCRIPTS.get(sys.argv[1],0) == 0:
    print("argv invaild")
    sys.exit(4)
SCRIPT_BASE_DIR = Path(__file__).parent / "CollectPolicyScript"
SCRIPT_PATH = SCRIPT_BASE_DIR / SCRIPTS[sys.argv[1]]
POWERSHELL = "powershell"  # 如果用 PowerShell 7，可以改成 "pwsh"

# ===== 2. 调用 PowerShell 脚本 =====
def run_powershell_script(script_path: Path, extra_args: Optional[List[str]] = None) -> str:
    cmd = [
        POWERSHELL,
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", str(script_path),
    ]

    # 添加额外参数
    if extra_args:
        cmd.extend(extra_args)

    try:
        completed = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding="gbk",
        )
    except Exception as e:
        print(f"[ERROR] 调用 PowerShell 失败: {e}", file=sys.stderr)
        sys.exit(1)

    if completed.stderr:
        # 只打印一下 stderr，不做复杂处理
        print("=== PowerShell STDERR ===", file=sys.stderr)
        print(completed.stderr, file=sys.stderr)
        print("=========================", file=sys.stderr)

    return completed.stdout


# ===== 3. 解析脚本输出 =====
def parse_output(output_text: str):
    """
    按 ---...--- 分割区域，单独解析一次 RETURN_CODE。

    返回:
      sections: [ {"header": str, "lines": [str, ...]}, ... ]
      return_code: int 或 None
    """
    lines = output_text.splitlines()

    sections = []
    current_header = None
    current_lines = []
    return_code = None

    def flush_section():
        nonlocal current_header, current_lines
        # 没有 header 且没有内容，就不要创建空 section
        if current_header is None and not current_lines:
            return
        header = current_header or ""
        sections.append({
            "header": header,
            "lines": current_lines[:]
        })
        current_header = None
        current_lines = []

    for line in lines:
        stripped = line.strip()

        # 1) 处理 RETURN_CODE，只要解析一次，不加入任何 section
        if stripped.startswith("RETURN_CODE="):
            # 先把当前 section 收尾
            flush_section()
            code_str = stripped.split("=", 1)[1].strip()
            try:
                return_code = int(code_str)
            except ValueError:
                return_code = None
            # 不把这行加入 current_lines
            continue

        # 2) 处理 ---xxx--- 分隔行：开启一个新的 section
        if stripped.startswith("---") and stripped.endswith("---") and len(stripped) >= 6:
            flush_section()
            inner = stripped.strip("-").strip()
            current_header = inner  # 这里存 header 文本
            current_lines = []
            continue

        # 3) 普通内容行，直接加入当前 section 内容
        current_lines.append(line)

    # 处理最后一个 section
    flush_section()

    return sections, return_code


def main():
    if not Path(SCRIPT_PATH).exists():
        print(f"[ERROR] 找不到脚本: {SCRIPT_PATH}")
        sys.exit(1)

    script_extra_args = sys.argv[2:] if len(sys.argv) > 2 else None
    
    # 1. 调脚本拿到原始输出
    output = run_powershell_script(SCRIPT_PATH,script_extra_args)
    
    # 2. 解析输出
    sections, return_code = parse_output(output)
    #print(sections)

    # 3. 输出各个 section 内容（不包含 RETURN_CODE，不包含 command）
    print("===== 分割后的内容 =====")
    for i, sec in enumerate(sections, start=1):
        print(f"\n--- Section {i} ---")
        header = sec["header"] or "无"
        print(f"[HEADER] {header}")
        print("[CONTENT]")
        for ln in sec["lines"]:
            print(ln)

    # 4. 最后单独输出一次 RETURN_CODE
    print("\n===== RETURN_CODE =====")
    print(return_code)


if __name__ == "__main__":
    main()