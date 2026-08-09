# 检查报告（v8）

## 结果
PASSED

## 检查项
| 检查项 | 方法 | 结果 |
|--------|------|------|
| 解码器签名合规 | 读取 `src/pure/{codec,pixel,color,process,util}/psd_decode.mbt:30` 验证 `pub fn decode_psd_pure(data : Bytes) -> @types.Image raise @types.LoadError` | 通过 — 与 BMP/QOI/TGA/PNM 惯例一致 |
| PSD 格式解析完整性 | 审查 header(26 字节) + 3 个 length 前缀段跳过 + image data(compression + 像素) 流程 | 通过 — signature/version/channelCount/h/w/bitdepth/colorMode/compression 全部校验 |
| 大端序读取正确性 | 审查 `read_u16_be`/`read_u32_be` 实现（`psd_decode.mbt:7-23`） | 通过 — 移位顺序与 BE 规范一致，含越界检查 |
| 通道交错公式正确性 | 审查 `psd_decode.mbt:96-103`，公式 `interleaved[i*channel_count + c] = data[pos + c*w*h + i]` | 通过 — 与任务要求 `data[i*channelCount + c] = raw_channel_data[c*w*h + i]` 一致 |
| 9 条错误路径覆盖 | 审查解码器中 9 个 `raise DecodeFailed` 分支 | 通过 — 数据过短/signature/version/channelCount/bitdepth/colorMode/compression/尺寸无效/像素不足全覆盖 |
| 纯逻辑测试数量与命名 | 读取 `src/pure/{codec,pixel,color,process,util}/psd_decode_test.mbt`，统计 `test` 块 | 通过 — 13 个（4 正例 + 9 错误路径），命名与任务要求一致 |
| 交错逻辑独立验证用例 | 审查 `channel interleave verify` 测试（`psd_decode_test.mbt:125`），2x1 R=[10,20] G=[30,40] B=[50,60] 期望 [10,30,50,20,40,60] | 通过 — 公式逐项验证正确，非简单拷贝 |
| 测试辅助函数复用 | 检查 `to_bytes` 是否重复定义 | 通过 — 复用 `qoi_decode_test.mbt` 的 `to_bytes`，仅新增 `push_be16`/`push_be32` |
| FFI 基准对比测试 | 读取 `src/roundtrip_test.mbt:449-488`，验证 2 个 native-only 测试 | 通过 — RGB 用 req_channels=Some(3) 匹配 pure；RGBA alpha=255 避免 white matte removal |
| pure 包全目标可用 | 检查 `src/pure/{codec,pixel,color,process,util}/moon.pkg` 仅 `import types`，无 `supported_targets` 限制 | 通过 — pure 包全目标，PSD 解码器仅依赖 @types |
| 根包 native-only 隔离 | 检查 `src/moon.pkg:26` `roundtrip_test.mbt: [native]` | 通过 — 对比测试限定 native 目标，无全目标警告问题 |
| `moon check --target native` | 执行构建检查 | 通过 — 0 errors 0 warnings |
| `moon check --target wasm` | 执行构建检查 | 通过 — 0 errors 0 warnings（pure 包全目标） |
| `moon check --target js` | 执行构建检查 | 通过 — 0 errors 0 warnings（pure 包全目标） |
| `moon test --target native` | 执行全量测试 | 通过 — Total tests: 597, passed: 597, failed: 0（582→597，+13 pure + 2 根包对比，符合预期） |
| v1.0 API 冻结保持 | 检查产出仅新增文件，未修改现有签名 | 通过 — 新建 `psd_decode.mbt`/`psd_decode_test.mbt`，仅追加 `roundtrip_test.mbt` 内容 |
| 现有测试未破坏 | 对比测试总数 582→597，新增 15 个 | 通过 — 原 582 测试全部继续通过 |

## 总结
Doer 产出完整满足 task_v8 全部要求：PSD 解码器实现正确（大端序解析 + 通道交错公式与规范一致，9 条错误路径全覆盖），13 个纯逻辑测试 + 2 个 FFI 基准对比测试全部通过，三目标构建零错误零警告，native 测试 597 全通过符合预期增量。v1.0 API 冻结保持，现有测试未破坏。产出质量高，无偏差。
