# 技术方案审查报告（v1）

## 审查结果

APPROVED

## 逐维度审查

### 1. 技术准确性

**[通过]** MoonBit v0.10.5 新格式 `moon.mod`/`moon.pkg` DSL 语法决策准确。已核实 `moonbit_wiki/toolchain/package-management.md:38` 确认 `preferred_target = "native"`（下划线）为新 DSL 语法；`:50` 确认旧 `moon.pkg.json` 在 v0.10.4 起弃用；`:60` 确认 `supported_targets = "native"` 语法。

**[通过]** `supported_targets = "native"` 决策准确。已核实 `moonbit_wp/llvm.mbt` 下 3 个 `moon.pkg`（unsafe/test/IR）均使用 `supported_targets = "native"`（不带 `+` 前缀），与 `moonbit_wiki/toolchain/package-management.md:60` 示例一致。tech_v1 §2.2 正确识别架构设计 D13 末尾"`+native`"提示的不准确性，基于实际先例与语义分析（`"native"` 排他性声明 vs `"+native"` 追加语义）做出正确决策，理由充分。

**[通过]** `moonbit.h` 运行时 API 引用全部准确。已逐行核实 `moonbit_wp/moonbit-native-runtime/include/moonbit.h`：`moonbit_make_bytes(int32_t size, int value)` 在第 343 行（§2.4 声称 343 ✓）、`MOONBIT_FFI_EXPORT` 宏在第 50/53 行（§2.4 声称 50/53 ✓）、`Moonbit_array_length` 在第 228 行（§2.4 声称 228 ✓）、`moonbit_make_external_object` 在第 374 行（§2.4 声称 374 ✓）、`moonbit_incref`/`moonbit_decref` 在第 311-312 行（§2.4 声称 311-312 ✓）。

**[通过]** stb_image.h API 签名引用准确。已 webfetch 核实上游 `nothings/stb/master/stb_image.h` v2.30：`stbi_load(char const *filename, int *x, int *y, int *channels_in_file, int desired_channels)`、`stbi_load_from_memory(stbi_uc const *buffer, int len, ...)`、`stbi_image_free(void *retval_from_stbi_load)` 签名与 §5.1 一致；失败时返回 NULL 且 `*x, *y, *channels_in_file` **保持不变**（非写入 0），§5.1 正确指出 wrapper 需主动写入 0；单头文件库需 `#define STB_IMAGE_IMPLEMENTATION` 特性确认。

**[通过]** `STBI_WINDOWS_UTF8` 宏与 `stbi_convert_wchar_to_utf8` 函数引用准确。已 webfetch 核实上游：stb_image.h 确实提供 `STBI_WINDOWS_UTF8` 编译宏（定义后内部 `stbi__fopen` 使用 `MultiByteToWideChar` + `_wfopen` 处理 UTF-8 路径），以及 `stbi_convert_wchar_to_utf8` 转换函数，§5.3 方案可行。

**[通过]** MoonBit FFI 类型映射准确。已核实 `moonbit_wiki/agent-guide/c-binding.md:39` 确认"输出 `int *` → `Ref[Int]`，借用 Ref"；`:35` 确认"`const uint8_t *` → `Bytes`，C 不存储则用 `#borrow`"；`moonbit_wiki/language/ffi.md` 确认 `#borrow` 语义与 `extern "c"`/`extern "C"` 均可。§5.2 类型映射表与文档一致。

**[通过]** `targets` 门控语法准确。已核实 `moonbit_wiki/toolchain/package-management.md:66-70` 示例 `targets: { "only_js.mbt": ["js"], ... }`，§3.3 门控清单语法正确。

**[轻微]** §3.3 门控清单中 `image_test.mbt` 初标注"不门控"，§7.2 又修正为"应门控到 `["native"]`"。方案内部已自洽修正（§7.2 明确结论），不影响实现启动，但建议统一门控清单表述避免实现者困惑。

### 2. 完备性

**[通过]** 需求文档所有功能要求均有技术方案覆盖：MVP 加载入口（§6.3）、`Image` 类型（§6.1）、`LoadError` 错误处理（§6.2）、9 种支持格式（§7.1 测试聚焦 5 种常见格式与需求文档一致）、vendoring（§4）、FFI 实现要点（§5）、验收标准（§7）、Windows 兼容性（§5.3）、格式嗅探决策（§6.4）、文档方案（§8）、版本演进技术支撑（§10）。

**[通过]** 数据流形成完整闭环。load_from_path: `String → UTF-8 Bytes → C wrapper → stbi_load → unsigned char* → moonbit_make_bytes → MoonBit Bytes → Image`；load_from_bytes: `Bytes → C wrapper → stbi_load_from_memory → ... → Image`；错误路径: `stbi_load 返回 NULL → C wrapper 写入 0 → MoonBit 检查空 Bytes → raise LoadError`。所有权转移流程（§5.1）清晰描述了 GC 接管与 C 释放的边界。

**[通过]** 架构设计 D1-D14 全部有技术方案落实（§十一对应表），无遗漏的技术方向性问题。§九列出的 6 个需编码时验证的技术假设均给出了降级方案（如假设 1 标准库文件 API 不可用时降级为"不预检查，统一归 DecodeFailed"），不阻塞实现启动。

### 3. 可操作性

**[通过]** 所有技术选型决策明确，无开放性问题：工具链版本（v0.10.5 新 DSL）、目标后端（native only）、vendoring 策略（单头文件库特殊处理）、C wrapper 机制（ABI 归一化 + moonbit_make_bytes + stbi_image_free）、extern "c" 声明（私有 + #borrow + Ref[Int]）、类型轮廓（pub(all) struct + suberror）、错误处理（raise + 默认归类 DecodeFailed）、条件编译（拆文件 + targets 门控）、测试策略（脚本生成 + ASan）、文档结构（SKILL.md + README.mbt.md）。

**[通过]** 实现者可从方案明确知道"做什么"与"怎么做的大方向"：文件布局（§3.1）、配置项轮廓（§3.2/§3.3）、C wrapper 职责（§5.1）、extern "c" 声明轮廓（§5.2）、安全 API 流程（§6.3）、测试层设计（§7.2）、验证命令序列（§7.4）均给出可执行的方向。

**[通过]** 技术引用足够具体，实现者能直接定位：MoonBit v0.10.5、`moon.mod`/`moon.pkg` 新 DSL、`moonbit.h`、`stb_image.h`、`stbi_load`/`stbi_load_from_memory`/`stbi_image_free`、`moonbit_make_bytes`、`MOONBIT_FFI_EXPORT`、`STBI_WINDOWS_UTF8`、`moonbit-c-binding/scripts/run-asan.py`、`make-moonbit-c-bindings/templates/prepare.py` 等引用均明确。

**[通过]** 方案停留在技术决策层，未过度深入实现细节（无完整代码片段、逐字段签名、逐方法实现），符合技术方案定位。自包含，不引用已有库作为依赖。