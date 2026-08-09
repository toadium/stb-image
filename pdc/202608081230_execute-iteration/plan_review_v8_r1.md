# 计划审查报告（v8 r1）

## 审查结果
REJECTED

## 发现
- **[一般]** 错误路径测试覆盖与实现要求不一致：task_v8.md line 32-41 明确列出 9 种错误路径（数据过短、signature 错误、version 错误、不支持的 channelCount、不支持的 bitdepth、不支持的 colorMode、不支持的 compression、尺寸无效、像素数据不足），但 line 47-55 的 8 个测试用例仅覆盖 4 种错误路径（测试 5 bad signature、测试 6 too short、测试 7 unsupported bitdepth、测试 8 unsupported compression），遗漏 5 种错误路径测试：version 错误（line 34）、不支持的 channelCount（line 36，如 channelCount=1 灰度或 5）、不支持的 colorMode（line 38，如 colorMode=1 Grayscale）、尺寸无效（line 40，w=0 或 h=0）、像素数据不足（line 41，剩余字节 < channelCount * w * h）。line 32-41 与 line 47-55 同一文档内对错误路径枚举不一致，Doer 按 line 47-55 测试列表实现会遗漏 5 种错误路径验证，这些分支（version 校验、channelCount 校验、colorMode 校验、尺寸校验、像素数据量校验）未被测试则正确性无保证。此问题与 T6（TGA）R11 RETRY（plan.md line 199-206）同类：T6 因 line 16 列 3 种错误路径而 line 25 测试建议仅列 2 种、遗漏"不支持的 bpp"被 REJECTED；T8 遗漏 5 种错误路径测试，问题更严重。

- **[轻微]** 预期测试数与错误路径测试扩充后不一致：line 67 预期 native 582→592（+8 pure 纯逻辑 + 2 根包对比），若按修正方向补充错误路径测试，pure 纯逻辑测试数将超过 8，预期数需同步调整。当前 line 47 硬性限定"8 个测试用例"与 line 32-41 的 9 种错误路径存在内部约束冲突，无法在 8 个测试内既覆盖 4 正例（RGB/RGBA/交错/1x1）又覆盖 9 种错误路径。

## 修改要求

### 问题 1：错误路径测试覆盖与实现要求不一致
**问题是什么**：task_v8.md line 32-41 列出 9 种错误路径作为解码器实现要求，但 line 47-55 的 8 个测试用例仅覆盖 4 种错误路径（signature、too short、bitdepth、compression），遗漏 5 种（version、channelCount、colorMode、尺寸无效、像素数据不足）。line 47 硬性限定"8 个测试用例"与 line 32-41 的 9 种错误路径无法兼容（4 正例 + 9 错误路径 = 13 测试 > 8）。

**为什么是问题**：错误路径是解码器健壮性关键组成，未测试的分支无法验证正确性。version 错误（PSD version=2 存在）、channelCount 错误（PSD 支持 1-56 通道）、colorMode 错误（Grayscale/Index/CMYK 等）、尺寸无效（w=0/h=0）、像素数据不足（截断文件）均为现实可能输入，拒绝逻辑未验证则解码器可能接受非法输入或崩溃。与 T6 R11 RETRY 先例一致，同文档内错误路径枚举不一致应修正。

**期望的修正方向**：
1. **调整 pure 包纯逻辑测试数**：从 8 个增加到 12-13 个，覆盖 4 正例 + 全部 9 种错误路径（或至少覆盖关键错误路径：version、channelCount、colorMode、尺寸无效、像素数据不足）。参考 T6 R11 RETRY 修正先例（plan.md line 202-205，测试数建议从 7-9 调整到 8-10）。
2. **line 47-55 测试用例补充**：在现有 8 测试基础上新增错误路径测试：
   - `bad version raises`：version=2，验证报错
   - `unsupported channelCount raises`：channelCount=1（灰度）或 5，验证报错
   - `unsupported colorMode raises`：colorMode=1（Grayscale），验证报错
   - `invalid dimensions raises`：w=0 或 h=0，验证报错
   - `pixel data insufficient raises`：像素数据截断（剩余字节 < channelCount * w * h），验证报错
3. **line 67 预期 native 测试数同步调整**：原"582→592（+8 pure 纯逻辑 + 2 根包对比）" → "582→596-597（+12-13 pure 纯逻辑 + 2 根包对比）"，具体数取决于补充的错误路径测试数。
4. **line 47 测试数表述调整**：原"8 个测试用例" → "12-13 个测试用例（4 正例 + 8-9 错误路径）"。

### 问题 2：预期测试数与测试扩充后不一致
**问题是什么**：line 67 预期 582→592 基于 8 个 pure 纯逻辑测试，若按问题 1 修正方向补充错误路径测试，pure 纯逻辑测试数增加，预期数需同步调整。

**为什么是问题**：预期测试数不准确会导致 Checker 验证时误判（如 Checker 按 592 验证但实际 596，会误报失败或遗漏）。

**期望的修正方向**：随问题 1 修正同步调整 line 67 预期数，确保与补充后的测试数一致。
