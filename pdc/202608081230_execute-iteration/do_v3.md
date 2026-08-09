# 执行报告（v3）

## 概述
移除 `src/pure/{codec,pixel,color,process,util}/moon.pkg` 的 `supported_targets = "native"` 限制，使 pure 包成为全目标包（native/wasm/js 可用），完成 v2.0 多目标支持的关键里程碑。采用**方案 B**：移除 2 个依赖 `@core.load_from_bytes` 的对比测试，pure 包完全脱离 @core 依赖，只保留 6 个纯逻辑测试（全目标可用）。构建验证通过：`moon check`（全目标）0 errors / 0 warnings，`moon test --target native` 552/552 通过，`moon test --target wasm`/`--target js` pure 包 6/6 通过。

## 产出清单
| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 修改 | `src/pure/{codec,pixel,color,process,util}/moon.pkg` | 移除 `supported_targets = "native"`，移除 `@core` 的 `for "test"` 依赖，仅保留 `import types`（全目标） |
| 修改 | `src/pure/{codec,pixel,color,process,util}/bmp_decode_test.mbt` | 移除 2 个对比测试（原第 88-107 行，测试 5-6，依赖 `@core.load_from_bytes`），保留 6 个纯逻辑测试（测试 1-4, 7-8），更新文件头注释 |

## 执行过程

### 1. 方案 A 尝试与放弃
按任务指令优先级先尝试方案 A（保留对比测试，分离到 native-only 文件）：
1. 创建 `src/pure/{codec,pixel,color,process,util}/bmp_compare_test.mbt`，包含 2 个对比测试（`@core.load_from_bytes` 对比验证）
2. 从 `bmp_decode_test.mbt` 移除对比测试（测试 5-6）
3. `moon.pkg`：移除 `supported_targets`，增加 `options(targets: { "bmp_compare_test.mbt": ["native"] })`，保留 `@core` 的 `for "test"` 依赖

**方案 A 验证结果**：
- `moon check --target wasm` / `--target js`：通过（功能可行）
- `moon check`（全目标）：**产生警告** "Package `src/pure` does not declare `supported_targets`, but depends on `src/core` which declares it. Consider declaring `supported_targets` explicitly"
- 尝试 `for "test" "native"` 语法给条件依赖加 target 限制：**语法不支持**（Parsing error: UnexpectedToken）

**放弃原因**：任务指令预期产出要求"0 errors 0 warnings"，方案 A 的警告无法通过 moon.pkg 语法消除（moon 0.1.20260713 的 `for "test"` 不支持 target 限定，全目标包 `for "test"` 依赖 native-only 包必然触发警告）。任务指令方案 A 第 4 点已预见此风险："若 `moon check` 全目标报 @core 不支持 wasm/js 则方案 A 不可行，转方案 B"。

### 2. 方案 B 实施
转方案 B（移除对比测试，pure 包完全脱离 @core）：
1. 删除 `bmp_compare_test.mbt`（方案 A 产物）
2. `moon.pkg`：仅保留 `import types`，移除 `@core` 的 `for "test"` 依赖，无 `supported_targets`，无 `options`
3. `bmp_decode_test.mbt`：对比测试已在方案 A 步骤 2 移除，保留 6 个纯逻辑测试，更新文件头注释说明对比验证留待后续轮次移至根包 `roundtrip_test.mbt`

### 3. 构建验证
- `moon check`（全目标，不带 `--target`）：通过，0 errors 0 warnings
- `moon check --target wasm`：通过
- `moon check --target js`：通过
- `moon test --target native`：552/552 通过（从 554 降至 552，移除 2 个对比测试）
- `moon test --target wasm`：pure 包 6/6 通过
- `moon test --target js`：pure 包 6/6 通过

### 关键决策
1. **采用方案 B 而非方案 A**：方案 A 功能可行（wasm/js 编译通过）但全目标 `moon check` 有警告，不符合任务"0 warnings"要求；moon 0.1.20260713 的 `for "test"` 语法不支持 target 限定，无法消除警告。方案 B 更干净：pure 包真正全目标，无 native-only 依赖，符合"pure 包是 wasm/js 后端基础"的设计目标。
2. **对比验证留待后续轮次**：2 个对比测试（`decode_bmp_pure` vs `@core.load_from_bytes`）移至根包 `roundtrip_test.mbt`（已 native-only，可依赖 @core + @pure 对比），任务指令方案 B 第 4 点已规划此后续动作。

## 偏差说明
1. **采用方案 B 而非优先的方案 A**：任务指令方案 A 优先，但实测方案 A 全目标 `moon check` 产生警告（全目标包 `for "test"` 依赖 native-only core 包），且 `for "test" "native"` 语法不支持，无法消除警告。任务指令预期产出要求"0 errors 0 warnings"，故转方案 B。任务指令已预见此情况并提供方案 B 作为 fallback，属于按预案执行，非意外偏差。
2. **测试数从 554 降至 552**：方案 B 移除 2 个对比测试，native 全量测试从 554 降至 552。任务指令方案 B 预期"降至 552，需在执行报告中说明"，符合预期。对比验证功能未丢失，留待后续轮次移至根包 `roundtrip_test.mbt`。
