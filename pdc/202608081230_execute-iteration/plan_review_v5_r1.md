# 计划审查报告（v5 r1）

## 审查结果
REJECTED

## 发现

- **[严重] 对比测试 API 引用错误，编译必失败**：task_v5.md 第 29 行与 plan.md 第 134 行均将对比测试描述为 `@core.encode_qoi(img)` 生成 QOI 字节流、`@core.decode_qoi(qoi_bytes)` 基准解码。经核实，`encode_qoi`/`decode_qoi` 定义在 `src/format/qoi.mbt:13,121`，属 `@format` 包；对 `src/core` 全量 grep `encode_qoi|decode_qoi` 无任何匹配，core 包未 re-export 这两个函数；根包 `src/reexport.mbt:824,842` 仅以 `pub let decode_qoi ... = @format.decode_qoi` / `pub let encode_qoi ... = @format.encode_qoi` re-export 到根包级别（无前缀调用），并非 `@core`。现有 `roundtrip_test.mbt:95,96,108,109` 的 QOI 测试均使用 `@format.encode_qoi`/`@format.decode_qoi`。若 Doer 照搬计划中的 `@core.encode_qoi`/`@core.decode_qoi`，`moon check` 必报 `unbound function @core.encode_qoi`，违反"0 errors"预期产出。更矛盾的是：plan.md 第 148 行上下文自述"`src/format/qoi.mbt:121-231`：`encode_qoi` 纯 MoonBit 实现，可用于对比测试"，已正确指向 format 包，却与同文件第 134 行任务描述的 `@core.encode_qoi` 自相矛盾。

- **[严重] "FFI 基准解码"描述失实，对比测试价值被误标**：task_v5.md 第 29 行称 `@core.decode_qoi(qoi_bytes)` 为"FFI 基准解码"，plan.md 第 134 行同。但 plan.md 第 147 行上下文自述"`decode_qoi` 纯 MoonBit 实现"，`src/format/qoi.mbt:13-116` 确无任何 FFI/C stub 调用。即对比测试实为"pure 包纯 MoonBit 解码器 vs format 包纯 MoonBit 解码器"，非"pure vs FFI"。项目 stb_image C 库不原生支持 QOI（QOI 为现代格式），无真正 FFI 基准可用。此描述误导 Doer/Checker 对测试性质的判断，且两份纯 MoonBit 实现若同源移植可能共享相同错误，对比验证价值弱于 T4 的 BMP pure-vs-FFI（T4 中 `@core.load_from_bytes` 走真实 stb C FFI）。计划未正视此差异，仍以"FFI 基准"名义宣称对比验证，属实质性误导。

- **[一般] 预期 native 测试数错误，遗漏 pure 包纯逻辑测试**：task_v5.md 第 34 行预期"`moon test --target native` 553→554 通过（新增 1 个根包对比测试，pure 包纯逻辑测试数另计）"。但 pure 包全目标化（T3 已完成，`src/pure/moon.pkg` 无 `supported_targets` 限制），native 为其目标之一，`moon test --target native` 必运行 pure 包测试。task_v5.md 第 18-25 行列出至少 7 个 pure 包测试（1x1 RGB、1x1 RGBA、2x2 DIFF、2x2 RUN、2x2 INDEX、magic 错误、数据过短错误），故实际 native 总数应为 553 + 1（根包对比）+ 7（pure 纯逻辑）= 561，而非 554。"pure 包纯逻辑测试数另计"的表述将 pure 包测试排除在 native 计数外，与 T3 先例矛盾（T3 的 native 552 已含 pure 包 6 测试，见 plan.md 第 93 行）。Checker 若按 554 验证 native 总数将误判为失败。

- **[一般] QOI_OP_LUMA 标签测试缺失，与"支持全部标签"要求不符**：task_v5.md 第 12 行要求"支持全部 QOI 标签：QOI_OP_INDEX、QOI_OP_DIFF、QOI_OP_LUMA、QOI_OP_RUN、QOI_OP_RGB、QOI_OP_RGBA"（6 种）。但测试用例（第 20-25 行）仅覆盖 5 种：RGB、RGBA、DIFF、RUN、INDEX，独缺 QOI_OP_LUMA（0x80-0xBF，双字节差分编码，解码逻辑最复杂，见 `src/format/qoi.mbt:73-81`）。LUMA 是 QOI 6 标签中唯一涉及第二字节读取与 dr_dg/db_dg 二级差分的标签，未测试则该分支正确性无验证，与"支持全部标签"的明示要求不符。

## 修改要求

1. **问题：对比测试 API 引用错误（`@core.encode_qoi`/`@core.decode_qoi` 不存在）**
   - 为什么是问题：core 包无此二函数，照搬导致编译失败，计划不可行；且 plan.md 上下文（第 148 行）已正确指向 format 包，与任务描述（第 134 行）自相矛盾，说明计划内部未对齐。
   - 期望修正方向：将 task_v5.md 第 29 行与 plan.md 第 134 行的 `@core.encode_qoi` 改为 `@format.encode_qoi`、`@core.decode_qoi` 改为 `@format.decode_qoi`。根包 `src/moon.pkg` 已 import format（第 11 行），无需新增依赖。

2. **问题："FFI 基准解码"描述失实**
   - 为什么是问题：`decode_qoi` 是纯 MoonBit，非 FFI；plan.md 自述（第 147 行）与"FFI 基准"描述矛盾。误导测试性质判断，且掩盖了"无真正 FFI 基准、对比实为交叉验证"的事实，影响对验证强度的合理预期。
   - 期望修正方向：将"FFI 基准解码"更正为"format 包纯 MoonBit 基准解码（交叉验证）"或类似表述，如实说明对比双方均为纯 MoonBit 实现，对比价值为独立实现交叉校验而非 FFI 基准对照。

3. **问题：预期 native 测试数遗漏 pure 包纯逻辑测试**
   - 为什么是问题：pure 包全目标，native 必运行其测试；"另计"表述与 T3 先例（native 552 含 pure 6 测试）矛盾。Checker 按 554 验证会误判。
   - 期望修正方向：明确列出 pure 包新增测试数（按第 18-25 行用例计为 7 个），将 native 预期修正为 553 + 1 + 7 = 561（或按最终确定的 pure 测试数如实计算），不再使用"另计"模糊表述。

4. **问题：QOI_OP_LUMA 测试缺失**
   - 为什么是问题：第 12 行明示"支持全部 QOI 标签"，测试却缺 LUMA，覆盖与要求不符；LUMA 是最复杂的双字节差分分支，未测试则正确性无保证。
   - 期望修正方向：在 task_v5.md 第 20-25 行测试用例中新增 1 个覆盖 QOI_OP_LUMA 的用例（如 2x2 RGB 像素含 LUMA 编码），并相应更新 pure 包测试数与 native 预期总数。
