# 任务：执行 stb-image 迭代计划

## 背景

当前项目为 `MoonBit-Toadium/stb-image`（v1.17.0），MoonBit 图像处理库。

上一轮已整理出迭代计划，位于：
`D:\CodeWorkspace\forTraeCN\stb-image\pdc\202608081117_iteration-plan\iteration_plan.md`

该计划包含多个版本的规划（v1.18、v1.19、v2.0 等），每个版本包含具体的功能项、实现方式、工作量评估、优先级等。

## 任务目标

根据迭代计划，逐步实现各版本的功能。采用 PDC 循环，每轮实现一个版本或一个版本中的一部分功能。

## 执行约束

1. **保持 v1.0 API 冻结原则**：新增功能只添加，不修改已有签名
2. **遵循五子包架构**：core（FFI+类型）/ process（图像处理）/ format（编解码）/ meta（元数据）/ util（工具）
3. **FFI 优先**：stb 库本身支持的功能优先通过 FFI 绑定
4. **纯 MoonBit 补齐**：stb 不支持的功能用纯 MoonBit 实现，放在单独包中
5. **测试先行**：每个新功能必须有测试 + ASan 验证（FFI 部分）
6. **不破坏现有测试**：所有现有 533 测试 + 29 基准测试必须继续通过
7. **构建验证**：每轮完成后必须执行 `moon check --target native` 和 `moon test --target native` 验证

## 工作流程

1. Planner 读取迭代计划，分解出当前轮次可执行的任务（task_v{N}.md）
2. Doer 根据任务文件实际编写代码（修改 src/ 下的文件、新增测试等）
3. Checker 验证构建和测试是否通过
4. 每轮完成后提交，进入下一轮

## 输出要求

- 代码修改直接在 src/ 下进行
- 每轮的执行报告写入 do_v{N}.md
- 每轮的检查报告写入 check_v{N}.md
- 计划文件 plan.md 记录整体进度
