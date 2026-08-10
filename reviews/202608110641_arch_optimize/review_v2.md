# R2: pure/codec + pure/pixel

审查时间：2026-08-11 07:10

### 审查范围

- `src/pure/codec/*.mbt`（14 种格式编解码 + APNG/GIF 动画）
- `src/pure/pixel/*.mbt`（pixel_ops、pixel_advanced）
- `src/pure/codec/moon.pkg`、`src/pure/pixel/moon.pkg`
- `src/pure/codec/pkg.generated.mbti`、`src/pure/pixel/pkg.generated.mbti`
- 参照：`src/types/image_types.mbt`、`src/util/pixel_ops.mbt`、`src/util/pixel_advanced.mbt`、`src/reexport.mbt`、`src/moon.pkg`

### 发现

#### [严重] pure/pixel 与 src/util 像素操作代码大量重复，pure/pixel 高级 API 实为死代码

- **位置**：`src/pure/pixel/pixel_ops.mbt:1-100`、`src/pure/pixel/pixel_advanced.mbt:1-188`、`src/util/pixel_ops.mbt:1-100`、`src/util/pixel_advanced.mbt:1-188`
- **描述**：
  - `src/pure/pixel/pixel_ops.mbt` 与 `src/util/pixel_ops.mbt` 内容几乎逐行重复（`clamp_byte_v`、`threshold`/`threshold_pure`、`posterize`/`posterize_pure`、`extract_channel`/`extract_channel_pure`）。
  - `src/pure/pixel/pixel_advanced.mbt` 与 `src/util/pixel_advanced.mbt` 同样重复（`clamp_b`、`pixelate`、`replace_color`、`convolve`、`swap_channels`、`clamp_int`、`check_color_match`）。
  - `src/reexport.mbt:1175-1220` 中 `convolve`/`extract_channel`/`pixelate`/`posterize`/`replace_color`/`swap_channels`/`threshold` 全部从 `@util` 转发，**没有一项从 `@pixel` 转发**。
  - 顶层 `src/moon.pkg` 未将 `src/pure/pixel` 列为依赖，下游无法直接通过顶层包使用 `pure/pixel` 的高级 API。
  - 实际依赖 `pure/pixel` 的只有 `pure/color` 和 `pure/process`，且仅使用 `clamp_b`/`clamp_byte_v` 两个工具函数（见 `src/pure/process/blend.mbt:85` 等、`src/pure/color/color_map.mbt:107`）。
  - 结论：`pure/pixel` 的高级像素操作（threshold/posterize/pixelate/convolve/extract_channel/swap_channels/replace_color）在当前架构下是**未被转发的死代码**，下游实际使用的是 `src/util` 中的同名副本。两套实现并存导致维护成本翻倍且存在行为偏离风险。
- **建议**：
  - 方案 A（推荐）：将 `pure/pixel` 的高级操作确立为唯一实现，`src/util/pixel_ops.mbt`、`src/util/pixel_advanced.mbt` 改为薄转发层（或直接删除并更新 reexport 指向 `@pixel`）。
  - 方案 B：将 `pure/pixel` 的高级操作删除，仅保留 `clamp_b`/`clamp_byte_v` 工具函数，并将包重命名为 `pure/pixel_util` 以反映其真实职责。
  - 无论哪种方案，都应消除重复，并在 `src/moon.pkg` 中补齐 `pure/pixel` 依赖（若保留高级 API）。

#### [一般] encode 函数 raise 行为不一致

- **位置**：`src/pure/codec/pkg.generated.mbti:44-76`
- **描述**：encode API 的 raise 行为分为两类，无统一规则：
  - 不 raise：`encode_bmp_pure`、`encode_png_pure`、`encode_tga_pure`、`encode_ico_pure`、`encode_ico_multi_pure`、`encode_icns_pure`、`encode_cur_pure`、`encode_cur_with_hotspot_pure`、`encode_pgm_pure`、`encode_pnm_pure`、`encode_ppm_pure`
  - raise LoadError：`encode_jpeg_pure`、`encode_gif_pure`、`encode_hdr_pure`、`encode_qoi_pure`、`encode_tiff_pure`、`encode_apng_pure`
  - raise 的原因各不相同：JPEG/QOI/GIF 校验 channels∈{3,4}，TIFF 校验 channels∈{1,3,4}，HDR 校验 channels==3，APNG 校验 frames 非空。不 raise 的格式（如 BMP/TGA/PNG）对任意 channels 静默处理。
  - 下游使用者难以预判哪个 encode 会抛异常，违反最小惊讶原则。
- **建议**：统一策略。推荐所有 encode 都 raise LoadError（channels 无效时），或所有 encode 都静默规范化 channels（如 BMP 的做法）。至少在文档注释中明确每个 encode 的前置条件。

#### [一般] encode 错误统一使用 LoadError::DecodeFailed，语义错误

- **位置**：`src/pure/codec/jpeg_encode.mbt:337`、`src/pure/codec/gif_encode.mbt:123`、`src/pure/codec/hdr_encode.mbt:59`、`src/pure/codec/qoi_encode.mbt:13`、`src/pure/codec/tiff_codec.mbt:351`、`src/pure/codec/apng_codec.mbt:336`
- **描述**：所有 encode 错误都 raise `LoadError::DecodeFailed`，但 encode 不是 decode。例如：
  ```
  raise @types.LoadError::DecodeFailed("JPEG 尺寸无效")  // encode_jpeg_pure
  raise @types.LoadError::DecodeFailed("HDR 编码需要 3 通道 float 图像")
  raise @types.LoadError::DecodeFailed("APNG 至少需要一帧")
  ```
  `DecodeFailed` 语义为"解码失败"，用于 encode 误导下游错误处理。
- **建议**：在 `src/types/image_types.mbt` 的 `LoadError` 中新增 `EncodeFailed(String)` 变体，或将 `DecodeFailed` 重命名为更中性的 `Failed`/`FormatError`。至少新增 `EncodeFailed` 用于 encode 路径。

#### [一般] PNG 16-bit 解码有 req_channels 可选参数，8-bit 解码没有，签名不一致

- **位置**：`src/pure/codec/png_decode.mbt:38`、`src/pure/codec/png_decode_16.mbt:10-13`
- **描述**：
  ```
  pub fn decode_png_pure(data : Bytes) -> Image raise LoadError
  pub fn decode_png_16_pure(data : Bytes, req_channels? : Int? = None) -> Image16 raise LoadError
  ```
  - 16-bit 版本支持 req_channels（1/2/3/4 通道转换），8-bit 版本不支持。
  - `decode_pnm_pure` 与 `decode_pnm_16_pure` 也存在类似不一致（16 版本无 req_channels，但行为不同）。
  - 同族 API 签名风格不一致，下游需要记忆哪个变体支持可选参数。
- **建议**：为 `decode_png_pure` 也添加 `req_channels? : Int? = None` 参数（用于请求 RGB/RGBA/灰度输出），保持同族 API 签名一致。或反之，移除 16-bit 版本的 req_channels 并提供单独的通道转换函数。

#### [一般] pure/codec 文件命名模式不统一：_decode/_encode vs _codec

- **位置**：`src/pure/codec/` 目录
- **描述**：文件命名存在两种模式：
  - 分文件模式：`png_decode.mbt`+`png_encode.mbt`、`jpeg_decode.mbt`+`jpeg_encode.mbt`、`bmp_decode.mbt`+`bmp_encode.mbt`、`gif_decode.mbt`+`gif_encode.mbt`、`tga_decode.mbt`+`tga_encode.mbt`、`hdr_decode.mbt`+`hdr_encode.mbt`、`pnm_decode.mbt`+`pnm_encode.mbt`、`qoi_decode.mbt`+`qoi_encode.mbt`
  - 合并模式：`ico_codec.mbt`（含 ICO+CUR 编解码）、`icns_codec.mbt`、`tiff_codec.mbt`、`apng_codec.mbt`
  - 单边模式：`psd_decode.mbt`（无 encode）、`gif_animation_decode.mbt`（无 encode）、`pnm_decode_16.mbt`（16-bit 变体）
  - `ico_codec.mbt` 同时承载 ICO 和 CUR 两种格式，职责过宽。
- **建议**：统一为分文件模式。将 `ico_codec.mbt` 拆为 `ico_decode.mbt`+`ico_encode.mbt`+`cur_decode.mbt`+`cur_encode.mbt`（CUR 与 ICO 共享的辅助函数提取到 `ico_util.mbt` 或保留在 `ico_decode.mbt`）。`tiff_codec.mbt`、`icns_codec.mbt`、`apng_codec.mbt` 同理拆分。

#### [一般] decode_png_pure 强制输出 channels=3，丢弃 alpha，与 BMP/TGA/QOI 行为不一致

- **位置**：`src/pure/codec/png_decode.mbt:227-232`、`src/pure/codec/png_decode.mbt:211-225`
- **描述**：
  - `decode_png_pure` 对 color_type==4（gray+alpha）和 color_type==6（RGBA）都丢弃 alpha，输出 channels=3。
  - 而 `decode_bmp_pure`（`bmp_decode.mbt:55` out_channels = bytes_per_pixel）保留 4 通道，`decode_tga_pure` 保留 4 通道，`decode_qoi_pure` 根据 header 选择 3 或 4。
  - 同样是 RGBA 输入，PNG 解码后变 RGB，BMP/TGA 解码后保留 RGBA，下游使用者会惊讶。
  - 注释 `支持 8-bit gray/RGB/RGBA/gray+alpha/palette` 暗示保留 alpha，但实际丢弃，注释与行为不符。
- **建议**：让 `decode_png_pure` 保留 alpha（color_type==6 输出 channels=4，color_type==4 输出 channels=2 或 4），或通过 `req_channels` 参数让调用方控制。至少修正注释明确说明"丢弃 alpha"。

#### [一般] decode_ico_pure 不校验 icon_type，CUR 文件可被当作 ICO 解码

- **位置**：`src/pure/codec/ico_codec.mbt:205-223`
- **描述**：
  ```
  pub fn decode_ico_pure(data : Bytes) -> @types.Image raise @types.LoadError {
    let (_, entries) = parse_ico_header(data)  // 忽略 icon_type
    ...
  }
  ```
  - `decode_ico_pure` 调用 `parse_ico_header` 但用 `_` 忽略 `icon_type`，不校验是否为 1。
  - 一个 CUR 文件（icon_type=2）传给 `decode_ico_pure` 也能成功解码，语义上不正确。
  - 而 `decode_cur_pure`（`ico_codec.mbt:227-247`）校验了 `icon_type != 2`，两者不对称。
- **建议**：在 `decode_ico_pure` 中添加 `if icon_type != 1 { raise LoadError::DecodeFailed("ICO type 应为 1") }`。

#### [一般] 大端/小端字节读写函数在 6+ 个文件重复定义

- **位置**：
  - `src/pure/codec/bmp_decode.mbt:92-102`：`read_i32_le`、`read_u16_le`
  - `src/pure/codec/ico_codec.mbt:16-40`：`ico_read_u16_le`、`ico_read_i32_le`、`ico_write_u16_le`、`ico_write_i32_le`
  - `src/pure/codec/tiff_codec.mbt:24-62`：`tiff_read_u16`、`tiff_read_u32`、`tiff_write_u16_le`、`tiff_write_u32_le`
  - `src/pure/codec/apng_codec.mbt:15-42`：`apng_read_u32_be`、`apng_read_u16_be`、`apng_write_u32_be`、`apng_write_u16_be`
  - `src/pure/codec/icns_codec.mbt:19-32`：`icns_read_u32_be`、`icns_write_u32_be`
  - `src/pure/codec/psd_decode.mbt:7-35`：`read_u16_be`、`read_u32_be`
  - `src/pure/codec/gif_decode.mbt:6-17`：`read_u16_le_safe`
  - `src/pure/codec/pnm_decode.mbt:7-55`：`pnm_is_whitespace`、`pnm_skip_ws_and_comments`、`pnm_read_ascii_int`（被 `pnm_decode_16.mbt` 跨文件复用）
- **描述**：大端/小端 16/32 位读写函数在 6 个文件中重复定义，每个文件加前缀（`ico_`、`tiff_`、`apng_`、`icns_`）避免冲突。这些是通用工具，重复实现违反 DRY。
- **建议**：提取到 `src/pure/codec/byte_io.mbt`（或 `src/pure/util/byte_io.mbt`）作为包内共享函数：`read_u16_le`、`read_u32_le`、`read_u16_be`、`read_u32_be`、`write_u16_le`、`write_u32_le`、`write_u16_be`、`write_u32_be`。各 codec 文件删除本地定义。

#### [一般] decode_gif_pure 与 decode_gif_animation_pure 代码大量重复

- **位置**：`src/pure/codec/gif_decode.mbt:110-279`、`src/pure/codec/gif_animation_decode.mbt:9-262`
- **描述**：两者都解析 GIF header、Global Color Table、Image Descriptor、Local Color Table、LZW 数据，代码大量重复。`decode_gif_pure` 实为 `decode_gif_animation_pure` 取第一帧的特例，但独立实现。
  - 共享的 `read_u16_le_safe`、`lzw_decode` 已在 `gif_decode.mbt` 定义并被 `gif_animation_decode.mbt` 跨文件复用（同包私有函数）。
  - 但 header 解析、颜色表解析、子块读取等逻辑重复。
- **建议**：让 `decode_gif_pure` 委托 `decode_gif_animation_pure` 取第一帧：`decode_gif_animation_pure(data).frames[0]`。或提取共享的 GIF 解析逻辑到 `gif_common.mbt`。

#### [一般] reexport 暴露的 quality/req_channels 参数被静默忽略

- **位置**：`src/reexport.mbt:99-105`（decode_any）、`src/reexport.mbt:145-151`（load_from_bytes）、`src/reexport.mbt:154-160`（load_gif_from_bytes）、`src/reexport.mbt:163-169`（loadf_from_bytes）、`src/reexport.mbt:197-203`（write_jpeg_to_bytes）
- **描述**：
  ```
  pub fn write_jpeg_to_bytes(arg0 : @types.Image, quality? : Int = 90) -> Bytes raise @types.LoadError {
    ignore(quality)  // quality 被忽略！
    @codec.encode_jpeg_pure(arg0)
  }
  pub fn decode_any(arg0 : Bytes, req_channels? : Int? = None) -> @types.Image raise @types.LoadError {
    ignore(req_channels)  // req_channels 被忽略！
    @lib.load_from_bytes_auto(arg0)
  }
  ```
  - 下游调用 `write_jpeg_to_bytes(img, quality=50)` 会以为设置了质量，实际无效。
  - 下游调用 `decode_any(data, req_channels=Some(1))` 会以为请求灰度输出，实际无效。
  - 这与 R2 范围相关：`encode_jpeg_pure` 签名无 quality 参数，`decode_png_pure` 签名无 req_channels 参数，导致 reexport 只能 ignore。
- **建议**：为 `encode_jpeg_pure` 添加 `quality? : Int = 90` 参数并实际使用；为 `decode_png_pure`/`decode_jpeg_pure` 等添加 `req_channels? : Int? = None` 参数。若暂不支持，应在 reexport 中移除这些参数，避免欺骗下游。

#### [一般] pure/pixel 职责模糊：既是底层 clamp 工具，又是高级像素操作

- **位置**：`src/pure/pixel/pixel_ops.mbt:6-14`（clamp_byte_v）、`src/pure/pixel/pixel_advanced.mbt:6-14`（clamp_b）、`src/pure/pixel/pkg.generated.mbti:9-25`
- **描述**：`pure/pixel` 公开 9 个函数：
  - 底层工具：`clamp_b`、`clamp_byte_v`（功能完全相同，只是名字不同）
  - 高级操作：`threshold_pure`、`posterize_pure`、`extract_channel_pure`、`pixelate_pure`、`replace_color_pure`、`convolve_pure`、`swap_channels_pure`
  - 实际被 `pure/color`、`pure/process` 使用的只有 `clamp_b`、`clamp_byte_v`（见前述严重问题）。
  - 包名 `pixel` 暗示"像素操作"，但实际承担两类不同职责，且高级操作未被下游使用。
- **建议**：明确 `pure/pixel` 的单一职责。若定位为底层工具包，删除高级操作（或迁移到 `src/util`）；若定位为高级像素操作包，将 `clamp_b`/`clamp_byte_v` 迁移到 `pure/util` 或 `types`。

#### [一般] clamp_b 与 clamp_byte_v 功能完全重复

- **位置**：`src/pure/pixel/pixel_ops.mbt:6-14`（clamp_byte_v）、`src/pure/pixel/pixel_advanced.mbt:6-14`（clamp_b）
- **描述**：
  ```
  pub fn clamp_byte_v(v : Int) -> Byte { if v < 0 { b'\x00' } else if v > 255 { b'\xFF' } else { v.to_byte() } }
  pub fn clamp_b(v : Int) -> Byte { if v < 0 { b'\x00' } else if v > 255 { b'\xFF' } else { v.to_byte() } }
  ```
  - 两个函数实现完全相同，只是名字不同。
  - `clamp_byte_v` 在 `pixel_ops.mbt`，`clamp_b` 在 `pixel_advanced.mbt`，跨文件定义。
  - reexport 两者都公开（`pkg.generated.mbti:9-11`），下游不知该用哪个。
  - `pure/process` 用 `clamp_b`，`pure/color` 用 `clamp_b`，`pixel_ops.mbt` 内部用 `clamp_byte_v`。
- **建议**：保留一个（推荐 `clamp_b`，更短），删除另一个，更新所有引用。

#### [一般] encode_ico_multi_pure 与 encode_cur_with_hotspot_pure 扩展命名风格不一致

- **位置**：`src/pure/codec/ico_codec.mbt:318`（encode_ico_multi_pure）、`src/pure/codec/ico_codec.mbt:366`（encode_cur_with_hotspot_pure）
- **描述**：
  - ICO 扩展：`encode_ico_multi_pure`（多分辨率）
  - CUR 扩展：`encode_cur_with_hotspot_pure`（指定热点）
  - 命名模式不统一：`_multi` vs `_with_hotspot`，下游难以记忆。
  - 两者都是单数版本的扩展，但后缀风格不同。
- **建议**：统一命名风格。推荐 `_with_<param>` 模式：`encode_ico_with_sizes_pure`、`encode_cur_with_hotspot_pure`。或都使用名词后缀：`encode_ico_multi_pure`、`encode_cur_hotspot_pure`。

#### [一般] decode_png_16_pure 的 req_channels=0 会导致空数组，无校验

- **位置**：`src/pure/codec/png_decode_16.mbt:151-154`
- **描述**：
  ```
  let out_ch = match req_channels {
    Some(n) => n  // n=0 会直接用作 out_ch
    None => ch
  }
  ...
  let out_data : Array[Byte] = Array::make(pixel_count * out_ch * 2, b'\x00')  // out_ch=0 → 空数组
  ```
  - 注释说 `req_channels: 0/None=原色`，但代码中 `Some(0)` 会被当作 out_ch=0，创建空数组，后续 `out_data[i * 0 * 2]` 越界。
  - None 才是"原色"（用 ch），Some(0) 是无效输入但未校验。
- **建议**：校验 `req_channels`：`if let Some(n) = req_channels { if n < 1 || n > 4 { raise ... } }`。或修正注释，明确 None=原色，Some(n) 必须 1-4。

#### [轻微] encode_png_pure 通道推断存在死代码分支

- **位置**：`src/pure/codec/png_encode.mbt:134-154`
- **描述**：
  ```
  if ch == out_ch {
    for c in 0..<ch { filtered.push(img.data[src_off + c]) }
  } else if ch == 3 && out_ch == 3 {
    for c in 0..<3 { filtered.push(img.data[src_off + c]) }
  } else if ch == 1 && out_ch == 1 {
    filtered.push(img.data[src_off])
  } else {
    ...
  }
  ```
  - `ch == 3 && out_ch == 3` 已被 `ch == out_ch` 覆盖（ch==3 时 out_ch=3），永远不会进入。
  - `ch == 1 && out_ch == 1` 同理被 `ch == out_ch` 覆盖。
  - 两个 else if 分支是死代码。
- **建议**：删除两个死代码分支，简化为 `if ch == out_ch { ... } else { ... }`。

#### [轻微] PNG signature 验证代码在 4 处重复

- **位置**：
  - `src/pure/codec/png_decode.mbt:41-50`
  - `src/pure/codec/png_decode_16.mbt:15-24`
  - `src/pure/codec/apng_codec.mbt:74-83`
  - `src/pure/codec/ico_codec.mbt:44-56`（`is_png_data`）
- **描述**：PNG 8 字节签名（`89 50 4E 47 0D 0A 1A 0A`）的验证代码在 4 处重复，每处都是 8 个字节比较。
- **建议**：提取为 `fn is_png_signature(data : Bytes, offset : Int, len : Int) -> Bool` 共享函数。

#### [轻微] convolve_pure kernel 长度校验不严格

- **位置**：`src/pure/pixel/pixel_advanced.mbt:93-94`
- **描述**：`if kernel.length() < 9 { raise ... }` 只校验最小长度，kernel 长度为 10+ 时多余元素被静默忽略。下游可能误以为传入 16 元素 kernel 会做 4x4 卷积。
- **建议**：改为 `if kernel.length() != 9 { raise ... }`，或在注释明确"仅取前 9 个值"。

#### [轻微] encode_pnm_pure 缺少 16-bit 版本，编解码不对称

- **位置**：`src/pure/codec/pnm_decode_16.mbt:9`（decode_pnm_16_pure）、`src/pure/codec/pnm_encode.mbt`（无 encode_pnm_16_pure）
- **描述**：有 `decode_pnm_16_pure` 但无对应的 `encode_pnm_16_pure`/`encode_ppm_16_pure`/`encode_pgm_16_pure`。PNM 16-bit 编解码不对称，下游无法 round-trip 16-bit PNM。
- **建议**：添加 `encode_pnm_16_pure` 系列函数，或在文档明确 16-bit PNM 仅支持解码。

#### [轻微] encode_pnm_pure 命名歧义：是分派函数，decode_pnm_pure 是直接实现

- **位置**：`src/pure/codec/pnm_encode.mbt:72-78`（encode_pnm_pure 分派 PGM/PPM）、`src/pure/codec/pnm_decode.mbt:63`（decode_pnm_pure 直接实现 P5/P6）
- **描述**：
  - `encode_pnm_pure`：根据 channels 分派到 `encode_pgm_pure` 或 `encode_ppm_pure`，是分派函数。
  - `decode_pnm_pure`：直接实现 P5/P6 解码，不分派。
  - 同名 `pnm` 但行为不对称：encode 是分派，decode 是直接实现。下游可能误以为 `decode_pnm_pure` 也能解码 P2/P3（ASCII）。
- **建议**：统一模式。推荐 `decode_pnm_pure` 也作为分派函数（根据 magic 分派到 `decode_pgm_pure`/`decode_ppm_pure`），或 `encode_pnm_pure` 重命名为 `encode_pnm_auto_pure` 明确分派语义。

#### [轻微] pure/codec 部分文件过大，职责过宽

- **位置**：`src/pure/codec/jpeg_decode.mbt`（560 行）、`src/pure/codec/jpeg_encode.mbt`（488 行）、`src/pure/codec/tiff_codec.mbt`（441 行）、`src/pure/codec/apng_codec.mbt`（411 行）、`src/pure/codec/ico_codec.mbt`（394 行）
- **描述**：
  - `jpeg_decode.mbt` 包含 JpegBitReader、JpegHuffmanTable、Huffman 解码、IDCT、YCbCr→RGB、zigzag、块解码、顶层解码等多个职责（560 行）。
  - `jpeg_encode.mbt` 同样包含 JpegBitWriter、Huffman 编码器、标准表、FDCT、RGB→YCbCr、块编码等（488 行）。
  - `ico_codec.mbt` 同时承载 ICO 和 CUR 两种格式的编解码（394 行）。
  - 虽然 MoonBit 同包文件拆分不影响 API，但大文件降低可维护性。
- **建议**：按职责拆分。例如 `jpeg_decode.mbt` 拆为 `jpeg_bit_reader.mbt`、`jpeg_huffman.mbt`、`jpeg_idct.mbt`、`jpeg_decode.mbt`。`ico_codec.mbt` 按 ICO/CUR 拆分（见前述命名问题）。

#### [轻微] encode_apng_pure 错误信息用 DecodeFailed

- **位置**：`src/pure/codec/apng_codec.mbt:336`
- **描述**：`raise @types.LoadError::DecodeFailed("APNG 至少需要一帧")` 在 encode 中用 DecodeFailed，语义错误（同前述 encode 错误类型问题，单列因为 APNG 这里是结构校验而非 channels 校验）。
- **建议**：同前述，新增 `EncodeFailed` 变体。

### 本轮统计

| 严重程度 | 数量 |
|---------|------|
| 严重 | 1 |
| 一般 | 12 |
| 轻微 | 7 |

### 总评

**pure/codec** 实现覆盖 14 种格式 + 2 种动画，功能完整度高，错误处理路径覆盖较好（边界校验、越界检查、格式校验均有）。但存在三类系统性问题：

1. **架构层**：`pure/pixel` 与 `src/util` 像素操作代码大量重复，且 reexport 从 `src/util` 转发而非 `pure/pixel`，导致 `pure/pixel` 高级 API 实为死代码。这是本轮最严重的问题，建议优先解决（确定唯一实现源，消除重复）。

2. **API 一致性层**：encode 函数 raise 行为不一致、错误类型统一用 DecodeFailed（语义错误）、PNG 8-bit/16-bit 解码签名不一致、文件命名 `_decode/_encode` vs `_codec` 不统一、ICO/CUR 扩展命名风格不一致。这些不影响正确性，但增加下游认知负担，建议统一。

3. **代码质量层**：大端/小端读写函数 6 处重复、PNG signature 验证 4 处重复、GIF 单帧/动画解码重复、clamp_b/clamp_byte_v 重复、encode_png 死代码分支。建议提取共享辅助函数到 `byte_io.mbt`/`png_common.mbt`/`gif_common.mbt`。

**pure/pixel** 包职责模糊，既是底层 clamp 工具又是高级像素操作，且高级操作未被下游使用。建议明确单一职责（推荐保留底层工具，高级操作迁移到 `src/util` 或确立为唯一实现）。

**下游可用性**方面，reexport 暴露的 `quality`/`req_channels` 参数被静默忽略，会误导下游使用者。建议要么实现这些参数，要么从 reexport 移除。

整体而言，pure/codec 的功能实现质量良好（错误路径覆盖完整、边界校验充分），主要问题在于架构层面的重复和 API 一致性，可通过提取共享代码、统一命名规范、明确 pure/pixel 职责来系统性改善。
