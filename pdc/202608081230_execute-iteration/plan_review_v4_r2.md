# 计划审查报告（v4 r2）

## 审查结果
APPROVED

## 发现

本轮独立核实 task_v4 的关键技术假设与源码现状，确认方案 A（仅保留 24-bit RGB 对比测试）技术可行，且完整回应了 plan_review_v4_r1 的 2 项严重问题的修改要求。

### 核实项

1. **FFI 24-bit BMP 写出格式已核实**（`src/core/stb_image_write.h:492-500`）：`stbi_write_bmp_core` 对 `comp != 4` 分支写出 BITMAPINFOHEADER（DIB 头 40 字节）+ BI_RGB（compression=0）+ 24bpp，文件头 `14+40`，data_offset=54。task_v4 引用准确。

2. **pure 解码器能力范围已核实**（`src/pure/{codec,pixel,color,process,util}/bmp_decode.mbt:21,31,35`）：`decode_bmp_pure` 显式校验 `dib_size == 40`（行 21）、`bpp ∈ {24, 32}`（行 31）、`compression == 0`（行 35），拒绝其他。24-bit 路径（dib_size=40, compression=0, bpp=24）兼容确认。

3. **32-bit 路径不兼容已核实**（`src/core/stb_image_write.h:501-508`）：`comp == 4` 分支写出 BITMAPV4HEADER（108 字节）+ BI_BITFIELDS（compression=3）+ 32bpp，pure 解码器在行 21 拒绝（dib_size=108 != 40）。task_v4 放弃 32-bit 对比测试的决策正确。

4. **函数签名均已核实匹配**：
   - `@core.load_from_path(path : String, req_channels? : Int? = None) -> Image raise LoadError`（`src/core/image_load_native.mbt:35`）— task_v4 调用 `@core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))` 匹配
   - `@core.write_bmp_to_bytes(img : Image) -> Bytes raise LoadError`（`src/core/image_write_native.mbt:95`）— task_v4 调用 `@core.write_bmp_to_bytes(img)` 匹配，传入 `img.channels=3` 走 24-bit 分支
   - `@core.load_from_bytes(data : Bytes, req_channels? : Int? = None) -> Image raise LoadError`（`src/core/image_load_native.mbt:3`）— task_v4 调用 `@core.load_from_bytes(bmp_bytes, req_channels=Some(3))` 匹配
   - `@codec.decode_bmp_pure(data : Bytes) -> @types.Image raise @types.LoadError`（`src/pure/{codec,pixel,color,process,util}/bmp_decode.mbt:8`）— 与 task_v4 描述一致

5. **`@types.Image` 字段已核实**（`src/types/image_types.mbt:3-8`）：`pub(all) struct Image { width : Int, height : Int, channels : Int, data : Bytes } derive(Eq, @debug.Debug)`。task_v4 断言 "width / height / channels / data 完全一致" 字段名正确，类型为 Int/Bytes，字段级 `assert_eq` 可行。

6. **测试数据存在**：`testdata/test_4x4_red.png` 已确认存在。用 `req_channels=Some(3)` 加载后 `img.channels == 3`，`write_bmp_to_bytes` 走 24-bit 分支。

7. **根包 import pure 包语法合法**：`src/moon.pkg` 当前 `supported_targets = "native"`，import 列表含 core/process/format/meta/util，不含 pure（已核实）。pure 包 `src/pure/{codec,pixel,color,process,util}/moon.pkg` 仅 import types，无 `supported_targets`（全目标，已核实）。native 包依赖全目标包语法合法。

8. **roundtrip_test.mbt native-only 已核实**：`src/moon.pkg` 第 22 行 `options(targets: {"roundtrip_test.mbt": ["native"]})`，roundtrip_test.mbt 仅 native 目标编译，可自由依赖 @core + @pure。

9. **测试模式有先例**：`src/roundtrip_test.mbt:32-42` 现有 `roundtrip: BMP RGB` 测试，模式正是 `@core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))` → `@core.write_bmp_to_bytes(img)` → `@core.load_from_bytes(encoded, req_channels=Some(3))` → 断言 data 一致。task_v4 新增测试在此基础上增加 `@codec.decode_bmp_pure` 对比分支，模式成熟。

10. **行 padding 与行序兼容性已核实**：24-bit BMP width=4，行数据 12 字节，4 字节对齐无 padding（pure `row_size=((4*3+3)/4)*4=12`，FFI `pad=(-4*3)&3=0`，一致）。stb_image_write 写出 height 为正（自下而上），pure 解码器 `bottom_up=true`（height>0）正确处理。两者 BGR→RGB 转换均正确，data 应一致。

11. **预期测试数 552→553 合理**：T3 后 native 552 通过（check_v3.md 确认），新增 1 个 24-bit RGB 对比测试，预期 553。

12. **v1.0 API 冻结与现有测试不破坏**：本轮仅新增 1 个测试文件内容 + 1 行 import，不改现有 API 或现有代码。新增测试在 native-only 的 roundtrip_test.mbt 中，不影响 wasm/js。

### 对上一轮审查修改要求的回应确认

- **问题 1（32-bit RGBA 技术不可行）**：task_v4 采用方案 A，仅保留 24-bit RGB，放弃 32-bit RGBA，预期 552→553。回应完整。
- **问题 2（未论证 FFI 生成与 pure 解码器匹配性）**：task_v4 在"选择理由"第 3 点和"任务上下文"明确论证了 `stb_image_write.h:494-500` 24-bit 路径与 `bmp_decode.mbt:21,35` pure 解码器的兼容性，并说明 32-bit 不兼容原因。回应完整。

### 轻微问题

- **[轻微] 测试名称未明确指定**：task_v4 步骤 2 描述了测试流程但未给出具体测试名称（如 `roundtrip: BMP pure vs FFI RGB`）。Doer 需自行命名以避免与现有 `roundtrip: BMP RGB` 冲突。不影响正确性。
- **[轻微] 断言方式未明确**：task_v4 说"断言两者 width / height / channels / data 完全一致"，未明确是 4 个独立 `assert_eq` 还是利用 `derive(Eq)` 直接 `assert_eq(pure_img, ffi_img)`。两者均可行，Doer 可自行决定。不影响正确性。
