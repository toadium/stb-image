# 任务：全面修订技术方案文档

## 修订对象
当前技术方案文档：`D:\CodeWorkspace\forMoonbit\stb-image\designs-tech\202608060929_stb-image-tech-design\tech_v1.md`

## 修订依据
前序审议式执行产出的审查报告：`D:\CodeWorkspace\forMoonbit\stb-image\deliberations\202608060953_tech-v1-review\output_v1.md`

该审查报告对 tech_v1.md 进行了 8 维度独立审查，发现了若干需修订的问题。

## 修订要求
1. **逐项落实审查报告中的修订建议**：对 output_v1.md 中指出的每个问题，在 tech_v1.md 中进行对应修订
2. **保持已通过部分的稳定性**：审查报告中确认无问题的部分应保留，不引入无关变更
3. **产出完整文档**：修订后的技术方案文档应为完整、自包含的文档（非 diff），可直接替代 tech_v1.md 作为最终技术方案
4. **保留既有约束**：
   - 技术方案级别定位（落实到库和技术路径级别，非过多实现细节）
   - "只参考，不引用已有库"
   - MoonBit v0.10.5 最新规范
   - FFI 最佳实践（#borrow、moonbit_make_bytes、MOONBIT_FFI_EXPORT 等）
   - 版本迭代技术支撑

## 上下文资源
- 审查报告：D:\CodeWorkspace\forMoonbit\stb-image\deliberations\202608060953_tech-v1-review\output_v1.md
- 当前技术方案文档：D:\CodeWorkspace\forMoonbit\stb-image\designs-tech\202608060929_stb-image-tech-design\tech_v1.md
- 需求文档：D:\CodeWorkspace\forMoonbit\stb-image\req.md
- 架构设计文档：D:\CodeWorkspace\forMoonbit\stb-image\designs-oo\202608060801_stb-image-arch-design\design_v3.md
- 源码仓库：D:\CodeWorkspace\moonbit_wp
- 本地 image-mbt 仓库：D:\CodeWorkspace\forMoonbit\stb-image\image-mbt（仅作参考，不引用）
- MoonBit 官方文档：https://docs.moonbitlang.cn/
- MoonBit wiki 知识库：D:\CodeWorkspace\forMoonbit\moonbit_wiki\
- stb_image.h 上游：https://github.com/nothings/stb
- 项目根：D:\CodeWorkspace\forMoonbit\stb-image

## 产出位置
修订后的技术方案文档写入：D:\CodeWorkspace\forMoonbit\stb-image\designs-tech\202608060929_stb-image-tech-design\tech_v2.md