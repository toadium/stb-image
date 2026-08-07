# stb-image

[English](README.md) | [中文](README.zh.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MoonBit](https://img.shields.io/badge/MoonBit-native-blue)](https://www.moonbitlang.com/)
[![Tests](https://img.shields.io/badge/tests-533%20passed-brightgreen)]()
[![Bench](https://img.shields.io/badge/bench-29%20passed-brightgreen)]()
[![ASan](https://img.shields.io/badge/ASan-passed-brightgreen)]()

MoonBit 原生 FFI 绑定库，封装 [stb_image.h](https://github.com/nothings/stb) v2.30 + [stb_image_write.h](https://github.com/nothings/stb) v1.16 + [stb_image_resize2.h](https://github.com/nothings/stb) v2.07。

完整图像解码/编码/缩放/处理能力：8位/16位/浮点加载、动画GIF、信息查询、写入 PNG/BMP/TGA/JPEG/HDR、缩放、格式检测、QOI/ICO/ICNS/GIF/PNM 编解码、EXIF/PNG 元数据、图像处理（裁剪/旋转/翻转/色彩/滤波/直方图/量化/形态学/边缘检测/质量评估）、往返测试、性能基准测试。

## 功能特性

- **10+ 格式解码**：PNG、JPEG、BMP、GIF、PSD、TGA、HDR、PIC、WebP、PNM (PPM/PGM)、QOI
- **8 格式编码**：PNG、BMP、TGA、JPEG、HDR、QOI、GIF、PNM (PPM/PGM)
- **3 种像素类型**：8位 (`Image`)、16位 (`Image16`)、HDR浮点 (`ImageF`)
- **缩放**：7种滤波器 × 4种边缘模式，支持8位/16位/浮点/sRGB
- **格式检测**：`detect_format` / `decode_any` / `is_supported_format`
- **图像处理**：裁剪、旋转、翻转、色彩转换、绘制/合成
- **色彩调整**：亮度、对比度、伽马、反色、HSV/HSL 转换
- **滤波器**：方框模糊、高斯模糊、锐化、Sobel/Laplacian/Prewitt 边缘检测
- **几何变换**：仿射变换、任意角度旋转
- **直方图**：计算、均衡化、归一化
- **量化**：Floyd-Steinberg 抖动、中位切割
- **形态学**：腐蚀、膨胀、开运算、闭运算（3x3 结构元素）
- **质量评估**：MSE、PSNR、SSIM
- **高级处理**：CLAHE（对比度受限自适应直方图均衡）、K-means 色彩量化、FFT 频域变换、频域滤波（低通/高通/带通/带阻）
- **自适应阈值**：均值法、高斯加权法、Otsu 大津法
- **连通域标记**：4/8 连通，含面积/边界框/质心
- **积分图像**：O(1) 矩形区域求和/均值/方差查询
- **霍夫变换**：直线检测，含非极大值抑制
- **局部二值模式(LBP)**：基本 LBP + 均匀 LBP
- **图像金字塔**：高斯/拉普拉斯金字塔构建与上下采样
- **双边滤波**：保边去噪滤波
- **轮廓提取**：Moore 边界跟踪，周长，面积
- **颜色分割**：K-means、区域生长、泛洪填充
- **NLM 去噪**：非局部均值（完整版 + 快速版）
- **Retinex**：SSR、MSR、MSRCR（多尺度带颜色恢复）
- **Canny 边缘**：高斯 → Sobel → 非极大值抑制 → 滞后连接
- **分水岭**：沉浸式分割，自动寻找种子
- **GLCM 纹理**：对比度/相关性/能量/同质性/熵（4 方向）
- **Haar 小波**：1D/2D 变换，多级分解，去噪
- **Harris 角点**：结构张量 + 非极大值抑制 + 距离过滤
- **去雾**：暗通道先验 + 引导滤波
- **距离变换**：L1/L2/Linf 距离，骨架化
- **Gabor 滤波**：多方向多尺度纹理分析
- **混合模式**：13种（正片叠底、滤色、叠加、变暗、变亮、差值、排除、颜色减淡、颜色加深、强光、柔光、线性减淡、线性加深）
- **元数据**：EXIF 读取、PNG 文本块
- **动画GIF**：多帧解码/编码，支持逐帧延迟
- **信息查询**：不解码像素即可获取尺寸
- **可配置**：翻转、非预乘Alpha、iPhone PNG、HDR伽马/缩放
- **错误诊断**：`failure_reason()` 获取 stb_image 内部错误字符串
- **533 测试 + 29 基准测试**，全部通过 AddressSanitizer

## 安装

```bash
moon add toadium/stb-image
```

## 快速上手

```moonbit
// 从文件解码
let img : Image = load_from_path("photo.png")
println("width=\{img.width}, height=\{img.height}, channels=\{img.channels}")

// 从内存解码，强制 RGBA
let img2 : Image = load_from_bytes(png_bytes, req_channels=Some(4))

// 编码为 PNG 字节
let out : Bytes = write_png_to_bytes(img)

// 使用默认滤波器缩放
let resized : Image = resize(img, 128, 128)

// 自动检测格式并解码
let any : Image = decode_any(data, req_channels=Some(3))

// 加载动画 GIF
let anim : GifAnimation = load_gif_from_path("animation.gif")
println("frames=\{anim.frames.length()}, delays=\{anim.delays}")

// 读取 EXIF 元数据
let exif : ExifInfo? = read_exif_from_path("photo.jpg")

// 查询图像信息（不解码）
let info : ImageInfo? = info_from_path("large.hdr")
```

## 错误处理

```moonbit
try {
  let img = load_from_bytes(data)
  // use img
} catch {
  LoadError::FileIO(msg) => println("文件IO错误: \{msg}")
  LoadError::DecodeFailed(msg) => println("解码失败: \{msg}")
  LoadError::UnsupportedFormat(msg) => println("不支持的格式: \{msg}")
}
```

`UnsupportedFormat` 和 `DecodeFailed` 无法精确区分；stb_image 返回 NULL 时默认为 `DecodeFailed`。使用 `failure_reason()` 获取 stb_image 内部错误字符串。

## 构建与测试

```bash
moon check --target native     # 检查编译
moon test --target native      # 运行 533 个测试
moon bench --target native     # 运行 29 个基准测试
moon info                      # 重新生成 API 接口
```

## 限制

- **I/O回调**（`stbi_io_callbacks`）：未实现。MoonBit FFI 不支持将闭包作为C函数指针传递。
- **零拷贝**：未实现。所有加载路径通过 `memcpy` 将像素数据从C缓冲区复制到MoonBit `Bytes`。
- **多目标**：仅支持 native。wasm/js 支持已评估但暂缓。

## 文档

| 文档 | 说明 |
|------|------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | 架构图、包依赖关系、FFI 边界、数据流、设计决策 |
| [API.md](API.md) | 完整 API 参考（199 个函数，29 个类型） |
| [CHANGELOG.zh.md](CHANGELOG.zh.md) | 版本历史与上游来源 |
| [ROADMAP.md](ROADMAP.md) | 迭代路线图 |
| [COMPARISON.md](COMPARISON.md) | mooncakes.io 图像库对比 |
| [SKILL.md](SKILL.md) | 包使用指南 |

## 许可证

MIT 许可证 — 详见 [LICENSE](LICENSE)。

stb_image.h、stb_image_write.h 和 stb_image_resize2.h 属于公共领域（Sean Barrett）。
