# `tech_v1.md` 独立审查报告

> 审查对象：`designs-tech/202608060929_stb-image-tech-design/tech_v1.md`（stb-image 技术方案设计 v1）
> 审查框架：deliberative-execution-harness
> 审查日期：2026-08-06
> 审查范围：task.md 列出的 8 个审查维度
> 核实方式：逐项对照 MoonBit wiki、moonbit_wp 源码先例、moonbit.h 头文件、stb_image.h 上游、skill 模板等一手资料，非凭推测

## 审查总结论

**APPROVED_WITH_MINOR_ISSUES**

tech_v1.md 是一份高质量的技术方案文档。8 个审查维度中 7 项通过、1 项基本通过（含轻微表述不一致）。所有关键技术事实经独立核实均准确。发现 4 个问题，其中 1 个为架构设计遗留错误的技术方案侧正确处理（亮点）、2 个轻微表述不一致、1 个可改进细节，均不阻塞实现启动。

---

## 一、需求与架构响应充分度

**[通过]**

### 需求文档（req.md）响应核查

逐条对照 req.md 的功能要求与 tech_v1.md 的落实位置：

| 需求文档要求 | tech_v1 落实位置 | 核查结论 |
|------------|----------------|---------|
| MVP 加载入口 `load_from_path` + `load_from_bytes` | §6.3 函数轮廓与流程 | ✓ 两个入口均有流程设计 |
| `Image { width, height, channels, data : Bytes }` 值类型 | §6.1 类型轮廓 | ✓ 字段、类型形态、导出级别均落实 |
| `LoadError` suberror + raise | §6.2 类型轮廓 + §6.3 raise 签名 | ✓ 三构造子、suberror、raise 均落实 |
| 9 种支持格式（PNG/JPEG/BMP/GIF/WebP/TGA/PSD/HDR/PIC） | §7.1 测试聚焦 5 种常见格式 | ✓ 与需求文档"6-10 张测试图片聚焦 5 格式"一致 |
| vendoring stb_image.h + prepare.py + SHA256 + 幂等 | §4 vendoring 方案（§4.1-§4.3） | ✓ 下载、校验、幂等均有方案 |
| FFI 实现要点（C wrapper、moonbit_make_bytes、#borrow、extern "c"） | §5 FFI 边界层方案 | ✓ 全部落实 |
| 验收标准（moon check/test、ASan、6-10 张测试图片、moon info、SKILL.md） | §7 测试与验证方案 + §8 文档方案 | ✓ 全部落实 |
| Windows 非 ASCII 路径兼容 | §5.3 Windows 路径编码兼容性 | ✓ STBI_WINDOWS_UTF8 方案 |
| 格式嗅探决策 | §6.4 错误处理流程与格式嗅探决策 | ✓ MVP 不纳入，给出理由与权衡 |
| 文档方案（SKILL.md + minimal example） | §8 文档方案 | ✓ SKILL.md 结构 + README.mbt.md |
| 版本迭代计划（v0.1→v1.0） | §10 版本演进技术支撑 | ✓ 各版本技术增量清晰 |
| 边界约束（完整库目标 vs MVP 阶段性限制） | §6.4 + §10 | ✓ MVP 限制与解锁计划对应 |

需求文档 §八"下游设计输入"的 12 个决策点也全部由架构设计 D1-D12 承接，再由 tech_v1 §十一对应表落实到技术方案。无遗漏的功能要求。

### 架构设计（design_v3.md）响应核查

逐条对照 design_v3.md 的 D1-D14 决策与 tech_v1.md §十一对应表：

| 架构决策 | tech_v1 落实 | 核查结论 |
|---------|------------|---------|
| D1. LoadError 统一并入 FileIO | §6.2 三构造子 + §6.3 预检查 | ✓ |
| D2. C wrapper 错误信号 + 默认归类 + 格式嗅探 + Windows | §5.1 失败信号 + §6.4 不纳入嗅探 + §5.3 STBI_WINDOWS_UTF8 | ✓ |
| D3. Image pub(all) + derive Eq/Debug | §6.1 类型轮廓 | ✓ |
| D4. 测试图片脚本生成 | §7.1 testdata 生成策略 | ✓ |
| D5. vendoring 固定 commit hash | §4.2 版本固定策略 | ✓ |
| D6. SKILL.md 参照技能格式 | §8.1 SKILL.md 结构 | ✓ |
| D7. MVP 单包，v0.2 保持单包 | §3.1 文件布局 | ✓ |
| D8. 16-bit/float little-endian | §10 v0.3 技术支撑 | ✓ |
| D9. IoCallbacks 留待 v0.4 | §10 v0.4 技术支撑 | ✓ |
| D10. 多目标留待 v1.0 | §10 v1.0 技术支撑 | ✓ |
| D11. 零拷贝留待 v1.0 | §5.1 所有权转移流程（拷贝+释放） | ✓ |
| D12. write 回调留待 v0.2 | §10 v0.2 技术支撑 | ✓ |
| D13. ffi.mbt 门控 native，类型定义全后端 | §6.5 拆文件条件编译策略 | ✓（见下文关于 D13 末尾提示的说明） |
| D14. extern "c" 小写 | §5.2 统一小写 | ✓ |

**关于 D13 末尾提示的重要发现**：design_v3.md D13 决策末尾有一段提示："`supported_targets` 的实际语法为 `"+native"`（带 `+` 前缀表示追加语义），非 `"native"`；技术设计阶段应以此为准。" 经独立核实，**此提示本身是错误的**，tech_v1 §2.2 正确识别并修正了这一错误（详见维度四的核实证据）。这是 tech_v1 相对架构设计的一个正向纠偏，而非遗漏。

**结论**：技术方案充分响应需求文档与架构设计文档的全部要求，无遗漏的技术方向性问题。

---

## 二、技术选型合理性

**[通过]**

### 2.1 工具链版本与配置格式（§2.1）

**决策**：MoonBit v0.10.5 新格式 `moon.mod`/`moon.pkg` DSL。

**核实**：`moonbit_wiki/toolchain/package-management.md:50` 明确"新格式 `moon.pkg`（DSL，推荐）；旧格式 `moon.pkg.json` 在 v0.10.4 起弃用，可用 `moon fmt` 迁移"。`:38` 确认 `preferred_target = "native"`（下划线）为新 DSL 语法。

**结论**：合理。新格式是官方推荐方向，旧 JSON 已弃用，新项目不应采用。

### 2.2 目标后端策略（§2.2）

**决策**：MVP 仅 native 后端，`supported_targets = "native"`（非 `"+native"`）。

**核实**：
- `moonbit_wiki/toolchain/package-management.md:60` 示例：`supported_targets = "native"                  // +js+wasm-gc | +all-js`，确认 `"native"` 是合法语法（排他性声明仅支持 native），`+js+wasm-gc`/`+all-js` 是追加语义的其他形式。
- `moonbit_wp/llvm.mbt` 下 3 个 `moon.pkg`（unsafe/test/IR）均使用 `supported_targets = "native"`（不带 `+` 前缀），与 wiki 示例一致。
- tech_v1 §2.2 正确识别架构设计 D13 末尾"`+native`"提示的不准确性，基于实际先例与语义分析做出正确决策。

**结论**：合理。本项目是 native-only FFI 绑定，`"native"` 准确表达排他性声明，与 llvm.mbt 先例一致。

**可改进细节（问题 1）**：`moonbit_wiki/agent-guide/c-binding.md:62` 提示"勿用 `supported-targets: ["native"]`（阻止下游包在其他 target 构建）；用 `targets` 门控单文件。" 这一提示针对的是**一般库**（希望被下游包在其他 target 构建时仍可用），对于 **native-only FFI 绑定项目**，`supported_targets = "native"` 是合理的——这正是 llvm.mbt 的做法。tech_v1 §2.2 的"权衡"段已提及"会阻止 `moon check --target all` 构建其他目标，这正是 MVP 期望行为"，但**未明确引用 c-binding skill 的这一提示并解释为何对本项目不适用**。建议在 §2.2 权衡段补一句："c-binding skill 提示一般库勿用 `supported_targets` 限制目标，但该提示针对希望被下游跨目标复用的库；本项目是 native-only FFI 绑定，`extern "c"` 仅 native 后端支持，排他性声明是准确语义。" 以避免实现者误用。

### 2.3 stb_image.h Vendoring 策略（§2.3 + §4）

**决策**：单头文件库特殊 vendoring（保留原名、wrapper.c 集中 IMPLEMENTATION 宏、native-stub 仅列 wrapper.c）。

**核实**：已 webfetch 核实 stb_image.h v2.30 上游，确认单头文件库机制：`#define STB_IMAGE_IMPLEMENTATION` 然后 `#include "stb_image.h"` 在一个 C 文件中生成实现。无需 vendoring 多个 `.c` 文件。

**结论**：合理。单头文件库无需扁平化命名，保留原名提升可读性。wrapper.c 集中管理宏定义避免宏泄漏。

### 2.4 C wrapper 与 moonbit.h 运行时（§2.4 + §5.1）

**决策**：C wrapper 负责 ABI 归一化，使用 `moonbit_make_bytes` + `MOONBIT_FFI_EXPORT`。

**核实**：已逐行核实 `moonbit_wp/moonbit-native-runtime/include/moonbit.h`：
- `moonbit_make_bytes(int32_t size, int value)` 在第 343 行（§2.4 声称 343 ✓）
- `MOONBIT_FFI_EXPORT` 宏在第 50/53 行（§2.4 声称 50/53 ✓）
- `Moonbit_array_length` 在第 228 行（§2.4 声称 228 ✓）
- `moonbit_make_external_object` 在第 374 行（§2.4 声称 374 ✓）
- `moonbit_incref`/`moonbit_decref` 在第 311-312 行（§2.4 声称 311-312 ✓）

**结论**：合理。MVP 仅需 `moonbit_make_bytes` + `MOONBIT_FFI_EXPORT`，无 external object、无 incref/decref（MVP 无 handle、无回调），选型最小化。

### 2.5 ASan 验证工具（§2.5 + §7.3）

**决策**：采用 `moonbit-c-binding` skill 的 `scripts/run-asan.py`。

**核实**：确认 `D:\CodeWorkspace\forMoonbit\stb-image\.codeartsdoer\skills\moonbit-c-binding\scripts\run-asan.py` 存在。

**结论**：合理。复用现成脚本，不重新发明。

### 2.6 错误处理选型（§6.2 + §6.4）

**决策**：`suberror` + `raise`，MVP 默认归类 `DecodeFailed`，不纳入格式嗅探。

**核实**：`moonbit_wiki/language/error-handling.md:29` 确认 `suberror DivError { DivError(Error) }` 是新语法（旧 `suberror A B` 已弃用，:33）。`:93` 确认 `fn div(a : Int, b : Int) -> Int raise DivError` 签名语法。`moonbit_wiki/stdlib/error-result.md:32-43` 确认 `suberror` 自动生成 `Eq`/`Show`/`ToJson`，是 MoonBit 惯例。

**结论**：合理。`suberror` + `raise` 符合 MoonBit 惯例；MVP 不纳入嗅探的理由充分（增加格式知识负担、嗅探可能误判、调用者处理差异不显著）。

**综合结论**：各技术决策（FFI 方案、内存管理、错误处理、配置管理）均合理且有充分理由，关键事实经核实准确。

---

## 三、FFI 最佳实践一致性

**[通过]**

### #borrow 所有权标注

**核实**：`moonbit_wiki/agent-guide/c-binding.md:35` 确认 `const uint8_t *` → `Bytes`，C 不存储则用 `#borrow`。`:39` 确认输出 `int *result` → `Ref[T]` + `#borrow`。`moonbit_wiki/language/ffi.md:199-215` C 后端 ABI 表确认 `Bytes` → `uint8_t*`。

**tech_v1 §5.2**：输入 `Bytes` 标注 `#borrow`（stb 仅在调用期间读取，不存储引用），输出参数用 `Ref[Int]` 标注 `#borrow`。**正确**。

### moonbit_make_bytes 使用

**核实**：`moonbit_wiki/agent-guide/c-binding.md:83` 确认 `moonbit_make_bytes(len, init)` 用于 GC 管理 Bytes。`moonbit.h:343` 确认签名 `moonbit_make_bytes(int32_t size, int value)`。

**tech_v1 §5.1**：C wrapper 用 `moonbit_make_bytes(size, 0)` 创建输出 Bytes，`memcpy` 覆盖后 `stbi_image_free` 释放原始缓冲。**正确**。

### MOONBIT_FFI_EXPORT 使用

**核实**：`moonbit_wiki/agent-guide/c-binding.md:86` 确认 `MOONBIT_FFI_EXPORT` 是导出函数必需宏。`moonbit.h:50/53` 确认宏定义。

**tech_v1 §5.1**：wrapper.c 中两个 `MOONBIT_FFI_EXPORT` 函数对应 `load_from_path` 与 `load_from_bytes`。**正确**。

### external object + finalizer 模式

**核实**：`moonbit_wiki/agent-guide/c-binding.md:68` 确认 external object 模式用于 C 句柄 + GC 清理。`moonbit_wiki/language/ffi.md:346-376` 详述 `moonbit_make_external_object` 机制。

**tech_v1 §2.4**：明确指出 MVP 不需要 external object（无 handle 场景），load 路径是"一次性解码返回数据"模式。**正确**。架构设计 §3.3 也确认"为何不引入 opaque handle 类型"。

### Value-as-Bytes 模式

**核实**：`moonbit_wiki/agent-guide/c-binding.md:76` 确认 Value-as-Bytes 模式用于小 struct 无清理场景。

**tech_v1**：MVP 未使用此模式（无小 struct 包装需求）。**正确**（不适用而非遗漏）。

### 6 大陷阱规避

**核实**：`moonbit_wiki/agent-guide/c-binding.md:117-124` 列出 6 大陷阱：
1. C 存储指针时用 `#borrow` —— GC 可能在 C 持有陈旧引用时回收对象
2. owned 参数忘 `moonbit_decref` —— 泄漏内存
3. 对 external object 容器调 `free()` —— GC 管理容器
4. 对含内部指针的 struct 用 `moonbit_make_bytes` —— 内部堆分配泄漏
5. 回调调用前忘 `moonbit_incref` —— GC 可能在 C 回调 MoonBit 时运行
6. 忘 `MOONBIT_FFI_EXPORT` 宏 —— 函数对 MoonBit 链接器不可见

**tech_v1 规避情况**：
| 陷阱 | tech_v1 规避 | 核查 |
|------|------------|------|
| 1. C 存储指针时用 #borrow | §5.2 正确判断 stb 仅调用期间读取，用 #borrow 合法 | ✓ |
| 2. owned 参数忘 decref | MVP 无 owned 参数（输入全 #borrow） | ✓ |
| 3. 对 external object 容器调 free() | MVP 无 external object | ✓ |
| 4. 含内部指针 struct 用 make_bytes | MVP 无此场景（输出是纯像素数据） | ✓ |
| 5. 回调前忘 incref | MVP 无回调（无 IoCallbacks） | ✓ |
| 6. 忘 MOONBIT_FFI_EXPORT | §5.1 明确使用 | ✓ |

**结论**：tech_v1 遵循 MoonBit FFI 最佳实践，正确使用 #borrow、moonbit_make_bytes、MOONBIT_FFI_EXPORT，合理判断 MVP 不需要 external object + finalizer 与 Value-as-Bytes，6 大陷阱全部规避。

---

## 四、MoonBit v0.10.5 规范一致性

**[通过]**

### moon.mod / moon.pkg 新格式

**核实**：`package-management.md:50` 确认新格式 `moon.pkg`（DSL，推荐），旧 `moon.pkg.json` v0.10.4 起弃用。

**tech_v1 §2.1 + §3.2 + §3.3**：采用新 DSL 语法。**正确**。

### preferred_target 语法

**核实**：`package-management.md:38` 确认 `preferred_target = "native"`（下划线，新 DSL）。

**tech_v1 §2.1 + §3.2**：`preferred_target = "native"`（下划线）。**正确**。

### supported_targets 语法

**核实**：
- `package-management.md:60` 示例 `supported_targets = "native"`，注释标明 `// +js+wasm-gc | +all-js` 是其他追加形式。
- `moonbit_wp/llvm.mbt` 下 3 个 `moon.pkg`（unsafe/test/IR）均使用 `supported_targets = "native"`（不带 `+` 前缀）。
- `"native"` 语义为"声明仅支持 native"（排他性），`"+native"` 语义为"在默认支持集合上追加 native"（追加语义）。

**tech_v1 §2.2**：`supported_targets = "native"`（非 `"+native"`）。**正确**。

**重要说明（问题 2 — 架构设计遗留错误，tech_v1 正向纠偏）**：
`design_v3.md` D13 决策末尾有一段提示："`supported_targets` 的实际语法为 `"+native"`（带 `+` 前缀表示追加语义），非 `"native"`；技术设计阶段应以此为准。" **此提示本身是错误的**——经 wiki 示例与 llvm.mbt 3 处先例核实，`"native"` 是合法且语义正确的排他性声明语法。tech_v1 §2.2 正确识别了这一错误，基于实际先例与语义分析做出正确决策，并在"理由"段明确指出"架构设计 D13 提示的 `"+native"` 适用于'追加'语义场景，不适用于本项目的'仅 native'定位"。

**这是 tech_v1 相对架构设计的正向纠偏，是技术方案的亮点而非问题**。但建议在审查报告中明确记录此分歧，以便：
1. 后续修订 design_v3.md D13 末尾的提示（该提示会误导其他基于架构设计工作的实现者）
2. 确认 tech_v1 的纠偏判断正确，无需回退

### targets 门控语法

**核实**：`package-management.md:66-70` 示例：
```
targets: {
  "only_js.mbt": ["js"],
  "not_js.mbt": ["not", "js"],
  "js_and_release.mbt": ["and", ["js"], ["release"]],
}
```
最小单元为文件，支持 `and`/`or`/`not`。

**tech_v1 §3.3 门控清单**：
| 文件 | 门控 | 核查 |
|------|------|------|
| `ffi.mbt` | `["native"]` | ✓ 语法正确 |
| `image_load_native.mbt` | `["native"]` | ✓ 语法正确 |
| `image_types.mbt` | 不门控 | ✓ 全后端可用 |
| `image_test.mbt` | 不门控（§3.3）→ 修正为 `["native"]`（§7.2） | ⚠️ 见问题 3 |
| `README.mbt.md` | `["native"]` | ✓ 语法正确 |
| `wrapper.c` | `native-stub` | ✓ 语法正确 |

### native-stub 配置

**核实**：`package-management.md:65` 确认 `"native-stub": ["stub.c"]` 语法。`c-binding.md:56` 确认 native-stub 列待编译的 C 源文件（须与 moon.pkg 同目录）。

**tech_v1 §3.3**：`options("native-stub": ["wrapper.c"])`，仅列 wrapper.c（stb_image.h 通过 #include 纳入）。**正确**。

### pkgtype 配置

**核实**：`package-management.md:59` 确认 `pkgtype(kind: "executable")` / `"library"` / `"foreign_library"` 语法。

**tech_v1**：MVP 是 library 包，未显式设置 pkgtype（默认 library）。**正确**（无需显式设置）。

**结论**：moon.mod/moon.pkg 新格式、preferred_target、targets 门控、native-stub、pkgtype 等配置均符合 MoonBit v0.10.5 规范。supported_targets 语法 tech_v1 正确纠偏了架构设计的错误提示。

---

## 五、版本迭代技术支撑

**[通过]**

### v0.2（write + req_channels）技术支撑（§10）

- vendoring 脚本预留 `--include-write`：§4.4 已预留，v0.2 激活即可 ✓
- wrapper.c 预留条件编译块：v0.2 纳入 `stb_image_write.h` 的 IMPLEMENTATION 宏 ✓
- 包结构保持单包：架构设计 D7，v0.2 按文件分职责 ✓
- `req_channels` 参数：v0.2 在 `load_from_*` 增加可选参数，C wrapper 透传 `desired_channels` ✓

**核实**：stb_image.h v2.30 确认 `desired_channels` 参数存在于 `stbi_load`/`stbi_load_from_memory` 签名中。tech_v1 §5.1 已注明 MVP 传 `0`（STBI_default），v0.2 透传调用者值。

### v0.3（16-bit / float / info / 配置 / PNM）技术支撑（§10）

- 类型定义全后端可用：§6.5 拆文件策略让 `Image16`/`ImageF` 等新类型可定义在 `image_types.mbt` ✓
- little-endian 编码：架构设计 D8，C wrapper 直接 `memcpy` ✓
- `stbi_failure_reason` 暴露：v0.3 在 wrapper 增加函数，返回 C 字符串为 `Bytes`，MoonBit 侧 `@utf8.decode_lossy` 转为 `String` ✓

**核实**：stb_image.h 确认 `stbi_load_16_from_memory`、`stbi_loadf_from_memory`、`stbi_info_from_memory`、`stbi_is_16_bit_from_memory`、`stbi_failure_reason` 等 API 均存在。tech_v1 的演进路径与上游 API 对齐。

### v0.4（callbacks / 动画 GIF）技术支撑（§10）

- `IoCallbacks` trait：架构设计 D9，涉及 C→MoonBit 反向调用（trampoline），需 `moonbit_incref`/`moonbit_decref` ✓
- FFI 边界层扩展：wrapper.c 增加 callbacks 相关函数 ✓
- 单包结构仍可容纳 ✓

**核实**：stb_image.h 确认 `stbi_io_callbacks` 结构体（read/skip/eof）与 `stbi_load_from_callbacks` 等 API。`moonbit.h:311-312` 确认 `moonbit_incref`/`moonbit_decref` 存在。tech_v1 正确识别 v0.4 需要 incref/decref 管理回调生命周期。

### v1.0（多目标支持）技术支撑（§10）

- 类型定义全后端可用：§6.5 拆文件策略让 `Image`/`LoadError` 在 wasm/js 后端可用 ✓
- `supported_targets` 可扩展：§2.2 采用包级 `supported_targets = "native"`，v1.0 可改为 `"+native+wasm"` 或移除限制 ✓
- FFI 边界层按目标分文件门控：v1.0 若纳入 wasm/js，可引入 `src/wasm/` 子目录 ✓

**结论**：技术方案充分支撑从 MVP 到完整库的演进路径，各版本技术增量清晰，与 stb_image.h 上游 API 对齐。

---

## 六、自包含性

**[通过]**

**核查**：通读 tech_v1.md 全文，未发现引用 mizchi/image 或任何已有库作为依赖、互补基准或对比对象。

tech_v1 引用的外部资源均为**核实依据**而非**依赖**：
- MoonBit 官方文档（docs.moonbitlang.cn）：规范核实
- moonbit_wiki：语法与 API 核实
- moonbit_wp/llvm.mbt：native FFI 绑定项目先例（参考，非依赖）
- moonbit_wp/moonbit-native-runtime/include/moonbit.h：运行时 API 核实
- stb_image.h 上游（nothings/stb）：被绑定对象本身（项目核心，非外部依赖）
- make-moonbit-c-bindings / moonbit-c-binding skill：模板与脚本参考（非运行时依赖）

**结论**：技术方案自包含，不引用已有库作为依赖、互补基准或对比对象。符合"只参考不引用已有库"的约束。

---

## 七、抽象层级适当性

**[通过]**

### 技术方案级别定位

tech_v1 §一"设计定位"明确："本技术方案是架构设计与编码实现之间的桥梁。比架构设计更具体（落实到工具链配置、C API 签名、FFI 机制级别），比代码更抽象（不给出完整实现）。"

**核实**：通读全文，tech_v1 的抽象层级适当：
- **落实到技术方案级别的具体内容**：工具链版本（v0.10.5）、配置格式（moon.mod/moon.pkg 新 DSL）、C API 签名（stbi_load 等）、moonbit.h API（moonbit_make_bytes 等）、FFI 机制（#borrow、Ref[Int]、MOONBIT_FFI_EXPORT）、类型轮廓（pub(all) struct/suberror）、门控清单、验证命令序列
- **未涉及的实现细节**：无完整代码片段、无逐字段签名、无逐方法实现、无算法细节

### 与架构设计的层级区分

架构设计 design_v3.md 聚焦职责划分、抽象层次、协作模式与关键设计决策（D1-D14），未落实到工具链配置与 C API 签名级别。tech_v1 在架构设计基础上下沉到技术选型决策、数据流方向、关键类型轮廓与方案决策，层级区分清晰。

### 与编码实现的层级区分

tech_v1 给出的是"做什么"与"怎么做的大方向"，而非完整代码。实现者在编码时查阅 MoonBit / stb_image API 文档是正常编码活动（§一明确）。§九列出 6 个需编码时验证的技术假设，给出了降级方案，不阻塞实现启动。

**结论**：抽象层级适当，为技术方案级别（落实到库和技术路径级别），不涉及过多实现细节，也不过于抽象。

---

## 八、可支撑编码实现

**[通过]**

### 实现者可从方案明确知道的内容

| 内容类别 | tech_v1 位置 | 可操作性 |
|---------|------------|---------|
| 文件布局 | §3.1 | ✓ 完整目录树 |
| moon.mod 配置项轮廓 | §3.2 | ✓ 配置项清单 |
| moon.pkg 配置项轮廓 | §3.3 | ✓ 配置项 + 门控清单 |
| C wrapper 职责轮廓 | §5.1 | ✓ 职责清单 + C API 签名 + ABI 归一化要点 + 所有权转移流程 |
| extern "c" 声明轮廓 | §5.2 | ✓ 声明轮廓 + 类型映射表 |
| Windows 路径兼容方案 | §5.3 | ✓ STBI_WINDOWS_UTF8 + FileIO 区分策略 |
| Image 类型轮廓 | §6.1 | ✓ 字段 + 类型形态 + 导出级别 + derive 决策 |
| LoadError 类型轮廓 | §6.2 | ✓ 构造子 + 类型形态 + 导出级别 |
| load_from_* 流程 | §6.3 | ✓ 逐步流程 |
| 错误处理流程 | §6.4 | ✓ MVP 区分粒度 + 不纳入嗅探理由 |
| 条件编译策略 | §6.5 | ✓ 拆文件方案 + 理由 |
| 测试图片生成策略 | §7.1 | ✓ 样本规格 + 生成方式 + 目录结构 |
| 测试层设计 | §7.2 | ✓ 6 层测试 + 门控决策 |
| ASan 验证 | §7.3 | ✓ 关注点 + 脚本职责 |
| 标准验证门 | §7.4 | ✓ 验证命令序列 |
| 文档方案 | §8.1 + §8.2 | ✓ SKILL.md 结构 + README.mbt.md 内容 |
| 需验证的技术假设 | §9 | ✓ 6 个假设 + 降级方案 |
| 版本演进技术支撑 | §10 | ✓ v0.2/v0.3/v0.4/v1.0 技术增量 |

### 无开放性问题

所有技术选型决策明确，不存在需实现者自行探索的方向性问题。§九的 6 个技术假设是编码时的常规验证项（非方向性问题），且均有降级方案。

### 技术引用具体可定位

MoonBit v0.10.5、`moon.mod`/`moon.pkg` 新 DSL、`moonbit.h`、`stb_image.h`、`stbi_load`/`stbi_load_from_memory`/`stbi_image_free`、`moonbit_make_bytes`、`MOONBIT_FFI_EXPORT`、`STBI_WINDOWS_UTF8`、`moonbit-c-binding/scripts/run-asan.py`、`make-moonbit-c-bindings/templates/prepare.py` 等引用均明确，实现者能直接定位。

**结论**：技术方案足以指导后续编码实现。

---

## 发现问题汇总

### 问题 1（可改进细节）：§2.2 未明确引用 c-binding skill 的 "勿用 supported-targets" 提示

**位置**：tech_v1.md §2.2 目标后端策略的"权衡"段（第 56 行）

**问题性质**：可改进细节，不影响实现启动

**描述**：`moonbit_wiki/agent-guide/c-binding.md:62` 提示"勿用 `supported-targets: ["native"]`（阻止下游包在其他 target 构建）；用 `targets` 门控单文件。" tech_v1 §2.2 采用 `supported_targets = "native"` 是正确的（本项目是 native-only FFI 绑定，该提示针对一般库），但未明确引用此提示并解释为何对本项目不适用。实现者若同时查阅 c-binding skill 可能产生困惑。

**建议修订**：在 §2.2 权衡段补充一句说明，例如："c-binding skill 提示一般库勿用 `supported_targets` 限制目标，但该提示针对希望被下游跨目标复用的库；本项目是 native-only FFI 绑定，`extern "c"` 仅 native 后端支持，排他性声明是准确语义，与 llvm.mbt 先例一致。"

### 问题 2（架构设计遗留错误，tech_v1 正向纠偏 — 亮点确认）：supported_targets 语法

**位置**：tech_v1.md §2.2（第 47-56 行）vs design_v3.md D13 末尾（第 417 行）

**问题性质**：架构设计 design_v3.md D13 末尾的提示本身是错误的；tech_v1 §2.2 正确识别并修正了这一错误。**这是 tech_v1 的亮点，无需修订 tech_v1**。

**描述**：design_v3.md D13 决策末尾提示："`supported_targets` 的实际语法为 `"+native"`（带 `+` 前缀表示追加语义），非 `"native"`；技术设计阶段应以此为准。"

经独立核实：
- `moonbit_wiki/toolchain/package-management.md:60` 示例 `supported_targets = "native"`（不带 `+`），注释标明 `+js+wasm-gc`/`+all-js` 是其他追加形式
- `moonbit_wp/llvm.mbt` 下 3 个 `moon.pkg`（unsafe/test/IR）均使用 `supported_targets = "native"`（不带 `+` 前缀）

**结论**：`"native"` 是合法且语义正确的排他性声明语法。tech_v1 §2.2 的决策正确，理由充分（基于实际先例与语义分析）。

**建议**：
1. tech_v1 无需修订（决策正确）
2. **建议后续修订 design_v3.md D13 末尾的提示**，避免误导其他基于架构设计工作的实现者。该提示应改为："`supported_targets` 语法可为 `"native"`（排他性声明仅支持 native）或 `"+native"`（在默认集合上追加 native）；本项目是 native-only FFI 绑定，技术设计阶段应采用 `"native"` 排他性声明。"

### 问题 3（轻微表述不一致）：§3.3 门控清单 image_test.mbt 标注与 §7.2 修正不同步

**位置**：tech_v1.md §3.3 门控清单表（第 158 行）vs §7.2 测试层设计（第 458 行）

**问题性质**：轻微表述不一致，不影响实现启动（§7.2 已给出明确修正结论）

**描述**：§3.3 门控清单表中 `image_test.mbt` 标注"不门控"，理由"测试应在所有后端运行（但 load 测试需 native，见 §7.2）"。§7.2 测试层设计明确修正："**修正 §3.3 门控清单**：`image_test.mbt` 应门控到 `["native"]`（测试调用 `load_from_*`，仅 native 可用）。"

方案内部已自洽修正（§7.2 明确结论），但 §3.3 的门控清单表未同步更新，可能让实现者困惑：究竟该用哪个门控？

**建议修订**：将 §3.3 门控清单表中 `image_test.mbt` 行的"门控"列从"不门控"改为 `["native"]`，"理由"列改为"测试调用 `load_from_*`，仅 native 可用（见 §7.2）"。或者保留 §3.3 原表述但在表脚注明确"以 §7.2 修正结论为准"。

### 问题 4（轻微表述）：§3.3 options 块轮廓分写可能误解

**位置**：tech_v1.md §3.3 配置项轮廓（第 148-149 行）

**问题性质**：轻微表述，不影响实现启动

**描述**：§3.3 将 `options("native-stub": ["wrapper.c"])` 与 `options(targets: { ... })` 分两行分写为两个独立的 `options(...)` 块。但 MoonBit 的 `moon.pkg` DSL 中，`native-stub` 与 `targets` 应在**同一个** `options(...)` 块内（见 `package-management.md:63-75` 示例）。此为轮廓描述而非完整配置，实现者应能理解，但分写可能让不熟悉 DSL 的实现者误解为两个独立块。

**建议修订**：将 §3.3 配置项轮廓合并为一个 options 块示意，例如：
```
options(
  "native-stub": ["wrapper.c"],
  targets: {
    "ffi.mbt": ["native"],
    "image_load_native.mbt": ["native"],
    "image_test.mbt": ["native"],
    "README.mbt.md": ["native"],
  },
)
```
或在配置项轮廓处注明"`native-stub` 与 `targets` 在同一 `options(...)` 块内"。

---

## 审查维度结论汇总

| 维度 | 结论 | 证据 |
|------|------|------|
| 1. 需求与架构响应充分度 | 通过 | 需求文档所有功能要求 + 架构 D1-D14 全部落实，无遗漏 |
| 2. 技术选型合理性 | 通过 | 5 项技术决策均合理，关键事实经核实准确 |
| 3. FFI 最佳实践一致性 | 通过 | #borrow/moonbit_make_bytes/MOONBIT_FFI_EXPORT 正确使用，6 大陷阱全部规避 |
| 4. MoonBit v0.10.5 规范一致性 | 通过 | 新格式/preferred_target/supported_targets/targets/native-stub/pkgtype 均符合规范；supported_targets 正向纠偏架构设计错误 |
| 5. 版本迭代技术支撑 | 通过 | v0.2/v0.3/v0.4/v1.0 技术增量清晰，与上游 API 对齐 |
| 6. 自包含性 | 通过 | 不引用已有库作为依赖/互补基准/对比对象 |
| 7. 抽象层级适当性 | 通过 | 技术方案级别，不涉及过多实现细节，不过于抽象 |
| 8. 可支撑编码实现 | 通过 | 文件布局/配置轮廓/C wrapper 职责/FFI 声明/安全 API 流程/测试层/验证门均给出可执行方向 |

**总结论**：APPROVED_WITH_MINOR_ISSUES。4 个问题中 1 个为 tech_v1 亮点确认（无需修订）、2 个轻微表述不一致、1 个可改进细节，均不阻塞实现启动。建议修订问题 1/3/4 以提升方案表述清晰度，问题 2 建议后续修订架构设计 design_v3.md D13 末尾的错误提示。