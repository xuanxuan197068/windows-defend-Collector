import subprocess
import sys
from pathlib import Path
from typing import List, Dict, Any, Optional


# ===== 1. 基本配置 =====
# 你可以改成绝对路径，例如：
# SCRIPT_PATH = Path(r"C:\Scripts\Get-GPOs.ps1")
SCRIPT_PATH = Path(__file__).parent / "Get-GPOs.ps1"
POWERSHELL = "powershell"  # 如果用 PowerShell 7，可以改成 "pwsh"
print(SCRIPT_PATH)

# ===== 2. 调用 PowerShell 脚本 =====
def run_powershell_script(script_path: Path, extra_args: Optional[List[str]] = None) -> str:
    """
    调用 PowerShell 脚本，返回 stdout 文本（UTF-8）
    """
    if extra_args is None:
        extra_args = []

    cmd = [
        POWERSHELL,
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", str(script_path)
    ] + extra_args

    try:
        completed = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            timeout=120,
        )
    except FileNotFoundError:
        print(f"[ERROR] 找不到 PowerShell 可执行文件: {POWERSHELL}", file=sys.stderr)
        sys.exit(1)
    except subprocess.TimeoutExpired as e:
        print(f"[ERROR] 脚本执行超时: {str(e)}", file=sys.stderr)
        sys.exit(1)

    if completed.stderr:
        # 注意：这里不会中断，只是打印一下 stderr，真正的错误以 RETURN_CODE 为准
        print("[PS STDERR]", file=sys.stderr)
        print(completed.stderr, file=sys.stderr)

    return completed.stdout


# ===== 3. 解析脚本输出 =====
def parse_script_output(output: str) -> Dict[str, Any]:
    """
    解析脚本输出：

    输入示例：
        ---Attempt: Get-GPO -All (GroupPolicy module)---
        <很多行...>

        ---Get-GPOReport -All -ReportType Html -Path "C:\\AllGPOs1.html"---
        [INFO] GPO HTML report generated: C:\\AllGPOs1.html
        ...
        RETURN_CODE=0

    返回结构：
    {
        "sections": [
            {
                "header": "Attempt: Get-GPO -All (GroupPolicy module)",
                "command": "Get-GPO -All (GroupPolicy module)",   # 可选解析
                "lines": ["Id : 31b2...", "DisplayName : ...", ...]
            },
            {
                "header": "Get-GPOReport -All -ReportType Html -Path \"C:\\AllGPOs1.html\"",
                "command": "Get-GPOReport -All -ReportType Html -Path \"C:\\AllGPOs1.html\"",
                "lines": ["[INFO] GPO HTML report generated: C:\\AllGPOs1.html"]
            },
            ...
        ],
        "return_code": 0,      # 若找不到则为 None
        "raw": "<原始完整输出>"
    }
    """
    lines = output.splitlines()
    sections: List[Dict[str, Any]] = []

    current_header: Optional[str] = None
    current_lines: List[str] = []
    return_code: Optional[int] = None

    def flush_section():
        """收尾当前 section"""
        nonlocal current_header, current_lines, sections
        if current_header is None and not current_lines:
            return
        header = current_header or "GLOBAL"
        header_stripped = header.strip()
        # 如果有 "Attempt: xxx" 的格式，提取后面的命令部分
        if header_stripped.lower().startswith("attempt:"):
            command = header_stripped.split(":", 1)[1].strip()
        else:
            command = header_stripped

        sections.append({
            "header": header_stripped,
            "command": command,
            "lines": current_lines[:],  # 拷贝一份
        })
        current_header = None
        current_lines = []

    for raw_line in lines:
        line = raw_line.rstrip("\n")
        stripped = line.strip()

        # 空行：保留在当前 section 里
        if stripped == "":
            current_lines.append(line)
            continue

        # RETURN_CODE=... 行
        if stripped.startswith("RETURN_CODE="):
            # 收尾最后一个 section
            flush_section()
            rc_str = stripped.split("=", 1)[1].strip()
            try:
                return_code = int(rc_str)
            except ValueError:
                # 解析失败也保留原字符串
                return_code = None
            continue

        # ---...--- 分割行
        if stripped.startswith("---") and stripped.endswith("---") and len(stripped) >= 6:
            # 先把前一个 section 收尾
            flush_section()
            # 去掉两端的 --- 和空格
            inner = stripped.strip("-").strip()
            current_header = inner
            current_lines = []
            continue

        # 普通内容行
        if current_header is None:
            # 没有 header 的情况也允许存在，归为 GLOBAL
            current_header = "GLOBAL"
        current_lines.append(line)

    # 结束循环后，可能还有最后一个 section
    flush_section()

    return {
        "sections": sections,
        "return_code": return_code,
        "raw": output,
    }


# ===== 4. Demo：主函数 =====
def main():
    if not SCRIPT_PATH.exists():
        print(f"[ERROR] 找不到脚本: {SCRIPT_PATH}", file=sys.stderr)
        sys.exit(1)

    print(f"[INFO] 正在运行脚本: {SCRIPT_PATH}")
    output = run_powershell_script(SCRIPT_PATH)

    # 解析输出
    parsed = parse_script_output(output)

    # 简单打印解析结果示例：你可以改成写入 JSON / DB / 发送到别的系统
    print("============== PARSED RESULT ==============")
    print(f"RETURN_CODE: {parsed['return_code']}")
    print(f"共解析到 {len(parsed['sections'])} 个防御策略区域\n")

    for idx, sec in enumerate(parsed["sections"], start=1):
        print(f"[SECTION {idx}] {sec['header']}")
        print(f"  关联命令: {sec['command']}")
        print("  内容预览:")
        # 只展示前几行，避免太长
        preview_lines = sec["lines"][:8]
        for pl in preview_lines:
            print("    " + pl)
        if len(sec["lines"]) > len(preview_lines):
            print(f"    ... (共 {len(sec['lines'])} 行)")
        print()

    # 如果你后面要用结构化结果：
    # 比如只拿 GPO 那一段：
    # gpo_sections = [s for s in parsed["sections"] if "Get-GPO" in s["command"]]
    # ...


if __name__ == "__main__":
    main()
