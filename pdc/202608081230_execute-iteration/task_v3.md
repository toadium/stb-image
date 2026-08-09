# 任务指令（v3）

## 动作
NEW

## 任务描述
移除 `src/pure/moon.pkg` 的 `supported_targets = "native"` 限制，使 pure 包成为全目标包（wasm/js 可用），这是 v2.0 多目标支持的关键里程碑。

**关键障碍**：测试文件 `src/pure/bmp_decode_test.mbt` 中 2 个对比测试（第 88-107 行，"compare with @core.load_from_bytes"）依赖 native-only 的 `@core` 包（`@core.load_from_bytes`），与全目标冲突。pure 包主代码 `bmp_decode.mbt` 已只依赖 `@types`（全目标），无障碍。

**处理方案（按优先级）**：

**方案 A（优先）**：保留对比测试，分离到 native-only 文件
1. 将 `bmp_decode_test.mbt` 中的对比测试（第 88-107 行，测试 5-6）移到新文件 `src/pure/bmp_compare_test.mbt`
2. `bmp_decode_test.mbt` 只保留纯逻辑测试（测试 1-4, 7-8，不依赖 @core）
3. `src/pure/moon.pkg`：移除 `supported_targets = "native"`，增加 `options(targets: { "bmp_compare_test.mbt": ["native"] })` 限制对比测试为 native-only（参照根包 `src/moon.pkg` 的 `options(targets: {...})` 先例）
4. `@core` 依赖保留 `for "test"`，需验证 moon 是否允许全目标包有 native-only 的 `for "test"` 依赖（若 `moon check` 全目标报 @core 不支持 wasm/js 则方案 A 不可行，转方案 B）

**方案 B（fallback）**：移除对比测试，pure 包完全脱离 @core
1. 移除 `bmp_decode_test.mbt` 中的对比测试（第 88-107 行，测试 5-6）
2. `src/pure/moon.pkg`：移除 `supported_targets = "native"`，移除 `@core` 的 `for "test"` 依赖
3. pure 包只保留纯逻辑测试（测试 1-4, 7-8）
4. 对比验证留待后续轮次移至根包 `roundtrip_test.mbt`（已 native-only，可依赖 @core + @pure 对比）

**约束**：
- pure 包主代码（`bmp_decode.mbt`）只依赖 @types（全目标），不引入新的 native-only 依赖
- 不破坏现有测试：`moon test --target native` 原有 554 测试应继续通过（方案 A 保留全部 554 测试；方案 B 移除 2 个对比测试降至 552，需在执行报告中说明）
- 保持 v1.0 API 冻结，不修改已有公开函数签名

**预期产出**：
- `src/pure/moon.pkg` 不含 `supported_targets` 限制（全目标）
- `moon check`（全目标，不带 `--target`）通过，0 errors 0 warnings
- `moon test --target native` 全量通过
- 执行报告 `do_v3.md` 说明采用了方案 A 还是 B 及原因

## 选择理由
- T2（core 包类型分离）已完成并通过检查，types 包全目标可用，pure 包主代码已改用 @types
- T2 修正方向 3 明确声明"pure 包真正脱离 native（全目标编译）需确认 moon.pkg 条件依赖语法，留待下轮"，本轮即承接此遗留问题
- pure 包全目标化是 v2.0 多目标支持（wasm/js）的关键里程碑：pure 包是 wasm/js 后端的基础，当前 `supported_targets = "native"` 限制使其无法在 wasm/js 使用
- 是后续后端选择层 `src/lib.mbt`（native 用 core，wasm/js 用 pure）的前提
- 风险可控：pure 包主代码已只依赖 @types（全目标），唯一障碍是测试对 @core 的依赖，处理测试依赖即可，不涉主代码逻辑改动
- 当前优先级最高：T1（概念验证）+ T2（类型分离）已完成，pure 包全目标化是 v2.0 路径的下一个逻辑节点

## 任务上下文
摘录与当前任务直接相关的需求/约束：

1. **ROADMAP.md v2.0 交付物**：`src/native/`（native 后端，现有 C FFI）+ `src/pure/`（纯 MoonBit 后端，wasm/js）+ `src/lib.mbt`（后端选择层）
2. **执行约束**（来自 task.md）：
   - 保持 v1.0 API 冻结原则：新增功能只添加，不修改已有签名
   - 遵循五子包架构
   - 不破坏现有测试：所有现有测试必须继续通过
   - 构建验证：每轮完成后必须执行 `moon check --target native` 和 `moon test --target native` 验证
3. **T2 修正方向 3 原文**："pure 包暂不移除 native 限制（选项 b）...本轮核心价值是 types 包全目标可用 + core 包 re-export 机制验证 + pure 包主代码改用 types 验证 types 包可用；pure 包真正脱离 native（全目标编译）需确认 moon.pkg 条件依赖语法（主代码 import types 全目标 + 测试 `for "test"` import core native-only），留待下轮。"
4. **根包 `src/moon.pkg` 先例**（按文件限制目标）：
   ```
   options(
     targets: {
       "reexport.mbt": [ "native" ],
       "bench.mbt": [ "native" ],
       "roundtrip_test.mbt": [ "native" ],
       "README.mbt.md": [ "native" ],
     },
   )
   ```
5. **pure 包测试结构**（`bmp_decode_test.mbt` 132 行）：
   - 测试 1-4（第 35-85 行）：纯逻辑断言，不依赖 @core，全目标可用
   - 测试 5-6（第 88-107 行）：对比验证 `@core.load_from_bytes`，依赖 @core（native-only）
   - 测试 7-8（第 110-132 行）：错误路径 `@types.LoadError::DecodeFailed`，不依赖 @core，全目标可用
6. **pure 包当前 moon.pkg**：
   ```
   import {
     "MoonBit-Toadium/stb-image/src/types",
   }
   import {
     "MoonBit-Toadium/stb-image/src/core",
   } for "test"
   supported_targets = "native"
   ```

## 已有产出上下文
工作目录中已有的相关产出概述：

1. **T1 产出**（R3 PASSED）：`src/pure/` 包创建，`bmp_decode.mbt`（纯 MoonBit BMP 解码器，24/32-bit 无压缩，行填充+行序处理），`bmp_decode_test.mbt`（8 测试），签名 `pub fn decode_bmp_pure(data : Bytes) -> @core.Image raise @core.LoadError`
2. **T2 产出**（R5 PASSED）：
   - `src/types/moon.pkg`：全目标包，import 仅 `moonbitlang/core/debug`，无 `supported_targets`，无 C stub
   - `src/types/image_types.mbt`：6 个类型定义（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError），`pub(all)` 可见性，`derive(Eq, @debug.Debug)`
   - `src/core/moon.pkg`：增加 `import types`，保留 `supported_targets = "native"` 和 `native-stub: ["wrapper.c"]`
   - `src/core/image_types_reexport.mbt`：6 个 `pub type X = @types.X` re-export 声明
   - `src/pure/moon.pkg`：增加 `import types`（主代码），`@core` 改为 `for "test"`（测试对比），保留 `supported_targets = "native"`
   - `src/pure/bmp_decode.mbt`：主代码已改用 `@types.*`（函数签名 + raise 构造）
   - `src/pure/bmp_decode_test.mbt`：测试 7-8 错误路径已改用 `@types.LoadError::DecodeFailed`
3. **构建状态**：`moon check`（全目标）30 tasks 通过；`moon test --target native` 554/554 通过
4. **迭代计划**：ROADMAP.md v2.0 多目标支持（路径 A 双后端），当前进展 T1（概念验证）+ T2（类型分离）已完成，本轮 T3（pure 包全目标化）是下一逻辑节点
