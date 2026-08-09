# 概述

## image

MoonBit 图像处理库，封装 stb_image.h v2.30 + stb_image_write.h v1.16 + stb_image_resize2.h v2.07。

- **模块名**：`Toadium/image`（发布包 `toadium/image`）
- **版本**：2.0.0
- **许可证**：MIT（stb 头文件属公共领域）

## 核心特性

- **多目标支持**：native 目标使用 C FFI（stb_image），wasm/js 目标使用纯 MoonBit 后端（`src/pure/`）
- **10+ 格式解码**：PNG/JPEG/BMP/GIF/TGA/PSD/HDR/PNM/QOI（native）；BMP/QOI/TGA/PNM/PSD/GIF（pure）
- **8 格式编码**：PNG/BMP/TGA/JPEG/HDR/ICO/ICNS + QOI/PNM/GIF（pure）
- **图像处理全套**：变换/色彩/滤波/边缘/特征/频域/分割/形态学/直方图/混合模式
- **三种像素类型**：Image（8-bit）、Image16（16-bit）、ImageF（HDR float）
- **7 种缩放滤波器** × 4 种边缘模式
- **199 公开函数 + 29 类型**（native），78 个 pub fn（pure）
- **847 测试 + 29 基准测试**，全部通过 AddressSanitizer
