# 执行报告（v6）

## 概述
在 `src/pure/{codec,pixel,color,process,util}/` 新增纯 MoonBit TGA 解码器，扩展 pure 包格式覆盖（BMP+QOI → BMP+QOI+TGA），推进 v2.0 多目标支持。实现了 `decode_tga_pure` 函数，支持 image type 2（未压缩 RGB）和 type 10（RLE RGB）、24-bit/32-bit、bottom-up/top-down 行序、BGR(A)→RGB(A) 转换。新增 9 个纯逻辑测试 + 1 个 FFI 基准对比测试，全量 572 测试通过。

## 产出清单
| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 新建 | `src/pure/{codec,pixel,color,process,util}/tga_decode.mbt` | 纯 MoonBit TGA 解码器，`decode_tga_pure` 函数 |
| 新建 | `src/pure/{codec,pixel,color,process,util}/tga_decode_test.mbt` | 9 个纯逻辑测试（全目标可用） |
| 修改 | `src/roundtrip_test.mbt` | 新增 `roundtrip: TGA pure vs FFI` 对比测试 |

## 执行过程

### 解码器实现（`src/pure/{codec,pixel,color,process,util}/tga_decode.mbt`）
1. **Header 解析**：18 字节 TGA header，提取 ID length、color map type、image type、width/height（LE）、bpp、descriptor
2. **格式校验**：color_map_type=0（无颜色映射）、image_type∈{2,10}、bpp∈{24,32}、尺寸非零
3. **像素解码**：
   - type 2（未压缩）：逐像素顺序读取，BGR(A)→RGB(A) 转换
   - type 10（RLE）：按 RLE packet（bit7=1，run=(header&0x7F)+1，读 1 像素重复 run 次）和 raw packet（bit7=0，count=(header&0x7F)+1，读 count 像素）解压
4. **行序处理**：descriptor bit4=0 → bottom-up 翻转，bit4=1 → top-down 保持
5. **辅助函数复用**：`read_u16_le` 复用自 `bmp_decode.mbt`（同包内私有函数）

### 测试实现（`src/pure/{codec,pixel,color,process,util}/tga_decode_test.mbt`）
9 个纯逻辑测试，手构造 TGA 字节流（通过 `make_tga_header` + `push_bgr`/`push_bgra` 辅助函数），复用 `qoi_decode_test.mbt` 的 `to_bytes` 辅助函数：
1. 1x1 24-bit type 2（未压缩 RGB，BGR→RGB 验证）
2. 1x1 32-bit type 2（未压缩 RGBA，BGRA→RGBA 验证）
3. 2x2 24-bit type 10（RLE RGB，RLE packet + raw packet 混合）
4. 2x2 32-bit type 10（RLE RGBA）
5. bottom-up 行序验证（descriptor=0，2x2 行序翻转）
6. top-down 行序验证（descriptor=0x10）
7. 错误：数据过短（3 字节）
8. 错误：不支持的 image type（type 1 颜色映射）
9. 错误：不支持的 bpp（bpp=16）

### FFI 基准对比测试（`src/roundtrip_test.mbt`）
新增 `roundtrip: TGA pure vs FFI`：加载 `testdata/test_4x4_red.png` → `@core.write_tga_to_bytes`（FFI 生成 RLE 压缩 TGA，image type 10）→ `@codec.decode_tga_pure` 纯解码 vs `@core.load_from_bytes` FFI 解码 → 断言 width/height/channels/data 完全一致。这是真正的 FFI 基准对比（stb_image C 库原生支持 TGA 读写）。

### 构建验证
- `moon check`（全目标）：0 errors 0 warnings ✓
- `moon test --target native`：Total tests: 572, passed: 572, failed: 0 ✓
- 测试增量：562 → 572（+9 pure TGA + 1 roundtrip TGA），符合预期 571-573

## 偏差说明
无
