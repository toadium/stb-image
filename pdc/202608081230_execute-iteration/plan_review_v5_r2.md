# 计划审查报告（v5 r2）

## 审查结果
APPROVED

## 发现
- **[轻微]** task_v5.md 第 14 行"验证 magic ... 8 字节结束标记"表述中"验证"一词可能被误读为解码器会强制校验结束标记，但参考的 `src/format/qoi.mbt:49-109` decode_qoi 实际按 `pixel_count` 终止循环、未显式校验 8 字节结束标记（encode_qoi 第 223-229 行写出 7×0x00+0x01 仅为规范合规）。pure 实现参考 decode_qoi 行为一致，不构成缺陷，仅建议 Doer 在测试手构造字节流时仍按规范附 8 字节结束标记以免边界歧义。
- **[轻微]** task_v5.md 第 31 行对比测试断言 width/height/channels/data 四字段完全一致，较 roundtrip_test.mbt 现有 QOI 测试（第 90-100 行仅断言 `restored.data`）更严格。这是合理增强（pure 与 format 为独立实现，字段级全断言更能发现移植错误），非缺陷，仅提示 Doer 注意 channels 字段需一致（encode_qoi 对 channels=3 输出 RGB、decode_qoi_pure 对 channels=3 输出 out_channels=3，一致）。

### 核实记录（独立验证 task_v5.md 关键事实）
1. **API 引用**：`@format.encode_qoi`/`@format.decode_qoi` 存在且签名正确（`src/format/qoi.mbt:13` `pub fn decode_qoi(data : Bytes) -> @core.Image raise @core.LoadError`、`src/format/qoi.mbt:121` `pub fn encode_qoi(img : @core.Image) -> Bytes raise @core.LoadError`），均为纯 MoonBit 无 FFI/C stub。`src/roundtrip_test.mbt:95,96,108,109` 现有 QOI 测试用 `@format.` 前缀印证。根包 `src/moon.pkg:11` 已 import format。r1 的 `@core.` 错误已修正。
2. **描述准确性**：task_v5.md 第 33 行如实说明"format 包纯 MoonBit 基准解码（交叉验证）""stb_image C 库不原生支持 QOI""两实现虽同源移植，但独立构造可发现移植错误"。r1 的"FFI 基准解码"失实描述已更正。
3. **参考实现**：`src/format/qoi.mbt:13-116` decode_qoi 确为纯 MoonBit（逐行核实无 FFI 调用），仅依赖 `@core.Image`/`@core.LoadError`，移植到 pure 包替换为 `@types.Image`/`@types.LoadError` 技术可行。qoi_hash（第 7-9 行 `(r*3+g*5+b*7+a*11)%64`）、6 种标签分支（INDEX 63-68、DIFF 69-72、LUMA 73-81、RUN 82-96、RGB 52-56、RGBA 57-62）、magic 校验（18-23）、尺寸校验（33-34）均与 task_v5.md 描述一致。
4. **预期测试数 562**：当前 native 553（check_v4.md 确认）。pure 包全目标化（`src/pure/moon.pkg` 无 supported_targets），native 为其目标之一，moon test --target native 必运行 pure 包测试（T3 先例：T3 后 native 552 已含 pure 6 测试）。新增 pure 8 测试 + 根包 1 测试 = 553+8+1=562，计算正确，不再有"另计"模糊表述。
5. **测试覆盖**：8 用例覆盖全部 6 种 QOI 标签（RGB/RGBA/DIFF/LUMA/RUN/INDEX）+ 2 错误路径（magic 不匹配/数据过短）。r1 缺失的 QOI_OP_LUMA 已补充（task_v5.md 第 22 行，参考 `src/format/qoi.mbt:73-81` 二级差分分支）。
6. **类型兼容**：`@pure.decode_qoi_pure` 返回 `@types.Image`，`@format.decode_qoi` 返回 `@core.Image`（即 `@types.Image` 别名，`src/core/image_types_reexport.mbt`），字段 width/height/channels/data 均 derive(Eq)，字段级比较可行。
7. **依赖可用性**：根包 `src/moon.pkg` 第 11 行 import format（主列表）、第 16-18 行 `for "test"` 声明 @pure。roundtrip_test.mbt 为 native-only（`options(targets: {"roundtrip_test.mbt": ["native"]})`），可自由依赖 @core+@format+@pure。现有 `roundtrip: BMP RGB pure vs FFI`（第 45-60 行）用 `@pure.decode_bmp_pure`、`roundtrip: QOI RGB`（第 90-100 行）用 `@format.encode_qoi`/`@format.decode_qoi`，均印证可用。
8. **pure 包现状**：`src/pure/` 当前仅 bmp_decode.mbt + bmp_decode_test.mbt（glob 确认），moon.pkg 仅 import types 全目标。新增 qoi_decode.mbt + qoi_decode_test.mbt 仅依赖 @types，全目标可用，不破坏现有结构。
9. **v1.0 API 冻结**：新增文件不修改现有代码，不改已有签名。
10. **r1 四项问题修正**：task_v5.md 第 81-86 行审查修订说明逐一对应 r1 的 4 项问题（2 严重 + 2 一般），修正方向具体且已核实源码论证。
