# Pure API（纯 MoonBit）

路径：`src/pure/`（wasm/js 后端，依赖 types）

## 编解码

| 函数 | 签名 |
|------|------|
| `decode_bmp_pure` | `(data : Bytes) -> Image raise LoadError` |
| `decode_qoi_pure` | `(data : Bytes) -> Image raise LoadError` |
| `encode_qoi_pure` | `(img : Image) -> Bytes raise LoadError` |
| `decode_pnm_pure` | `(data : Bytes) -> Image raise LoadError` |
| `encode_ppm_pure` | `(img : Image) -> Bytes` |
| `encode_pgm_pure` | `(img : Image) -> Bytes` |
| `encode_pnm_pure` | `(img : Image) -> Bytes` |
| `decode_psd_pure` | `(data : Bytes) -> Image raise LoadError` |
| `decode_tga_pure` | `(data : Bytes) -> Image raise LoadError` |
| `decode_gif_pure` | `(data : Bytes) -> Image raise LoadError` |
| `encode_gif_pure` | `(img : Image) -> Bytes raise LoadError` |

## 变换

| 函数 | 说明 |
|------|------|
| `crop_pure` | 裁剪 |
| `rotate_90/180/270_pure` | 旋转 |
| `flip_horizontal_pure` | 水平翻转 |
| `warp_affine_pure` | 仿射变换 |
| `rotate_pure` | 任意角度旋转 |

## 色彩

| 函数 | 说明 |
|------|------|
| `to_grayscale_pure` | 转灰度 |
| `to_rgb_pure` / `to_rgba_pure` | 转 RGB/RGBA |
| `adjust_brightness/contrast/gamma_pure` | 亮度/对比度/Gamma |
| `invert_pure` | 反色 |
| `rgb_to_hsv_pure` / `hsv_to_rgb_pure` | RGB ↔ HSV |
| `rgb_to_hsl_pure` / `hsl_to_rgb_pure` | RGB ↔ HSL |

## 滤波

| 函数 | 说明 |
|------|------|
| `box_blur_pure` | 盒式模糊 |
| `gaussian_blur_pure` | 高斯模糊 |
| `sharpen_pure` | 锐化 |
| `edge_detect_sobel_pure` | Sobel 边缘检测 |

## 其他

| 函数 | 说明 |
|------|------|
| `histogram_pure` / `histogram_equalize_pure` / `histogram_normalize_pure` | 直方图 |
| `erode_pure` / `dilate_pure` / `morph_open_pure` / `morph_close_pure` | 形态学 |
| `threshold_pure` / `posterize_pure` / `extract_channel_pure` | 像素操作 |
| `pixelate_pure` / `replace_color_pure` / `convolve_pure` | 高级像素操作 |
| `hstack_pure` / `vstack_pure` / `tile_pure` / `transpose_pure` | 图像合成 |
| `add_noise_gaussian_pure` / `add_noise_salt_pepper_pure` | 噪声 |
| `compute_stats_pure` / `mean_value_pure` | 统计 |
| `blend_*_pure`（13 种） | 混合模式 |
