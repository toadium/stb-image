---
name: stb-image
description: MoonBit native FFI bindings for stb_image.h v2.30 + stb_image_write.h v1.16 — full image decode/encode capability: 8-bit/16-bit/float load, animated GIF, info query, write PNG/BMP/TGA/JPEG, HDR config, flip/unpremultiply/iPhone PNG config. 61 tests, ASan verified.
---

# stb-image

MoonBit native FFI bindings for [stb_image.h](https://github.com/nothings/stb) v2.30 + [stb_image_write.h](https://github.com/nothings/stb) v1.16.

## 用途

将 C 单头文件库 `stb_image.h` / `stb_image_write.h` 以 MoonBit 原生 FFI 绑定形式暴露为 MoonBit 包，提供完整的图像 load/write/info/16-bit/float/GIF 能力。支持 native 目标，覆盖 PNG/JPEG/BMP/GIF/WebP/TGA/PSD/HDR/PIC 等 9+ 种格式。

## 快速开始

```moonbit
// 从文件路径加载
let img : Image = load_from_path("photo.png")
println("width=\{img.width}, height=\{img.height}, channels=\{img.channels}")

// 从内存字节加载，强制 RGBA
let img2 : Image = load_from_bytes(png_bytes, req_channels=Some(4))

// 编码为 PNG 字节
let out : Bytes = write_png_to_bytes(img)

// 加载动画 GIF
let anim : GifAnimation = load_gif_from_path("animation.gif")
println("frames=\{anim.frames.length()}")
```

## API 概览

### 类型

| 类型 | 说明 |
|------|------|
| `Image` | 8-bit 解码结果 `{ width, height, channels, data : Bytes }` |
| `Image16` | 16-bit 解码结果（UInt16 little-endian） |
| `ImageF` | HDR float 解码结果（IEEE 754 little-endian） |
| `ImageInfo` | 图像信息 `{ width, height, channels }`，不含像素数据 |
| `GifAnimation` | 动画 GIF `{ frames : Array[Image], delays : Array[Int] }` |
| `LoadError` | 错误类型 `{ FileIO, UnsupportedFormat, DecodeFailed }` |

### 加载（8 组 path/bytes 对）

`load_from_*`、`load_16_from_*`、`loadf_from_*`、`load_gif_from_*` — 均支持 `req_channels? : Int?` 可选参数

### 写入（4 格式 × path/bytes）

`write_png/bmp/tga/jpeg_to_path/bytes` — JPEG 支持 `quality? : Int`（默认 90）

### 查询

`info_from_*`、`is_16_bit_from_*`、`is_hdr_from_*`、`failure_reason`

### 配置

`set_flip_vertically_on_load`、`flip_vertically_on_write`、`set_unpremultiply_on_load`、`convert_iphone_png_to_rgb`、`hdr_to_ldr_gamma/scale`、`ldr_to_hdr_gamma/scale`

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

`UnsupportedFormat` 与 `DecodeFailed` 不可精确区分，stb_image 返回 NULL 时默认归类为 `DecodeFailed`。可用 `failure_reason()` 获取 stb_image 内部失败原因字符串。

## 目标后端

仅支持 **native** 目标。多目标（wasm/js）已评估并暂缓：需 Emscripten 构建链 + `extern "wasm"`/`extern "js"` FFI 机制，成本过高。类型定义（`Image`/`Image16`/`ImageF`/`ImageInfo`/`GifAnimation`/`LoadError`）全后端可用。

## 架构

四层分层架构，依赖单向向下：

1. **Vendoring 层**：`scripts/prepare.py` 下载 pinned `stb_image.h` v2.30 + `stb_image_write.h` v1.16
2. **FFI 边界层**：`wrapper.c`（ABI 归一化）+ `ffi.mbt`（私有 `extern "c"` 声明）
3. **安全 API 层**：`image_types.mbt`（类型）+ `image_*_native.mbt`（公开 API）
4. **测试与文档层**：`*_test.mbt`（61 测试）+ `README.mbt.md`

## 版本演进

- **v0.1**：8-bit load（path + bytes），9 种格式
- **v0.2**：write（PNG/BMP/TGA/JPEG）+ req_channels + flip
- **v0.3**：16-bit/float load + info + is_16_bit/is_hdr + failure_reason + config
- **v0.4**：HDR config + animated GIF
- **v1.0**：API 冻结，完整文档，61 测试，ASan 验证通过

## 限制

- I/O callbacks（`stbi_io_callbacks`）未实现：MoonBit FFI 不支持将闭包传递给 C 作为函数指针
- 多目标支持暂缓：需 Emscripten + 不同 FFI 机制
- 零拷贝未实现：当前所有 load 路径通过 `memcpy` 从 C 缓冲区拷贝到 MoonBit `Bytes`
