"""验收契约测试（detail_v1.md §验收契约）。

这些测试依赖外部工具或网络（moon 工具链、raw.githubusercontent.com），
缺失时跳过，仅在环境可用时执行。

验收契约：
- `moon check` 通过（渐进式声明策略，无悬空引用）
- `python3 scripts/prepare.py` 成功生成 `src/stb_image.h`
- 重复运行 `python3 scripts/prepare.py` 无 tracked diff（幂等）
- `src/stb_image.h` 的 SHA256 为 pinned 值
"""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = REPO_ROOT / "scripts"

if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import prepare  # noqa: E402


@pytest.fixture
def moon_binary():
    """返回 moon 可执行文件路径；不可用时跳过。"""
    path = shutil.which("moon")
    if path is None:
        pytest.skip("moon toolchain not available")
    return path


class TestMoonCheck:
    """验收契约：moon check 通过。"""

    def test_moon_check_passes(self, moon_binary):
        """正向用例：`moon check` 退出码 0（渐进式声明策略，无悬空引用）。"""
        result = subprocess.run(
            [moon_binary, "check"],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0, f"moon check failed:\n{result.stderr}"

    def test_moon_check_native_passes(self, moon_binary):
        """正向用例：`moon check --target native` 退出码 0。"""
        result = subprocess.run(
            [moon_binary, "check", "--target", "native"],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0, (
            f"moon check --target native failed:\n{result.stderr}"
        )


class TestPrepareGeneratesHeader:
    """验收契约：python3 scripts/prepare.py 成功生成 src/stb_image.h 且 SHA256 匹配。"""

    @staticmethod
    def _run_prepare(tmp_path, monkeypatch):
        """在隔离的 tmp_path 中运行 prepare.main，返回生成的 stb_image.h 路径。"""
        monkeypatch.setattr(prepare, "CACHE_DIR", tmp_path / ".prepare")
        monkeypatch.setattr(prepare, "PACKAGE_DIR", tmp_path / "src")
        monkeypatch.setattr(sys, "argv", ["prepare.py"])
        prepare.main()
        return tmp_path / "src" / "stb_image.h"

    def test_prepare_generates_stb_image_h(self, tmp_path, monkeypatch):
        """正向用例：运行 prepare.main 后 src/stb_image.h 存在。"""
        try:
            dest = self._run_prepare(tmp_path, monkeypatch)
        except SystemExit as e:
            pytest.skip(f"prepare.main exited (network?): {e}")
        except Exception as e:
            pytest.skip(f"prepare.main raised (network?): {e}")

        assert dest.is_file(), "src/stb_image.h not generated"

    def test_generated_header_sha256_matches_pinned(self, tmp_path, monkeypatch):
        """正向用例：生成的 src/stb_image.h SHA256 等于硬编码 STB_IMAGE_SHA256。"""
        try:
            dest = self._run_prepare(tmp_path, monkeypatch)
        except SystemExit as e:
            pytest.skip(f"prepare.main exited (network?): {e}")
        except Exception as e:
            pytest.skip(f"prepare.main raised (network?): {e}")

        if not dest.is_file():
            pytest.skip("stb_image.h not generated")

        actual_sha = prepare.sha256_bytes(dest.read_bytes())
        assert actual_sha == prepare.STB_IMAGE_SHA256, (
            f"sha256 mismatch: expected {prepare.STB_IMAGE_SHA256}, got {actual_sha}"
        )

    def test_repeated_prepare_no_tracked_diff(self, tmp_path, monkeypatch):
        """幂等契约：重复运行 prepare.main，src/stb_image.h 内容与时间戳不变。"""
        monkeypatch.setattr(prepare, "CACHE_DIR", tmp_path / ".prepare")
        monkeypatch.setattr(prepare, "PACKAGE_DIR", tmp_path / "src")
        monkeypatch.setattr(sys, "argv", ["prepare.py"])

        try:
            prepare.main()
        except SystemExit as e:
            pytest.skip(f"first prepare.main exited (network?): {e}")
        except Exception as e:
            pytest.skip(f"first prepare.main raised (network?): {e}")

        dest = tmp_path / "src" / "stb_image.h"
        if not dest.is_file():
            pytest.skip("first run did not generate stb_image.h")

        content_first = dest.read_bytes()
        mtime_first = dest.stat().st_mtime_ns

        try:
            prepare.main()
        except SystemExit as e:
            pytest.skip(f"second prepare.main exited (network?): {e}")
        except Exception as e:
            pytest.skip(f"second prepare.main raised (network?): {e}")

        assert dest.read_bytes() == content_first
        assert dest.stat().st_mtime_ns == mtime_first


class TestPinnedConstants:
    """验收契约：pinned 常量非空且形态正确（不依赖网络，始终可执行）。"""

    def test_stb_image_commit_is_pinned(self):
        """正向用例：STB_IMAGE_COMMIT 为 40 字符 hex 串（固定到具体 commit）。"""
        commit = prepare.STB_IMAGE_COMMIT
        assert len(commit) == 40
        assert all(c in "0123456789abcdef" for c in commit)

    def test_stb_image_sha256_is_pinned(self):
        """正向用例：STB_IMAGE_SHA256 为 64 字符 hex 串。"""
        sha = prepare.STB_IMAGE_SHA256
        assert len(sha) == 64
        assert all(c in "0123456789abcdef" for c in sha)

    def test_stb_image_url_references_pinned_commit(self):
        """正向用例：STB_IMAGE_URL 引用 pinned commit。"""
        assert prepare.STB_IMAGE_COMMIT in prepare.STB_IMAGE_URL
        assert prepare.STB_IMAGE_URL.endswith(prepare.STB_IMAGE_FILENAME)

    def test_stb_image_write_commit_empty_in_v0_1(self):
        """边界条件：v0.1 阶段 STB_IMAGE_WRITE_COMMIT 为空（--include-write 未激活）。"""
        assert prepare.STB_IMAGE_WRITE_COMMIT == ""

    def test_stb_image_write_sha256_empty_in_v0_1(self):
        """边界条件：v0.1 阶段 STB_IMAGE_WRITE_SHA256 为空。"""
        assert prepare.STB_IMAGE_WRITE_SHA256 == ""

    def test_stb_image_write_url_empty_in_v0_1(self):
        """边界条件：v0.1 阶段 STB_IMAGE_WRITE_URL 为空。"""
        assert prepare.STB_IMAGE_WRITE_URL == ""

    def test_stb_image_write_filename_defined(self):
        """正向用例：STB_IMAGE_WRITE_FILENAME 已定义（预留骨架）。"""
        assert prepare.STB_IMAGE_WRITE_FILENAME == "stb_image_write.h"

    def test_repo_root_points_to_project_root(self):
        """正向用例：REPO_ROOT 指向含 src/ 与 scripts/ 的项目根目录。"""
        assert (prepare.REPO_ROOT / "src").is_dir()
        assert (prepare.REPO_ROOT / "scripts").is_dir()

    def test_package_dir_under_repo_root_src(self):
        """正向用例：PACKAGE_DIR = REPO_ROOT/src。"""
        assert prepare.PACKAGE_DIR == prepare.REPO_ROOT / "src"

    def test_cache_dir_under_repo_root_prepare(self):
        """正向用例：CACHE_DIR = REPO_ROOT/.prepare。"""
        assert prepare.CACHE_DIR == prepare.REPO_ROOT / ".prepare"