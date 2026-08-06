---
name: stb-image
description: MoonBit native FFI bindings for stb_image.h — decode PNG/JPEG/BMP/GIF/WebP/TGA/PSD/HDR/PIC from file path or memory. Provides load_from_path/load_from_bytes returning Image with width/height/channels/data, raising LoadError on failure.
---

# stb-image

MoonBit native FFI bindings for [stb_image.h](https://github.com/nothings/stb) v2.30.

## 用途

将 C 单头文件库 `stb_image.h` 以 MoonBit 原生 FFI 绑定形式暴露为 MoonBit 包，提供安全、惯用的图像 load 能力。MVP 聚焦 8-bit load 路径（native 目标），支持 9 种格式解码。

## 快速开始

```moonbit
// 从内存字节加载
let img : Image = load_from_bytes(png_bytes)
println("width=\{img.width}, height=\{img.height}, channels=\{img.channels}")

// 从文件路径加载
let img2 : Image = load_from_path("photo.png")
```

## API 概览

| 函数 | 签名 | 说明 |
|------|------|------|
| `load_from_path` | `(String) -> Image raise LoadError` | 从文件路径加载图像 |
| `load_from_bytes` | `(Bytes) -> Image raise LoadError` | 从内存字节序列加载图像 |

| 类型 | 说明 |
|------|------|
| `Image` | `pub(all) struct { width : Int, height : Int, channels : Int, data : Bytes }`，derive `Eq`/`@debug.Debug` |
| `LoadError` | `pub(all) suberror { FileIO(String), UnsupportedFormat(String), DecodeFailed(String) }` |

## 最小示例

```moonbit
let bmp = b"\x42\x4D\x3A\x00\x00\x00\x00\x00\x00\x00\x36\x00\x00\x00\x28\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x18\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xFF\x00"
let img = load_from_bytes(bmp)
assert_eq(img.width, 1)
assert_eq(img.height, 1)
assert_eq(img.channels, 3)
```

## 错误处理

```moonbit
try {
  let img = load_from_bytes(data)
} catch {
  LoadError::FileIO(msg) => println("文件 IO 错误: \{msg}")
  LoadError::DecodeFailed(msg) => println("解码失败: \{msg}")
  LoadError::UnsupportedFormat(msg) => println("格式不支持: \{msg}")
}
```

MVP 阶段 `UnsupportedFormat` 与 `DecodeFailed` 不可精确区分，stb_image 返回 NULL 时默认归类为 `DecodeFailed`。`FileIO` 可在 path 入口独立区分。

## 目标后端限制

MVP 仅支持 **native** 目标。`load_from_path`/`load_from_bytes` 通过 `moon.pkg` 的 `targets` 门控到 native。`Image`/`LoadError` 类型定义全后端可用。

## 架构

四层分层架构，依赖单向向下：

1. **Vendoring 层**：`scripts/prepare.py` 下载 pinned `stb_image.h`
2. **FFI 边界层**：`wrapper.c`（ABI 归一化）+ `ffi.mbt`（私有 extern "c" 声明）
3. **安全 API 层**：`image_types.mbt`（类型定义）+ `image_load_native.mbt`（公开 API）
4. **测试与文档层**：`*_test.mbt` + `README.mbt.md`

## 版本演进路线

- **v0.1 (MVP)**：8-bit load（path + bytes），9 种格式
- **v0.2**：write（stb_image_write.h）
- **v0.3**：16-bit/float 数据，`stbi_failure_reason`，flip/req_channels
- **v0.4**：IO callbacks（`stbi_io_callbacks`）
- **v1.0**：多目标支持（wasm/js）