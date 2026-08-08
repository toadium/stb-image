# 检查报告（v4）

## 结果
PASSED

## 检查项
| 检查项 | 方法 | 结果 |
|--------|------|------|
| `src/moon.pkg` 新增 `@pure` 依赖 | 读取文件内容 | 通过：第 16-18 行以 `for "test"` 语法声明 `MoonBit-Toadium/stb-image/src/pure @pure`，pure 包对根包测试可用 |
| 依赖声明方式偏差合理性 | 对比任务指令步骤 1 与 do_v4.md 偏差说明 | 通过：任务指令原文"import 列表添加"，实际采用 `for "test"` 测试专用依赖语法。偏差原因合理——普通 import 触发 `unused_package` 警告（`@pure` 仅在 native-only 测试文件 `roundtrip_test.mbt` 中使用，`moon check` 不分析测试文件包引用），与预期产出"0 warnings"冲突。`for "test"` 是 MoonBit 官方测试专用依赖声明方式，语义等价，不改变任务意图 |
| `src/roundtrip_test.mbt` 新增 24-bit RGB pure-FFI 对比测试 | 读取文件第 44-60 行 | 通过：新增 `roundtrip: BMP RGB pure vs FFI` 测试，共 1 个，符合"仅保留 24-bit RGB"方案 A |
| 测试实现模式符合要求 | 逐行核对测试代码 | 通过：`@core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))` → `@core.write_bmp_to_bytes(img)` → `@pure.decode_bmp_pure(bmp_bytes)` → `@core.load_from_bytes(bmp_bytes, req_channels=Some(3))` → 断言 width/height/channels/data 完全一致，与任务指令步骤 2 完全吻合 |
| 未新增 32-bit RGBA 对比测试 | 全文搜索 `roundtrip_test.mbt` | 通过：文件中仅 1 个 pure-FFI 对比测试（24-bit RGB），无 32-bit RGBA 测试，符合任务指令步骤 3 与方案 A |
| `moon check --target native` 0 errors 0 warnings | `moon clean && moon check --target native` | 通过：输出 "Finished. moon: ran 30 tasks, now up to date"，无任何 error/warning |
| 全目标 `moon check` 0 errors 0 warnings | `moon check` | 通过：输出 "no work to do"，无任何 error/warning |
| `moon test --target native` 553/553 通过 | `moon test --target native` | 通过：输出 "Total tests: 553, passed: 553, failed: 0"，符合预期 552→553（新增 1 测试） |
| v1.0 API 冻结保持 | 审查产出清单 | 通过：仅修改 `src/moon.pkg`（新增测试专用依赖）和 `src/roundtrip_test.mbt`（新增测试），未改动任何已有 API 签名 |
| 现有测试不破坏 | 测试结果 553 全通过 | 通过：553 测试全部通过，其中 552 为原有测试，1 为新增测试，原有测试均继续通过 |

## 总结
Doer 按任务指令方案 A 完成了 T3 收尾工作：将 pure-FFI BMP 24-bit RGB 对比验证测试移至根包 `roundtrip_test.mbt`，恢复了纯 MoonBit 解码器与 FFI 解码器的一致性验证。构建验证全部通过（native 与全目标均 0 errors 0 warnings），测试 553/553 通过。唯一偏差是 `src/moon.pkg` 依赖声明采用 `for "test"` 语法而非普通 import，该调整是为满足"0 warnings"要求的合理实现细节，语义等价，不改变任务意图。所有检查项均通过。
