# stb-image API 参考

> 版本 v2.0.0 | 196 公开函数 + 27 类型 | 847 测试 + 75 基准测试

## 类型总览

| 类型 | 包 | 字段/变体 | 说明 |
|------|------|-----------|------|
| `Image` | core | `width, height, channels : Int; data : Bytes` | 8位解码图像 |
| `Image16` | core | `width, height, channels : Int; data : Bytes` | 16位解码图像（UInt16 LE） |
| `ImageF` | core | `width, height, channels : Int; data : Bytes` | HDR浮点图像（IEEE 754 LE） |
| `ImageInfo` | core | `width, height, channels : Int` | 图像信息（无像素数据） |
| `GifAnimation` | core | `frames : Array[Image]; delays : Array[Int]` | 动画GIF |
| `LoadError` | core | `FileIO(String) \| UnsupportedFormat(String) \| DecodeFailed(String)` | 加载失败错误 |
| `ImageFormat` | core | `Png \| Jpeg \| Bmp \| Gif \| Tga \| Psd \| Hdr \| Pnm \| Qoi \| Unknown` | 图像格式枚举 |
| `ResizeFilter` | core | `Default \| Box \| Triangle \| CubicBSPline \| CatmullROM \| Mitchell \| PointSample` | 缩放滤波器 |
| `ResizeEdge` | core | `Clamp \| Reflect \| Wrap \| Zero` | 缩放边缘模式 |
| `ExifInfo` | meta | `make, model, date_time : String; orientation : Int` | EXIF元数据 |
| `PngTextChunk` | meta | `keyword, text : String` | PNG文本块 |
| `ImageStats` | util | `min, max, mean, std_dev : Float; histogram : Array[Int]` | 图像统计 |
| `Complex` | process | `re, im : Float` | 复数 |
| `FFTResult` | process | `width, height : Int; data : Array[Complex]` | FFT结果 |
| `FreqFilterType` | process | `LowPass \| HighPass \| BandPass \| BandStop` | 频域滤波类型 |
| `ConnectedComponent` | process | `label, area, x, y, w, h : Int; centroid_x, centroid_y : Float` | 连通域 |
| `ConnectedComponentLabelImage` | process | `width, height : Int; labels : Array[Int]` | 标签图 |
| `IntegralImage` | process | `width, height : Int; data : Array[Int64]` | 积分图像 |
| `IntegralImageSq` | process | `width, height : Int; data : Array[Int64]` | 平方积分图像 |
| `HoughLine` | process | `rho, theta : Float; votes : Int` | 霍夫直线 |
| `ContourPoint` | process | `x, y : Int` | 轮廓点 |
| `Contour` | process | `points : Array[ContourPoint]; is_hole : Bool` | 轮廓 |
| `SegmentLabelImage` | process | `width, height : Int; labels : Array[Int]` | 分割标签图 |
| `SegmentRegion` | process | `label, area : Int; centroid_x, centroid_y : Float; mean_color : Array[Byte]` | 分割区域 |
| `GlcmFeatures` | process | `contrast, correlation, energy, homogeneity, entropy, asm, dissimilarity : Float` | GLCM特征 |
| `HaarWaveletResult` | process | `width, height, channels : Int; ll : Array[Float]; lh, hl, hh : Array[Array[Float]]; levels : Int` | Haar小波结果 |
| `CornerPoint` | process | `x, y : Int; response : Float` | 角点 |

所有类型派生 `Eq` 和 `@debug.Debug`。

---

## I/O — 加载（8个函数）

所有加载函数接受可选参数 `req_channels : Int?`（1=灰度, 2=灰度+Alpha, 3=RGB, 4=RGBA）。传 `None` 保持原始通道数。

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `load_from_path` | `(String, req_channels?: Int?) -> Image` | 8位图像 | 从文件加载 |
| `load_from_bytes` | `(Bytes, req_channels?: Int?) -> Image` | 8位图像 | 从内存加载 |
| `load_16_from_path` | `(String, req_channels?: Int?) -> Image16` | 16位图像 | 从文件加载16位 |
| `load_16_from_bytes` | `(Bytes, req_channels?: Int?) -> Image16` | 16位图像 | 从内存加载16位 |
| `loadf_from_path` | `(String, req_channels?: Int?) -> ImageF` | HDR浮点 | 从文件加载HDR |
| `loadf_from_bytes` | `(Bytes, req_channels?: Int?) -> ImageF` | HDR浮点 | 从内存加载HDR |
| `load_gif_from_path` | `(String, req_channels?: Int?) -> GifAnimation` | 动画GIF | 从文件加载GIF |
| `load_gif_from_bytes` | `(Bytes, req_channels?: Int?) -> GifAnimation` | 动画GIF | 从内存加载GIF |

## I/O — 写入（10个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `write_png_to_path` | `(String, Image) -> Unit` | 写入PNG文件 |
| `write_bmp_to_path` | `(String, Image) -> Unit` | 写入BMP文件 |
| `write_tga_to_path` | `(String, Image) -> Unit` | 写入TGA文件 |
| `write_jpeg_to_path` | `(String, Image, quality?: Int) -> Unit` | 写入JPEG（默认质量90） |
| `write_hdr_to_path` | `(String, ImageF) -> Unit` | 写入HDR文件 |
| `write_png_to_bytes` | `(Image) -> Bytes` | 编码PNG为字节 |
| `write_bmp_to_bytes` | `(Image) -> Bytes` | 编码BMP为字节 |
| `write_tga_to_bytes` | `(Image) -> Bytes` | 编码TGA为字节 |
| `write_jpeg_to_bytes` | `(Image, quality?: Int) -> Bytes` | 编码JPEG为字节 |
| `write_hdr_to_bytes` | `(ImageF) -> Bytes` | 编码HDR为字节 |

## I/O — 缩放（4个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `resize` | `(Image, Int, Int, filter?: ResizeFilter, edge?: ResizeEdge) -> Image` | 8位缩放 |
| `resize_srgb` | `(Image, Int, Int, filter?, edge?) -> Image` | sRGB色彩空间缩放 |
| `resize_16` | `(Image16, Int, Int, filter?, edge?) -> Image16` | 16位缩放 |
| `resizef` | `(ImageF, Int, Int, filter?, edge?) -> ImageF` | 浮点缩放 |

## I/O — 格式检测（3个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `detect_format` | `(Bytes) -> ImageFormat` | 从魔数字节检测格式 |
| `decode_any` | `(Bytes, req_channels?: Int?) -> Image` | 自动检测并解码 |
| `is_supported_format` | `(Bytes) -> Bool` | 检查格式是否支持 |

## I/O — 查询（7个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `info_from_path` | `(String) -> ImageInfo?` | 从文件查询信息（不解码） |
| `info_from_bytes` | `(Bytes) -> ImageInfo?` | 从内存查询信息 |
| `is_16_bit_from_path` | `(String) -> Bool` | 检查是否16位 |
| `is_16_bit_from_bytes` | `(Bytes) -> Bool` | 检查是否16位 |
| `is_hdr_from_path` | `(String) -> Bool` | 检查是否HDR |
| `is_hdr_from_bytes` | `(Bytes) -> Bool` | 检查是否HDR |
| `failure_reason` | `() -> String` | 获取上次stb_image失败原因 |

## I/O — 配置（8个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `set_flip_vertically_on_load` | `(Bool) -> Unit` | 加载时垂直翻转 |
| `flip_vertically_on_write` | `(Bool) -> Unit` | 写入时垂直翻转 |
| `set_unpremultiply_on_load` | `(Bool) -> Unit` | 加载时非预乘Alpha |
| `convert_iphone_png_to_rgb` | `(Bool) -> Unit` | 将iPhone PNG转为RGB |
| `hdr_to_ldr_gamma` | `(Float) -> Unit` | HDR转LDR伽马（默认1.0） |
| `hdr_to_ldr_scale` | `(Float) -> Unit` | HDR转LDR缩放（默认1.0） |
| `ldr_to_hdr_gamma` | `(Float) -> Unit` | LDR转HDR伽马（默认1.0） |
| `ldr_to_hdr_scale` | `(Float) -> Unit` | LDR转HDR缩放（默认1.0） |

## I/O — 文件（1个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `read_file_bytes` | `(String) -> Bytes` | 读取原始文件字节 |

---

## 编解码 — QOI（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `decode_qoi` | `(Bytes) -> Image` | 解码QOI格式 |
| `encode_qoi` | `(Image) -> Bytes` | 编码QOI格式 |

## 编解码 — ICO/ICNS（3个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `encode_ico` | `(Image) -> Bytes` | 编码单尺寸ICO（PNG载荷） |
| `encode_ico_sizes` | `(Array[Image]) -> Bytes` | 编码多尺寸ICO |
| `encode_icns` | `(Image) -> Bytes` | 编码ICNS（PNG载荷） |

## 编解码 — GIF/PNM（4个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `encode_gif` | `(Image) -> Bytes` | 编码单帧GIF89a |
| `encode_gif_animation` | `(GifAnimation) -> Bytes` | 编码多帧GIF89a |
| `encode_ppm` | `(Image) -> Bytes` | 编码PPM (P6) |
| `encode_pgm` | `(Image) -> Bytes` | 编码PGM (P5) |

---

## 元数据（4个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `read_exif_from_bytes` | `(Bytes) -> ExifInfo?` | 从JPEG字节读取EXIF |
| `read_exif_from_path` | `(String) -> ExifInfo?` | 从JPEG文件读取EXIF |
| `read_png_text_chunks` | `(Bytes) -> Array[PngTextChunk]` | 读取PNG tEXt/iTXt文本块 |
| `read_png_text_chunks_from_path` | `(String) -> Array[PngTextChunk]` | 从文件读取PNG文本块 |

---

## 处理 — 变换（7个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `crop` | `(Image, Int, Int, Int, Int) -> Image` | 裁剪区域 (x, y, w, h) |
| `crop_16` | `(Image16, Int, Int, Int, Int) -> Image16` | 裁剪16位 |
| `cropf` | `(ImageF, Int, Int, Int, Int) -> ImageF` | 裁剪浮点 |
| `rotate_90` | `(Image) -> Image` | 顺时针旋转90° |
| `rotate_180` | `(Image) -> Image` | 旋转180° |
| `rotate_270` | `(Image) -> Image` | 顺时针旋转270° |
| `flip_horizontal` | `(Image) -> Image` | 水平翻转 |

## 处理 — 几何（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `warp_affine` | `(Image, (Float,Float,Float,Float,Float,Float), Int, Int) -> Image` | 仿射变换（双线性插值） |
| `rotate` | `(Image, Float) -> Image` | 任意角度旋转 |

## 处理 — 色彩转换（5个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `to_grayscale` | `(Image) -> Image` | 转为灰度 |
| `to_rgb` | `(Image) -> Image` | 移除Alpha通道 |
| `to_rgba` | `(Image) -> Image` | 添加Alpha通道 |
| `premultiply_alpha` | `(Image) -> Image` | 预乘Alpha |
| `unpremultiply_alpha` | `(Image) -> Image` | 非预乘Alpha |

## 处理 — 色彩调整（8个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `adjust_brightness` | `(Image, Int) -> Image` | 调整亮度（增量） |
| `adjust_contrast` | `(Image, Float) -> Image` | 调整对比度（因子） |
| `adjust_gamma` | `(Image, Float) -> Image` | 伽马校正 |
| `invert` | `(Image) -> Image` | 颜色反色 |
| `rgb_to_hsv` | `(Int, Int, Int) -> (Float, Float, Float)` | RGB转HSV |
| `hsv_to_rgb` | `(Float, Float, Float) -> (Int, Int, Int)` | HSV转RGB |
| `rgb_to_hsl` | `(Int, Int, Int) -> (Float, Float, Float)` | RGB转HSL |
| `hsl_to_rgb` | `(Float, Float, Float) -> (Int, Int, Int)` | HSL转RGB |

## 处理 — 滤波器（6个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `box_blur` | `(Image, Int) -> Image` | 方框模糊（滑动窗口） |
| `gaussian_blur` | `(Image, Int, Float) -> Image` | 高斯模糊（可分离核） |
| `sharpen` | `(Image, Float) -> Image` | 锐化（拉普拉斯） |
| `edge_detect_sobel` | `(Image) -> Image` | Sobel边缘检测 |
| `edge_detect_laplacian` | `(Image) -> Image` | 拉普拉斯边缘检测 |
| `edge_detect_prewitt` | `(Image) -> Image` | Prewitt边缘检测 |

## 处理 — 直方图（3个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `histogram` | `(Image) -> Array[Int]` | 计算直方图（256箱） |
| `histogram_equalize` | `(Image) -> Image` | 直方图均衡化 |
| `histogram_normalize` | `(Image) -> Image` | 直方图归一化 |

## 处理 — 量化（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `floyd_steinberg` | `(Image, Int) -> Image` | Floyd-Steinberg抖动 |
| `median_cut` | `(Image, Int) -> Image` | 中位切割量化 |

## 处理 — 形态学（4个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `erode` | `(Image) -> Image` | 腐蚀（3x3最小值） |
| `dilate` | `(Image) -> Image` | 膨胀（3x3最大值） |
| `morph_open` | `(Image) -> Image` | 开运算（先腐蚀后膨胀） |
| `morph_close` | `(Image) -> Image` | 闭运算（先膨胀后腐蚀） |

## 处理 — 绘制（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `draw_copy` | `(Image, Image, Int, Int) -> Image` | 将源图复制到目标图(x,y) |
| `draw_over` | `(Image, Image, Int, Int) -> Image` | 源图Alpha混合到目标图上方 |

## 处理 — 质量评估（3个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `mse` | `(Image, Image) -> Double` | 均方误差 |
| `psnr` | `(Image, Image) -> Double` | 峰值信噪比（dB） |
| `ssim` | `(Image, Image) -> Double` | 结构相似性指数 [-1, 1] |

## 处理 — 混合模式（13个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `blend_multiply` | `(Image, Image) -> Image` | 正片叠底 |
| `blend_screen` | `(Image, Image) -> Image` | 滤色 |
| `blend_overlay` | `(Image, Image) -> Image` | 叠加 |
| `blend_darken` | `(Image, Image) -> Image` | 变暗 |
| `blend_lighten` | `(Image, Image) -> Image` | 变亮 |
| `blend_difference` | `(Image, Image) -> Image` | 差值 |
| `blend_exclusion` | `(Image, Image) -> Image` | 排除 |
| `blend_color_dodge` | `(Image, Image) -> Image` | 颜色减淡 |
| `blend_color_burn` | `(Image, Image) -> Image` | 颜色加深 |
| `blend_hard_light` | `(Image, Image) -> Image` | 强光 |
| `blend_soft_light` | `(Image, Image) -> Image` | 柔光 |
| `blend_linear_dodge` | `(Image, Image) -> Image` | 线性减淡 |
| `blend_linear_burn` | `(Image, Image) -> Image` | 线性加深 |

## 处理 — 高级处理（5个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `clahe` | `(Image, Int, Float) -> Image` | CLAHE（块大小，裁剪限制） |
| `k_means_quantize` | `(Image, Int, Int) -> Image` | K-means色彩量化（k, 最大迭代） |
| `convolve` | `(Image, Array[Float], Float, Float) -> Image` | 通用卷积（核，除数，偏移） |
| `pixelate` | `(Image, Int) -> Image` | 像素化效果（块大小） |
| `replace_color` | `(Image, Array[Byte], Array[Byte], Int) -> Image` | 颜色替换（容差） |

## 处理 — FFT/频域（6个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `fft_2d` | `(Image) -> Array[FFTResult]` | 2D FFT（逐通道） |
| `ifft_2d` | `(FFTResult) -> Image` | 2D 逆FFT |
| `fft_magnitude` | `(FFTResult, Bool) -> Image` | FFT幅度谱 |
| `fft_shift` | `(FFTResult) -> FFTResult` | FFT中心化 |
| `freq_filter` | `(Image, FreqFilterType, Float, band_width?: Float) -> Image` | 理想频率滤波 |
| `freq_filter_gaussian` | `(Image, FreqFilterType, Float, band_width?: Float) -> Image` | 高斯频率滤波 |

## 处理 — 自适应阈值（3个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `adaptive_threshold_mean` | `(Image, Int, Int) -> Image` | 均值自适应阈值 |
| `adaptive_threshold_gaussian` | `(Image, Int, Int) -> Image` | 高斯加权自适应阈值 |
| `threshold_otsu` | `(Image) -> Image` | Otsu自动阈值 |

## 处理 — 连通域（1个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `connected_components` | `(Image, Int) -> (ConnectedComponentLabelImage, Array[ConnectedComponent])` | 标记连通域（4/8连通） |

## 处理 — 积分图像（6个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `integral_image` | `(Image) -> IntegralImage` | 计算积分图像 |
| `integral_image_sq` | `(Image) -> IntegralImageSq` | 计算平方积分图像 |
| `integral_sum` | `(IntegralImage, Int, Int, Int, Int) -> Int64` | 矩形求和 O(1) |
| `integral_sum_sq` | `(IntegralImageSq, Int, Int, Int, Int) -> Int64` | 矩形平方和 O(1) |
| `integral_mean` | `(IntegralImage, Int, Int, Int, Int) -> Float` | 矩形均值 O(1) |
| `integral_variance` | `(IntegralImage, IntegralImageSq, Int, Int, Int, Int) -> Float` | 矩形方差 O(1) |

## 处理 — 霍夫变换（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `hough_lines` | `(Image, Int, theta_resolution?: Float, rho_resolution?: Float) -> Array[HoughLine]` | 直线检测 |
| `hough_lines_nms` | `(Array[HoughLine], rho_threshold?: Float, theta_threshold?: Float) -> Array[HoughLine]` | 非极大值抑制 |

## 处理 — LBP（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `lbp` | `(Image) -> Image` | 局部二值模式 |
| `lbp_uniform` | `(Image) -> Image` | 均匀LBP（58种模式） |

## 处理 — 图像金字塔（4个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `pyr_down` | `(Image) -> Image` | 下采样2x（高斯） |
| `pyr_up` | `(Image) -> Image` | 上采样2x（双线性） |
| `build_gaussian_pyramid` | `(Image, Int) -> Array[Image]` | 高斯金字塔（层数） |
| `build_laplacian_pyramid` | `(Image, Int) -> Array[Image]` | 拉普拉斯金字塔（层数） |

## 处理 — 双边滤波（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `bilateral_filter` | `(Image, Int, Float, Float) -> Image` | 双边滤波（半径，空间sigma，值域sigma） |
| `bilateral_filter_fast` | `(Image, Int, Float, Float, Int) -> Image` | 快速双边（降采样近似） |

## 处理 — 轮廓（4个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `find_contours` | `(Image) -> Array[Contour]` | Moore边界跟踪 |
| `draw_contours` | `(Image, Array[Contour], Array[Byte]) -> Image` | 绘制轮廓 |
| `contour_perimeter` | `(Contour) -> Float` | 轮廓周长 |
| `contour_area` | `(Contour) -> Float` | 轮廓面积（鞋带公式） |

## 处理 — 分割（4个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `kmeans_segment` | `(Image, Int, max_iters?: Int) -> (SegmentLabelImage, Array[SegmentRegion])` | K-means分割 |
| `region_growing_segment` | `(Image, Array[(Int, Int)], threshold?: Int) -> (SegmentLabelImage, Array[SegmentRegion])` | 区域生长 |
| `flood_fill` | `(Image, Int, Int, Array[Byte], threshold?: Int) -> Image` | 泛洪填充 |
| `segment_to_color` | `(SegmentLabelImage) -> Image` | 标签图可视化 |

## 处理 — NLM去噪（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `nlm_denoise` | `(Image, patch_size?: Int, search_size?: Int, h?: Int) -> Image` | 非局部均值去噪 |
| `nlm_denoise_fast` | `(Image, patch_size?: Int, search_size?: Int, h?: Int, step?: Int) -> Image` | 快速NLM |

## 处理 — Retinex（3个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `ssr` | `(Image, sigma?: Float, gain?: Float, offset?: Float) -> Image` | 单尺度Retinex |
| `msr` | `(Image, sigmas?: Array[Float], gain?: Float, offset?: Float) -> Image` | 多尺度Retinex |
| `msrcr` | `(Image, sigmas?: Array[Float], gain?: Float, offset?: Float, alpha?: Float, beta?: Float) -> Image` | 多尺度Retinex带颜色恢复 |

## 处理 — Canny边缘（1个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `canny_edge` | `(Image, low_threshold?: Int, high_threshold?: Int) -> Image` | Canny边缘检测 |

## 处理 — 分水岭（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `watershed` | `(Image, Array[Int]) -> Array[Int]` | 分水岭（标记点） |
| `watershed_auto` | `(Image) -> (Array[Int], Int)` | 自动分水岭 |

## 处理 — GLCM纹理（3个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `compute_glcm` | `(Image, Int, Int, levels?: Int) -> Array[Array[Int]]` | 计算GLCM |
| `glcm_features` | `(Array[Array[Int]]) -> GlcmFeatures` | GLCM特征 |
| `glcm_features_multi_direction` | `(Image, levels?: Int) -> Array[GlcmFeatures]` | 多方向GLCM特征 |

## 处理 — Haar小波（5个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `haar_transform_1d` | `(Array[Float]) -> Array[Float]` | 一维Haar变换 |
| `haar_inverse_transform_1d` | `(Array[Float]) -> Array[Float]` | 一维Haar逆变换 |
| `haar_transform_2d` | `(Image, levels?: Int) -> HaarWaveletResult` | 二维Haar变换 |
| `haar_inverse_transform_2d` | `(HaarWaveletResult) -> Image` | 二维Haar逆变换 |
| `haar_denoise` | `(Image, threshold?: Float, soft?: Bool, levels?: Int) -> Image` | Haar小波去噪 |

## 处理 — Harris角点（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `harris_corners` | `(Image, k?: Float, threshold?: Float, min_distance?: Int) -> Array[CornerPoint]` | Harris角点检测 |
| `draw_corners` | `(Image, Array[CornerPoint], color?: Array[Byte], radius?: Int) -> Image` | 绘制角点标记 |

## 处理 — 去雾（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `dehaze` | `(Image, patch_size?: Int, omega?: Float, t0?: Float) -> Image` | 暗通道先验去雾 |
| `guided_filter` | `(Image, Array[Float], radius?: Int, eps?: Float) -> Array[Float]` | 引导滤波 |

## 处理 — 距离变换（3个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `distance_transform` | `(Image, distance_type?: Int) -> Array[Float]` | 距离变换（1=L1, 2=L2, 3=Linf） |
| `distance_transform_visualize` | `(Array[Float], Int, Int) -> Image` | 距离场可视化 |
| `skeletonize` | `(Image) -> Image` | 骨架化 |

## 处理 — Gabor滤波（3个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `gabor_filter` | `(Image, Int, Float, Float, lambda?: Float, gamma?: Float, phi?: Float) -> Image` | Gabor滤波 |
| `gabor_filter_bank` | `(Image, Int, Float, num_orientations?: Int, lambda?: Float, gamma?: Float) -> Image` | Gabor滤波器组 |
| `gabor_kernel` | `(Int, Float, Float, lambda?: Float, gamma?: Float, phi?: Float) -> Array[Array[Float]]` | 获取Gabor核 |

---

## 工具 — 像素操作（3个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `threshold` | `(Image, Int) -> Image` | 二值阈值 |
| `posterize` | `(Image, Int) -> Image` | 色调分离 |
| `extract_channel` | `(Image, Int) -> Image` | 提取单通道 |

## 工具 — 高级像素操作（4个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `set_alpha` | `(Image, Byte) -> Image` | 设置统一Alpha |
| `fill_alpha` | `(Image, Int, Byte, Byte, Byte) -> Image` | 用颜色填充Alpha |
| `replace_color` | `(Image, Array[Byte], Array[Byte], Int) -> Image` | 颜色替换 |
| `apply_lut` | `(Image, Array[Byte]) -> Image` | 应用查找表 |

## 工具 — 图像工具（4个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `pad` | `(Image, Int, Int, Array[Byte]) -> Image` | 边缘填充 |
| `add_border` | `(Image, Int, Int, Int, Int, Array[Byte]) -> Image` | 非对称边框 |
| `resize_to_cover` | `(Image, Int, Int) -> Image` | 缩放至覆盖 |
| `resize_to_contain` | `(Image, Int, Int, Array[Byte]) -> Image` | 缩放至包含 |

## 工具 — 图像合成（5个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `hstack` | `(Image, Image) -> Image` | 水平拼接 |
| `vstack` | `(Image, Image) -> Image` | 垂直拼接 |
| `tile` | `(Image, Int, Int) -> Image` | 平铺 |
| `flip_vertical` | `(Image) -> Image` | 垂直翻转 |
| `transpose` | `(Image) -> Image` | 转置 |

## 工具 — 噪声（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `add_noise_gaussian` | `(Image, Float, UInt) -> Image` | 高斯噪声（sigma, 种子） |
| `add_noise_salt_pepper` | `(Image, Float, UInt) -> Image` | 椒盐噪声（比例, 种子） |

## 工具 — 色彩映射（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `gradient_map` | `(Image, Array[(Int, Byte, Byte, Byte)]) -> Image` | 渐变色彩映射 |
| `swap_channels` | `(Image, Int, Int) -> Image` | 交换通道 |

## 工具 — 统计（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `compute_stats` | `(Image) -> ImageStats` | 计算图像统计 |
| `mean_value` | `(Image) -> Float` | 平均像素值 |

---

## 函数统计

| 分类 | 函数数 | 版本 |
|------|--------|------|
| I/O — 加载 | 8 | v0.1-v0.4 |
| I/O — 写入 | 10 | v0.2-v1.1 |
| I/O — 缩放 | 4 | v1.1 |
| I/O — 格式检测 | 3 | v1.2 |
| I/O — 查询 | 7 | v0.3 |
| I/O — 配置 | 8 | v0.3-v0.4 |
| I/O — 文件 | 1 | v0.3 |
| 编解码 — QOI | 2 | v1.2 |
| 编解码 — ICO/ICNS | 3 | v1.2 |
| 编解码 — GIF/PNM | 4 | v1.2-v1.5 |
| 元数据 | 4 | v1.5-v1.6 |
| 处理 — 变换 | 7 | v1.3 |
| 处理 — 几何 | 2 | v1.4 |
| 处理 — 色彩转换 | 5 | v1.3 |
| 处理 — 色彩调整 | 8 | v1.4 |
| 处理 — 滤波器 | 6 | v1.4-v1.10 |
| 处理 — 直方图 | 3 | v1.4 |
| 处理 — 量化 | 2 | v1.4 |
| 处理 — 形态学 | 4 | v1.10 |
| 处理 — 绘制 | 2 | v1.3 |
| 处理 — 质量评估 | 3 | v1.10 |
| 处理 — 混合模式 | 13 | v1.7-v1.12 |
| 处理 — 高级处理 | 5 | v1.8-v1.12 |
| 处理 — FFT/频域 | 6 | v1.12-v1.13 |
| 处理 — 自适应阈值 | 3 | v1.13 |
| 处理 — 连通域 | 1 | v1.13 |
| 处理 — 积分图像 | 6 | v1.13 |
| 处理 — 霍夫变换 | 2 | v1.14 |
| 处理 — LBP | 2 | v1.14 |
| 处理 — 图像金字塔 | 4 | v1.14 |
| 处理 — 双边滤波 | 2 | v1.14 |
| 处理 — 轮廓 | 4 | v1.15 |
| 处理 — 分割 | 4 | v1.15 |
| 处理 — NLM去噪 | 2 | v1.15 |
| 处理 — Retinex | 3 | v1.15 |
| 处理 — Canny边缘 | 1 | v1.16 |
| 处理 — 分水岭 | 2 | v1.16 |
| 处理 — GLCM纹理 | 3 | v1.16 |
| 处理 — Haar小波 | 5 | v1.16 |
| 处理 — Harris角点 | 2 | v1.17 |
| 处理 — 去雾 | 2 | v1.17 |
| 处理 — 距离变换 | 3 | v1.17 |
| 处理 — Gabor滤波 | 3 | v1.17 |
| 工具 — 像素操作 | 3 | v1.7 |
| 工具 — 高级像素操作 | 4 | v1.8-v1.9 |
| 工具 — 图像工具 | 4 | v1.7-v1.8 |
| 工具 — 图像合成 | 5 | v1.9 |
| 工具 — 噪声 | 2 | v1.9 |
| 工具 — 色彩映射 | 2 | v1.8-v1.9 |
| 工具 — 统计 | 2 | v1.8 |
| **总计** | **196** | |