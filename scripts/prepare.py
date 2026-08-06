#!/usr/bin/env python3
"""Vendoring script for stb-image MoonBit package.

Downloads pinned stb_image.h from upstream, verifies SHA256, and writes
idempotently into src/. Run `python3 scripts/prepare.py` to vendor.
"""

from __future__ import annotations

import argparse
import hashlib
import urllib.request
from pathlib import Path

# 上游 stb_image.h 版本固定（架构设计 D5 + 技术方案 §4.2）
# commit 013ac3beddff3dbffafd5177e7972067cd2b5083 对应 stb_image v2.30（2024-05-31）
# commit message: "stb_image: fix gcc bounds-check warning (believed erroneous)"
STB_IMAGE_COMMIT = "013ac3beddff3dbffafd5177e7972067cd2b5083"
STB_IMAGE_SHA256 = "594c2fe35d49488b4382dbfaec8f98366defca819d916ac95becf3e75f4200b3"
STB_IMAGE_URL = f"https://raw.githubusercontent.com/nothings/stb/{STB_IMAGE_COMMIT}/stb_image.h"
STB_IMAGE_FILENAME = "stb_image.h"

# stb_image_write.h v1.16（与 stb_image.h 同一 commit，v0.2 激活）
STB_IMAGE_WRITE_COMMIT = "013ac3beddff3dbffafd5177e7972067cd2b5083"
STB_IMAGE_WRITE_SHA256 = "cbd5f0ad7a9cf4468affb36354a1d2338034f2c12473cf1a8e32053cb6914a05"
STB_IMAGE_WRITE_URL = f"https://raw.githubusercontent.com/nothings/stb/{STB_IMAGE_WRITE_COMMIT}/stb_image_write.h"
STB_IMAGE_WRITE_FILENAME = "stb_image_write.h"

# 路径常量
REPO_ROOT = Path(__file__).resolve().parents[1]
PACKAGE_DIR = REPO_ROOT / "src"
CACHE_DIR = REPO_ROOT / ".prepare"


def sha256_bytes(data: bytes) -> str:
    """返回 data 的 SHA256 十六进制摘要（小写）。"""
    return hashlib.sha256(data).hexdigest()


def download_to_cache(
    url: str,
    expected_sha256: str,
    cache_dir: Path,
    filename: str,
) -> bytes:
    """
    下载 url 内容到 cache_dir/filename，校验 SHA256 与 expected_sha256 匹配。
    若缓存文件已存在且 SHA256 匹配，直接读取返回（避免重复下载）。
    SHA256 不匹配时 raise SystemExit（非零退出，不自动回退）。
    返回下载的字节内容。
    """
    cache_dir.mkdir(parents=True, exist_ok=True)
    cache_path = cache_dir / filename
    if cache_path.exists():
        cached = cache_path.read_bytes()
        if sha256_bytes(cached) == expected_sha256:
            return cached
    with urllib.request.urlopen(url) as resp:
        data = resp.read()
    actual = sha256_bytes(data)
    if actual != expected_sha256:
        raise SystemExit(
            f"sha256 mismatch for {filename}: expected {expected_sha256}, got {actual}"
        )
    cache_path.write_bytes(data)
    return data


def write_if_changed(path: Path, data: bytes) -> bool:
    """
    若 path 不存在或现有内容与 data 不同，则写入 data 并返回 True。
    否则不写入（保持时间戳不变），返回 False。
    父目录不存在时自动创建。
    """
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.read_bytes() == data:
        return False
    path.write_bytes(data)
    return True


def vendor_single_header(
    url: str,
    expected_sha256: str,
    filename: str,
    cache_dir: Path,
    package_dir: Path,
) -> None:
    """
    vendoring 单个头文件的完整流程：
    1. 调用 download_to_cache 下载并校验 SHA256
    2. 调用 write_if_changed 幂等写入到 package_dir/filename
    3. 打印 vendoring 结果日志（filename + commit + 是否更新）
    """
    data = download_to_cache(url, expected_sha256, cache_dir, filename)
    dest = package_dir / filename
    updated = write_if_changed(dest, data)
    commit = url.rsplit("/", 2)[-2]
    status = "updated" if updated else "unchanged"
    print(f"vendored {filename} @ {commit} ({status})")


def main() -> None:
    """
    入口函数：
    1. 用 argparse 解析命令行参数：
       - `--include-write`：可选 flag，带此参数时额外 vendoring stb_image_write.h
    2. 调用 vendor_single_header vendoring stb_image.h
    3. 若 args.include_write 为 True：
       - 若 STB_IMAGE_WRITE_COMMIT 为空字符串，raise SystemExit（提示"--include-write 尚未激活，待 v0.2 填入 stb_image_write.h 的 commit hash + SHA256"）
       - 否则调用 vendor_single_header vendoring stb_image_write.h
    """
    parser = argparse.ArgumentParser(
        description="Vendor pinned stb_image.h (and optionally stb_image_write.h) into src/"
    )
    parser.add_argument(
        "--include-write",
        action="store_true",
        help="additionally vendor stb_image_write.h (not yet activated, reserved for v0.2)",
    )
    args = parser.parse_args()

    vendor_single_header(
        STB_IMAGE_URL,
        STB_IMAGE_SHA256,
        STB_IMAGE_FILENAME,
        CACHE_DIR,
        PACKAGE_DIR,
    )

    if args.include_write:
        if STB_IMAGE_WRITE_COMMIT == "":
            raise SystemExit(
                "--include-write 尚未激活，待 v0.2 填入 stb_image_write.h 的 commit hash + SHA256"
            )
        vendor_single_header(
            STB_IMAGE_WRITE_URL,
            STB_IMAGE_WRITE_SHA256,
            STB_IMAGE_WRITE_FILENAME,
            CACHE_DIR,
            PACKAGE_DIR,
        )


if __name__ == "__main__":
    main()