# 计划审查报告（v7 r1）

## 审查结果
APPROVED

## 发现
- **[轻微]** plan.md line 215 测试数预期固定为 "572→581"，对应 7 个 pure 纯逻辑测试 + 2 根包对比，但 task_v7.md line 28 纯逻辑测试建议 "7-9 个"。若 Doer 按 8 或 9 个实现，实际为 582 或 583，与 plan.md 固定值 581 不符（task_v7.md line 47 已给建议范围 580-582 可兜底 7-8 个，9 个则超范围）。不影响正确性，Doer 按 task_v7.md line 47 "+7" 预期实现即可对齐。

### 核实项（均已通过）
- `@format.encode_ppm` 存在（`src/format/pnm_encode.mbt:6`），签名 `pub fn encode_ppm(img : @core.Image) -> Bytes`，输出 "P6\n{w} {h}\n255\n" + RGB 像素，与 plan.md/task_v7.md 描述一致
- `@format.encode_pgm` 存在（`src/format/pnm_encode.mbt:37`），签名 `pub fn encode_pgm(img : @core.Image) -> Bytes`，输出 "P5\n{w} {h}\n255\n" + 灰度像素，与 plan.md/task_v7.md 描述一致
- `@core.load_from_bytes` 支持 PNM 解码（`src/format/pnm_encode_test.mbt:23,76` roundtrip 测试印证）
- pure 包 `src/pure/{codec,pixel,color,process,util}/moon.pkg` 仅 `import types`，无 `supported_targets`，全目标可用
- 根包 `src/moon.pkg`：`for "test"` 已声明 `@pure` 依赖（line 16-18），第 11 行 import format，`options(targets: {"roundtrip_test.mbt": ["native"]})`（line 26），与 plan.md/task_v7.md 描述一致
- `roundtrip_test.mbt` 现有 PNM 测试模式（line 148-174）：`@format.encode_ppm`/`encode_pgm` → `@core.load_from_bytes` → 断言 data 一致，可参照
- `qoi_decode_test.mbt` 有 `to_bytes` 辅助函数（line 37），可复用
- pure 包现有文件：bmp/qoi/tga 解码器及测试 + moon.pkg，与 task_v7.md "已有产出上下文" 一致
- PNM 格式规格（P5/P6 二进制、注释行、whitespace、maxval < 256）plan.md 与 task_v7.md 描述一致
- 错误路径（数据过短、不支持的 magic、不支持的 maxval ≥ 256）plan.md 与 task_v7.md 一致
- 对比测试类型匹配：`@format.encode_ppm`/`encode_pgm` 接受 `@core.Image`，`@core.load_from_path` 返回 `@core.Image`；`@codec.decode_pnm_pure` 返回 `@types.Image`，`@core.Image` 即 `@types.Image`（re-export），字段级比较可行
- `@format.encode_ppm`/`encode_pgm` 输出 maxval=255 < 256，在 pure 解码器支持范围内（对比测试不会因 maxval 被拒绝）
- `@format.encode_ppm`/`encode_pgm` 输出使用 LF 分隔无注释行，对比测试验证基本路径；注释行/混合 whitespace 由纯逻辑测试覆盖，分工合理
