# 详细设计（v1）

## 概述

本设计为 stb-image 项目的 **R1：Vendoring 层 + 项目骨架** 任务的具体实现规格。范围包括：

1. 项目模块配置 `moon.mod`（MoonBit v0.10.5 新 DSL 语法）
2. 包配置 `src/moon.pkg`（新 DSL 语法，渐进式声明策略）
3. vendoring 脚本 `scripts/prepare.py`（下载 pinned stb_image.h + SHA256 校验 + 幂等 + 预留 `--include-write`）
4. vendored 上游头文件 `src/stb_image.h`（由运行脚本生成，stb_image v2.30）
5. `.gitignore`（忽略缓存目录与构建产物）

本任务不涉及任何 MoonBit 源码（`.mbt`）、C 源码（`.c`）、FFI 声明、类型定义或测试代码，仅搭建项目骨架与 vendoring 基础设施。后续任务（R2/R3/R4）在此基础上渐进追加 FFI 边界层、安全 API 层、测试与文档层。

设计依据：需求文档 §二 MVP 范围、架构设计 §3.5 Vendoring 脚本职责、技术方案 §2.1 工具链版本、§2.2 目标后端策略、§2.3 stb_image.h Vendoring 策略、§3.1 文件布局、§3.2 moon.mod 配置、§3.3 moon.pkg 配置、§4 Vendoring 方案。

## 文件规划

| 文件路径 | 操作 | 职责 |
|---------|------|------|
| `moon.mod` | 新建 | 模块配置（新 DSL）：name、version、preferred_target="native"、license、description、keywords；不设 readme 行、不设模块级 supported_targets |
| `src/moon.pkg` | 新建 | 包配置（新 DSL）：仅 `supported_targets = "native"`；不声明 `options(...)` 块（渐进式声明，避免悬空引用） |
| `scripts/prepare.py` | 新建 | vendoring 脚本：下载 pinned stb_image.h + SHA256 校验 + 幂等写入 + 预留 `--include-write` 参数骨架 |
| `src/stb_image.h` | 新建（由运行 `python3 scripts/prepare.py` 生成） | vendored 上游头文件，stb_image v2.30，commit `013ac3beddff3dbffafd5177e7972067cd2b5083`（2024-05-31） |
| `.gitignore` | 新建 | 忽略 `.prepare/`（vendoring 缓存）、`target/`（MoonBit 构建产物）、`.mooncakes/`（依赖缓存） |

## 类型定义

本任务无 MoonBit 类型定义。以下为 `scripts/prepare.py` 的 Python 模块结构与函数签名设计（精确到可直接编码）。

### prepare.py 模块常量

**形态**：Python 模块级常量
**职责**：固定 vendoring 目标版本与校验哈希

```python
# 上游 stb_image.h 版本固定（架构设计 D5 + 技术方案 §4.2）
# commit 013ac3beddff3dbffafd5177e7972067cd2b5083 对应 stb_image v2.30（2024-05-31）
# commit message: "stb_image: fix gcc bounds-check warning (believed erroneous)"
STB_IMAGE_COMMIT = "013ac3beddff3dbffafd5177e7972067cd2b5083"
STB_IMAGE_SHA256 = "594c2fe35d49488b4382dbfaec8f98366defca819d916ac95becf3e75f4200b3"
STB_IMAGE_URL = f"https://raw.githubusercontent.com/nothings/stb/{STB_IMAGE_COMMIT}/stb_image.h"
STB_IMAGE_FILENAME = "stb_image.h"

# stb_image_write.h 预留（v0.2 激活，本任务仅预留参数骨架，不实际下载）
# v0.2 纳入时填入具体 commit hash + SHA256
STB_IMAGE_WRITE_COMMIT = ""  # 待 v0.2 填入
STB_IMAGE_WRITE_SHA256 = ""  # 待 v0.2 填入
STB_IMAGE_WRITE_URL = ""     # 待 v0.2 填入
STB_IMAGE_WRITE_FILENAME = "stb_image_write.h"

# 路径常量
REPO_ROOT = Path(__file__).resolve().parents[1]
PACKAGE_DIR = REPO_ROOT / "src"
CACHE_DIR = REPO_ROOT / ".prepare"
```

### sha256_bytes

**形态**：Python 模块级函数
**职责**：计算字节序列的 SHA256 十六进制摘要

```python
def sha256_bytes(data: bytes) -> str:
    """返回 data 的 SHA256 十六进制摘要（小写）。"""
```

**公开接口**：`sha256_bytes(data: bytes) -> str`
**构造方式**：模块级函数，直接调用
**类型关系**：无

### download_to_cache

**形态**：Python 模块级函数
**职责**：从 URL 下载内容到缓存目录，校验 SHA256，返回下载的字节内容

```python
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
```

**公开接口**：`download_to_cache(url, expected_sha256, cache_dir, filename) -> bytes`
**构造方式**：模块级函数，直接调用
**类型关系**：无

### write_if_changed

**形态**：Python 模块级函数
**职责**：幂等写入——仅当目标文件不存在或内容不同时写入，避免时间戳变化产生 tracked diff

```python
def write_if_changed(path: Path, data: bytes) -> bool:
    """
    若 path 不存在或现有内容与 data 不同，则写入 data 并返回 True。
    否则不写入（保持时间戳不变），返回 False。
    父目录不存在时自动创建。
    """
```

**公开接口**：`write_if_changed(path, data) -> bool`
**构造方式**：模块级函数，直接调用
**类型关系**：无

### vendor_single_header

**形态**：Python 模块级函数
**职责**：vendoring 单个头文件的完整流程：下载 → 校验 → 幂等写入到 `src/`

```python
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
```

**公开接口**：`vendor_single_header(url, expected_sha256, filename, cache_dir, package_dir) -> None`
**构造方式**：模块级函数，直接调用
**类型关系**：调用 `download_to_cache` 与 `write_if_changed`

### main

**形态**：Python 模块级函数（入口）
**职责**：解析命令行参数，分发 vendoring 任务

```python
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
```

**公开接口**：`main() -> None`
**构造方式**：`if __name__ == "__main__": main()`
**类型关系**：调用 `vendor_single_header`

## 错误处理

### prepare.py 错误处理策略

- **SHA256 不匹配**：`raise SystemExit(f"sha256 mismatch for {filename}: expected {expected_sha256}, got {actual}")`，非零退出，**不自动回退**到其他版本（架构设计 §3.5、技术方案 §4.1）
- **下载失败**：`urllib.request` 抛异常自然传播，Python 以非零退出码终止
- **`--include-write` 未激活时带参数**：`raise SystemExit("--include-write 尚未激活，待 v0.2 填入 stb_image_write.h 的 commit hash + SHA256")`，非零退出，提示维护者
- **缓存目录创建失败**：`Path.mkdir(parents=True, exist_ok=True)` 异常自然传播
- **不使用 try-except 吞错**：所有失败路径均以非零退出终止，不静默继续

### moon.mod / moon.pkg 错误处理

本任务配置文件采用渐进式声明策略，无悬空引用，`moon check` 应通过。不涉及运行时错误处理。

## 行为契约

### prepare.py 行为契约

**前置条件**：
- Python 3 运行环境
- 网络可访问 `raw.githubusercontent.com`
- 对 `src/` 目录与 `.prepare/` 目录的读写权限

**后置条件（happy path）**：
- 运行 `python3 scripts/prepare.py` 后，`src/stb_image.h` 存在且内容为 commit `013ac3beddff3dbffafd5177e7972067cd2b5083` 的 stb_image.h，SHA256 为 `594c2fe35d49488b4382dbfaec8f98366defca819d916ac95becf3e75f4200b3`
- 退出码为 0

**幂等契约**：
- 重复运行 `python3 scripts/prepare.py`，`src/stb_image.h` 内容不变且文件时间戳不变（`write_if_changed` 仅当内容不同时写入），无 tracked diff
- 缓存目录 `.prepare/` 中的文件可重复利用（若 SHA256 匹配则不重复下载）

**SHA256 校验契约**：
- 下载内容 SHA256 与硬编码 `STB_IMAGE_SHA256` 匹配方可继续，否则非零退出
- 不存在"未回填跳过校验"的中间态——首次运行即对硬编码哈希严格校验

**`--include-write` 契约**：
- 不带参数：仅 vendoring `stb_image.h`，不触碰 `stb_image_write.h`
- 带参数（本任务阶段）：因 `STB_IMAGE_WRITE_COMMIT` 为空，非零退出并提示"待 v0.2 填入"
- 带参数（v0.2 激活后）：额外 vendoring `stb_image_write.h` 到 `src/stb_image_write.h`

**不自动回退契约**：
- 任何失败（下载失败、SHA256 不匹配）均非零退出，不尝试其他 commit 或版本

### moon.mod 行为契约

- `preferred_target = "native"`：`moon`/LSP 默认使用 native 后端
- 不设 `readme` 行：避免指向不存在的 `src/README.mbt.md`（后续任务 R4 创建该文件时再追加）
- 不设模块级 `supported_targets`：让包级 `src/moon.pkg` 的 `supported_targets = "native"` 生效

### moon.pkg 行为契约

- `supported_targets = "native"`：包级排他性声明仅支持 native 后端，与 `llvm.mbt/unsafe/moon.pkg` 先例一致
- 不声明 `options(...)` 块：本任务不创建 `wrapper.c`、`ffi.mbt`、`image_load_native.mbt`、`image_test.mbt`、`README.mbt.md`，若提前声明 `native-stub` 或 `targets` 引用这些不存在文件，`moon check` 将因悬空引用失败
- 后续任务渐进追加（合并到单一 `options(...)` 块）：
  - R2 创建 `wrapper.c` 时追加 `options("native-stub": ["wrapper.c"])`
  - R2 创建 `ffi.mbt` 时在 `options` 块追加 `targets: { "ffi.mbt": ["native"] }`
  - R3 创建 `image_load_native.mbt` 时追加对应 `targets` 条目
  - R4 创建 `image_test.mbt` 时追加对应 `targets` 条目
  - R4 创建 `README.mbt.md` 时追加对应 `targets` 条目，并在 `moon.mod` 追加 `readme = "README.mbt.md"` 行

### .gitignore 行为契约

- `.prepare/`：vendoring 脚本缓存目录，不应纳入版本控制
- `target/`：MoonBit 构建产物目录，不应纳入版本控制
- `.mooncakes/`：mooncakes 依赖缓存，不应纳入版本控制

### 验收契约

- `moon check` 通过（渐进式声明策略，无悬空引用）
- `python3 scripts/prepare.py` 成功生成 `src/stb_image.h`
- 重复运行 `python3 scripts/prepare.py` 无 tracked diff（幂等）
- `src/stb_image.h` 的 SHA256 为 `594c2fe35d49488b4382dbfaec8f98366defca819d916ac95becf3e75f4200b3`

## 依赖关系

### 本任务依赖

- **Python 3 标准库**：`hashlib`（SHA256）、`urllib.request`（下载）、`pathlib`（路径）、`argparse`（命令行参数）、`sys`（SystemExit）
- **无 MoonBit 依赖**：本任务无 `.mbt` 文件，不依赖任何 MoonBit 包
- **无第三方 Python 依赖**：仅用标准库，跨平台可移植

### 暴露给后续任务的公开接口

- **`src/stb_image.h`**：后续 R2 的 `src/wrapper.c` 通过 `#define STB_IMAGE_IMPLEMENTATION` + `#include "stb_image.h"` 纳入编译
- **`moon.mod`**：后续任务在 `readme` 行追加时覆写
- **`src/moon.pkg`**：后续任务在 `options(...)` 块渐进追加 `native-stub` 与 `targets` 条目时覆写
- **`scripts/prepare.py`**：后续 R4 可能扩展为生成 testdata；v0.2 激活 `--include-write` 时填入 `STB_IMAGE_WRITE_COMMIT` 与 `STB_IMAGE_WRITE_SHA256`
- **`.gitignore`**：后续任务可追加更多忽略项（如 `*.o`、`*.obj` 等构建中间产物）

### 与已有代码的关系

- **不引用** `image-mbt/`（参考实现，仅参考 DSL 语法，不引用其代码）
- **参考** `moonbit_wp/llvm.mbt/unsafe/moon.pkg` 的 `supported_targets = "native"` 配置先例
- **参考** `make-moonbit-c-bindings` skill 的 `templates/prepare.py` 结构（下载→校验→写入流程），适配单头文件库特性（无需扁平化、无需 include 重写、无需刷新 native-stub 列表）