#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# sensitive_data_scanner.py: 在指定目录中扫描敏感数据（PII）。
# 该脚本用于检测中国手机号码、身份证号码和电子邮件地址。

import os
import regex as re
import argparse

# 定义用于匹配敏感信息的正则表达式。
# 这些模式是为匹配特定格式而设计的。
PII_PATTERNS = {
    "CHINESE_MOBILE": re.compile(r"1[3-9]\d{9}"),
    "CHINESE_ID": re.compile(r"\d{17}(\d|X|x)"),
    "EMAIL": re.compile(r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"),
}

def scan_file_for_pii(filepath):
    # 此函数打开并读取单个文件，逐行扫描PII。
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            # 逐行读取文件以避免加载大文件到内存中。
            for line_num, line in enumerate(f, 1):
                # 检查每种类型的PII模式。
                for pii_type, pattern in PII_PATTERNS.items():
                    # 在行中查找所有匹配项。
                    matches = pattern.findall(line)
                    for match in matches:
                        # 如果找到匹配项，打印详细信息。
                        print(f"⚠️  发现敏感数据! "
                              f"文件: {filepath}, "
                              f"行: {line_num}, "
                              f"类型: {pii_type}, "
                              f"内容: {match}")
    except (IOError, OSError) as e:
        # 处理读取文件时可能发生的错误。
        print(f"❌ 无法读取文件 {filepath}: {e}")

def main(directory):
    # 主函数，用于遍历指定目录中的所有文件和子目录。
    print(f"🔍 开始扫描目录: {directory}")

    # os.walk会递归地遍历目录树。
    for root, _, files in os.walk(directory):
        for filename in files:
            # 构建完整的文件路径。
            filepath = os.path.join(root, filename)
            # 对每个文件执行扫描。
            scan_file_for_pii(filepath)

    print("✅ 扫描完成。")

if __name__ == "__main__":
    # 使用argparse来处理命令行参数。
    # 这使得脚本更易于从命令行使用。
    parser = argparse.ArgumentParser(
        description="在目录中扫描敏感数据 (PII)。",
        epilog="例如: python3 sensitive_data_scanner.py /data"
    )
    # 定义要扫描的目录参数。
    parser.add_argument(
        "directory",
        nargs='?',
        default="/data",
        help="要扫描的目录路径 (默认为: /data)"
    )

    args = parser.parse_args()

    # 检查目标目录是否存在。
    if not os.path.isdir(args.directory):
        print(f"❌ 错误: 目录不存在 -> {args.directory}")
        exit(1)

    # 调用主函数开始扫描。
    main(args.directory)
