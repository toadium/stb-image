# 执行报告（v1）

## 概述
创建 `src/pure/{codec,pixel,color,process,util}/` 目录结构，实现纯 MoonBit 的 BMP 解码器（24-bit/32-bit 无压缩），作为 v2.0 多目标支持的第一步概念验证。本轮 pure 包暂设为 native-only，复用 `@core.Image` 与 `@core.LoadError`，与现有 `src/format/qoi.mbt` 同构，不引入新架构不一致。

## 产出清单
| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 新建 | `src/pure/{codec,pixel,color,process,util}/moon.pkg` | pure 包配置，import core，supported_targets = "native" |
| 新建 | `src/pure/{codec,pixel,color,process,util}/bmp_decode.mbt` | 纯 MoonBit BMP 解码器实现 |
| 新建 | `src/pure/{codec,pixel,color,process,util}/bmp_decode_test.mbt` | 8 个测试（纯逻辑断言 + 与 FFI 对比验证） |

## 执行过程

### 架构决策（响应审查意见）
1. **本轮范围**：pure 包暂设 native-only，仅验证纯 MoonBit BMP 解码逻辑正确性。wasm/js 目标平台解耦属于架构重构，需先拆分 core 包（分离类型定义与 C stub FFI），留待后续轮次。
2. **类型方案**：复用 `@core.Image` 与 `@core.LoadError`，与 `src/format/qoi.mbt` 同构。pure 包 `moon.pkg` 设置 `supported_targets = "native"` 并 `import @core`。
3. **错误处理**：签名 `pub fn decode_bmp_pure(data : Bytes) -> @core.Image raise @core.LoadError`，与 `decode_qoi` 惯例一致。
4. **对比测试**：对比测试仅在 native 目标运行（pure 包主配置已 import core，测试自动继承）。纯解码逻辑测试不依赖 core，仅断言自构造已知 BMP 数据的解码结果。

### 实现细节
- **BMP 文件头解析**：14 字节，校验 magic "BM"，读取 data_offset
- **DIB 头解析**：BITMAPINFOHEADER（40 字节），读取 width/height/bpp/compression
- **支持范围**：24-bit（channels=3）和 32-bit（channels=4）无压缩 BMP（BI_RGB，compression=0）
- **行填充**：每行 4 字节对齐，`row_size = ((width * bytes_per_pixel + 3) / 4) * 4`
- **行序处理**：height > 0 自下而上，height < 0 自上而下
- **像素转换**：BGR(A) -> RGB(A)
- **失败路径**：数据过短/magic 不匹配/不支持的 DIB 头/位深/压缩/尺寸无效/像素越界，统一 `raise @core.LoadError::DecodeFailed(...)`，错误消息中文

### 测试覆盖
1. 1x1 24-bit BMP 解码（纯逻辑断言）
2. 2x2 24-bit BMP 解码（含行填充，纯逻辑断言）
3. 1x1 32-bit BMP 解码（纯逻辑断言）
4. 1x2 自上而下行序（height < 0，纯逻辑断言，顶行红底行绿验证行序）
5. 与 `@core.load_from_bytes` 对比验证（1x1，逐字段比较）
6. 与 `@core.load_from_bytes` 对比验证（2x2，逐字段比较）
7. invalid magic 错误路径
8. too short 错误路径

### 构建验证
- `moon check --target native`：通过
- `moon test --target native`：全部 554 测试通过（原有测试 + 新增 8 个 pure 测试），未破坏现有测试

### 关键决策依据
- 参考 `src/format/qoi.mbt` 的纯 MoonBit 解码器模式（签名、错误处理、Bytes 操作）
- 参考 `src/format/moon.pkg` 的包配置模式（import core，supported_targets = "native"）
- BMP 测试数据参考 `src/format/test_helpers_test.mbt` 和 `src/core/ffi_test.mbt` 的 `make_1x1_red_bmp` / `make_2x2_colors_bmp`
- 用 Python struct 模块生成正确的字节字面量，避免手动计数错误

## 偏差说明
无。按任务指令完成所有具体要求，未修改 `src/moon.pkg`（pure 包作为独立包存在，本轮不需要 re-export）。
