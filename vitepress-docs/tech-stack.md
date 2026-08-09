# 技术栈

| 项目 | 详情 |
|------|------|
| 编程语言 | MoonBit（主）+ C（FFI wrapper） |
| MoonBit 目标 | native（首选，C FFI）+ wasm + js（纯 MoonBit 后端） |
| 构建工具 | `moon`（MoonBit 官方包管理器/构建工具） |
| C FFI 桥接 | `src/core/wrapper.c`（ABI 标准化）+ `native-stub` 配置 |
| 第三方头文件 | `stb_image.h` v2.30、`stb_image_write.h` v1.16、`stb_image_resize2.h` v2.07 |
| 标准库依赖 | `moonbitlang/core/bench`、`moonbitlang/core/debug`、`moonbitlang/core/math`、`moonbitlang/core/encoding/utf8` |
| 内存管理 | C 侧 `stbi_malloc` → `memcpy` 到 MoonBit `Bytes` → 立即 `stbi_image_free` |
| 验证工具 | AddressSanitizer（ASan），脚本 `scripts/run-asan.py` |

## 子包依赖关系

```
根包 src/
├── types        （纯 MoonBit，无依赖）
├── core         （C FFI，依赖 types）
├── pure         （纯 MoonBit，依赖 types）
├── lib          （纯 MoonBit，依赖 types + pure）
├── process/*    （纯 MoonBit，依赖 core）
├── format       （纯 MoonBit，依赖 core）
├── meta         （纯 MoonBit，依赖 core）
└── util         （纯 MoonBit，依赖 core + process）
```
