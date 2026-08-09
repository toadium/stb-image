# 检查报告（v5）

## 结果
PASSED

## 检查项
| 检查项 | 方法 | 结果 |
|--------|------|------|
| 产出文件存在性 | 读取 `src/pure/qoi_decode.mbt`（119 行）、`src/pure/qoi_decode_test.mbt`（267 行）、`src/roundtrip_test.mbt:116` 新增测试 | 通过：三处产出均存在且非空 |
| 函数签名一致性 | 对比 `qoi_decode.mbt:16` 与 task_v5.md 要求 `pub fn decode_qoi_pure(data : Bytes) -> @types.Image raise @types.LoadError` | 通过：签名完全一致 |
| 移植正确性（@core→@types） | 对比 `src/pure/qoi_decode.mbt` 与 `src/format/qoi.mbt:13-116` 逻辑 | 通过：仅类型引用 `@core.Image`→`@types.Image`、`@core.LoadError`→`@types.LoadError` 替换，解码逻辑完全保留 |
| QOI 标签覆盖（6 种） | 审查 `qoi_decode.mbt:55-98` 分支 | 通过：OP_RGB(0xFE):55、OP_RGBA(0xFF):60、OP_INDEX(0x00-0x3F):66、OP_DIFF(0x40-0x7F):72、OP_LUMA(0x80-0xBF):76、OP_RUN(0xC0-0xFF):85 全部覆盖 |
| 哈希函数正确性 | 审查 `qoi_decode.mbt:9-11` | 通过：`(r*3 + g*5 + b*7 + a*11) % 64` 与规范及 `src/format/qoi.mbt:7-9` 一致 |
| 头部验证（magic/宽高/channels/结束标记） | 审查 `qoi_decode.mbt:18-38` | 通过：magic 0x71 0x6F 0x69 0x66 校验、宽高大端解析、channels 读取、尺寸有效性校验 |
| 纯逻辑测试数量 | 统计 `qoi_decode_test.mbt` 中 `test` 块 | 通过：共 8 个测试，符合 task_v5.md 要求 |
| 测试覆盖全部 6 种标签 + 2 错误路径 | 审查测试名及构造 | 通过：OP_RGB(165)、OP_RGBA(177)、OP_DIFF(190)、OP_LUMA(203)、OP_RUN(216)、OP_INDEX(229)、magic 错误(244)、数据过短(257) |
| LUMA 测试编码值正确性 | 手算验证：像素(118,120,122) prev(100,100,100)，dg=20, dr_dg=-2, db_dg=2，tag=0x80\|(20+32)=0xB4，b2=((6)<<4)\|10=0x6A | 通过：`qoi_decode_test.mbt:110-111` 字节 0xB4 0x6A 与计算一致 |
| INDEX 测试哈希值正确性 | 手算验证：(10*3+20*5+30*7+40*11)%64=780%64=12，tag=0x0C | 通过：`qoi_decode_test.mbt:154,157` hash=12、tag=0x0C 与计算一致 |
| DIFF 测试编码值正确性 | 手算验证：dr=dg=db=1，tag=0x40\|0x30\|0x0C\|0x03=0x7F | 通过：`qoi_decode_test.mbt:88` tag=0x7F 与计算一致 |
| RUN 测试编码值正确性 | 手算验证：run=3，tag=0xC0\|(3-1)=0xC2 | 通过：`qoi_decode_test.mbt:137` tag=0xC2 与计算一致 |
| 对比测试存在且 native-only | 读取 `src/roundtrip_test.mbt:116-132`，确认 `src/moon.pkg:26` `roundtrip_test.mbt: ["native"]` | 通过：测试名 `roundtrip: QOI pure vs format`，受 moon.pkg targets 约束为 native-only |
| 对比测试 API 引用正确性 | 审查 `roundtrip_test.mbt:121-123` | 通过：使用 `@format.encode_qoi`/`@format.decode_qoi`/`@pure.decode_qoi_pure`（非 `@core.encode_qoi`），符合 task_v5.md r1 修正要求 |
| 对比测试交叉验证逻辑 | 审查 `roundtrip_test.mbt:125-128` | 通过：断言 width/height/channels/data 完全一致，覆盖 RGB 路径（req_channels=Some(3)） |
| pure 包全目标化 | 读取 `src/pure/moon.pkg` | 通过：仅 `import types`，无 `supported_targets` 限制，全目标可用 |
| 根包依赖配置 | 读取 `src/moon.pkg:11,17` | 通过：主 import 含 `@format`，`for "test"` 声明 `@pure` 依赖，无需新增 |
| 构建验证（全目标） | 执行 `moon check` | 通过：0 errors 0 warnings（no work to do，缓存有效） |
| 构建验证（native） | 执行 `moon check --target native` | 通过：0 errors 0 warnings |
| 测试验证（native） | 执行 `moon test --target native` | 通过：Total tests: 562, passed: 562, failed: 0（553→562，新增 9 测试全部通过） |
| v1.0 API 冻结保持 | 审查产出清单：仅新增 2 文件 + roundtrip_test.mbt 末尾追加测试 | 通过：未修改任何现有 API 签名，现有 553 测试全部通过 |
| 现有测试不破坏 | moon test 结果 562 passed 含原有 553 | 通过：现有测试全部通过 |

## 总结
Doer 的产出完整满足 task_v5.md 全部要求：QOI 解码器移植正确（仅类型引用替换，逻辑与 `src/format/qoi.mbt` 一致），8 个纯逻辑测试覆盖全部 6 种 QOI 标签 + 2 错误路径且编码值经手算验证正确，1 个 native-only 交叉验证对比测试使用正确的 `@format` API。构建全目标 0 errors 0 warnings，native 测试 562 通过（553→562，+9），v1.0 API 冻结保持。任务全部按指令完成，无偏差。
