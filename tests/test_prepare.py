"""基于行为契约的单元测试 for scripts/prepare.py。

验证公开接口行为，不测实现细节。
契约来源：detail_v1.md §prepare.py 行为契约

覆盖维度：
- 正常路径：sha256_bytes、download_to_cache、write_if_changed、vendor_single_header、main
- 边界条件：空字节、缓存命中、内容相同、父目录缺失
- 错误路径：SHA256 不匹配、--include-write 未激活
- 状态交互：幂等契约（重复运行无 tracked diff）、缓存复用
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

# 将 scripts/ 加入 sys.path 以导入 prepare 模块
SCRIPTS_DIR = Path(__file__).resolve().parents[1] / "scripts"
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import prepare  # noqa: E402


# ---------- sha256_bytes 契约 ----------


class TestSha256Bytes:
    """契约：返回 data 的 SHA256 十六进制摘要（小写）。"""

    def test_returns_lowercase_hex_for_known_input(self):
        """正向用例：已知输入返回小写十六进制摘要。"""
        # "hello" 的 SHA256 标准向量
        assert prepare.sha256_bytes(b"hello") == (
            "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
        )

    def test_empty_bytes_known_vector(self):
        """边界条件：空字节返回空串 SHA256 标准向量。"""
        assert prepare.sha256_bytes(b"") == (
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        )

    def test_deterministic_same_input_same_output(self):
        """状态交互：相同输入产生相同输出（确定性）。"""
        assert prepare.sha256_bytes(b"data") == prepare.sha256_bytes(b"data")

    def test_different_input_different_output(self):
        """正向用例：不同输入产生不同输出。"""
        assert prepare.sha256_bytes(b"a") != prepare.sha256_bytes(b"b")

    def test_returns_hex_length_64(self):
        """边界条件：返回值为 64 字符的十六进制串。"""
        digest = prepare.sha256_bytes(b"any")
        assert len(digest) == 64
        assert all(c in "0123456789abcdef" for c in digest)


# ---------- write_if_changed 契约 ----------


class TestWriteIfChanged:
    """契约：仅当目标文件不存在或内容不同时写入，避免时间戳变化产生 tracked diff。"""

    def test_new_file_writes_and_returns_true(self, tmp_path):
        """正向用例：path 不存在时写入并返回 True。"""
        target = tmp_path / "new.txt"
        assert prepare.write_if_changed(target, b"content") is True
        assert target.read_bytes() == b"content"

    def test_content_differs_writes_and_returns_true(self, tmp_path):
        """正向用例：path 存在但内容不同时写入并返回 True。"""
        target = tmp_path / "file.txt"
        target.write_bytes(b"old")
        assert prepare.write_if_changed(target, b"new") is True
        assert target.read_bytes() == b"new"

    def test_content_same_no_write_returns_false(self, tmp_path):
        """幂等契约：path 存在且内容相同时不写入，返回 False。"""
        target = tmp_path / "file.txt"
        target.write_bytes(b"same")
        mtime_before = target.stat().st_mtime_ns
        assert prepare.write_if_changed(target, b"same") is False
        assert target.read_bytes() == b"same"
        # 时间戳不变（无 tracked diff 契约）
        assert target.stat().st_mtime_ns == mtime_before

    def test_creates_parent_dir(self, tmp_path):
        """边界条件：父目录不存在时自动创建。"""
        target = tmp_path / "nested" / "deep" / "file.txt"
        assert prepare.write_if_changed(target, b"x") is True
        assert target.read_bytes() == b"x"

    def test_idempotent_second_call_preserves_timestamp(self, tmp_path):
        """状态交互：连续两次调用，第二次不修改文件时间戳。"""
        target = tmp_path / "idem.txt"
        prepare.write_if_changed(target, b"payload")
        mtime_first = target.stat().st_mtime_ns

        result = prepare.write_if_changed(target, b"payload")

        assert result is False
        assert target.stat().st_mtime_ns == mtime_first


# ---------- download_to_cache 契约 ----------


def _fake_urlopen(payload: bytes):
    """构造返回固定 payload 的 urlopen 替身。"""

    class FakeResp:
        def __enter__(self):
            return self

        def __exit__(self, *args):
            return False

        def read(self):
            return payload

    return lambda url: FakeResp()


class TestDownloadToCache:
    """契约：下载 → SHA256 校验 → 缓存；失败非零退出，不自动回退。"""

    def test_happy_path_downloads_and_caches(self, tmp_path, monkeypatch):
        """正向用例：成功下载、校验、写入缓存、返回内容。"""
        payload = b"#ifndef STBI_INCLUDE_STB_IMAGE_H\n"
        expected_sha = prepare.sha256_bytes(payload)
        monkeypatch.setattr(prepare.urllib.request, "urlopen", _fake_urlopen(payload))

        cache_dir = tmp_path / ".prepare"
        data = prepare.download_to_cache(
            "https://example.com/x.h", expected_sha, cache_dir, "x.h"
        )

        assert data == payload
        assert (cache_dir / "x.h").read_bytes() == payload

    def test_cache_hit_skips_download(self, tmp_path, monkeypatch):
        """状态交互：缓存已存在且 SHA256 匹配时不下载，直接返回缓存内容。"""
        payload = b"cached content"
        expected_sha = prepare.sha256_bytes(payload)
        cache_dir = tmp_path / ".prepare"
        cache_dir.mkdir()
        (cache_dir / "x.h").write_bytes(payload)

        def fail_urlopen(*args, **kwargs):
            raise AssertionError("urlopen should not be called on cache hit")

        monkeypatch.setattr(prepare.urllib.request, "urlopen", fail_urlopen)

        data = prepare.download_to_cache(
            "https://example.com/x.h", expected_sha, cache_dir, "x.h"
        )
        assert data == payload

    def test_sha256_mismatch_raises_systemexit(self, tmp_path, monkeypatch):
        """错误路径：SHA256 不匹配时 raise SystemExit，不自动回退。"""
        payload = b"tampered"
        monkeypatch.setattr(prepare.urllib.request, "urlopen", _fake_urlopen(payload))

        with pytest.raises(SystemExit) as exc_info:
            prepare.download_to_cache(
                "https://example.com/x.h",
                "0" * 64,
                tmp_path / ".prepare",
                "x.h",
            )
        assert "sha256 mismatch" in str(exc_info.value)

    def test_sha256_mismatch_does_not_write_cache(self, tmp_path, monkeypatch):
        """错误路径：SHA256 不匹配时不写入缓存文件（不自动回退）。"""
        payload = b"tampered"
        monkeypatch.setattr(prepare.urllib.request, "urlopen", _fake_urlopen(payload))
        cache_dir = tmp_path / ".prepare"

        with pytest.raises(SystemExit):
            prepare.download_to_cache(
                "https://example.com/x.h",
                "0" * 64,
                cache_dir,
                "x.h",
            )
        assert not (cache_dir / "x.h").exists()

    def test_creates_cache_dir_if_missing(self, tmp_path, monkeypatch):
        """边界条件：缓存目录不存在时自动创建。"""
        payload = b"x"
        expected_sha = prepare.sha256_bytes(payload)
        monkeypatch.setattr(prepare.urllib.request, "urlopen", _fake_urlopen(payload))

        cache_dir = tmp_path / "nested" / ".prepare"
        prepare.download_to_cache(
            "https://example.com/x.h", expected_sha, cache_dir, "x.h"
        )
        assert cache_dir.is_dir()


# ---------- vendor_single_header 契约 ----------


class TestVendorSingleHeader:
    """契约：下载 → 校验 → 幂等写入到 package_dir/filename，打印日志。"""

    def test_writes_to_package_dir_and_logs(self, tmp_path, monkeypatch, capsys):
        """正向用例：完整流程写入 package_dir/filename，日志含 filename 与 commit。"""
        payload = b"// header"
        expected_sha = prepare.sha256_bytes(payload)
        monkeypatch.setattr(prepare.urllib.request, "urlopen", _fake_urlopen(payload))

        cache_dir = tmp_path / ".prepare"
        package_dir = tmp_path / "src"
        prepare.vendor_single_header(
            "https://example.com/repo/abc123/file.h",
            expected_sha,
            "file.h",
            cache_dir,
            package_dir,
        )

        assert (package_dir / "file.h").read_bytes() == payload
        captured = capsys.readouterr()
        assert "file.h" in captured.out
        assert "abc123" in captured.out

    def test_idempotent_second_call_marks_unchanged(self, tmp_path, monkeypatch, capsys):
        """幂等契约：第二次调用不写入，日志标记 unchanged，时间戳不变。"""
        payload = b"// header"
        expected_sha = prepare.sha256_bytes(payload)
        monkeypatch.setattr(prepare.urllib.request, "urlopen", _fake_urlopen(payload))

        cache_dir = tmp_path / ".prepare"
        package_dir = tmp_path / "src"
        url = "https://example.com/repo/abc123/file.h"

        prepare.vendor_single_header(url, expected_sha, "file.h", cache_dir, package_dir)
        capsys.readouterr()  # 清空首次输出

        dest = package_dir / "file.h"
        mtime_before = dest.stat().st_mtime_ns

        prepare.vendor_single_header(url, expected_sha, "file.h", cache_dir, package_dir)
        captured = capsys.readouterr()

        assert "unchanged" in captured.out
        assert dest.stat().st_mtime_ns == mtime_before

    def test_sha256_mismatch_propagates_systemexit(
        self, tmp_path, monkeypatch, capsys
    ):
        """错误路径：上游 SHA256 不匹配时 vendor 流程 raise SystemExit。"""
        payload = b"bad upstream"
        monkeypatch.setattr(prepare.urllib.request, "urlopen", _fake_urlopen(payload))

        with pytest.raises(SystemExit):
            prepare.vendor_single_header(
                "https://example.com/repo/abc123/file.h",
                "0" * 64,
                "file.h",
                tmp_path / ".prepare",
                tmp_path / "src",
            )
        assert not (tmp_path / "src" / "file.h").exists()


# ---------- main 契约 ----------


def _patch_paths(monkeypatch, tmp_path):
    """将 prepare 的路径常量重定向到 tmp_path，避免污染源码树。"""
    monkeypatch.setattr(prepare, "CACHE_DIR", tmp_path / ".prepare")
    monkeypatch.setattr(prepare, "PACKAGE_DIR", tmp_path / "src")


class TestMain:
    """契约：--include-write 未激活时 raise SystemExit；不带参数仅 vendoring stb_image.h。"""

    def test_without_include_write_vendors_stb_image_h(
        self, tmp_path, monkeypatch, capsys
    ):
        """正向用例：不带参数时仅 vendoring stb_image.h，退出码 0。"""
        payload = b"// stb_image.h content"
        monkeypatch.setattr(prepare.urllib.request, "urlopen", _fake_urlopen(payload))
        monkeypatch.setattr(prepare, "STB_IMAGE_SHA256", prepare.sha256_bytes(payload))
        _patch_paths(monkeypatch, tmp_path)
        monkeypatch.setattr(sys, "argv", ["prepare.py"])

        prepare.main()  # 不应抛出

        assert (tmp_path / "src" / "stb_image.h").read_bytes() == payload
        captured = capsys.readouterr()
        assert "stb_image.h" in captured.out
        # 不应触碰 stb_image_write.h
        assert not (tmp_path / "src" / "stb_image_write.h").exists()

    def test_with_include_write_raises_systemexit_when_not_activated(
        self, tmp_path, monkeypatch
    ):
        """错误路径：带 --include-write（本任务阶段）raise SystemExit 提示待 v0.2。"""
        payload = b"// stb_image.h content"
        monkeypatch.setattr(prepare.urllib.request, "urlopen", _fake_urlopen(payload))
        monkeypatch.setattr(prepare, "STB_IMAGE_SHA256", prepare.sha256_bytes(payload))
        _patch_paths(monkeypatch, tmp_path)
        monkeypatch.setattr(sys, "argv", ["prepare.py", "--include-write"])

        with pytest.raises(SystemExit) as exc_info:
            prepare.main()
        msg = str(exc_info.value)
        assert "v0.2" in msg or "--include-write" in msg

    def test_with_include_write_activated_vendors_both_headers(
        self, tmp_path, monkeypatch, capsys
    ):
        """状态交互：v0.2 激活后（STB_IMAGE_WRITE_COMMIT 非空）额外 vendoring stb_image_write.h。"""
        payload_read = b"// stb_image.h"
        payload_write = b"// stb_image_write.h"
        calls = iter([payload_read, payload_write])

        class FakeResp:
            def __enter__(self):
                return self

            def __exit__(self, *args):
                return False

            def read(self):
                return next(calls)

        monkeypatch.setattr(prepare.urllib.request, "urlopen", lambda url: FakeResp())
        monkeypatch.setattr(prepare, "STB_IMAGE_SHA256", prepare.sha256_bytes(payload_read))
        monkeypatch.setattr(
            prepare, "STB_IMAGE_WRITE_SHA256", prepare.sha256_bytes(payload_write)
        )
        monkeypatch.setattr(prepare, "STB_IMAGE_WRITE_COMMIT", "deadbeef")
        monkeypatch.setattr(
            prepare,
            "STB_IMAGE_WRITE_URL",
            "https://example.com/repo/deadbeef/stb_image_write.h",
        )
        _patch_paths(monkeypatch, tmp_path)
        monkeypatch.setattr(sys, "argv", ["prepare.py", "--include-write"])

        prepare.main()

        assert (tmp_path / "src" / "stb_image.h").read_bytes() == payload_read
        assert (tmp_path / "src" / "stb_image_write.h").read_bytes() == payload_write
        captured = capsys.readouterr()
        assert "stb_image.h" in captured.out
        assert "stb_image_write.h" in captured.out


# ---------- 幂等契约（main 端到端） ----------


class TestMainIdempotent:
    """契约：重复运行 python3 scripts/prepare.py，src/stb_image.h 内容不变且时间戳不变。"""

    def test_repeated_main_no_tracked_diff(self, tmp_path, monkeypatch, capsys):
        """状态交互：连续两次 main 调用，第二次内容与时间戳均不变。"""
        payload = b"// stb_image.h content"
        monkeypatch.setattr(prepare.urllib.request, "urlopen", _fake_urlopen(payload))
        monkeypatch.setattr(prepare, "STB_IMAGE_SHA256", prepare.sha256_bytes(payload))
        _patch_paths(monkeypatch, tmp_path)
        monkeypatch.setattr(sys, "argv", ["prepare.py"])

        prepare.main()
        capsys.readouterr()

        dest = tmp_path / "src" / "stb_image.h"
        content_first = dest.read_bytes()
        mtime_first = dest.stat().st_mtime_ns

        prepare.main()
        captured = capsys.readouterr()

        assert dest.read_bytes() == content_first
        assert dest.stat().st_mtime_ns == mtime_first
        assert "unchanged" in captured.out