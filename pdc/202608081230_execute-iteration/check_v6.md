# 检查报告（v6）

## 结果
PASSED

## 检查项
| 检查项 | 方法 | 结果 |
|--------|------|------|
| 产出文件存在性 | `ls src/pure/` + 读取文件 | 通过：`tga_decode.mbt`（145 行）、`tga_decode_test.mbt`（198 行）新建，`roundtrip_test.mbt` 修改 |
| 解码器签名 | 读取 `tga_decode.mbt:9` | 通过：`pub fn decode_tga_pure(data : Bytes) -> @types.Image raise @types.LoadError`，与 BMP/QOI 惯例一致 |
| 18 字节 header 解析 | 读取 `tga_decode.mbt:11-21` | 通过：解析 ID length、color map type、image type、width/height（LE）、bpp、descriptor |
| image type 2 支持 | 读取 `tga_decode.mbt:49-70` | 通过：未压缩逐像素读取 + BGR(A)→RGB(A) 转换 |
| image type 10 RLE 支持 | 读取 `tga_decode.mbt:71-126` | 通过：bit7=1 → RLE packet（run=(header&0x7F)+1，读 1 像素重复 run 次）；bit7=0 → raw packet（count=(header&0x7F)+1，读 count 像素） |
| 24-bit/32-bit 支持 | 读取 `tga_decode.mbt:30-33, 38-39` | 通过：bpp∈{24,32} 校验，out_channels = bpp/8 |
| BGR(A)→RGB(A) 转换 | 读取 `tga_decode.mbt:56-67, 83-96, 109-119` | 通过：data[p]=B、data[p+1]=G、data[p+2]=R，输出 R/G/B[+A] |
| 行序处理 | 读取 `tga_decode.mbt:41, 127-138` | 通过：descriptor bit4=0 → bottom-up 翻转（out_row = height-1-file_row）；bit4=1 → top-down 保持 |
| 错误路径 | 读取 `tga_decode.mbt:12-14, 23-25, 27-29, 31-33, 35-37` | 通过：数据过短（<18 字节）、color_map_type≠0、image_type∉{2,10}、bpp∉{24,32}、尺寸为 0 均 raise `LoadError::DecodeFailed` |
| 纯逻辑测试数量 | 读取 `tga_decode_test.mbt` | 通过：9 个测试（任务建议 8-10 个） |
| 测试覆盖 - type 2 24-bit | `tga_decode_test.mbt:52-63` | 通过：1x1 红色 BGR→RGB 验证 |
| 测试覆盖 - type 2 32-bit | `tga_decode_test.mbt:66-78` | 通过：1x1 红色 BGRA→RGBA 验证 |
| 测试覆盖 - type 10 RLE 24-bit | `tga_decode_test.mbt:81-99` | 通过：2x2 RLE packet + raw packet 混合验证 |
| 测试覆盖 - type 10 RLE 32-bit | `tga_decode_test.mbt:102-122` | 通过：2x2 RLE RGBA 验证 |
| 测试覆盖 - bottom-up 行序 | `tga_decode_test.mbt:125-141` | 通过：2x2 descriptor=0 行序翻转验证 |
| 测试覆盖 - top-down 行序 | `tga_decode_test.mbt:144-160` | 通过：2x2 descriptor=0x10 行序保持验证 |
| 测试覆盖 - 错误路径（3 个） | `tga_decode_test.mbt:163-198` | 通过：数据过短（3 字节）、不支持 image type（type 1）、不支持 bpp（bpp=16）各 1 个测试 |
| FFI 基准对比测试 | 读取 `roundtrip_test.mbt:322-338` | 通过：`roundtrip: TGA pure vs FFI` 加载 PNG → `write_tga_to_bytes` → `decode_tga_pure` vs `load_from_bytes` → 断言 width/height/channels/data 完全一致 |
| pure 包全目标可用 | 读取 `src/pure/moon.pkg` | 通过：仅 `import types`，无 `supported_targets` 限制，全目标可用 |
| 辅助函数复用 | grep `fn read_u16_le` | 通过：复用 `bmp_decode.mbt:100` 的私有函数（同包内） |
| 构建验证 - moon check（全目标） | `moon clean && moon check` | 通过：ran 30 tasks，0 errors 0 warnings |
| 构建验证 - moon test native | `moon test --target native` | 通过：Total 572, passed 572, failed 0 |
| 测试增量符合预期 | 572 - 562 = 10 | 通过：+9 pure TGA + 1 roundtrip TGA = 10，符合预期 571-573 |
| 现有测试未破坏 | native 572 全通过 | 通过：原 562 测试继续通过，新增 10 测试全部通过 |
| v1.0 API 冻结 | 仅新增文件 + roundtrip_test 新增测试 | 通过：未修改任何已有签名 |

## 总结
Doer 完整实现了任务 v6 的全部要求：在 `src/pure/` 新增纯 MoonBit TGA 解码器，支持 image type 2/10、24/32-bit、RLE 解压、bottom-up/top-down 行序、BGR(A)→RGB(A) 转换及全部错误路径；新增 9 个纯逻辑测试覆盖所有功能点（含 3 个错误路径测试）+ 1 个 FFI 基准对比测试。构建验证全目标 0 errors 0 warnings，native 全量 572 测试通过（562→572，+10 符合预期 571-573）。v1.0 API 冻结保持，五子包架构未破坏，现有测试全部通过。
