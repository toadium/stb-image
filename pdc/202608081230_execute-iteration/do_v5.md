# 执行报告（v5）

## 概述
在 `src/pure/{codec,pixel,color,process,util}/` 新增纯 MoonBit QOI 解码器 `decode_qoi_pure`，扩展 pure 包格式覆盖（从仅 BMP 扩展到 BMP + QOI），推进 v2.0 多目标支持的实质功能。同时新增 8 个 pure 包纯逻辑测试（覆盖全部 6 种 QOI 标签 + 2 错误路径）和 1 个根包 QOI pure vs format 交叉验证对比测试。构建验证全通过：`moon check`（全目标）0 errors 0 warnings，`moon test --target native` 562 通过（553→562，新增 9 测试全部通过）。

## 产出清单
| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 新建 | `src/pure/{codec,pixel,color,process,util}/qoi_decode.mbt` | 纯 MoonBit QOI 解码器，`pub fn decode_qoi_pure(data : Bytes) -> @types.Image raise @types.LoadError`，支持全部 6 种 QOI 标签（INDEX/DIFF/LUMA/RUN/RGB/RGBA），移植自 `src/format/qoi.mbt:13-116`，仅替换 `@core.Image`→`@types.Image`、`@core.LoadError`→`@types.LoadError` |
| 新建 | `src/pure/{codec,pixel,color,process,util}/qoi_decode_test.mbt` | 8 个纯逻辑测试（全目标可用，不依赖 @core）：1x1 RGB(OP_RGB)、1x1 RGBA(OP_RGBA)、2x2 RGB(OP_DIFF)、2x2 RGB(OP_LUMA)、2x2 RGB(OP_RUN)、2x2 RGBA(OP_INDEX)、magic 错误、数据过短 |
| 修改 | `src/roundtrip_test.mbt` | 新增 1 个 native-only 对比测试 `roundtrip: QOI pure vs format`，`@format.encode_qoi` 生成 QOI 字节流 → `@codec.decode_qoi_pure` 与 `@format.decode_qoi` 交叉验证，断言 width/height/channels/data 完全一致 |

## 执行过程

### 1. QOI 解码器移植（`src/pure/{codec,pixel,color,process,util}/qoi_decode.mbt`）
- **参考实现**：`src/format/qoi.mbt:13-116` 的 `decode_qoi`，该实现已是纯 MoonBit（无 FFI 调用）
- **移植改动**：仅替换类型引用 `@core.Image` → `@types.Image`、`@core.LoadError` → `@types.LoadError`，逻辑完全保留
- **标签覆盖**：
  - QOI_OP_INDEX(0x00-0x3F)：从 64 槽位 index 数组读取像素
  - QOI_OP_DIFF(0x40-0x7F)：单字节差分（dr/dg/db 各 2-bit，范围 [-2,1]）
  - QOI_OP_LUMA(0x80-0xBF)：双字节差分（dg 6-bit + dr_dg/db_dg 各 4-bit）
  - QOI_OP_RUN(0xC0-0xFF)：游程编码（run 范围 [1,62]）
  - QOI_OP_RGB(0xFE)：显式 RGB 三字节
  - QOI_OP_RGBA(0xFF)：显式 RGBA 四字节
- **哈希函数**：`qoi_hash(r,g,b,a) = (r*3 + g*5 + b*7 + a*11) % 64`
- **头部验证**：magic "qoif"（0x71 0x6F 0x69 0x66）、宽高（大端）、channels、8 字节结束标记

### 2. 纯逻辑测试构造（`src/pure/{codec,pixel,color,process,util}/qoi_decode_test.mbt`）
- **辅助函数**：`make_qoi_header`（构造 14 字节 QOI 头）、`make_qoi_end`（8 字节结束标记）、`append_bytes`（Array[Byte] 追加）、`to_bytes`（Array[Byte] → Bytes）
- **测试用例设计**（手构造 QOI 字节流，编码值经 Python 预计算验证）：
  1. `1x1 RGB (QOI_OP_RGB)`：像素 (100,150,200)，标签 0xFE + 3 字节
  2. `1x1 RGBA (QOI_OP_RGBA)`：像素 (100,150,200,50)，标签 0xFF + 4 字节
  3. `2x2 RGB (QOI_OP_DIFF)`：4 像素 (50,50,50)→(53,53,53)，首像素 OP_RGB，后续 3 个 OP_DIFF（tag=0x7F）
  4. `2x2 RGB (QOI_OP_LUMA)`：像素 1 为 (118,120,122)，prev=(100,100,100)，dg=20/dr_dg=-2/db_dg=2，tag=0xB4 b2=0x6A
  5. `2x2 RGB (QOI_OP_RUN)`：4 像素全 (200,100,50)，首像素 OP_RGB，后续 OP_RUN run=3（tag=0xC2）
  6. `2x2 RGBA (QOI_OP_INDEX)`：4 像素全 (10,20,30,40)，首像素 OP_RGBA，后续 OP_INDEX（hash=12, tag=0x0C）
  7. `invalid magic raises`：magic="xxxx"，断言抛出 `LoadError::DecodeFailed`
  8. `too short raises`：4 字节（< 14），断言抛出 `LoadError::DecodeFailed`
- **编码值验证**：QOI_OP_DIFF/LUMA/INDEX/RUN 的 tag 字节均经 Python 脚本预计算确认（DIFF=0x7F, LUMA tag=0xB4 b2=0x6A, INDEX hash=12, RUN=0xC2）

### 3. 交叉验证对比测试（`src/roundtrip_test.mbt`）
- **测试名**：`roundtrip: QOI pure vs format`（native-only，由 `src/moon.pkg` 的 `options(targets: {"roundtrip_test.mbt": ["native"]})` 约束）
- **验证模式**：`@core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))` → `@format.encode_qoi(img)` → `@codec.decode_qoi_pure(qoi_bytes)` vs `@format.decode_qoi(qoi_bytes)` → 断言 width/height/channels/data 完全一致
- **依赖配置**：根包 `src/moon.pkg` 已 import `@format`（第 11 行）且 `for "test"` 声明 `@pure` 依赖（第 17 行），无需新增依赖
- **对比性质**：`@format.encode_qoi`/`@format.decode_qoi` 均为纯 MoonBit 实现（`src/format/qoi.mbt:13,121`，无 FFI/C stub），stb_image C 库不原生支持 QOI，故此对比为"pure 包独立实现 vs format 包独立实现"的交叉验证，两实现虽同源移植但独立构造可发现移植错误

### 4. 构建验证
- `moon check`（全目标）：0 errors 0 warnings ✓
- `moon test --target native`：Total tests: 562, passed: 562, failed: 0 ✓
  - 现有 553 测试全部通过（v1.0 API 冻结保持，无破坏）
  - 新增 8 个 pure 包纯逻辑测试全部通过
  - 新增 1 个根包对比测试通过
  - pure 包全目标化（T3 已完成），native 为其目标之一，必运行其测试

### 5. 关键决策
- **移植而非重写**：`src/format/qoi.mbt` 的 `decode_qoi` 已是纯 MoonBit 实现，直接移植仅替换类型引用，技术风险极低，且保证两实现同源便于交叉验证
- **辅助函数构造字节流**：测试用辅助函数 `make_qoi_header`/`make_qoi_end`/`append_bytes` 构造 QOI 字节流，比字节字面量更清晰且易维护，编码值经 Python 预计算验证
- **`append_bytes` 替代 `push_all`**：MoonBit `Array[Byte]` 无 `push_all` 方法，改用循环 push 的辅助函数
- **不修改现有代码**：仅新增文件 + 在 `roundtrip_test.mbt` 末尾追加测试，v1.0 API 冻结保持

## 偏差说明
无。任务全部按指令完成：
1. ✓ `src/pure/{codec,pixel,color,process,util}/qoi_decode.mbt` 实现 `decode_qoi_pure`，支持 RGB/RGBA 解码，覆盖全部 6 种 QOI 标签
2. ✓ `src/pure/{codec,pixel,color,process,util}/qoi_decode_test.mbt` 8 个测试用例，覆盖全部 6 种标签 + 2 错误路径，含 LUMA 双字节差分
3. ✓ `src/roundtrip_test.mbt` 新增 1 个 pure vs format 交叉验证测试（native-only，RGB 路径）
4. ✓ `moon check`（全目标）0 errors 0 warnings，`moon test --target native` 553→562 通过
