# 计划审查报告（v1 r1）

## 审查结果
REJECTED

## 发现

- **[严重] 架构目标自相矛盾：pure 包的目标平台与 core 依赖冲突**
  计划声称 `src/pure/` 是"v2.0 多目标支持（路径 A 双后端）的第一步概念验证"，目标是"wasm/js 目标纯 MoonBit fallback"。但 `src/core/moon.pkg` 设置 `supported_targets = "native"` 且通过 `options("native-stub": [ "wrapper.c" ])` 绑定 C stub，是 native-only 包。`src/moon.pkg` 根包同样 `supported_targets = "native"`。若 `src/pure/` 依赖 `@core`（复用 `Image` 类型或对比测试调用 `load_from_bytes`），则 pure 包被传染为 native-only，完全违背"wasm/js 后端"初衷。计划未说明 `src/pure/moon.pkg` 的 `supported_targets` 如何配置，也未说明如何在不依赖 core 的前提下达成 wasm/js 目标。

- **[严重] 类型依赖决策悬而未决，且两个选项都与目标冲突**
  task_v1.md 第 17 行写"复用 core 的 `Image` 类型，或定义等价类型"，将关键架构决策推给 Doer。两个选项均有问题：
  - 复用 `@core.Image`：pure 包必须 `import @core` → pure 包成为 native-only → wasm/js 目标不可达。
  - 定义等价类型：pure 包可独立，但 task_v1.md 第 30 行又要求"与现有 FFI 的 `load_from_bytes` 结果对比验证"，对比测试需要同时持有 pure 类型与 core.Image，要么 pure 包在 test 配置下依赖 core（再次锁死 native），要么 Doer 自行实现跨类型逐字段比较，计划未给出任何指引。
  此决策是整个任务可行性的基础，必须在计划阶段明确，不能下放给 Doer。

- **[一般] 函数签名与项目既有惯例不一致，缺失错误处理**
  task_v1.md 第 17 行要求签名 `pub fn decode_bmp_pure(data : Bytes) -> Image`。但项目现有纯 MoonBit 解码器 `src/format/qoi.mbt:13` 的签名为 `pub fn decode_qoi(data : Bytes) -> @core.Image raise @core.LoadError`，统一使用 `raise @core.LoadError` 处理解码失败。BMP 解码存在多种失败情况（数据过短、magic 不匹配、不支持的压缩、尺寸非法等），计划签名缺少 `raise`，既偏离惯例，又无法表达失败，会导致 Doer 要么自行发明错误处理风格，要么忽略错误情况。

- **[一般] 对比测试可行性未论证，与 pure 包目标平台冲突**
  task_v1.md 第 30 行要求"与现有 FFI 的 `load_from_bytes` 结果对比验证（使用相同 BMP 数据）"。`load_from_bytes` 位于 native-only 的 `src/core`，若 pure 包测试需调用它，则 pure 包的 `moon.pkg` 必须在 `for "test"` 配置中依赖 core，导致测试只能在 native 目标运行。这与"为后续 wasm/js 后端奠定基础"的目标矛盾——一个测试只能 native 跑的"纯 MoonBit 后端"无法验证其在 wasm/js 下的正确性。计划未说明对比测试如何在不破坏 pure 包目标平台的前提下进行（例如是否仅在 native 目标做对比、是否接受测试目标与运行目标分离等）。

- **[轻微] "概念验证"范围偏大，与定位不符**
  task_v1.md 要求支持 24-bit 与 32-bit、行填充、自下而上与自上而下两种行序、5 类测试、FFI 对比验证，工作量接近完整实现。作为"第一步概念验证"，可先只做 24-bit 无压缩 + 基本解码验证以降低风险，但这不影响正确性。

## 修改要求（仅 REJECTED 时）

1. **[严重] 架构目标矛盾**：
   - 问题：pure 包声称服务 wasm/js 目标，但任何对 native-only 的 core 包的依赖都会把 pure 包锁死为 native-only，使目标不可达。
   - 为什么是问题：Doer 按当前指令实现后，要么产出一个名不副实的"pure"包（实际只能 native 运行，wasm/js 目标落空），要么在实现中自行做架构决策，偏离计划意图。
   - 期望修正方向：计划必须明确 `src/pure/` 的 `supported_targets` 配置，并给出不依赖 core 的类型方案。若本轮确实只能在 native 下做概念验证，应明确声明"本轮 pure 包暂设为 native-only，仅验证解码逻辑正确性，wasm/js 目标平台解耦留待后续轮次"，并相应调整"为 wasm/js 后端奠定基础"的表述，避免误导。

2. **[严重] 类型依赖决策未明确**：
   - 问题：复用 core.Image 与定义等价类型两条路径均与既定目标冲突，计划却未做选择。
   - 为什么是问题：这是整个任务可行性的根基，下放给 Doer 会导致实现方向不可控，且无论 Doer 选哪条都会撞上对比测试的依赖问题。
   - 期望修正方向：计划应明确选定一种类型方案，并论证其与目标平台及对比测试的相容性。若选独立类型，需说明对比测试如何跨类型验证；若选复用 core.Image，需承认 pure 包本轮为 native-only 并修正目标表述。

3. **[一般] 函数签名缺失错误处理**：
   - 问题：签名 `pub fn decode_bmp_pure(data : Bytes) -> Image` 缺少 `raise @core.LoadError`，与 `decode_qoi` 惯例不符。
   - 为什么是问题：BMP 解码有多种失败路径，无 `raise` 则 Doer 无法表达失败，要么偏离项目风格，要么忽略错误。
   - 期望修正方向：签名改为 `pub fn decode_bmp_pure(data : Bytes) -> <Image 类型> raise <LoadError 类型>`，并明确错误类型来源（core.LoadError 或 pure 包自定义错误），与类型依赖决策一并考虑。

4. **[一般] 对比测试可行性**：
   - 问题：对比测试依赖 native-only 的 core，与 pure 包目标平台冲突。
   - 为什么是问题：Doer 无法在满足"pure 包可服务 wasm/js"的同时满足"对比测试调用 FFI"，会陷入两难。
   - 期望修正方向：明确对比测试的目标平台归属。例如：声明对比测试仅在 native 目标运行（pure 包测试配置 `for "test"` 依赖 core，但纯解码逻辑测试不依赖 core），或改为 pure 包内部自构造已知 BMP 数据做断言，不与 FFI 对比。需在计划中给出明确取舍。
