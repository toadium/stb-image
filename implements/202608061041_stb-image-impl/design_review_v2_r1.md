# 设计审查报告（v2 r1）

## 审查结果
APPROVED

## 发现
- **[轻微]** `w * h * c` 在 `int`（32 位）域内乘法可能溢出。对于超大图像（如 50000×50000×4 = 10^10），有符号整数溢出是 C 未定义行为，且 `moonbit_make_bytes(int32_t size, ...)` 与 `memcpy(..., (size_t)(w*h*c))` 均会使用溢出后的值。此为 stb_image 自身 API（`int *x, int *y, int *channels_in_file`）的固有局限，MVP 测试图片为小尺寸样本，不构成实际风险。完整库版本可在 wrapper 追加 `size_t total = (size_t)w * h * c` 溢出检查。
- **[轻微]** `stb_image_mbt_load_from_path` 的 `malloc(path_len + 1)` 返回值未显式 NULL 检查。设计已在"错误处理"节明确声明此为 MVP 简化策略并给出完整库的修正方向（追加 NULL 检查并返回失败信号），透明可追溯。
- **[轻微]** ffi.mbt 声明前的 `///|` 文档注释分隔符在 MoonBit 官方 FFI 示例（`ffi.md` 第 453-456 行、`attributes.md` 第 354-356 行）中未出现，设计援引 `moonbit_wp/x/fs/fs_native.mbt` 先例。此为风格选择，不影响编译正确性。