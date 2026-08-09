# 计划审查报告（v6 r2）

## 审查结果
APPROVED

## 发现
- **[轻微]** 对比测试图像 `testdata/test_4x4_red.png` 为 4x4 纯红色图像，RLE 压缩后仅生成 RLE packet（相同像素重复），不生成 raw packet（异质像素序列）。故根包对比测试仅验证 RLE packet 解码路径，raw packet 路径依赖 pure 包纯逻辑测试（line 22-23 手构造 RLE packet + raw packet）覆盖。此为测试分工合理设计，非缺陷，仅提示 Doer 注意纯逻辑测试须显式构造 raw packet 用例。

### 核实项
1. **`@core.write_tga_to_bytes` 存在性**：`src/core/image_write_native.mbt:110` 确认，签名 `pub fn write_tga_to_bytes(img : Image) -> Bytes raise LoadError`，与 task_v6.md line 119 一致
2. **`@core.load_from_bytes` 签名**：`src/core/image_load_native.mbt:3-6` 确认 `pub fn load_from_bytes(data : Bytes, req_channels? : Int? = None) -> Image raise LoadError`，与 line 120 一致
3. **`testdata/test_4x4_red.png` 存在**：glob 确认
4. **stb_image_write TGA 输出格式**（`src/core/stb_image_write.h:532-609`）：
   - image type = format + 8（RLE 分支），comp=3/4 → colorbytes=3, format=2 → image type=10 ✓
   - bpp = (colorbytes + has_alpha) * 8，comp=3 → 24，comp=4 → 32 ✓
   - descriptor = has_alpha * 8，comp=3 → 0（bottom-up），comp=4 → 8（bottom-up）✓
   - 默认 RLE（`stbi_write_tga_with_rle = 1`，line 252/256，MoonBit FFI 未修改）✓
   - 默认 bottom-up（`stbi__flip_vertically_on_write = 0`，line 260，`write_tga_to_bytes` 未调用 `flip_vertically_on_write`）✓
   - BGR(A) 像素顺序（`stbiw__write_pixel` rgb_dir=-1 → `stbiw__write3(s, d[2], d[1], d[0])`，line 444）✓
5. **RLE 编码规则**（line 594/600）：
   - raw packet：`header = STBIW_UCHAR(len - 1)`，len∈[1,128] → header∈[0,127]（bit7=0），count=(header&0x7F)+1 ✓
   - RLE packet：`header = STBIW_UCHAR(len - 129)`，len∈[2,128] → header∈[0x81,0xFF]（bit7=1），run=(header&0x7F)+1 ✓
   - task_v6.md line 64-65 描述与源码一致
6. **TGA header 结构**（18 字节）：task_v6.md line 67-81 与 TGA 规范一致
7. **对比测试技术可行性**：`@core.write_tga_to_bytes` 对 3 通道图像输出 image type=10、bpp=24、descriptor=0、BGR 像素顺序，`@pure.decode_tga_pure` 支持 image type 10、24-bit、RLE、bottom-up、BGR→RGB，兼容匹配，可解码
8. **pure 包全目标**：`src/pure/moon.pkg` 仅 `import types`，无 `supported_targets`，全目标 ✓
9. **根包依赖配置**：`src/moon.pkg:16-18` `for "test"` 声明 `@pure` 依赖，`src/moon.pkg:26` `roundtrip_test.mbt: ["native"]` ✓
10. **签名惯例**：`decode_bmp_pure`（`bmp_decode.mbt:8`）、`decode_qoi_pure`（`qoi_decode.mbt:16`）均为 `pub fn decode_X_pure(data : Bytes) -> @types.Image raise @types.LoadError`，task_v6.md line 126 一致
11. **r1 修正落实**：
    - line 25 已补充"不支持的 bpp（如 bpp=16 或 bpp=8）"，与 line 16 三种错误路径一致 ✓
    - line 26 已调整为"建议 8-10 个，含 3 个错误路径测试" ✓
    - line 38 已调整为"预期 571-573" ✓
12. **预期测试数**：T5 完成后 native 562（plan.md line 171），新增 pure 包 8-10 + 根包 1 = 9-11，预期 571-573 ✓
