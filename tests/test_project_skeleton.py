"""基于行为契约的单元测试 for 项目骨架配置文件。

验证公开接口行为，不测实现细节。
契约来源：detail_v1.md §moon.mod 行为契约、§moon.pkg 行为契约、§.gitignore 行为契约

这些测试只读取配置文件并断言其结构契约，不修改源文件。
"""

from __future__ import annotations

import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]


# ---------- moon.mod 契约 ----------


class TestMoonMod:
    """契约：preferred_target="native"，不设 readme，不设模块级 supported_targets。"""

    @staticmethod
    def _read_moon_mod() -> str:
        return (REPO_ROOT / "moon.mod").read_text(encoding="utf-8")

    def test_preferred_target_is_native(self):
        """正向用例：preferred_target = "native"，moon/LSP 默认使用 native 后端。"""
        text = self._read_moon_mod()
        assert re.search(r'^preferred_target\s*=\s*"native"\s*$', text, re.MULTILINE)

    def test_no_readme_line(self):
        """边界条件：不设 readme 行，避免指向不存在的 src/README.mbt.md。"""
        text = self._read_moon_mod()
        assert not re.search(r'^readme\s*=', text, re.MULTILINE)

    def test_no_module_level_supported_targets(self):
        """边界条件：不设模块级 supported_targets，让包级 src/moon.pkg 的声明生效。"""
        text = self._read_moon_mod()
        assert not re.search(r'^supported_targets\s*=', text, re.MULTILINE)

    def test_has_name_field(self):
        """正向用例：存在 name 字段。"""
        text = self._read_moon_mod()
        assert re.search(r'^name\s*=\s*"', text, re.MULTILINE)

    def test_has_version_field(self):
        """正向用例：存在 version 字段。"""
        text = self._read_moon_mod()
        assert re.search(r'^version\s*=\s*"', text, re.MULTILINE)

    def test_has_license_field(self):
        """正向用例：存在 license 字段。"""
        text = self._read_moon_mod()
        assert re.search(r'^license\s*=\s*"', text, re.MULTILINE)

    def test_has_description_field(self):
        """正向用例：存在 description 字段。"""
        text = self._read_moon_mod()
        assert re.search(r'^description\s*=', text, re.MULTILINE)

    def test_has_keywords_field(self):
        """正向用例：存在 keywords 字段。"""
        text = self._read_moon_mod()
        assert re.search(r'^keywords\s*=', text, re.MULTILINE)


# ---------- moon.pkg 契约 ----------


class TestMoonPkg:
    """契约：supported_targets = "native"，不声明 options(...) 块。"""

    @staticmethod
    def _read_moon_pkg() -> str:
        return (REPO_ROOT / "src" / "moon.pkg").read_text(encoding="utf-8")

    def test_supported_targets_is_native(self):
        """正向用例：包级排他性声明仅支持 native 后端。"""
        text = self._read_moon_pkg()
        assert re.search(r'^supported_targets\s*=\s*"native"\s*$', text, re.MULTILINE)

    def test_no_options_block(self):
        """边界条件：不声明 options(...) 块，避免悬空引用不存在的 wrapper.c/ffi.mbt 等。"""
        text = self._read_moon_pkg()
        assert "options" not in text

    def test_no_native_stub_reference(self):
        """边界条件：不引用 native-stub（wrapper.c 尚未创建）。"""
        text = self._read_moon_pkg()
        assert "native-stub" not in text

    def test_no_targets_block(self):
        """边界条件：options 块内不声明 targets 子键（无 .mbt 文件需按后端分流）。"""
        text = self._read_moon_pkg()
        # targets 作为 options 子键形如 `targets:` 或 `targets =`
        assert not re.search(r'\btargets\s*[:=]', text)


# ---------- .gitignore 契约 ----------


class TestGitignore:
    """契约：忽略 .prepare/、target/、.mooncakes/。"""

    @staticmethod
    def _read_gitignore_lines() -> list[str]:
        return (REPO_ROOT / ".gitignore").read_text(encoding="utf-8").splitlines()

    def test_ignores_prepare_cache(self):
        """正向用例：.prepare/（vendoring 脚本缓存目录）被忽略。"""
        assert ".prepare/" in self._read_gitignore_lines()

    def test_ignores_target_dir(self):
        """正向用例：target/（MoonBit 构建产物目录）被忽略。"""
        assert "target/" in self._read_gitignore_lines()

    def test_ignores_mooncakes_cache(self):
        """正向用例：.mooncakes/（mooncakes 依赖缓存）被忽略。"""
        assert ".mooncakes/" in self._read_gitignore_lines()