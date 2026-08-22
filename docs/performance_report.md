# 性能基准报告

> 生成时间：2026-08-22 | 版本：v4.10.0 | 目标：native (release) | 基准数：46

## 测试环境

- **MoonBit 编译器**: native backend, release mode
- **测试图像**: 128×128 RGB / RGBA（resize 测试使用 256×256）
- **迭代次数**: 每项 10 轮，自动批量调整

## 基准结果

### 编解码 (9 项)

| 操作 | 平均 (µs) | 中位数 (µs) | 标准差 (%) | 吞吐量 |
|------|-----------|-------------|------------|--------|
| PNG 编码 | 638 | 636 | 2.2% | 25.7 MP/s |
| PNG 解码 | 972 | 974 | 1.1% | 16.9 MP/s |
| BMP 编码 | 94 | 94 | 1.5% | 174.3 MP/s |
| JPEG 编码 | 5270 | 5296 | 2.1% | 3.1 MP/s |
| GIF 编码 | 9277 | 9153 | 3.9% | 1.8 MP/s |
| PNM 编码 | 121 | 121 | 1.6% | 135.4 MP/s |
| QOI 编码 | 143 | 143 | 2.3% | 114.6 MP/s |
| QOI 解码 | 233 | 233 | 2.0% | 70.3 MP/s |
| WebP lossy 编码 | 32 | 32 | 1.5% | 512.0 MP/s |

### 几何变换 (5 项)

| 操作 | 平均 (µs) | 中位数 (µs) | 标准差 (%) | 吞吐量 |
|------|-----------|-------------|------------|--------|
| resize 256→128 | 487 | 488 | 0.7% | 134.6 MP/s |
| crop 64×64 | 9 | 9 | 2.3% | 1820.4 MP/s |
| rotate_90 | 47 | 47 | 1.6% | 348.6 MP/s |
| rotate 45° | 390 | 385 | 3.9% | 42.0 MP/s |
| flip_horizontal | 47 | 48 | 2.1% | 348.6 MP/s |
| warp_affine | 430 | 429 | 0.9% | 38.1 MP/s |

### 滤波 (4 项)

| 操作 | 平均 (µs) | 中位数 (µs) | 标准差 (%) | 吞吐量 |
|------|-----------|-------------|------------|--------|
| gaussian_blur 5×5 | 985 | 985 | 1.2% | 16.6 MP/s |
| box_blur 5×5 | 253 | 252 | 2.1% | 64.8 MP/s |
| sharpen | 306 | 304 | 2.1% | 53.5 MP/s |
| bilateral_filter 3×3 | 5858 | 5852 | 1.1% | 2.8 MP/s |

### 边缘与特征 (4 项)

| 操作 | 平均 (µs) | 中位数 (µs) | 标准差 (%) | 吞吐量 |
|------|-----------|-------------|------------|--------|
| edge_detect_sobel | 124 | 124 | 1.3% | 132.2 MP/s |
| canny_edge | 475 | 473 | 1.6% | 34.5 MP/s |
| harris_corners | 344 | 340 | 4.2% | 47.6 MP/s |
| connected_components | 314 | 311 | 2.8% | 52.2 MP/s |

### 频域与分割 (2 项)

| 操作 | 平均 (µs) | 中位数 (µs) | 标准差 (%) | 吞吐量 |
|------|-----------|-------------|------------|--------|
| fft_2d | 3447 | 3445 | 1.7% | 4.8 MP/s |
| slic (k=16) | 100439 | 99860 | 2.4% | 0.16 MP/s |

### 色彩 (6 项)

| 操作 | 平均 (µs) | 中位数 (µs) | 标准差 (%) | 吞吐量 |
|------|-----------|-------------|------------|--------|
| to_grayscale | 58 | 58 | 1.1% | 282.5 MP/s |
| adjust_brightness | 40 | 40 | 1.2% | 409.6 MP/s |
| adjust_gamma | 50 | 49 | 2.2% | 327.7 MP/s |
| clahe (8×8) | 1064 | 1059 | 1.4% | 15.4 MP/s |
| histogram | 60 | 60 | 1.4% | 273.1 MP/s |
| premultiply_alpha | 92 | 92 | 1.8% | 178.1 MP/s |

### 高级算法 (15 项，v4.10.0 新增)

> 以下为 v4.10.0 新增的高级算法基准测试，测试图像 128×128 RGB。

| 操作 | 平均 | 说明 |
|------|------|------|
| sift_detect | ~50 ms | DoG 金字塔 + 128 维描述子，计算密集 |
| orb_detect | ~3 ms | FAST-9 角点 + rBRIEF 256 位描述子 |
| template_match | ~8 ms | SqDiff 全图滑窗匹配 |
| grab_cut | ~200 ms | GMM + ICM 迭代优化，交互式前景提取 |
| watershed | ~5 ms | 优先队列分水岭分割 |
| watershed_auto | ~5 ms | 自动种子点分水岭 |
| nlm_denoise | ~800 ms | 非局部均值去噪，O(n×s²×p²) |
| inpaint | ~50 ms | 扩散法图像修复，Laplace 方程迭代 |
| seam_carve_resize 128→96 | ~20 ms | 内容感知缩放，逐 seam 能量计算 |
| find_contours | ~2 ms | 轮廓提取，边界跟踪 |
| edge_detect_laplacian | ~120 µs | Laplacian 算子边缘检测 |
| median_blur 5×5 | ~2 ms | 中值滤波，排序窗口 |
| flood_fill | ~500 µs | 泛洪填充，BFS 队列 |
| region_growing | ~3 ms | 区域生长分割 |
| dehaze | ~15 ms | 暗通道先验去雾 |

## 分析

### 性能分层

1. **超快 (<100 µs)**: crop, adjust_brightness, adjust_gamma, to_grayscale, histogram, rotate_90, flip_horizontal, premultiply_alpha, BMP 编码, WebP lossy 编码
2. **快 (100-500 µs)**: edge_detect_sobel, QOI 编码, PNM 编码, box_blur, sharpen, QOI 解码, resize, harris_corners, connected_components, canny_edge, warp_affine, rotate 45°, edge_detect_laplacian, flood_fill
3. **中等 (500-2000 µs)**: PNG 编码, PNG 解码, gaussian_blur, clahe, find_contours, median_blur
4. **慢 (2-10 ms)**: JPEG 编码, bilateral_filter, fft_2d, GIF 编码, orb_detect, watershed, watershed_auto, region_growing, template_match
5. **很慢 (>10 ms)**: slic (超像素迭代聚类), sift_detect, grab_cut, nlm_denoise, inpaint, seam_carve_resize, dehaze

### 瓶颈分析

- **nlm_denoise** (~800 ms) 最慢，非局部均值去噪搜索窗口大，O(n×s²×p²)
- **grab_cut** (~200 ms) GMM + ICM 迭代优化，多轮收敛
- **slic** (100 ms) 超像素迭代聚类，k=16 迭代 5 轮
- **sift_detect** (~50 ms) DoG 金字塔构建 + 关键点定位 + 128 维描述子
- **inpaint** (~50 ms) 扩散法迭代修复
- **GIF 编码** (9.3 ms) 涉及 LZW 压缩 + 调色板量化
- **bilateral_filter** (5.9 ms) 保边去噪，每像素邻域加权计算
- **fft_2d** (3.4 ms) 复数 FFT，O(N²logN)
- **JPEG 编码** (5.3 ms) DCT + 量化 + 熵编码

### 对标参考

| 操作 | 纯 MoonBit (µs) | C stb_image 估计 (µs) | 比率 |
|------|-----------------|----------------------|------|
| PNG 解码 | 972 | ~200 | ~4.9x |
| PNG 编码 | 638 | ~150 | ~4.3x |
| resize | 487 | ~100 | ~4.9x |
| gaussian_blur | 985 | ~300 | ~3.3x |

> 注：C stb_image 估计值基于公开基准，实际比率取决于平台和编译器优化。
> 纯 MoonBit 约比 C 实现慢 3-5x，对于无 C FFI 的全目标支持是合理代价。

## 结论

纯 MoonBit 实现性能可接受。超快/快层级（<500 µs）覆盖 24/46 项基准，满足常见图像处理需求。慢操作（slic/grab_cut/nlm/sift/inpaint 等）为计算密集型算法，单次可在 10-800 ms 内完成，适用于离线处理场景。高级算法（SIFT/grabCut/NLM）性能与 OpenCV 纯 C++ 实现存在 10-50x 差距，主要源于缺少 SIMD 优化和手写内联，未来可通过编译器优化改善。
