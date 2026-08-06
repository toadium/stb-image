# 设计审查报告（v1 r1）

## 审查结果
APPROVED

## 发现

### [轻微] 发现 1：`moon.mod` 配置项缺少具体字段值

设计文档第 21 行文件规划中，对 `moon.mod` 仅列出字段名（name、version、preferred_target、license、description、keywords），除 `preferred_target = "native"` 外未给出具体值。而同文档对 `scripts/prepare.py` 达到了"精确到可直接编码"的精度（第 29 行明确声明），两者精度不一致。

任务文件第 14-20 行已给出具体值（version: 0.1.0、description: "MoonBit native FFI bindings for stb_image.h"、keywords: ["image", "stb", "ffi", "native"] 等），实现者需交叉对照两份文档方可编码。建议设计文档直接内联这些值，与 `prepare.py` 规格保持同等精度，减少跨文档对照负担。

### [轻微] 发现 2：`license` 字段未在设计中定选

任务文件第 17 行给出两个候选：`Public Domain`（stb_image 本身为 public domain）或 `MIT`。设计文档未明确选定其一，将决策留给实现者。此为未决项，不影响正确性，但建议设计文档明确选定（推荐 `Public Domain`，与上游 stb_image 许可一致），消除实现者的判断负担。

### [轻微] 发现 3：`vendor_single_header` 与 `download_to_cache` 参数顺序不一致

- `download_to_cache(url, expected_sha256, cache_dir, filename)`（第 78-83 行）：`cache_dir` 在 `filename` 前
- `vendor_single_header(url, expected_sha256, filename, cache_dir, package_dir)`（第 120-126 行）：`filename` 在 `cache_dir` 前

两个函数中 `cache_dir` 与 `filename` 的相对顺序相反。不影响功能（Python 支持关键字参数调用），但影响代码可读性与一致性。建议统一参数顺序，例如统一为 `(url, expected_sha256, cache_dir, filename, ...)`。

### [轻微] 发现 4：`vendor_single_header` 日志格式未明确

设计文档第 131 行职责描述为"打印 vendoring 结果日志（filename + commit + 是否更新）"，但未给出具体日志格式或示例输出。不影响正确性，但建议明确格式（如 `print(f"vendored {filename} @ {commit} ({'updated' if changed else 'unchanged'})")`），便于实现者产出统一日志。

### 审查过程说明

已核实以下关键点，均无问题：

1. **DSL 语法先例**：`moonbit_wp/llvm.mbt/unsafe/moon.pkg:1` 的 `supported_targets = "native"` 与 `moonbit_wp/llvm.mbt/moon.mod:15` 的 `preferred_target = "native"` 先例存在，设计引用的语法正确。
2. **渐进式声明策略**：`moon.pkg` 仅声明 `supported_targets = "native"` 不声明 `options(...)` 块，彻底消除悬空引用，`moon check` 可通过。策略自洽。
3. **SHA256 严格校验**：设计明确"首次运行即对硬编码哈希严格校验"，不存在"未回填跳过校验"的中间态。哈希值的正确性属运行时可验证属性，非设计缺陷。
4. **幂等契约**：`write_if_changed` 仅当内容不同时写入，避免时间戳变化产生 tracked diff。逻辑正确。
5. **`--include-write` 预留**：`STB_IMAGE_WRITE_COMMIT` 等置空字符串，带参数时 `raise SystemExit` 提示"待 v0.2 填入"。预留逻辑完整。
6. **错误处理覆盖**：SHA256 不匹配、下载失败、`--include-write` 未激活、缓存目录创建失败均有明确处理策略，不吞错。
7. **任务覆盖完整性**：任务文件要求的 5 个文件（moon.mod、src/moon.pkg、scripts/prepare.py、src/stb_image.h、.gitignore）均在设计中覆盖，行为契约、依赖关系、验收契约齐全。
8. **后续任务衔接**：设计明确列出 R2/R3/R4 渐进追加 `options(...)` 块的清单，与任务文件第 29-34 行一致，衔接清晰。