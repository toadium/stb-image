# 使用说明与提示

> 从 README 提取的详细提示、约束与版本说明。

## 版本与安装

> [!NOTE]
> 包版本 `0.4.10`（mooncakes，要求 0.x.y 格式）对应功能迭代版本 `v4.8.0`。安装：`moon add walkzzz/image`。

## 格式检测

> [!NOTE]
> `detect_format` 仅通过 magic bytes 识别 PNG/JPEG/BMP/GIF/QOI/PNM/PSD/HDR/WebP。TIFF/ICO/CUR/ICNS/APNG/TGA 需手动调用 `decode_tiff`/`decode_ico`/`decode_cur`/`decode_icns`/`decode_apng` 等函数。

## 多目标测试

> [!NOTE]
> 四目标（native / wasm-gc / js / wasm）均使用同一套纯 MoonBit 代码，各 1177 测试全部通过，覆盖率 90.4%。

> [!TIP]
> 四目标共用 `src/pure/` 下的同一套代码，无任何条件编译或目标分支。

## 版本更新摘要

> [!TIP]
> **v4.8 最新更新** — WebP lossy (VP8) 编码 · PNG/TIFF 整数溢出安全修复 · 44 项 fuzzing 安全审计 · 22 项错误路径测试 · 性能基准报告（31 项基准）

## 核心约束

> [!WARNING]
> 以下约束不可违反，否则 PR 将被拒绝：

- **禁止引入 C FFI 依赖** — 所有代码必须纯 MoonBit 实现，确保四目标可用
- **禁止破坏已有 API** — 新增功能只添加不修改已有签名，保持向后兼容
- **禁止目标条件编译** — 不使用 `target == "native"` 等条件分支，四目标共用代码
- **新增 `pub` 函数须在 `reexport.mbt` 注册** — 保持顶层 API 完整性
