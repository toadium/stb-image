# 计划审查报告（v1 r2）

## 审查结果
APPROVED

## 发现

r1 审查的 4 项问题均已有效修正，核实如下：

- **[r1 严重-1 已修正] 架构目标矛盾**：task_v1.md 第 11 行明确声明"本轮 pure 包暂设为 native-only，仅验证纯 MoonBit BMP 解码逻辑的正确性。wasm/js 目标平台解耦属于架构重构，需先拆分 core 包……留待后续轮次单独处理。本轮不声称'为 wasm/js 后端奠定基础'"。目标表述与依赖关系不再矛盾。核实 `src/core/moon.pkg` 确为 native-only（`supported_targets = "native"` + `native-stub`），pure 包依赖 core 则同样 native-only，计划已承认此事实而非掩饰。

- **[r1 严重-2 已修正] 类型依赖决策**：task_v1.md 第 13 行明确选定"复用 `@core.Image` 与 `@core.LoadError`，与现有纯 MoonBit 解码器 `src/format/qoi.mbt` 保持一致"。核实 `src/format/moon.pkg` 与 qoi 包同构（`import @core` + `supported_targets = "native"`），决策与项目既有模式一致，未下放给 Doer。

- **[r1 一般-3 已修正] 函数签名**：task_v1.md 第 15 行、第 33 行签名改为 `pub fn decode_bmp_pure(data : Bytes) -> @core.Image raise @core.LoadError`，与 `decode_qoi`（`src/format/qoi.mbt:13`）完全一致。失败路径（数据过短/magic 不匹配/不支持压缩/尺寸非法）均覆盖。

- **[r1 一般-4 已修正] 对比测试可行性**：task_v1.md 第 17 行明确"对比测试仅在 native 目标运行（pure 包 `for "test"` 配置依赖 core，调用 `@core.load_from_bytes`）。纯解码逻辑测试不依赖 core，仅断言自构造已知 BMP 数据的解码结果"。核实 `load_from_bytes`（`src/core/image_load_native.mbt:3`）支持 BMP（stb_image 内置 BMP 解码），`Image` 类型 `derive(Eq)`（`src/core/image_types.mbt:8`）支持逐字段比较，对比测试技术上可行。

新发现（均不影响正确性）：

- **[轻微] moon.pkg 的 `for "test"` 配置表述不精确**：task_v1.md 第 17 行说"pure 包 `for "test"` 配置依赖 core"，但第 22-27 行给出的 moon.pkg 示例已在主配置 `import @core`，测试文件天然可访问 `@core`，无需额外 `for "test"` 配置。此表述不精确但不影响 Doer 实现——Doer 按 moon.pkg 示例配置即可，对比测试可正常运行。

- **[轻微] re-export 决策未明确**：task_v1.md 第 58 行说"可能需要更新 `src/moon.pkg` 添加 pure 包依赖（若根包需要 re-export）"，未明确是否 re-export。但此模糊性给了 Doer 合理自主空间：不 re-export 更安全（不修改根包配置，零风险破坏 533 测试），re-export 则与 qoi 模式一致。两种选择均不违反 v1.0 API 冻结原则（纯新增）。不影响正确性。

- **[轻微] BMP 像素 BGR→RGB 转换未显式提及**：task_v1.md 第 39 行说"输出 RGB（channels=3）或 RGBA（channels=4）像素数据"，未显式提醒 BMP 文件存储为 BGR 顺序需转换。但此为 BMP 格式常识，且对比测试会自动验证像素顺序正确性，Doer 若遗漏则对比测试失败会修正。
