# walkzzz/image/src

> stb-image 顶层包 — 纯 MoonBit 图像处理库，零 C FFI 依赖

## 包结构

| 包 | 说明 |
|------|------|
| [`types`](types/) | 核心类型（Image、Image16、ImageF、LoadError） |
| [`pure/codec`](pure/codec/) | 18 种格式编解码（PNG/JPEG/BMP/GIF/QOI/TGA/PSD/HDR/PNM/TIFF/ICO/CUR/ICNS/APNG/WebP/AVIF/HEIF/JPEG-XL） |
| [`pure/color`](pure/color/) | 颜色操作（色彩空间转换、调整、映射） |
| [`pure/util`](pure/util/) | 纯 MoonBit 工具函数（缩放、裁剪） |
| [`lib`](lib/) | 高层封装（自动格式分派、流式解码） |
| [`meta`](meta/) | 元数据处理（EXIF 读写、PNG 元数据） |
| [`util`](util/) | 工具函数（颜色映射、合成、统计、像素操作） |
| [`process`](process/) | 高级图像处理算法（90 子包） |

## 统计

- 公开函数：1338
- 公开类型：491
- 测试：4801 × 4 目标（native/wasm-gc/js/wasm）
- 覆盖率：90.4%

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
