# 执行审查报告（v1 r2）

## 审查结果
REJECTED

## 发现

- **[一般] v2.0 交付物清单遗漏功能项 7 明确要修改的文档文件**
  - v2.0 功能项 7（第 198 行）要求"更新 `ARCHITECTURE.md`、`ROADMAP.md`、`COMPARISON.md` 反映多目标支持"，但 v2.0 交付物清单（第 207-210 行）仅列出 `src/core/native/`、`src/core/wasm/`、`src/core/moon.pkg`、`src/lib.mbt`、`moon.mod`，未包含上述三个文档文件。交付物清单与功能项列表脱节，影响可追踪性。

- **[一般] v2.1 交付物清单遗漏功能项 8（链式 API，涉及 process 子包）对应的文件变更**
  - v2.1 功能项 8（第 235 行）"链式 API：`img.brightness(10).contrast(1.2).blur(3)`"涉及子包标 `process`，但 v2.1 交付物清单（第 245-249 行）的新增文件仅列 `src/core/image_builder.mbt`、`src/core/image_methods.mbt`（均在 core），process 子包仅列出 `src/process/frequency/fft.mbt`（属功能项 3 的迭代式优化）。链式 API 需在 process 子包新增方法或封装文件，交付物清单未反映该变更，与功能项涉及的子包标注不一致。

- **[一般] 决策点 2 建议 `failure_reason` 改造推迟到 v2.1，但 v2.1 功能项列表未明确包含该改造**
  - 审阅检查清单决策点 2（第 395 行）建议"推迟到 v2.1 API 人体工程学改进时统一处理" `failure_reason` 改造。v1.20 功能项 4（第 128 行）描述的改造方向是"在 `LoadError` 变体中携带 stb 错误字符串"。但 v2.1 功能项 7（第 234 行）仅明确"配置函数改为 `LoadConfig` struct 传参（消除 `set_flip_vertically_on_load` 等全局状态）"，核心是配置函数 struct 化，与 `failure_reason` 的"LoadError 变体携带错误字符串"是不同改造方向。v2.1 功能项 1-9 无一项明确涵盖 `failure_reason` 改造，决策建议与功能项列表脱节，审阅者无法确认该改造的落地版本。

- **[一般] v2.0 工作量说明的 L 项计数与功能项表不一致**
  - v2.0 工作量说明（第 186 行）称"功能项拆分后含 2 个 L 项（纯 MoonBit PNG/JPEG 解码）和 2 个 M 项"，但 v2.0 功能项表（第 192-198 行）实际有 3 个 L 项：功能项 2（设计条件编译结构，L）、功能项 3（PNG 解码，L）、功能项 4（JPEG 解码，L）；M 项 2 个（项 1、项 5）；S 项 2 个（项 6、项 7）。工作量说明遗漏了功能项 2 的 L 等级，计数与功能项表数据矛盾，影响论证可信度。

- **[轻微] v1.20 合并理由工作量下限表述不够严谨**
  - v1.20 合并理由（第 119 行）称"P3（2-3 人日）+ P4（3-5 人日）= 5-8 人日落在 L 范围内"，但 L 定义为 6-10 人日，下限 5 落在 M 而非 L。虽 5-8 ≤ 10 满足"不超过 L"的合并原则，但"落在 L 范围内"的表述与口径定义有偏差。

- **[轻微] v1.21 交付物清单未明确 ICC profile 读取功能的文件归属**
  - v1.21 功能项 3（第 161 行）实现 `read_icc_profile_from_bytes`，但交付物清单（第 171-172 行）仅列新增 `src/meta/exif_write.mbt`，未说明 ICC profile 读取是并入 `exif_write.mbt` 还是新建独立文件（如 `src/meta/icc_profile.mbt`），文件归属不明确。

## 修改要求

1. **[一般] v2.0 交付物清单遗漏文档文件**：
   - 问题：功能项 7 要求修改 ARCHITECTURE.md、ROADMAP.md、COMPARISON.md，但交付物清单未列出。
   - 为什么是问题：交付物清单是版本可追踪性的关键，遗漏会使审阅者误以为该版本不涉及文档变更，且与功能项列表矛盾。
   - 期望修正方向：在 v2.0 交付物清单的"修改"项中补充 `ARCHITECTURE.md`、`ROADMAP.md`、`COMPARISON.md`。

2. **[一般] v2.1 交付物清单遗漏 process 链式 API 文件**：
   - 问题：功能项 8 链式 API 涉及 process 子包，但交付物清单未反映 process 子包的文件变更。
   - 为什么是问题：交付物清单与功能项的子包标注不一致，审阅者无法追踪链式 API 的实现位置。
   - 期望修正方向：在 v2.1 交付物清单中补充 process 子包对应的新增/修改文件（如 `src/process/image_chain.mbt` 或明确链式 API 在 `src/core/image_methods.mbt` 中通过调用 process 函数实现，并据此修正功能项 8 的涉及子包标注使两者一致）。

3. **[一般] `failure_reason` 改造在 v2.1 缺失**：
   - 问题：决策点 2 建议推迟到 v2.1，但 v2.1 功能项列表无对应项。
   - 为什么是问题：决策建议与功能项列表脱节，审阅者无法确认 `failure_reason` 改造的落地版本，影响决策闭环。
   - 期望修正方向：在 v2.1 功能项中新增一项明确"`failure_reason` 改造：在 `LoadError` 变体中携带 stb 错误字符串，消除全局状态依赖"，或修正决策点 2 的建议为"推迟到 v2.1 并在 v2.1 功能项 7 中明确涵盖"，使决策与功能项一致。

4. **[一般] v2.0 工作量说明 L 项计数错误**：
   - 问题：说明称"2 个 L 项"，功能项表实际有 3 个 L 项。
   - 为什么是问题：工作量说明是论证合并原则和版本工作量评估的基础，数据与功能项表矛盾会误导审阅者。
   - 期望修正方向：将第 186 行"含 2 个 L 项（纯 MoonBit PNG/JPEG 解码）和 2 个 M 项"修正为"含 3 个 L 项（条件编译架构设计、纯 MoonBit PNG/JPEG 解码）和 2 个 M 项"，并相应更新加总估算。
