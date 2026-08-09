# 任务指令（v1）

## 动作
RETRY

## 任务描述
创建 `src/pure/{codec,pixel,color,process,util}/` 目录结构，实现纯 MoonBit 的 BMP 解码器，作为 v2.0 多目标支持的第一步概念验证。

### 架构决策（响应审查意见）

**本轮范围声明**：本轮 pure 包**暂设为 native-only**，仅验证纯 MoonBit BMP 解码逻辑的正确性。wasm/js 目标平台解耦属于架构重构，需先拆分 core 包（将 `Image`/`LoadError` 类型定义与 C stub FFI 分离到 `src/types/` 与 `src/native/`），留待后续轮次单独处理。本轮不声称"为 wasm/js 后端奠定基础"，仅验证"用纯 MoonBit 实现 BMP 解码"这一子目标可行性。

**类型方案**：复用 `@core.Image` 与 `@core.LoadError`，与现有纯 MoonBit 解码器 `src/format/qoi.mbt` 保持一致。pure 包 `moon.pkg` 设置 `supported_targets = "native"` 并 `import @core`。此决策承认本轮 pure 包为 native-only，与 qoi 包同构，不引入新的架构不一致。

**错误处理**：签名 `pub fn decode_bmp_pure(data : Bytes) -> @core.Image raise @core.LoadError`，与 `decode_qoi` 惯例一致，覆盖数据过短/magic 不匹配/不支持压缩/尺寸非法等失败路径。

**对比测试归属**：对比测试仅在 native 目标运行（pure 包 `for "test"` 配置依赖 core，调用 `@core.load_from_bytes`）。这与 qoi 包的测试配置模式一致（qoi 包 `moon.pkg` 已有 `import @process/color for "test"`）。纯解码逻辑测试不依赖 core，仅断言自构造已知 BMP 数据的解码结果。

### 具体要求

1. **创建 `src/pure/{codec,pixel,color,process,util}/` 目录结构**：
   - 创建 `src/pure/{codec,pixel,color,process,util}/moon.pkg`：
     ```
     import {
       "Toadium/image/src/core",
     }
     supported_targets = "native"
     ```
   - 创建 `src/pure/{codec,pixel,color,process,util}/bmp_decode.mbt`（BMP 解码实现）
   - 创建 `src/pure/{codec,pixel,color,process,util}/bmp_decode_test.mbt`（测试）

2. **实现纯 MoonBit 的 BMP 解码器**：
   - 函数签名：`pub fn decode_bmp_pure(data : Bytes) -> @core.Image raise @core.LoadError`
   - 支持 24-bit 无压缩 BMP（BI_RGB，compression=0）
   - 支持 32-bit 无压缩 BMP（BI_RGB，compression=0）
   - 正确解析 BMP 文件头（14 字节）+ DIB 头（BITMAPINFOHEADER，40 字节）
   - 处理行填充（每行 4 字节对齐）
   - 处理自下而上（height > 0）和自上而下（height < 0）的行序
   - 输出 RGB（channels=3）或 RGBA（channels=4）像素数据
   - 失败路径统一 `raise @core.LoadError::DecodeFailed(...)`，错误消息中文

3. **测试验证**：
   - 测试 1x1 24-bit BMP 解码（纯逻辑断言，不依赖 FFI）
   - 测试 2x2 24-bit BMP 解码（含行填充，纯逻辑断言）
   - 测试 1x1 32-bit BMP 解码（纯逻辑断言）
   - 测试自上而下行序（height < 0，纯逻辑断言）
   - 与 `@core.load_from_bytes` 结果对比验证（使用相同 BMP 数据，逐字段比较 width/height/channels/data）

4. **构建验证**：
   - 执行 `moon check --target native` 通过
   - 执行 `moon test --target native` 通过
   - 不破坏现有 533 测试 + 29 基准测试

### 预期产出
- `src/pure/{codec,pixel,color,process,util}/moon.pkg`
- `src/pure/{codec,pixel,color,process,util}/bmp_decode.mbt`
- `src/pure/{codec,pixel,color,process,util}/bmp_decode_test.mbt`
- 可能需要更新 `src/moon.pkg` 添加 pure 包依赖（若根包需要 re-export）

## 选择理由
- v1.17 已完成，下一版本为 v2.0 多目标支持（架构升级）
- v2.0 路径 A（双后端）需要纯 MoonBit 解码逻辑，本轮先验证 BMP 可行性
- BMP 格式简单（无压缩 24/32-bit），适合作为纯 MoonBit 解码起点
- 复用 core 类型与 qoi 包同构，不引入新架构不一致，风险低
- 放在新目录 `src/pure/{codec,pixel,color,process,util}/`，不破坏现有五子包架构和 533 测试

## 任务上下文
摘录自 task.md 和 ROADMAP.md 的直接相关需求/约束：

- **执行约束 1**：保持 v1.0 API 冻结原则，新增功能只添加，不修改已有签名
- **执行约束 2**：遵循五子包架构：core（FFI+类型）/ process / format / meta / util
- **执行约束 5**：测试先行，每个新功能必须有测试 + ASan 验证（FFI 部分）
- **执行约束 6**：不破坏现有测试，所有现有 533 测试 + 29 基准测试必须继续通过
- **执行约束 7**：构建验证，每轮完成后必须执行 `moon check --target native` 和 `moon test --target native` 验证

- **ROADMAP v2.0 目标**：支持 wasm/js 目标，与 mizchi 拉平
- **ROADMAP v2.0 路径 A**：native 目标保持现有 C FFI 绑定，wasm/js 目标纯 MoonBit fallback
- **ROADMAP v2.0 交付物**：`src/native/`（native 后端，现有 C FFI）+ `src/pure/{codec,pixel,color,process,util}/`（纯 MoonBit 后端，wasm/js）+ `src/lib.mbt`（后端选择层）

## 已有产出上下文
工作目录中暂无其他产出（首轮 PDC 循环，计划审查后修正重试）。

项目现有结构：
- `src/core/` — FFI 绑定 + 类型定义（`Image` 类型在 `image_types.mbt`，`LoadError` 错误类型）
- `src/format/` — 纯 MoonBit 编解码（qoi/gif_encode/pnm_encode），`moon.pkg` 同样 `supported_targets = "native"` 并 `import @core`
- `src/process/` — 图像处理（filter/edge/color/frequency/transform/feature/segment 子包）
- `src/meta/` — 元数据（exif/png_meta）
- `src/util/` — 工具函数
- `src/reexport.mbt` — 根包 re-export 保持向后兼容
- `moon.mod` — 版本 1.17.0，`preferred_target = "native"`
- `src/moon.pkg` — `supported_targets = "native"`

关键参考：
- `src/core/image_types.mbt` — `Image` 类型定义（`{ width, height, channels, data : Bytes }`）
- `src/core/image_load_native.mbt` — 现有 FFI 加载实现（`load_from_bytes`，对比验证用）
- `src/format/qoi.mbt:13` — 纯 MoonBit 解码器范例（`pub fn decode_qoi(data : Bytes) -> @core.Image raise @core.LoadError`）

## RETRY 说明（仅 RETRY 时）
**失败原因**：计划审查 REJECTED，4 项问题：
1. [严重] 架构目标矛盾：pure 包声称服务 wasm/js 但依赖 core 则被锁死 native-only
2. [严重] 类型依赖决策未明确：复用 core.Image 与定义等价类型两路径均与目标冲突，计划未做选择
3. [一般] 函数签名缺 `raise @core.LoadError`，与 `decode_qoi` 惯例不符
4. [一般] 对比测试可行性未论证：对比测试依赖 native-only 的 core，与 pure 包目标平台冲突

**修正方向**：
1. 明确声明本轮 pure 包暂设 native-only，仅验证解码逻辑正确性，wasm/js 解耦留待后续轮次（需先重构 core 包分离类型与 FFI）
2. 选定复用 `@core.Image` 与 `@core.LoadError`，与 qoi 包同构，承认本轮 native-only
3. 签名改为 `pub fn decode_bmp_pure(data : Bytes) -> @core.Image raise @core.LoadError`
4. 对比测试仅在 native 目标运行（pure 包 `for "test"` 依赖 core），纯逻辑测试不依赖 core
