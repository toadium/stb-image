# stb-image 架构文档

> 版本 v1.17.0 | 199 公开函数 + 29 类型 | 533 测试 + 29 基准测试

## 概述

stb-image 是 MoonBit 原生 FFI 绑定库，封装 [stb](https://github.com/nothings/stb) 系列单头文件库，提供完整的图像解码/编码/缩放/处理能力。采用五子包架构，根包 re-export 保持向后兼容 API。

## 包依赖关系

```mermaid
flowchart TB
    Root["根包 src/<br/>reexport.mbt · bench · roundtrip_test"]
    Core["core/<br/>FFI + 类型 + 加载/写入/缩放"]
    Process["process/<br/>图像处理（纯 MoonBit）"]
    Format["format/<br/>编解码（纯 MoonBit）"]
    Meta["meta/<br/>元数据（纯 MoonBit）"]
    Util["util/<br/>工具函数（纯 MoonBit）"]

    Root --> Core
    Root --> Process
    Root --> Format
    Root --> Meta
    Root --> Util
    Process --> Core
    Format --> Core
    Meta --> Core
    Util --> Core
    Util --> Process

    Stb["stb_image.h v2.30<br/>stb_image_write.h v1.16<br/>stb_image_resize2.h v2.07"]
    Core --> Stb

    classDef pure fill:#e1f5fe,stroke:#01579b
    classDef ffi fill:#fff3e0,stroke:#e65100
    classDef ext fill:#f3e5f5,stroke:#4a148c
    class Process,Format,Meta,Util pure
    class Core ffi
    class Stb ext
```

## FFI 边界

```mermaid
flowchart LR
    subgraph MoonBit["MoonBit 层"]
        Types["image_types.mbt<br/>Image · Image16 · ImageF"]
        FFI["ffi.mbt<br/>extern \"c\" 声明"]
        Native["image_*_native.mbt<br/>加载/写入/缩放"]
    end

    subgraph C["C 层"]
        Wrapper["wrapper.c<br/>ABI 标准化"]
        Stb["stb_image*.h<br/>单头文件库"]
    end

    Types --> Native
    Native --> FFI
    FFI --> Wrapper
    Wrapper --> Stb

    subgraph Memory["内存管理"]
        Alloc["stbi_malloc<br/>C 分配"]
        Copy["memcpy<br/>C → MoonBit Bytes"]
        Free["stbi_image_free<br/>C 释放"]
    end

    Stb --> Alloc
    Alloc --> Copy
    Copy --> Free
```

**FFI 约束**：
- 所有像素数据通过 `memcpy` 从 C 缓冲区复制到 MoonBit `Bytes`（无零拷贝）
- `wrapper.c` 负责 ABI 标准化：将 stb 的 `unsigned char*` 返回值转换为 MoonBit 可读的 `Bytes`
- 闭包无法作为 C 函数指针传递（`stbi_io_callbacks` 未实现）

## 子包详解

### core/ — FFI + 类型 + I/O

```mermaid
flowchart TB
    subgraph CorePkg["core/ (FFI 边界)"]
        direction TB
        Types["image_types.mbt<br/>Image · Image16 · ImageF<br/>ImageInfo · GifAnimation · LoadError<br/>ImageFormat · ResizeFilter · ResizeEdge"]
        FFI["ffi.mbt<br/>私有 extern \"c\" 声明"]
        Wrapper["wrapper.c<br/>C ABI 包装器"]
        Load["image_load_native.mbt<br/>load_from_path/bytes<br/>load_16_* · loadf_* · load_gif_*"]
        Write["image_write_native.mbt<br/>write_png/bmp/tga/jpeg/hdr"]
        Resize["image_resize_native.mbt<br/>resize · resize_16 · resizef · resize_srgb"]
        Info["image_info_native.mbt<br/>info_from_path/bytes<br/>is_16_bit · is_hdr"]
        Detect["image_detect.mbt<br/>detect_format · decode_any<br/>is_supported_format"]
        Icon["icon_encode.mbt<br/>encode_ico · encode_icns"]
        Config["image_config.mbt<br/>flip · unpremultiply · HDR gamma/scale"]
    end
```

**职责**：所有 C FFI 交互、像素类型定义、加载/写入/缩放/检测/配置

**关键设计**：
- `Image.data : Bytes` — 像素数据存储在 MoonBit 管理的 `Bytes` 中，C 侧分配后立即拷贝并释放
- `LoadError` — 三种错误变体：`FileIO` / `UnsupportedFormat` / `DecodeFailed`
- `req_channels` — 可选参数强制输出通道数（1=灰度, 2=灰度+Alpha, 3=RGB, 4=RGBA）

### process/ — 图像处理

```mermaid
flowchart TB
    subgraph ProcPkg["process/ (纯 MoonBit)"]
        direction TB
        Transform["transform.mbt<br/>crop · rotate_90/180/270 · flip_h"]
        Geometry["geometry.mbt<br/>warp_affine · rotate"]
        ColorCV["color_convert.mbt<br/>to_grayscale · to_rgb · to_rgba<br/>premultiply · unpremultiply"]
        ColorAdj["color_adjust.mbt<br/>brightness · contrast · gamma · invert<br/>HSV · HSL"]
        Filter["filter.mbt<br/>box_blur · gaussian_blur · sharpen<br/>sobel · laplacian · prewitt"]
        Hist["histogram.mbt<br/>compute · equalize · normalize"]
        Quant["quantize.mbt<br/>floyd_steinberg · median_cut"]
        Draw["draw.mbt<br/>draw_copy · draw_over"]
        Morph["morphology.mbt<br/>erode · dilate · open · close"]
        Edge["edge_detect.mbt<br/>laplacian · prewitt"]
        Quality["image_quality.mbt<br/>mse · psnr · ssim"]
        ClaheP["clahe.mbt<br/>CLAHE"]
        Kmeans["kmeans_quantize.mbt<br/>K-means 量化"]
        FFT["fft.mbt<br/>fft_2d · ifft_2d · magnitude · shift"]
        FreqF["freq_filter.mbt<br/>freq_filter · freq_filter_gaussian"]
        AdaptT["adaptive_threshold.mbt<br/>mean · gaussian · otsu"]
        CC["connected_components.mbt<br/>labeling + Union-Find"]
        Integral["integral_image.mbt<br/>O(1) 矩形查询"]
        Hough["hough.mbt<br/>直线检测 + NMS"]
        LBP["lbp.mbt<br/>基本 + 均匀 LBP"]
        Pyr["pyramid.mbt<br/>高斯/拉普拉斯金字塔"]
        Bilat["bilateral_filter.mbt<br/>保边去噪"]
        Contour["contour.mbt<br/>Moore 边界跟踪"]
        Seg["color_segment.mbt<br/>K-means · 区域生长 · 泛洪填充"]
        NLM["nlm_denoise.mbt<br/>非局部均值"]
        Retinex["retinex.mbt<br/>SSR · MSR · MSRCR"]
        Canny["canny.mbt<br/>Canny 边缘"]
        Water["watershed.mbt<br/>分水岭分割"]
        GLCM["glcm.mbt<br/>灰度共生矩阵"]
        Haar["haar_wavelet.mbt<br/>Haar 小波"]
        Harris["harris.mbt<br/>Harris 角点"]
        Dehaze["dehaze.mbt<br/>暗通道先验去雾"]
        DistT["distance_transform.mbt<br/>距离变换 · 骨架化"]
        Gabor["gabor.mbt<br/>Gabor 滤波"]
    end
```

**职责**：所有纯 MoonBit 图像处理算法，无 FFI 依赖

**关键设计**：
- 仅依赖 `@core`（类型定义）和 `@math`（数学函数）
- 所有函数接受 `Image` 返回 `Image`，支持函数组合
- 29 个类型中 17 个定义在此包（`Complex`, `FFTResult`, `FreqFilterType`, `ConnectedComponent`, ...）

### format/ — 编解码

```mermaid
flowchart TB
    subgraph FormatPkg["format/ (纯 MoonBit)"]
        QOI["qoi.mbt<br/>decode_qoi · encode_qoi"]
        GIF["gif_encode.mbt<br/>encode_gif · encode_gif_animation"]
        PNM["pnm_encode.mbt<br/>encode_ppm · encode_pgm · encode_pnm"]
    end
```

**职责**：QOI/GIF/PNM 格式的纯 MoonBit 编解码

### meta/ — 元数据

```mermaid
flowchart TB
    subgraph MetaPkg["meta/ (纯 MoonBit)"]
        EXIF["exif.mbt<br/>read_exif_from_bytes/path<br/>ExifInfo (make, model, date_time, orientation)"]
        PNG["png_meta.mbt<br/>read_png_text_chunks<br/>PngTextChunk (keyword, text)"]
    end
```

**职责**：EXIF 和 PNG 文本块元数据读取

### util/ — 工具函数

```mermaid
flowchart TB
    subgraph UtilPkg["util/ (纯 MoonBit)"]
        PixelOps["pixel_ops.mbt<br/>threshold · posterize · extract_channel"]
        PixelAdv["pixel_advanced.mbt<br/>set_alpha · fill_alpha · replace_color · apply_lut"]
        Compose["image_compose.mbt<br/>hstack · vstack · tile · flip_v · transpose"]
        Noise["image_noise.mbt<br/>add_noise_gaussian · salt_pepper"]
        ColorMap["color_map.mbt<br/>gradient_map · 13 blend modes"]
        Stats["image_stats.mbt<br/>compute_stats · mean_value"]
        Util["image_util.mbt<br/>pad · border · resize_to_cover/contain · pixelate · convolve"]
    end
```

**职责**：像素操作、图像合成、噪声、色彩映射、统计等工具函数

## 数据流

### 加载-处理-写入流水线

```mermaid
sequenceDiagram
    participant User as 用户代码
    participant Root as reexport.mbt
    participant Core as core/
    participant C as stb_image.h
    participant Proc as process/
    participant Fmt as format/

    User->>Root: load_from_path("photo.png")
    Root->>Core: @core.load_from_path(path)
    Core->>C: stbi_load(path, ...)
    C-->>Core: unsigned char* pixels
    Core->>Core: memcpy to Bytes
    Core->>C: stbi_image_free(pixels)
    Core-->>Root: Image
    Root-->>User: Image

    User->>Root: gaussian_blur(img, 5, 1.0)
    Root->>Proc: @process.gaussian_blur(img, 5, 1.0)
    Proc-->>Root: Image (blurred)
    Root-->>User: Image

    User->>Root: write_png_to_bytes(result)
    Root->>Core: @core.write_png_to_bytes(img)
    Core->>C: stbi_write_png_to_memory(...)
    C-->>Core: Bytes
    Core-->>Root: Bytes
    Root-->>User: Bytes
```

### 格式检测流程

```mermaid
flowchart TB
    Input["输入 Bytes"] --> Magic["检查魔数字节<br/>PNG: 89 50 4E 47<br/>JPEG: FF D8<br/>BMP: 42 4D<br/>GIF: 47 49 46<br/>QOI: 71 6F 69 66<br/>..."]
    Magic --> Format{"格式识别"}
    Format -->|PNG| PNG["stbi_load<br/>PNG 解码"]
    Format -->|JPEG| JPEG["stbi_load<br/>JPEG 解码"]
    Format -->|BMP| BMP["stbi_load<br/>BMP 解码"]
    Format -->|GIF| GIF["stbi_load<br/>GIF 解码"]
    Format -->|QOI| QOI["纯 MoonBit<br/>QOI 解码"]
    Format -->|PNM| PNM["纯 MoonBit<br/>PNM 解码"]
    Format -->|未知| Err["UnsupportedFormat"]
    PNG --> Image["Image"]
    JPEG --> Image
    BMP --> Image
    GIF --> Image
    QOI --> Image
    PNM --> Image
```

## 类型体系

```mermaid
classDiagram
    class Image {
        +Int width
        +Int height
        +Int channels
        +Bytes data
    }
    class Image16 {
        +Int width
        +Int height
        +Int channels
        +Bytes data
    }
    class ImageF {
        +Int width
        +Int height
        +Int channels
        +Bytes data
    }
    class ImageInfo {
        +Int width
        +Int height
        +Int channels
    }
    class GifAnimation {
        +Array~Image~ frames
        +Array~Int~ delays
    }
    class LoadError {
        <<enum>>
        FileIO(String)
        UnsupportedFormat(String)
        DecodeFailed(String)
    }
    class ImageFormat {
        <<enum>>
        Png
        Jpeg
        Bmp
        Gif
        Tga
        Psd
        Hdr
        Pnm
        Qoi
        Unknown
    }
    class ResizeFilter {
        <<enum>>
        Default
        Box
        Triangle
        CubicBSPline
        CatmullROM
        Mitchell
        PointSample
    }
    class ResizeEdge {
        <<enum>>
        Clamp
        Reflect
        Wrap
        Zero
    }
```

## 设计决策

### 1. 五子包架构（v1.10.1）

**问题**：单包超过 30 个源文件，编译慢、职责不清

**方案**：按职责拆分为 `core`（FFI）/ `process`（处理）/ `format`（编解码）/ `meta`（元数据）/ `util`（工具），根包 re-export 保持 API 兼容

**收益**：编译并行化、职责清晰、可独立测试

### 2. re-export 策略

**问题**：`pub let` 无法 re-export 带标签参数的函数

**方案**：普通函数用 `pub let` 直接别名，带标签参数的函数用 `pub fn` 包装器保留默认值

### 3. FFI 内存管理

**问题**：MoonBit GC 与 C malloc 的内存边界

**方案**：C 侧分配 → `memcpy` 到 MoonBit `Bytes` → 立即 `stbi_image_free`。无零拷贝，但安全简单

### 4. 纯 MoonBit vs FFI

**原则**：
- stb 已有的功能 → FFI 绑定（低成本、高质量、ASan 可验证）
- stb 没有的功能 → 纯 MoonBit 实现（放在 `process/` 或 `format/`）
- 格式编解码：QOI/GIF/PNM 用纯 MoonBit，PNG/JPEG/BMP/TGA/HDR 用 FFI

### 5. `pub(all) struct` vs `pub struct`

**问题**：测试中需要构造 struct 实例

**方案**：需要外部构造的类型用 `pub(all) struct`（如 `HoughLine`, `Contour`, `CornerPoint`），仅内部使用的用 `pub struct`

## 性能特征

| 操作 | 复杂度 | 备注 |
|------|--------|------|
| 加载/写入 | O(n) | n = 像素数，FFI 调用 |
| 缩放 | O(n) | FFI stb_image_resize2 |
| box_blur | O(n) | 滑动窗口优化 |
| gaussian_blur | O(n × r) | 可分离核，r = 半径 |
| bilateral_filter | O(n × r²) | r = 半径 |
| bilateral_filter_fast | O(n × r² / s²) | s = 降采样因子 |
| nlm_denoise | O(n × s² × p²) | s = 搜索窗口, p = 块大小 |
| fft_2d | O(n log n) | Cooley-Tukey radix-2 |
| connected_components | O(n × α(n)) | Union-Find，α ≈ 4 |
| integral_image | O(n) | 预处理 |
| integral_sum/mean/variance | O(1) | 矩形查询 |
| distance_transform | O(n) | 两遍扫描 |
| hough_lines | O(n × θ) | θ = 角度分辨率 |
| watershed | O(n log n) | 优先队列 |
| dehaze | O(n × p²) | p = 暗通道块大小 |