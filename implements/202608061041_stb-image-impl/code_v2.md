# 实现报告（v2）

## 概述

实现 stb-image 项目 R2：FFI 边界层。新建 C wrapper `src/wrapper.c`（两个 `MOONBIT_FFI_EXPORT` 函数：`stb_image_mbt_load_from_memory` / `stb_image_mbt_load_from_path`，ABI 归一化 + 所有权转移 + 失败信号统一 + Windows UTF-8 路径支持 + NUL 结尾副本），新建 MoonBit 私有 FFI 声明 `src/ffi.mbt`（两个 `extern "c" fn` 声明，`#borrow` 标注、返回 `Bytes`），覆写 `src/moon.pkg`（追加单一 `options(...)` 块承载 `native-stub` 与 `targets` 门控）。

前置条件：`src/stb_image.h` 缺失，已运行 `python scripts/prepare.py` 生成（vendored @ `013ac3beddff3dbffafd5177e7972067cd2b5083`，v2.30）。

## 文件变更清单

| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 新建 | src/wrapper.c | C wrapper：两个 `MOONBIT_FFI_EXPORT` 函数，ABI 归一化 stbi_load/stbi_load_from_memory，所有权转移（memcpy 到 MoonBit Bytes + stbi_image_free），失败信号统一（NULL → 零长度 Bytes + 输出参数写 0），Windows UTF-8 路径支持（STBI_WINDOWS_UTF8），NUL 结尾副本（malloc + memcpy + free） |
| 新建 | src/ffi.mbt | MoonBit 私有 `extern "c" fn` 声明：`stb_image_mbt_load_from_memory` / `stb_image_mbt_load_from_path`，`#borrow` 标注输入 Bytes 与 Ref[Int]，返回 `Bytes`，显式指定 C 符号名 |
| 覆写 | src/moon.pkg | 保留 `supported_targets = "native"`，追加单一 `options(...)` 块：`"native-stub": ["wrapper.c"]` + `targets: { "ffi.mbt": ["native"] }` |
| 生成 | src/stb_image.h | 由 `python scripts/prepare.py` 生成（R1 vendoring 产物，本任务前置条件，非本任务编码产出） |

## 编译验证

- `moon check --target native`：**通过**（0 errors，2 warnings）
  - Warning (unused_value): `stb_image_mbt_load_from_memory` 未使用
  - Warning (unused_value): `stb_image_mbt_load_from_path` 未使用
  - 两个警告为预期行为：本任务 R2 仅声明 FFI 入口，调用者 R3 的 `image_load_native.mbt` 尚未创建。R3 落地后警告消除
- `moon info --target native`：**通过**，生成 `src/pkg.generated.mbti` 无公开 API（ffi.mbt 私有，符合验收契约）
- moon 版本：`0.1.20260713 (75c7e1f 2026-07-13)`，满足设计要求 `0.1.20260713+`

## 设计偏差说明

无偏差。实现严格按设计规格：

- **wrapper.c**：头文件包含顺序严格按设计 §"C wrapper 头文件包含顺序"（STBI_WINDOWS_UTF8 → STB_IMAGE_IMPLEMENTATION → stb_image.h → moonbit.h → string.h/stdlib.h）；两个函数签名、成功/失败路径、所有权转移、NUL 结尾副本构建均与设计 §"C wrapper 函数签名" 一致；`desired_channels=0` 传参；失败时主动写入 0 + 返回 `moonbit_make_bytes(0, 0)`；`path_cstr` 在 stbi_load 调用后无论成功失败均 free
- **ffi.mbt**：两个 `extern "c" fn` 签名、`#borrow` 标注位置（在 `extern "c" fn` 之前）、`///|` 分隔符、显式 C 符号名、小写 `extern "c"`、私有（不 `pub`）、返回 `Bytes`（非 `Bytes?`）均与设计 §"MoonBit extern 声明签名" 一致
- **moon.pkg**：`supported_targets = "native"` + 单一 `options(...)` 块承载 `native-stub` 与 `targets`，不门控未创建文件，与设计 §"moon.pkg 配置" 一致