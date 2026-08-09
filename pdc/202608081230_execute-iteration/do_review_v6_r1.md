# 执行审查报告（v6 r1）

## 审查结果
APPROVED

## 发现

### 任务覆盖度（通过）
- `decode_tga_pure` 签名 `pub fn decode_tga_pure(data : Bytes) -> @types.Image raise @types.LoadError` 与任务要求和 pure 包现有惯例（`decode_bmp_pure`/`decode_qoi_pure`）一致 ✓
- image type 2（未压缩 RGB）和 type 10（RLE RGB）均实现 ✓
- 24-bit（BGR→RGB，comp=3）和 32-bit（BGRA→RGBA，comp=4）均实现 ✓
- 18 字节 TGA header 解析完整（ID length、color map type、image type、width/height LE、bpp、descriptor）✓
- RLE 解压算法正确：bit7=1 → RLE packet run=(header&0x7F)+1 读 1 像素重复 run 次；bit7=0 → raw packet count=(header&0x7F)+1 读 count 像素 ✓
- 行序处理正确：descriptor bit4=0 → bottom-up 翻转，bit4=1 → top-down 保持 ✓
- BGR(A)→RGB(A) 像素顺序转换正确 ✓
- 错误路径覆盖：数据过短、不支持的 image type、不支持的 bpp 均 raise `@types.LoadError::DecodeFailed` ✓
- `read_u16_le` 复用自 `bmp_decode.mbt:100`（同包私有函数），无重复实现 ✓

### 测试覆盖度（通过）
- 9 个纯逻辑测试（`tga_decode_test.mbt`），在任务建议的 8-10 范围内 ✓
- 覆盖 type 2 24-bit RGB、type 2 32-bit RGBA、type 10 24-bit RLE RGB、type 10 32-bit RLE RGBA、bottom-up 行序、top-down 行序 ✓
- 3 个错误路径测试（数据过短 + 不支持 image type + 不支持 bpp），符合任务要求 ✓
- 测试手构造 TGA 字节流（`make_tga_header` + `push_bgr`/`push_bgra` 辅助函数），纯逻辑不依赖 @core，全目标可用 ✓
- bottom-up 行序测试验证逻辑正确：文件行序 row0=黑黑 row1=红红 → 输出 row0=红红 row1=黑黑 ✓
- RLE 测试混合 RLE packet（header=0x81, run=2）和 raw packet（header=0x01, count=2），覆盖两种 packet 类型 ✓

### FFI 基准对比测试（通过）
- `roundtrip: TGA pure vs FFI`（`roundtrip_test.mbt:322-338`）正确实现：
  - `@core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))` 加载测试图像 ✓
  - `@core.write_tga_to_bytes(img)` 生成 TGA 字节流（FFI 生成，默认 RLE 压缩，image type 10）✓
  - `@pure.decode_tga_pure(tga_bytes)` 纯 MoonBit 解码 ✓
  - `@core.load_from_bytes(tga_bytes, req_channels=Some(3))` FFI 基准解码 ✓
  - 断言 width/height/channels/data 完全一致 ✓
- 对比性质为真正的 FFI 基准对比（stb_image C 库原生支持 TGA 读写），非 QOI 的纯 MoonBit 交叉验证 ✓

### 构建验证（通过）
- `moon clean && moon check`（全目标）：ran 30 tasks，0 errors 0 warnings ✓
- `moon test --target native`：Total tests: 572, passed: 572, failed: 0 ✓
- 测试增量：562 → 572（+9 pure TGA + 1 roundtrip TGA），符合预期 571-573 ✓

### 架构约束（通过）
- v1.0 API 冻结：新增文件不修改现有代码签名，仅 `roundtrip_test.mbt` 新增测试 ✓
- 五子包架构：pure 包仅 `import types`（`moon.pkg`），全目标可用，无 FFI 依赖 ✓
- 纯 MoonBit 补齐：TGA 解码用纯 MoonBit 实现，放在 pure 包 ✓

### 执行报告一致性（通过）
- 产出清单与实际文件一致 ✓
- 偏差说明"无"与实际产出一致 ✓

### 轻微问题（不影响正确性，值得后续改进）
- **[轻微]** RLE 循环退出条件 `while pixel_idx.val < pixel_count && pos.val < len`（`tga_decode.mbt:73`）：若 RLE 数据不完整（pos 耗尽但像素未填满），循环静默退出，raw_pixels 剩余部分保持初始化的 0，函数返回部分黑色图像而非报错。对合规 TGA 文件无影响，任务也未要求此错误路径。
- **[轻微]** RLE packet 和 raw packet 的 run/count 超出 pixel_count 时（`tga_decode.mbt:89,108`），通过 `if pixel_idx.val + i < pixel_count` 软检查静默忽略超出部分，而非报错。对合规 TGA 文件无影响。
- **[轻微]** 未校验 `pixel_data_start <= len`（`tga_decode.mbt:43`）：若 id_length 异常大，pixel_data_start 超过数据长度，type 2 会在首次像素读取时报错，type 10 会因循环条件静默退出。对合规 TGA 文件无影响。
