# stb-image API Reference

> 版本 v1.17.0 | 199 公开函数 + 29 类型 | 533 测试 + 29 基准测试
>
> [English](API.en.md) | [中文](API.md)

## Type Overview

| Type | Package | Fields/Variants | Description |
|------|---------|-----------------|-------------|
| `Image` | core | `width, height, channels : Int; data : Bytes` | 8-bit decoded image |
| `Image16` | core | `width, height, channels : Int; data : Bytes` | 16-bit decoded image (UInt16 LE) |
| `ImageF` | core | `width, height, channels : Int; data : Bytes` | HDR float image (IEEE 754 LE) |
| `ImageInfo` | core | `width, height, channels : Int` | Image info (no pixel data) |
| `GifAnimation` | core | `frames : Array[Image]; delays : Array[Int]` | Animated GIF |
| `LoadError` | core | `FileIO(String) \| UnsupportedFormat(String) \| DecodeFailed(String)` | Load failure error |
| `ImageFormat` | core | `Png \| Jpeg \| Bmp \| Gif \| Tga \| Psd \| Hdr \| Pnm \| Qoi \| Unknown` | Image format enum |
| `ResizeFilter` | core | `Default \| Box \| Triangle \| CubicBSPline \| CatmullROM \| Mitchell \| PointSample` | Resize filter |
| `ResizeEdge` | core | `Clamp \| Reflect \| Wrap \| Zero` | Resize edge mode |
| `ExifInfo` | meta | `make, model, date_time : String; orientation : Int` | EXIF metadata |
| `PngTextChunk` | meta | `keyword, text : String` | PNG text chunk |
| `ImageStats` | util | `min, max, mean, std_dev : Float; histogram : Array[Int]` | Image statistics |
| `Complex` | process | `re, im : Float` | Complex number |
| `FFTResult` | process | `width, height : Int; data : Array[Complex]` | FFT result |
| `FreqFilterType` | process | `LowPass \| HighPass \| BandPass \| BandStop` | Frequency domain filter type |
| `ConnectedComponent` | process | `label, area, x, y, w, h : Int; centroid_x, centroid_y : Float` | Connected component |
| `ConnectedComponentLabelImage` | process | `width, height : Int; labels : Array[Int]` | Label image |
| `IntegralImage` | process | `width, height : Int; data : Array[Int64]` | Integral image |
| `IntegralImageSq` | process | `width, height : Int; data : Array[Int64]` | Squared integral image |
| `HoughLine` | process | `rho, theta : Float; votes : Int` | Hough line |
| `ContourPoint` | process | `x, y : Int` | Contour point |
| `Contour` | process | `points : Array[ContourPoint]; is_hole : Bool` | Contour |
| `SegmentLabelImage` | process | `width, height : Int; labels : Array[Int]` | Segmentation label image |
| `SegmentRegion` | process | `label, area : Int; centroid_x, centroid_y : Float; mean_color : Array[Byte]` | Segmentation region |
| `GlcmFeatures` | process | `contrast, correlation, energy, homogeneity, entropy, asm, dissimilarity : Float` | GLCM features |
| `HaarWaveletResult` | process | `width, height, channels : Int; ll : Array[Float]; lh, hl, hh : Array[Array[Float]]; levels : Int` | Haar wavelet result |
| `CornerPoint` | process | `x, y : Int; response : Float` | Corner point |

All types derive `Eq` and `@debug.Debug`.

---

## I/O — Load (8 functions)

All load functions accept an optional parameter `req_channels : Int?` (1=grayscale, 2=grayscale+Alpha, 3=RGB, 4=RGBA). Pass `None` to keep the original channel count.

| Function | Signature | Returns | Description |
|----------|-----------|---------|-------------|
| `load_from_path` | `(String, req_channels?: Int?) -> Image` | 8-bit image | Load from file |
| `load_from_bytes` | `(Bytes, req_channels?: Int?) -> Image` | 8-bit image | Load from memory |
| `load_16_from_path` | `(String, req_channels?: Int?) -> Image16` | 16-bit image | Load 16-bit from file |
| `load_16_from_bytes` | `(Bytes, req_channels?: Int?) -> Image16` | 16-bit image | Load 16-bit from memory |
| `loadf_from_path` | `(String, req_channels?: Int?) -> ImageF` | HDR float | Load HDR from file |
| `loadf_from_bytes` | `(Bytes, req_channels?: Int?) -> ImageF` | HDR float | Load HDR from memory |
| `load_gif_from_path` | `(String, req_channels?: Int?) -> GifAnimation` | Animated GIF | Load GIF from file |
| `load_gif_from_bytes` | `(Bytes, req_channels?: Int?) -> GifAnimation` | Animated GIF | Load GIF from memory |

## I/O — Write (10 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `write_png_to_path` | `(String, Image) -> Unit` | Write PNG file |
| `write_bmp_to_path` | `(String, Image) -> Unit` | Write BMP file |
| `write_tga_to_path` | `(String, Image) -> Unit` | Write TGA file |
| `write_jpeg_to_path` | `(String, Image, quality?: Int) -> Unit` | Write JPEG (default quality 90) |
| `write_hdr_to_path` | `(String, ImageF) -> Unit` | Write HDR file |
| `write_png_to_bytes` | `(Image) -> Bytes` | Encode PNG to bytes |
| `write_bmp_to_bytes` | `(Image) -> Bytes` | Encode BMP to bytes |
| `write_tga_to_bytes` | `(Image) -> Bytes` | Encode TGA to bytes |
| `write_jpeg_to_bytes` | `(Image, quality?: Int) -> Bytes` | Encode JPEG to bytes |
| `write_hdr_to_bytes` | `(ImageF) -> Bytes` | Encode HDR to bytes |

## I/O — Resize (4 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `resize` | `(Image, Int, Int, filter?: ResizeFilter, edge?: ResizeEdge) -> Image` | 8-bit resize |
| `resize_srgb` | `(Image, Int, Int, filter?, edge?) -> Image` | Resize in sRGB color space |
| `resize_16` | `(Image16, Int, Int, filter?, edge?) -> Image16` | 16-bit resize |
| `resizef` | `(ImageF, Int, Int, filter?, edge?) -> ImageF` | Float resize |

## I/O — Format Detection (3 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `detect_format` | `(Bytes) -> ImageFormat` | Detect format from magic bytes |
| `decode_any` | `(Bytes, req_channels?: Int?) -> Image` | Auto-detect and decode |
| `is_supported_format` | `(Bytes) -> Bool` | Check if format is supported |

## I/O — Query (7 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `info_from_path` | `(String) -> ImageInfo?` | Query info from file (no decode) |
| `info_from_bytes` | `(Bytes) -> ImageInfo?` | Query info from memory |
| `is_16_bit_from_path` | `(String) -> Bool` | Check if 16-bit |
| `is_16_bit_from_bytes` | `(Bytes) -> Bool` | Check if 16-bit |
| `is_hdr_from_path` | `(String) -> Bool` | Check if HDR |
| `is_hdr_from_bytes` | `(Bytes) -> Bool` | Check if HDR |
| `failure_reason` | `() -> String` | Get last stb_image failure reason |

## I/O — Configuration (8 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `set_flip_vertically_on_load` | `(Bool) -> Unit` | Flip vertically on load |
| `flip_vertically_on_write` | `(Bool) -> Unit` | Flip vertically on write |
| `set_unpremultiply_on_load` | `(Bool) -> Unit` | Unpremultiply alpha on load |
| `convert_iphone_png_to_rgb` | `(Bool) -> Unit` | Convert iPhone PNG to RGB |
| `hdr_to_ldr_gamma` | `(Float) -> Unit` | HDR to LDR gamma (default 1.0) |
| `hdr_to_ldr_scale` | `(Float) -> Unit` | HDR to LDR scale (default 1.0) |
| `ldr_to_hdr_gamma` | `(Float) -> Unit` | LDR to HDR gamma (default 1.0) |
| `ldr_to_hdr_scale` | `(Float) -> Unit` | LDR to HDR scale (default 1.0) |

## I/O — File (1 function)

| Function | Signature | Description |
|----------|-----------|-------------|
| `read_file_bytes` | `(String) -> Bytes` | Read raw file bytes |

---

## Codec — QOI (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `decode_qoi` | `(Bytes) -> Image` | Decode QOI format |
| `encode_qoi` | `(Image) -> Bytes` | Encode QOI format |

## Codec — ICO/ICNS (3 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `encode_ico` | `(Image) -> Bytes` | Encode single-size ICO (PNG payload) |
| `encode_ico_sizes` | `(Array[Image]) -> Bytes` | Encode multi-size ICO |
| `encode_icns` | `(Image) -> Bytes` | Encode ICNS (PNG payload) |

## Codec — GIF/PNM (4 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `encode_gif` | `(Image) -> Bytes` | Encode single-frame GIF89a |
| `encode_gif_animation` | `(GifAnimation) -> Bytes` | Encode multi-frame GIF89a |
| `encode_ppm` | `(Image) -> Bytes` | Encode PPM (P6) |
| `encode_pgm` | `(Image) -> Bytes` | Encode PGM (P5) |

---

## Metadata (4 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `read_exif_from_bytes` | `(Bytes) -> ExifInfo?` | Read EXIF from JPEG bytes |
| `read_exif_from_path` | `(String) -> ExifInfo?` | Read EXIF from JPEG file |
| `read_png_text_chunks` | `(Bytes) -> Array[PngTextChunk]` | Read PNG tEXt/iTXt text chunks |
| `read_png_text_chunks_from_path` | `(String) -> Array[PngTextChunk]` | Read PNG text chunks from file |

---

## Process — Transform (7 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `crop` | `(Image, Int, Int, Int, Int) -> Image` | Crop region (x, y, w, h) |
| `crop_16` | `(Image16, Int, Int, Int, Int) -> Image16` | Crop 16-bit |
| `cropf` | `(ImageF, Int, Int, Int, Int) -> ImageF` | Crop float |
| `rotate_90` | `(Image) -> Image` | Rotate 90° clockwise |
| `rotate_180` | `(Image) -> Image` | Rotate 180° |
| `rotate_270` | `(Image) -> Image` | Rotate 270° clockwise |
| `flip_horizontal` | `(Image) -> Image` | Flip horizontally |

## Process — Geometry (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `warp_affine` | `(Image, (Float,Float,Float,Float,Float,Float), Int, Int) -> Image` | Affine transform (bilinear interpolation) |
| `rotate` | `(Image, Float) -> Image` | Rotate by arbitrary angle |

## Process — Color Conversion (5 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `to_grayscale` | `(Image) -> Image` | Convert to grayscale |
| `to_rgb` | `(Image) -> Image` | Remove alpha channel |
| `to_rgba` | `(Image) -> Image` | Add alpha channel |
| `premultiply_alpha` | `(Image) -> Image` | Premultiply alpha |
| `unpremultiply_alpha` | `(Image) -> Image` | Unpremultiply alpha |

## Process — Color Adjustment (8 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `adjust_brightness` | `(Image, Int) -> Image` | Adjust brightness (delta) |
| `adjust_contrast` | `(Image, Float) -> Image` | Adjust contrast (factor) |
| `adjust_gamma` | `(Image, Float) -> Image` | Gamma correction |
| `invert` | `(Image) -> Image` | Invert colors |
| `rgb_to_hsv` | `(Int, Int, Int) -> (Float, Float, Float)` | RGB to HSV |
| `hsv_to_rgb` | `(Float, Float, Float) -> (Int, Int, Int)` | HSV to RGB |
| `rgb_to_hsl` | `(Int, Int, Int) -> (Float, Float, Float)` | RGB to HSL |
| `hsl_to_rgb` | `(Float, Float, Float) -> (Int, Int, Int)` | HSL to RGB |

## Process — Filters (6 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `box_blur` | `(Image, Int) -> Image` | Box blur (sliding window) |
| `gaussian_blur` | `(Image, Int, Float) -> Image` | Gaussian blur (separable kernel) |
| `sharpen` | `(Image, Float) -> Image` | Sharpen (Laplacian) |
| `edge_detect_sobel` | `(Image) -> Image` | Sobel edge detection |
| `edge_detect_laplacian` | `(Image) -> Image` | Laplacian edge detection |
| `edge_detect_prewitt` | `(Image) -> Image` | Prewitt edge detection |

## Process — Histogram (3 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `histogram` | `(Image) -> Array[Int]` | Compute histogram (256 bins) |
| `histogram_equalize` | `(Image) -> Image` | Histogram equalization |
| `histogram_normalize` | `(Image) -> Image` | Histogram normalization |

## Process — Quantization (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `floyd_steinberg` | `(Image, Int) -> Image` | Floyd-Steinberg dithering |
| `median_cut` | `(Image, Int) -> Image` | Median cut quantization |

## Process — Morphology (4 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `erode` | `(Image) -> Image` | Erode (3x3 minimum) |
| `dilate` | `(Image) -> Image` | Dilate (3x3 maximum) |
| `morph_open` | `(Image) -> Image` | Opening (erode then dilate) |
| `morph_close` | `(Image) -> Image` | Closing (dilate then erode) |

## Process — Drawing (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_copy` | `(Image, Image, Int, Int) -> Image` | Copy source image to target at (x,y) |
| `draw_over` | `(Image, Image, Int, Int) -> Image` | Alpha-blend source image over target |

## Process — Quality Assessment (3 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `mse` | `(Image, Image) -> Double` | Mean squared error |
| `psnr` | `(Image, Image) -> Double` | Peak signal-to-noise ratio (dB) |
| `ssim` | `(Image, Image) -> Double` | Structural similarity index [-1, 1] |

## Process — Blend Modes (13 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `blend_multiply` | `(Image, Image) -> Image` | Multiply |
| `blend_screen` | `(Image, Image) -> Image` | Screen |
| `blend_overlay` | `(Image, Image) -> Image` | Overlay |
| `blend_darken` | `(Image, Image) -> Image` | Darken |
| `blend_lighten` | `(Image, Image) -> Image` | Lighten |
| `blend_difference` | `(Image, Image) -> Image` | Difference |
| `blend_exclusion` | `(Image, Image) -> Image` | Exclusion |
| `blend_color_dodge` | `(Image, Image) -> Image` | Color dodge |
| `blend_color_burn` | `(Image, Image) -> Image` | Color burn |
| `blend_hard_light` | `(Image, Image) -> Image` | Hard light |
| `blend_soft_light` | `(Image, Image) -> Image` | Soft light |
| `blend_linear_dodge` | `(Image, Image) -> Image` | Linear dodge |
| `blend_linear_burn` | `(Image, Image) -> Image` | Linear burn |

## Process — Advanced (5 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `clahe` | `(Image, Int, Float) -> Image` | CLAHE (tile size, clip limit) |
| `k_means_quantize` | `(Image, Int, Int) -> Image` | K-means color quantization (k, max iterations) |
| `convolve` | `(Image, Array[Float], Float, Float) -> Image` | Generic convolution (kernel, divisor, offset) |
| `pixelate` | `(Image, Int) -> Image` | Pixelate effect (block size) |
| `replace_color` | `(Image, Array[Byte], Array[Byte], Int) -> Image` | Color replacement (tolerance) |

## Process — FFT/Frequency Domain (6 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `fft_2d` | `(Image) -> Array[FFTResult]` | 2D FFT (per channel) |
| `ifft_2d` | `(FFTResult) -> Image` | 2D inverse FFT |
| `fft_magnitude` | `(FFTResult, Bool) -> Image` | FFT magnitude spectrum |
| `fft_shift` | `(FFTResult) -> FFTResult` | FFT centering |
| `freq_filter` | `(Image, FreqFilterType, Float, band_width?: Float) -> Image` | Ideal frequency filter |
| `freq_filter_gaussian` | `(Image, FreqFilterType, Float, band_width?: Float) -> Image` | Gaussian frequency filter |

## Process — Adaptive Threshold (3 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `adaptive_threshold_mean` | `(Image, Int, Int) -> Image` | Mean adaptive threshold |
| `adaptive_threshold_gaussian` | `(Image, Int, Int) -> Image` | Gaussian-weighted adaptive threshold |
| `threshold_otsu` | `(Image) -> Image` | Otsu auto threshold |

## Process — Connected Components (1 function)

| Function | Signature | Description |
|----------|-----------|-------------|
| `connected_components` | `(Image, Int) -> (ConnectedComponentLabelImage, Array[ConnectedComponent])` | Label connected components (4/8-connectivity) |

## Process — Integral Image (6 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `integral_image` | `(Image) -> IntegralImage` | Compute integral image |
| `integral_image_sq` | `(Image) -> IntegralImageSq` | Compute squared integral image |
| `integral_sum` | `(IntegralImage, Int, Int, Int, Int) -> Int64` | Rectangular sum O(1) |
| `integral_sum_sq` | `(IntegralImageSq, Int, Int, Int, Int) -> Int64` | Rectangular sum of squares O(1) |
| `integral_mean` | `(IntegralImage, Int, Int, Int, Int) -> Float` | Rectangular mean O(1) |
| `integral_variance` | `(IntegralImage, IntegralImageSq, Int, Int, Int, Int) -> Float` | Rectangular variance O(1) |

## Process — Hough Transform (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `hough_lines` | `(Image, Int, theta_resolution?: Float, rho_resolution?: Float) -> Array[HoughLine]` | Line detection |
| `hough_lines_nms` | `(Array[HoughLine], rho_threshold?: Float, theta_threshold?: Float) -> Array[HoughLine]` | Non-maximum suppression |

## Process — LBP (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `lbp` | `(Image) -> Image` | Local binary pattern |
| `lbp_uniform` | `(Image) -> Image` | Uniform LBP (58 patterns) |

## Process — Image Pyramid (4 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `pyr_down` | `(Image) -> Image` | Downsample 2x (Gaussian) |
| `pyr_up` | `(Image) -> Image` | Upsample 2x (bilinear) |
| `build_gaussian_pyramid` | `(Image, Int) -> Array[Image]` | Gaussian pyramid (levels) |
| `build_laplacian_pyramid` | `(Image, Int) -> Array[Image]` | Laplacian pyramid (levels) |

## Process — Bilateral Filter (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `bilateral_filter` | `(Image, Int, Float, Float) -> Image` | Bilateral filter (radius, spatial sigma, range sigma) |
| `bilateral_filter_fast` | `(Image, Int, Float, Float, Int) -> Image` | Fast bilateral (downsampled approximation) |

## Process — Contours (4 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `find_contours` | `(Image) -> Array[Contour]` | Moore boundary tracing |
| `draw_contours` | `(Image, Array[Contour], Array[Byte]) -> Image` | Draw contours |
| `contour_perimeter` | `(Contour) -> Float` | Contour perimeter |
| `contour_area` | `(Contour) -> Float` | Contour area (shoelace formula) |

## Process — Segmentation (4 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `kmeans_segment` | `(Image, Int, max_iters?: Int) -> (SegmentLabelImage, Array[SegmentRegion])` | K-means segmentation |
| `region_growing_segment` | `(Image, Array[(Int, Int)], threshold?: Int) -> (SegmentLabelImage, Array[SegmentRegion])` | Region growing |
| `flood_fill` | `(Image, Int, Int, Array[Byte], threshold?: Int) -> Image` | Flood fill |
| `segment_to_color` | `(SegmentLabelImage) -> Image` | Label image visualization |

## Process — NLM Denoising (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `nlm_denoise` | `(Image, patch_size?: Int, search_size?: Int, h?: Int) -> Image` | Non-local means denoising |
| `nlm_denoise_fast` | `(Image, patch_size?: Int, search_size?: Int, h?: Int, step?: Int) -> Image` | Fast NLM |

## Process — Retinex (3 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `ssr` | `(Image, sigma?: Float, gain?: Float, offset?: Float) -> Image` | Single-scale Retinex |
| `msr` | `(Image, sigmas?: Array[Float], gain?: Float, offset?: Float) -> Image` | Multi-scale Retinex |
| `msrcr` | `(Image, sigmas?: Array[Float], gain?: Float, offset?: Float, alpha?: Float, beta?: Float) -> Image` | Multi-scale Retinex with color restoration |

## Process — Canny Edge (1 function)

| Function | Signature | Description |
|----------|-----------|-------------|
| `canny_edge` | `(Image, low_threshold?: Int, high_threshold?: Int) -> Image` | Canny edge detection |

## Process — Watershed (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `watershed` | `(Image, Array[Int]) -> Array[Int]` | Watershed (marker points) |
| `watershed_auto` | `(Image) -> (Array[Int], Int)` | Auto watershed |

## Process — GLCM Texture (3 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `compute_glcm` | `(Image, Int, Int, levels?: Int) -> Array[Array[Int]]` | Compute GLCM |
| `glcm_features` | `(Array[Array[Int]]) -> GlcmFeatures` | GLCM features |
| `glcm_features_multi_direction` | `(Image, levels?: Int) -> Array[GlcmFeatures]` | Multi-direction GLCM features |

## Process — Haar Wavelet (5 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `haar_transform_1d` | `(Array[Float]) -> Array[Float]` | 1D Haar transform |
| `haar_inverse_transform_1d` | `(Array[Float]) -> Array[Float]` | 1D Haar inverse transform |
| `haar_transform_2d` | `(Image, levels?: Int) -> HaarWaveletResult` | 2D Haar transform |
| `haar_inverse_transform_2d` | `(HaarWaveletResult) -> Image` | 2D Haar inverse transform |
| `haar_denoise` | `(Image, threshold?: Float, soft?: Bool, levels?: Int) -> Image` | Haar wavelet denoising |

## Process — Harris Corners (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `harris_corners` | `(Image, k?: Float, threshold?: Float, min_distance?: Int) -> Array[CornerPoint]` | Harris corner detection |
| `draw_corners` | `(Image, Array[CornerPoint], color?: Array[Byte], radius?: Int) -> Image` | Draw corner markers |

## Process — Dehazing (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `dehaze` | `(Image, patch_size?: Int, omega?: Float, t0?: Float) -> Image` | Dark channel prior dehazing |
| `guided_filter` | `(Image, Array[Float], radius?: Int, eps?: Float) -> Array[Float]` | Guided filter |

## Process — Distance Transform (3 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `distance_transform` | `(Image, distance_type?: Int) -> Array[Float]` | Distance transform (1=L1, 2=L2, 3=Linf) |
| `distance_transform_visualize` | `(Array[Float], Int, Int) -> Image` | Distance field visualization |
| `skeletonize` | `(Image) -> Image` | Skeletonization |

## Process — Gabor Filter (3 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `gabor_filter` | `(Image, Int, Float, Float, lambda?: Float, gamma?: Float, phi?: Float) -> Image` | Gabor filter |
| `gabor_filter_bank` | `(Image, Int, Float, num_orientations?: Int, lambda?: Float, gamma?: Float) -> Image` | Gabor filter bank |
| `gabor_kernel` | `(Int, Float, Float, lambda?: Float, gamma?: Float, phi?: Float) -> Array[Array[Float]]` | Get Gabor kernel |

---

## Utility — Pixel Operations (3 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `threshold` | `(Image, Int) -> Image` | Binary threshold |
| `posterize` | `(Image, Int) -> Image` | Posterize |
| `extract_channel` | `(Image, Int) -> Image` | Extract single channel |

## Utility — Advanced Pixel Operations (4 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `set_alpha` | `(Image, Byte) -> Image` | Set uniform alpha |
| `fill_alpha` | `(Image, Int, Byte, Byte, Byte) -> Image` | Fill alpha with color |
| `replace_color` | `(Image, Array[Byte], Array[Byte], Int) -> Image` | Color replacement |
| `apply_lut` | `(Image, Array[Byte]) -> Image` | Apply lookup table |

## Utility — Image Utilities (4 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `pad` | `(Image, Int, Int, Array[Byte]) -> Image` | Edge padding |
| `add_border` | `(Image, Int, Int, Int, Int, Array[Byte]) -> Image` | Asymmetric border |
| `resize_to_cover` | `(Image, Int, Int) -> Image` | Resize to cover |
| `resize_to_contain` | `(Image, Int, Int, Array[Byte]) -> Image` | Resize to contain |

## Utility — Image Composition (5 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `hstack` | `(Image, Image) -> Image` | Horizontal concatenation |
| `vstack` | `(Image, Image) -> Image` | Vertical concatenation |
| `tile` | `(Image, Int, Int) -> Image` | Tiling |
| `flip_vertical` | `(Image) -> Image` | Flip vertically |
| `transpose` | `(Image) -> Image` | Transpose |

## Utility — Noise (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `add_noise_gaussian` | `(Image, Float, UInt) -> Image` | Gaussian noise (sigma, seed) |
| `add_noise_salt_pepper` | `(Image, Float, UInt) -> Image` | Salt-and-pepper noise (ratio, seed) |

## Utility — Color Mapping (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `gradient_map` | `(Image, Array[(Int, Byte, Byte, Byte)]) -> Image` | Gradient color mapping |
| `swap_channels` | `(Image, Int, Int) -> Image` | Swap channels |

## Utility — Statistics (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `compute_stats` | `(Image) -> ImageStats` | Compute image statistics |
| `mean_value` | `(Image) -> Float` | Mean pixel value |

---

## Function Statistics

| Category | Count | Version |
|----------|-------|---------|
| I/O — Load | 8 | v0.1-v0.4 |
| I/O — Write | 10 | v0.2-v1.1 |
| I/O — Resize | 4 | v1.1 |
| I/O — Format Detection | 3 | v1.2 |
| I/O — Query | 7 | v0.3 |
| I/O — Configuration | 8 | v0.3-v0.4 |
| I/O — File | 1 | v0.3 |
| Codec — QOI | 2 | v1.2 |
| Codec — ICO/ICNS | 3 | v1.2 |
| Codec — GIF/PNM | 4 | v1.2-v1.5 |
| Metadata | 4 | v1.5-v1.6 |
| Process — Transform | 7 | v1.3 |
| Process — Geometry | 2 | v1.4 |
| Process — Color Conversion | 5 | v1.3 |
| Process — Color Adjustment | 8 | v1.4 |
| Process — Filters | 6 | v1.4-v1.10 |
| Process — Histogram | 3 | v1.4 |
| Process — Quantization | 2 | v1.4 |
| Process — Morphology | 4 | v1.10 |
| Process — Drawing | 2 | v1.3 |
| Process — Quality Assessment | 3 | v1.10 |
| Process — Blend Modes | 13 | v1.7-v1.12 |
| Process — Advanced | 5 | v1.8-v1.12 |
| Process — FFT/Frequency Domain | 6 | v1.12-v1.13 |
| Process — Adaptive Threshold | 3 | v1.13 |
| Process — Connected Components | 1 | v1.13 |
| Process — Integral Image | 6 | v1.13 |
| Process — Hough Transform | 2 | v1.14 |
| Process — LBP | 2 | v1.14 |
| Process — Image Pyramid | 4 | v1.14 |
| Process — Bilateral Filter | 2 | v1.14 |
| Process — Contours | 4 | v1.15 |
| Process — Segmentation | 4 | v1.15 |
| Process — NLM Denoising | 2 | v1.15 |
| Process — Retinex | 3 | v1.15 |
| Process — Canny Edge | 1 | v1.16 |
| Process — Watershed | 2 | v1.16 |
| Process — GLCM Texture | 3 | v1.16 |
| Process — Haar Wavelet | 5 | v1.16 |
| Process — Harris Corners | 2 | v1.17 |
| Process — Dehazing | 2 | v1.17 |
| Process — Distance Transform | 3 | v1.17 |
| Process — Gabor Filter | 3 | v1.17 |
| Utility — Pixel Operations | 3 | v1.7 |
| Utility — Advanced Pixel Operations | 4 | v1.8-v1.9 |
| Utility — Image Utilities | 4 | v1.7-v1.8 |
| Utility — Image Composition | 5 | v1.9 |
| Utility — Noise | 2 | v1.9 |
| Utility — Color Mapping | 2 | v1.8-v1.9 |
| Utility — Statistics | 2 | v1.8 |
| **Total** | **199** | |