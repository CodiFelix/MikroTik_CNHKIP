#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
将 ipprefix.txt 中的 IP 地址和掩码统一转换为
"x.x.x.x 255.255.255.x" 点分十进制格式，
结果保存到 ipmask.txt。

支持的输入格式（每行一条，混合出现均可）：
  1. CIDR 前缀长度  ：192.168.1.0/24
  2. 斜杠点分掩码  ：192.168.1.0/255.255.255.0
  3. 空格分隔掩码  ：192.168.1.0 255.255.255.0
  4. 制表符分隔    ：192.168.1.0\t255.255.255.0
  5. 带主机位的CIDR：192.168.1.100/24  → 192.168.1.100 255.255.255.0
"""

import ipaddress
import re
from pathlib import Path

INPUT_FILE  = Path("ipprefix.txt")
OUTPUT_FILE = Path("ipmask.txt")

# 匹配 "IP 掩码"（空格或制表符分隔）
_RE_IP_MASK = re.compile(
    r'^(\d{1,3}(?:\.\d{1,3}){3})'   # IP 地址
    r'[\s\t]+'                        # 分隔符
    r'(\d{1,3}(?:\.\d{1,3}){3})$'   # 掩码（点分十进制）
)


def convert_line(s: str) -> str | None:
    """
    尝试将一行解析为 IPv4 地址+掩码，返回
    "x.x.x.x 255.255.255.x" 格式；无法识别则返回 None。
    """
    s = s.strip()

    # ── 情况 1 / 2：含斜杠（CIDR 或 斜杠点分掩码）──────────────────
    if "/" in s:
        ip_part, mask_part = s.split("/", 1)
        ip_part  = ip_part.strip()
        mask_part = mask_part.strip()

        # 把掩码部分统一成前缀长度，再构造网络对象
        try:
            prefix = int(mask_part)  # 已经是数字前缀
        except ValueError:
            # 是点分掩码，转成前缀长度
            try:
                prefix = ipaddress.IPv4Network(f"0.0.0.0/{mask_part}").prefixlen
            except ValueError:
                return None

        try:
            ip_obj  = ipaddress.IPv4Address(ip_part)
            netmask = ipaddress.IPv4Network(f"0.0.0.0/{prefix}").netmask
        except ValueError:
            return None

        return f"{ip_obj} space {netmask}"

    # ── 情况 3 / 4：空格或 Tab 分隔 ────────────────────────────────
    m = _RE_IP_MASK.match(s)
    if m:
        ip_part, mask_part = m.group(1), m.group(2)
        try:
            ip_obj   = ipaddress.IPv4Address(ip_part)
            # 验证掩码合法性（必须是连续 1 块）
            netmask  = ipaddress.IPv4Address(mask_part)
            # 借助 ip_network 做合法性校验
            ipaddress.IPv4Network(f"0.0.0.0/{mask_part}")
        except ValueError:
            return None
        return f"{ip_obj} space {netmask}"

    return None


def main() -> None:
    if not INPUT_FILE.exists():
        raise SystemExit(f"找不到输入文件：{INPUT_FILE.resolve()}")

    lines    = INPUT_FILE.read_text(encoding="utf-8", errors="ignore").splitlines()
    out_lines: list[str] = []
    converted_count = 0
    skipped_count   = 0

    for line in lines:
        raw = line.rstrip("\n")
        s   = raw.strip()

        # 空行 / 注释行 → 原样保留
        if s == "" or s.startswith(("#", ";", "//")):
            out_lines.append(raw)
            continue

        result = convert_line(s)
        if result is not None:
            out_lines.append(result)
            converted_count += 1
        else:
            # 无法识别的行原样保留，并加注释提示
            out_lines.append(raw)
            skipped_count += 1

    OUTPUT_FILE.write_text("\n".join(out_lines) + "\n", encoding="utf-8")

    print(f"完成！")
    print(f"  输入文件  : {INPUT_FILE.resolve()}")
    print(f"  输出文件  : {OUTPUT_FILE.resolve()}")
    print(f"  成功转换  : {converted_count} 行")
    print(f"  无法识别  : {skipped_count} 行（已原样保留）")


if __name__ == "__main__":
    main()