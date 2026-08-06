# 需求文档审查报告（v2）

## 审查结果

[APPROVED]

## 逐维度审查

### 1. 忠实性

**[通过]** 准确传达用户"我需要一个完整的库"的原始意图：第一节"项目定位"明确"最终目标是提供一个完整的图像处理库"，第五节"边界约束"重新审视所有限制，区分"完整库目标"与"MVP 阶段性限制"，每条阶段性限制均给出解锁计划，与"完整库"定位一致。

**[通过]** 忠实执行"只参考，不引用已有库"约束：grep 确认 mizchi/image 仅出现在第 302、306 行"修订说明"中，作为记录"已移除"的元说明（说明修订动作），非需求内容中将其作为依赖、互补基准或对比对象的引用。需求正文（第一至八节）中无任何已有库（mizchi/image、image-mbt 等）作为依赖/互补/对比的引用。第 11 行"MoonBit 生态较少覆盖的格式"为泛指生态现状的定性陈述，未点名任何具体库，属于对 stb_image 价值定位的独立陈述，不违反约束。

**[通过]** 忠实补充版本迭代计划：第六节规划 v0.1→v0.2→v0.3→v0.4→v1.0 演进路径，各版本目标、范围、关键 API 增量、验收标准概要齐备，符合用户"补充版本迭代计划"要求。

**[通过]** 推断性补充均标注清楚：stb_image_write.h 纳入（基于"完整库"诉求合理推断）、PNM 格式补齐（基于 stb_image v2.30 默认能力核实，标注 v1 漏列）、多目标支持（标注为 v1.0 评估项而非承诺），均在第七节"澄清与推断汇总"中列明依据。

**[通过]** 无遗漏：原始需求的目标用户、核心问题、MVP 范围、FFI 方案要点、验收标准、边界约束均在 req_v2.md 中体现，并按"完整库"定位重新定性。

### 2. 清晰性

**[通过]** 版本迭代计划清晰无歧义：各版本目标明确（v0.1 验证 FFI 可行性、v0.2 补齐 write 闭环、v0.3 覆盖全部数据类型与查询、v0.4 暴露流式能力、v1.0 评估多目标），范围与 API 增量具体到函数名（如 `load_16_from_path`、`write_png_to_path`、`IoCallbacks` trait），下游可准确理解每步交付物。

**[通过]** 边界清晰：第五节明确区分"完整库目标"（11 项能力）与"MVP 阶段性限制"（11 项，每项给出解锁计划与对应版本），读者能准确区分"最终要做"与"当前不做"。

**[通过]** MoonBit v0.10.5 规范保留且清晰：第 74、86、87、144 行明确使用新格式 `moon.mod`/`moon.pkg`（非 `moon.mod.json`/`moon.pkg.json`），`preferred_target`（下划线，非旧 `"preferred-target"`），并标注旧格式在 v0.10.4 弃用，下游不会误用旧格式。

**[通过]** 多目标演进表述清晰：第 249-258 行详细评估 wasm/js/wasm-gc 路径，明确标注"v1.0 的核心评估项，而非承诺交付"，避免下游误解为强制交付。

**[通过]** `Image` 值类型、错误处理（`raise LoadError`）、加载入口（`load_from_path` + `load_from_bytes`）均澄清了原始表述的歧义（"返回"→`raise`、`InputStream` 移除）。

### 3. 完备性

**[通过]** 版本迭代计划完整合理：
- v0.1 MVP：load 路径，9 种格式，8-bit，native 目标
- v0.2：write 能力 + req_channels + flip + write 端配置（基本读写闭环）
- v0.3：16-bit/float/info/查询/HDR 配置/iPhone PNG/unpremultiply/PNM/failure_reason（覆盖全部数据类型与查询）
- v0.4：I/O callbacks/动画 GIF/流式（流式能力）
- v1.0：多目标支持/API 冻结/性能优化（完整库）
演进逻辑递进合理，API 增量与 stb_image 能力对应。

**[通过]** stb_image 完整能力覆盖完备：第 150-173 行梳理 load 端（8-bit/16-bit/float/info/is_16_bit/is_hdr/动画 GIF/配置/HDR 配置/failure_reason/image_free/I/O callbacks/desired_channels/支持格式）与 write 端（PNG/BMP/TGA/JPEG/HDR to file/to func/to mem/flip/配置），覆盖 stb_image.h v2.30 + stb_image_write.h v1.16 完整 API，作为版本迭代规划基准。

**[通过]** 边界约束修订与"完整库"定位一致：第五节"完整库目标"11 项能力与"MVP 阶段性限制"11 项一一对应，每项阶段性限制均指向具体解锁版本，无永久边界（除"仅 native"已标注 v1.0 评估），与"完整库"定位一致。

**[通过]** 文档自包含可支撑下游设计：第八节"下游设计输入"列出 11 个决策点（LoadError 层级、C wrapper 错误信号、Image 导出级别、测试图片取得、vendoring 版本、SKILL.md 结构、包结构策略、16-bit/float Bytes 编码、IoCallbacks trait 设计、多目标路径、零拷贝评估），下游架构设计与技术设计可据此推进，无需回查原始表述。

**[通过]** MoonBit v0.10.5 规范完备保留：包布局、moon.mod 配置、moon.pkg 配置、ffi.mbt 门控均按新格式描述，并核实 `moonbit_make_bytes` 存在于 `moonbit.h:343`，方案可行。