# 编解码

## Native 侧（C FFI）

- **解码**：PNG/JPEG/BMP/GIF/TGA/PSD/HDR/PNM/QOI（10+ 格式）
- **编码**：PNG/BMP/TGA/JPEG/HDR/ICO/ICNS（8 格式）

## Pure 侧（纯 MoonBit，wasm/js）

- **解码**：BMP/QOI/TGA/PNM(P5/P6)/PSD/GIF（6 解码器）
- **编码**：QOI/PNM/GIF（3 编码器）

## 函数命名约定

- Native 侧：`load_from_bytes`、`write_png_to_bytes` 等
- Pure 侧：`@pure.decode_bmp_pure`、`@pure.encode_qoi_pure` 等
- 统一入口：`@lib.load_from_bytes_auto`（自动格式分派）
