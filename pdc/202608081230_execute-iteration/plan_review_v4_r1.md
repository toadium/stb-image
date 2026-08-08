# 计划审查报告（v4 r1）

## 审查结果
REJECTED

## 发现

- **[严重] 测试 2（32-bit RGBA）技术不可行**：计划提出用 `@core.write_bmp_to_bytes` 生成 32-bit BMP 字节流再由 `@pure.decode_bmp_pure` 解码对比。但 `stbi_write_bmp_core`（`src/core/stb_image_write.h:492-510`）对 `comp == 4` 分支写出的 BMP 使用 **BITMAPV4HEADER（DIB 头 108 字节）+ BI_BITFIELDS（compression=3）**，而非 BITMAPINFOHEADER（40 字节）+ BI_RGB（compression=0）。而 `decode_bmp_pure`（`src/pure/bmp_decode.mbt:21,35`）显式拒绝 `dib_size != 40` 和 `compression != 0`，会 `raise LoadError::DecodeFailed("不支持的 BMP DIB 头大小，仅支持 BITMAPINFOHEADER（40 字节）")`。因此测试 2 会在运行时抛出未捕获异常而失败，`moon test --target native` 无法通过，违反"不破坏现有测试"约束，预期产出"552→554"也无法达成。计划声称"覆盖 24-bit RGB 与 32-bit RGBA 两种位深"对 FFI 生成路径不成立。

- **[严重] 计划未论证 FFI 生成 BMP 与 pure 解码器能力范围的匹配性**：计划"选择理由"称"测试模式已有先例（roundtrip_test.mbt 现有 `roundtrip: BMP RGB` 用 `@core.write_bmp_to_bytes`）"，但该先例是纯 FFI roundtrip（write_bmp → load_from_bytes），不涉及 pure 解码器。T3 移累的 2 个对比测试（`git show f0ca5af:src/pure/bmp_decode_test.mbt` 测试 5-6）使用**手构造 BMP 字节**（BITMAPINFOHEADER + BI_RGB），而非 `@core.write_bmp_to_bytes` 生成。计划改用 FFI 生成路径却未核实 stb_image_write 的 32-bit BMP 编码格式与 `decode_bmp_pure` 的解码能力是否兼容，这是导致测试 2 不可行的根因。

## 修改要求

### 问题 1：测试 2（32-bit RGBA）技术不可行
**问题是什么**：`@core.write_bmp_to_bytes` 对 4 通道图像写出 BITMAPV4HEADER（108 字节）+ BI_BITFIELDS（compression=3）的 32-bit BMP，`decode_bmp_pure` 仅支持 BITMAPINFOHEADER（40 字节）+ BI_RGB（compression=0），会拒绝解码。

**为什么是问题**：测试 2 会在运行时抛出 `LoadError::DecodeFailed`，导致 `moon test --target native` 失败，违反"不破坏现有测试"和"构建验证"约束，计划预期产出"552→554"无法达成。

**期望的修正方向**：二选一：
- **方案 A（推荐）**：仅保留测试 1（24-bit RGB），放弃 32-bit RGBA 对比测试。理由：`@core.write_bmp_to_bytes` 的 32-bit BMP 格式（BITMAPV4HEADER + BI_BITFIELDS）超出 `decode_bmp_pure` 当前能力范围，32-bit 对比验证需先扩展 pure 解码器支持 BITMAPV4HEADER（属后续轮次）。预期测试数调整为 552→553。
- **方案 B**：32-bit 测试改用手构造的 BITMAPINFOHEADER + BI_RGB 32-bit BMP 字节（参照 T3 移除前的测试 3 `make_1x1_red_bmp_32()` 模式），分别用 `@core.load_from_bytes` 和 `@pure.decode_bmp_pure` 解码对比。需核实 stb_image 的 BMP reader 是否支持解码 32-bit BI_RGB BMP（BITMAPINFOHEADER + compression=0 + bpp=32）。

### 问题 2：计划未论证 FFI 生成 BMP 与 pure 解码器能力范围的匹配性
**问题是什么**：计划改用 `@core.write_bmp_to_bytes` 生成 BMP（T3 原对比测试用手构造字节），但未核实 stb_image_write 输出格式与 `decode_bmp_pure` 输入要求的兼容性。

**为什么是问题**：这是导致问题 1 的根因。计划"选择理由"称"风险低：仅新增测试不改现有代码"，但未验证前提假设（FFI 生成 BMP 可被 pure 解码器解码），实际风险不可控。

**期望的修正方向**：计划须明确论证 `@core.write_bmp_to_bytes` 各通道数输出格式（24-bit: BITMAPINFOHEADER+BI_RGB；32-bit: BITMAPV4HEADER+BI_BITFIELDS）与 `decode_bmp_pure` 能力范围（仅 BITMAPINFOHEADER+BI_RGB）的匹配情况，据此确定可行的测试覆盖范围，不应留待 Doer 现场发现。
