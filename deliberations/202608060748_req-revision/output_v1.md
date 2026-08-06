# req_v3.md 修订摘要

## 修订信息

- **修订对象**：`D:\CodeWorkspace\forMoonbit\stb-image\requirements\202608060700_stb-image-requirement\req_v2.md`（306 行）
- **修订产出**：`D:\CodeWorkspace\forMoonbit\stb-image\requirements\202608060700_stb-image-requirement\req_v3.md`（322 行）
- **修订依据**：`D:\CodeWorkspace\forMoonbit\stb-image\deliberations\202608060736_req-v2-review\output_v1.md`（审查报告）
- **审查结论**：[APPROVED] — 6 个维度均通过，发现 3 项轻微问题与 2 项建议优化
- **修订日期**：2026-08-06

## 修订依据核实

已完整读取审查报告（211 行）与当前需求文档 req_v2.md（306 行），理解全部 5 项待修订问题。审查报告核实工作充分（含 MoonBit 工具链版本、官方文档、stb_image.h API、image-mbt 实际项目等多源交叉核实），审查结论可信。

## 逐项修订摘要

### 问题 1（轻微）：`extern "c"` 大小写

| 项 | 内容 |
|---|------|
| **审查问题** | req_v2.md 使用 `extern "c"`（小写），与 make-moonbit-c-bindings skill 模板一致；但 MoonBit 官方 FFI 文档示例使用 `extern "C"`（大写）。无功能影响（两者均接受），但与官方文档规范形式不一致 |
| **独立判断** | 合理。两者均接受，但应在文档中明确标注选择理由，消除歧义 |
| **修订措施** | 保持小写形式（与 skill 模板一致），在包布局注释中标注"小写形式，与 skill 模板一致"，并在 FFI 方案要点中新增一条说明，注明两者均接受、技术设计阶段可统一为官方大写形式 |
| **修订位置** | req_v3.md 第 80 行（包布局注释）+ 第 89 行（新增 `extern "c"` 大小写说明条目） |

### 问题 2（轻微）：`supported_targets` 声明级别表述

| 项 | 内容 |
|---|------|
| **审查问题** | 原文"可设 `supported_targets = "native"` 声明包级支持范围"中"包级"一词可能产生歧义。根据 MoonBit 文档，`supported_targets` 可在 `moon.mod`（模块级）和 `moon.pkg`（包级）两个级别设置；当两者都声明时，实际生效的后端集合是它们的交集。req_v2.md 此处上下文是在讨论 `moon.mod` 配置，因此"包级"可能意指"模块级" |
| **独立判断** | 合理。上下文确实是在讨论 `moon.mod`（模块级配置），"包级"表述不精确 |
| **修订措施** | 将"声明包级支持范围"改为"声明模块级支持范围"，并补充说明 `supported_targets` 可在 `moon.mod` 模块级与 `moon.pkg` 包级两处设置、两者并存时取交集 |
| **修订位置** | req_v3.md 第 145 行（第五节边界约束"仅支持 native 目标"条目） |

### 问题 3（轻微）：moon.pkg 配置示例未展示 README.mbt.md 门控

| 项 | 内容 |
|---|------|
| **审查问题** | moon.pkg 配置示例 `options("native-stub": ["wrapper.c"], targets: { "ffi.mbt": ["native"] })` 仅展示 `ffi.mbt` 的 native 门控，但包布局中列出的 `src/README.mbt.md`（测试过的文档示例）在 make-moonbit-c-bindings skill 模板中也被门控到 native |
| **独立判断** | 合理。配置示例应更完整。但 `image.mbt`（安全公开 API）的门控需谨慎——其类型定义应跨后端可用，不应直接门控到 native，仅 FFI 调用部分需条件编译。故仅补全 `README.mbt.md` 门控，`image.mbt` 门控交由技术设计确定 |
| **修订措施** | 在 `moon.pkg` 配置示例中补全 `README.mbt.md` 的 native 门控（含 native FFI 示例），并说明 `image.mbt` 的门控由技术设计确定（类型定义应跨后端可用，但 FFI 调用部分需条件编译），完整门控列表可参考 skill 模板 |
| **修订位置** | req_v3.md 第 87 行（FFI 方案要点 moon.pkg 配置） |

### 建议 1（优化）：vendoring 脚本可考虑 `stb_image_write.h` 预留方式

| 项 | 内容 |
|---|------|
| **审查建议** | req_v2.md 说"完整库版本会追加 vendoring `stb_image_write.h`，脚本应预留扩展能力"。可在技术设计阶段考虑脚本是否支持一次性 vendoring 多个头文件（如 `--include-write` 参数），避免 v0.2 时修改脚本结构 |
| **独立判断** | 合理。提前在需求文档中注明此建议，可为技术设计提供更明确的输入 |
| **修订措施** | 采纳。在 vendoring 部分补充建议脚本支持一次性 vendoring 多个头文件（如 `--include-write` 参数），避免 v0.2 纳入 write 时修改脚本结构 |
| **修订位置** | req_v3.md 第 68 行（第二节 vendoring"完整库版本会追加 vendoring"条目） |

### 建议 2（优化）：v0.2 write 入口可考虑 `write_png_to_bytes` 的内存管理

| 项 | 内容 |
|---|------|
| **审查建议** | v0.2 范围列出 `write_*_to_bytes` 版本（基于 `stbi_write_*_to_func`）。`stbi_write_*_to_func` 使用回调写入，MoonBit 侧需设计回调机制将 C 侧的写入回调转换为 `Bytes` 累积。这一设计可在第八节决策点中补充（当前决策点 9 `IoCallbacks` trait 设计覆盖了 load 端回调，但 write 端回调设计未明确列为决策点） |
| **独立判断** | 合理。write 端回调与 load 端回调方向相反（read vs write），需独立设计，应列为独立决策点 |
| **修订措施** | 采纳。在第八节"下游设计输入"新增第 12 个决策点"write 端回调设计"，说明 `stbi_write_*_to_func` 回调写入机制、MoonBit 侧回调到 `Bytes` 累积的设计需求（如动态缓冲 + 容量扩展策略），及其与决策点 9 load 端 `IoCallbacks` 的对偶关系 |
| **修订位置** | req_v3.md 第 293 行（第八节决策点 12） |

## 修订原则遵循情况

| 原则 | 遵循情况 |
|------|---------|
| 逐项落实审查报告中的修订建议 | ✓ 5 项问题/建议全部处理（3 项修订 + 2 项采纳） |
| 保持已通过部分的稳定性 | ✓ 审查报告确认无问题的核心内容均保留，未引入无关变更 |
| 产出完整文档 | ✓ req_v3.md 为完整、自包含的文档（322 行），可直接替代 req_v2.md |
| 保留"完整库"定位 | ✓ 第一节项目定位、第五节边界约束、第六节版本迭代计划均保留 |
| 保留"只参考不引用已有库" | ✓ 需求正文无 mizchi/image-mbt 引用（仅"修订说明"章节作为元说明记录修订动作） |
| 保留 MoonBit v0.10.5 规范 | ✓ moon.mod/moon.pkg 新格式、preferred_target 下划线语法、extern "c" 语法均保留 |
| 保留版本迭代计划 | ✓ 第六节 v0.1→v0.2→v0.3→v0.4→v1.0 演进路径完整保留 |

## 修订后文档结构

req_v3.md 共 322 行，结构如下：

- 第一节：项目背景与目标（保留）
- 第二节：MVP 范围（vendoring 部分修订）
- 第三节：FFI 实现要点（`extern "c"` 注解 + moon.pkg 配置示例补全 + `extern "c"` 大小写说明新增）
- 第四节：验收标准（保留）
- 第五节：边界约束（`supported_targets` 声明级别修订）
- 第六节：版本迭代计划（保留）
- 第七节：澄清与推断汇总（保留）
- 第八节：下游设计输入（新增决策点 12：write 端回调设计）
- 修订说明（v2）（保留）
- 修订说明（v3）（新增）

## 一致性自检

修订后已读取 req_v3.md 自行核对，确认：

1. **5 项修订全部正确应用**：通过逐行验证关键修订点（第 68、80、87-89、145、293 行），内容与修订措施一致
2. **无遗漏修订**：审查报告 5 项问题/建议全部处理
3. **无无关变更**：除 5 项修订点外，其余内容与 req_v2.md 一致
4. **自包含性保持**：mizchi/image-mbt 仅出现在"修订说明"章节作为元说明，需求正文无引用
5. **既有约束保留**：完整库定位、只参考不引用、MoonBit v0.10.5 规范、版本迭代计划均保留
6. **文档完整性**：322 行，结构清晰，可直接作为最终需求文档