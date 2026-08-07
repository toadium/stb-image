# Changelog

> [English](CHANGELOG.md) | [中文](CHANGELOG.zh.md)

## Version History

| Version | Highlights | Tests |
|---------|-----------|-------|
| v0.1 | 8-bit load (path + bytes), 9 formats | 23 |
| v0.2 | write (PNG/BMP/TGA/JPEG) + req_channels + flip | 32 |
| v0.3 | 16-bit/float load + info + failure_reason + config | 55 |
| v0.4 | HDR config + animated GIF | 61 |
| v1.0 | API freeze, complete docs, ASan verified | 61 |
| v1.1 | HDR write + resize (FFI stb_image_resize2.h) | 75 |
| v1.2 | QOI/ICO/ICNS/GIF encode + format auto-detect | 114 |
| v1.3 | crop/rotate/flip + color convert + draw/compositing | 145 |
| v1.4 | color adjust + filters + geometry + histogram + quantize | 206 |
| v1.5 | PNM encode + GIF animation + EXIF reading | 229 |
| **v1.6** | **PNG metadata + roundtrip tests + benchmarks** | **254+29** |
| **v1.7** | **pad/border/resize_to_cover/contain + threshold/posterize/extract_channel + blend modes** | **275+29** |
| **v1.8** | **more blend modes + stats + pixelate/replace_color/convolve/swap_channels** | **292+29** |
| **v1.9** | **hstack/vstack/tile/transpose + noise + LUT/gradient_map + alpha ops** | **315+29** |
| **v1.10** | **morphology (erode/dilate/open/close) + Laplacian/Prewitt edge + MSE/PSNR/SSIM** | **341+29** |
| **v1.12** | **6 blend modes + CLAHE + K-means quantize + FFT frequency domain** | **369+29** |
| **v1.13** | **frequency filtering + adaptive threshold + connected components + integral image** | **402+29** |
| **v1.14** | **Hough transform + LBP + image pyramids + bilateral filter** | **433+29** |
| **v1.15** | **contour extraction + color segmentation + NLM denoise + Retinex** | **472+29** |
| **v1.16** | **Canny edge + watershed + GLCM texture + Haar wavelet** | **501+29** |
| **v1.17** | **Harris corners + dehaze + distance transform + Gabor filter** | **533+29** |

## Upstream

- [stb_image.h](https://github.com/nothings/stb/blob/master/stb_image.h) — commit `013ac3beddff3dbffafd5177e7972067cd2b5083` (v2.30)
- [stb_image_write.h](https://github.com/nothings/stb/blob/master/stb_image_write.h) — same commit (v1.16)
- [stb_image_resize2.h](https://github.com/nothings/stb/blob/master/stb_image_resize2.h) — v2.07