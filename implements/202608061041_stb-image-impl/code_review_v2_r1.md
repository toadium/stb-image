# 代码审查报告（v2 r1）

## 审查结果
APPROVED

## 发现
- **[轻微]** src/wrapper.c:53 — `malloc` 返回值未检查，OOM 时 `memcpy(NULL, ...)` 与 `path_cstr[path_len]` 将段错误。设计文档 §"错误处理" 已明确接受为 MVP 简化策略（"假设路径长度合理不会 OOM"），完整库版本应追加 NULL 检查并返回失败信号（零长度 Bytes + 输出参数写 0）。不影响 MVP 正确性。
- **[轻微]** src/wrapper.c:36,65 — `pixel_size = (int32_t)w * (int32_t)h * (int32_t)c` 存在整数溢出风险：超大图像（如 w*h*c > INT32_MAX ≈ 21 亿）会溢出为负数，传给 `moonbit_make_bytes` 致未定义行为。设计文档未要求处理溢出，MVP 阶段假设图像尺寸合理。值得在完整库版本以 `size_t` 中间变量 + 溢出检查改进。
- **[轻微]** src/wrapper.c:36,65 — 设计文档 §"行为契约" 字面表述为 `moonbit_make_bytes(w * h * c, 0)`（int 乘法），实际代码用 `(int32_t)w * (int32_t)h * (int32_t)c`（先转 int32_t 再乘）。两者最终均截断到 32 位赋值给 `int32_t pixel_size`，语义等价，无功能缺陷，仅字面表述微偏。

## 验证记录
- `moon check --target native`：0 errors, 2 warnings（unused_value，预期行为，R3 调用后消除）
- `moon info --target native`：通过，`src/pkg.generated.mbti` 无公开 API（ffi.mbt 私有，符合验收契约）
- `src/stb_image.h` 存在（R1 vendoring 产物，commit `013ac3b...`，v2.30）
- `STBI_WINDOWS_UTF8` 在 stb_image.h:436 有 `#ifdef` 门控支持，wrapper.c:2-4 的 `_WIN32` 条件定义正确

## 符合性确认
- **wrapper.c**：头文件包含顺序（STBI_WINDOWS_UTF8 → STB_IMAGE_IMPLEMENTATION → stb_image.h → moonbit.h → string.h/stdlib.h）、两函数签名、成功/失败路径、所有权转移（memcpy + stbi_image_free）、NUL 结尾副本（malloc + memcpy + '\0' + free 无论成功失败）、失败信号统一（NULL → 零长度 Bytes + 输出参数写 0）、desired_channels=0 均与设计一致
- **ffi.mbt**：两 `extern "c" fn` 签名、`#borrow` 标注位置（在 `extern "c" fn` 之前）、`///|` 分隔符、显式 C 符号名、小写 `extern "c"`、私有（不 `pub`）、返回 `Bytes`（非 `Bytes?`）均与设计一致
- **moon.pkg**：`supported_targets = "native"` + 单一 `options(...)` 块承载 `native-stub` 与 `targets`，不门控未创建文件，与设计一致