# 执行报告（v4）

## 概述
将 T3 方案 B 移除的 pure-FFI BMP 对比验证测试移至根包 `src/roundtrip_test.mbt`（已 native-only），恢复纯 MoonBit 解码器与 FFI 解码器的一致性验证。采用方案 A：仅保留 24-bit RGB 对比测试（审查 v4 r1 推荐），放弃 32-bit RGBA 对比测试（FFI 写出 BITMAPV4HEADER+BI_BITFIELDS，超出 pure 解码器能力范围）。构建验证通过：`moon check --target native` 0 errors / 0 warnings，`moon test --target native` 553/553 通过（552→553，新增 1 测试），全目标 `moon check` 0 errors / 0 warnings。

## 产出清单
| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 修改 | `src/moon.pkg` | 新增 `@pure` 测试专用依赖（`for "test"` 语法），消除 unused_package 警告 |
| 修改 | `src/roundtrip_test.mbt` | 新增 1 个 24-bit RGB pure-FFI 对比测试 `roundtrip: BMP RGB pure vs FFI` |

## 执行过程

### 1. 方案 A 实施
按任务指令采用方案 A（仅保留 24-bit RGB 对比测试）：

1. **`src/moon.pkg` 依赖声明**：新增 `@pure` 依赖。初版采用普通 import（加入主 import 列表），`moon check --target native` 报 `unused_package` 警告——`@pure` 只在 native-only 测试文件 `roundtrip_test.mbt` 中使用，`moon check` 不分析测试文件的包引用，故认为 `@pure` 未使用。改用 `for "test"` 语法声明为测试专用依赖（项目内 `src/pure/{codec,pixel,color,process,util}/moon.pkg` v2 版本已有此语法先例），警告消除，语义等价。
2. **`src/roundtrip_test.mbt` 新增测试**：在现有 `roundtrip: BMP RGB` 测试后新增 `roundtrip: BMP RGB pure vs FFI`，模式：
   - `@core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))` 加载 24-bit RGB 图像
   - `@core.write_bmp_to_bytes(img)` 生成 BMP 字节流（FFI 写出 BITMAPINFOHEADER 40 字节 + BI_RGB + 24bpp）
   - `@codec.decode_bmp_pure(bmp_bytes)` 纯 MoonBit 解码
   - `@core.load_from_bytes(bmp_bytes, req_channels=Some(3))` FFI 基准解码
   - 断言两者 width / height / channels / data 完全一致

### 2. 兼容性核实
- **FFI 24-bit 写出路径**（`src/core/stb_image_write.h:492-510`）：comp!=4 → BITMAPINFOHEADER(40) + BI_RGB(0) + 24bpp，与 pure 解码器兼容
- **pure 解码器能力**（`src/pure/{codec,pixel,color,process,util}/bmp_decode.mbt:21,35`）：接受 dib_size==40 && compression==0 && bpp∈{24,32}，24-bit 路径兼容确认
- **类型兼容**：`@codec.decode_bmp_pure` 返回 `@types.Image`，`@core.load_from_bytes` 返回 `@core.Image`（即 `@types.Image` 别名，`src/core/image_types_reexport.mbt:5`），字段 width/height/channels/data 均 derive(Eq)，直接比较可行

### 3. 构建验证
- `moon check --target native`：通过，0 errors 0 warnings
- `moon check`（全目标）：通过，0 errors 0 warnings
- `moon test --target native`：553/553 通过（552→553，新增 1 测试）

### 关键决策
1. **`for "test"` 语法而非普通 import**：任务指令步骤 1 原文是"import 列表添加 pure"，但普通 import 导致 `unused_package` 警告（`@pure` 仅测试文件使用），不符合"0 warnings"要求。`for "test"` 是 MoonBit 声明测试专用依赖的官方方式，语义等价且消除警告，属于对任务指令的实现细节调整，不改变任务意图（pure 包对根包测试可用）。
2. **仅 24-bit RGB，不新增 32-bit RGBA**：审查 v4 r1 已指出 32-bit 技术不可行（FFI 写出 BITMAPV4HEADER+BI_BITFIELDS，pure 解码器仅支持 BITMAPINFOHEADER+BI_RGB），任务指令明确采用方案 A，32-bit 对比验证留待后续轮次扩展 pure 解码器后补充。

## 偏差说明
1. **`src/moon.pkg` 依赖声明方式调整**：任务指令步骤 1 原文"import 列表添加 `src/pure`"，实际采用 `for "test"` 语法声明为测试专用依赖（非主 import 列表）。原因：普通 import 触发 `unused_package` 警告（`@pure` 仅在 native-only 测试文件中使用，`moon check` 不分析测试文件包引用），不符合任务指令"0 errors 0 warnings"预期产出。`for "test"` 语法是 MoonBit 官方测试专用依赖声明方式（项目内 `src/pure/{codec,pixel,color,process,util}/moon.pkg` v2 版本已有先例），语义等价，属实现细节调整，不改变任务意图。
