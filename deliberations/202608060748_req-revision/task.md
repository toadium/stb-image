# 任务：全面修订需求文档

## 修订对象
当前最终需求文档：`D:\CodeWorkspace\forMoonbit\stb-image\requirements\202608060700_stb-image-requirement\req_v2.md`

## 修订依据
前序审议式执行产出的审查报告：`D:\CodeWorkspace\forMoonbit\stb-image\deliberations\202608060736_req-v2-review\output_v1.md`

该审查报告对 req_v2.md 进行了 6 维度独立审查（完整性、准确性、自包含性、版本迭代计划合理性、可支撑下游设计、MoonBit v0.10.5 规范一致性），发现了若干需修订的问题。

## 修订要求
1. **逐项落实审查报告中的修订建议**：对 output_v1.md 中指出的每个问题，在 req_v2.md 中进行对应修订
2. **保持已通过部分的稳定性**：审查报告中确认无问题的部分应保留，不引入无关变更
3. **产出完整文档**：修订后的需求文档应为完整、自包含的文档（非 diff），可直接替代 req_v2.md 作为最终需求文档
4. **保留既有约束**：
   - "完整库"定位（非仅 MVP 读取）
   - "只参考，不引用已有库"（不得引用 mizchi/image 或任何已有库作为依赖、互补基准或对比对象）
   - MoonBit v0.10.5 最新规范（moon.mod/moon.pkg 新格式，preferred_target 下划线语法）
   - 版本迭代计划

## 上下文资源
- 审查报告：D:\CodeWorkspace\forMoonbit\stb-image\deliberations\202608060736_req-v2-review\output_v1.md
- 当前需求文档：D:\CodeWorkspace\forMoonbit\stb-image\requirements\202608060700_stb-image-requirement\req_v2.md
- 源码仓库：D:\CodeWorkspace\moonbit_wp
- 本地 image-mbt 仓库：D:\CodeWorkspace\forMoonbit\stb-image\image-mbt（仅作参考，不引用）
- MoonBit 官方文档：https://docs.moonbitlang.cn/
- stb_image.h 上游：https://github.com/nothings/stb
- 项目根：D:\CodeWorkspace\forMoonbit\stb-image

## 产出位置
修订后的需求文档写入：D:\CodeWorkspace\forMoonbit\stb-image\requirements\202608060700_stb-image-requirement\req_v3.md