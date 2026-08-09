# 执行审查报告（v1 r1）

## 审查结果
[APPROVED]

## 发现

### 任务覆盖度
- 14 项具体要求全部覆盖：目录结构（`src/pure/moon.pkg` + `bmp_decode.mbt` + `bmp_decode_test.mbt`）、函数签名 `pub fn decode_bmp_pure(data : Bytes) -> @core.Image raise @core.LoadError`、24-bit/32-bit 无压缩支持、BMP 文件头(14B)+DIB 头(40B) 解析、行填充 4 字节对齐、height>0 自下而上 / height<0 自上而下、RGB/RGBA 输出、中文错误消息、4 类纯逻辑测试、与 `@core.load_from_bytes` 对比测试、构建验证。
- 测试数量与 do_v1.md 声称一致：8 个测试（4 纯逻辑 + 2 对比 + 2 错误路径）。

### 构建与测试验证（独立复跑）
- `moon check --target native`：通过（Finished, no work to do —— 缓存命中，表明此前已成功检查）。
- `moon test --target native`：Total 554, passed 554, failed 0。未破坏现有测试，新增 8 个 pure 测试全通过。
- `load_from_bytes` 签名 `pub fn load_from_bytes(Bytes, req_channels? : Int?) -> Image raise LoadError` 与测试调用 `@core.load_from_bytes(bmp, req_channels=Some(3))` 匹配。

### 架构一致性
- `src/pure/moon.pkg` 与 `src/format/moon.pkg` 同构：`import @core` + `supported_targets = "native"`，符合本轮"pure 包暂设 native-only"的范围声明。
- 复用 `@core.Image` / `@core.LoadError`，与 `src/format/qoi.mbt` 模式一致，未引入新架构不一致。
- 未修改 `src/moon.pkg`，pure 包作为独立包存在，符合任务"可能需要"的可选语义。

### 代码正确性
- `read_i32_le` 利用 32 位有符号整数溢出环绕正确还原负值：height=-2（`FE FF FF FF`）经运算得 -2，测试 "top-down row order" 验证通过。
- 像素越界检查 `pixel_offset + bytes_per_pixel > len` 在读取前执行，无越界风险。
- BGR(A)→RGB(A) 转换正确，2x2 对比测试与 FFI 结果逐字段相等。
- 行填充 `row_size = ((abs_width * bytes_per_pixel + 3) / 4) * 4` 公式正确，2x2 24-bit 测试（row_size=8，实际像素 6 字节 + 2 字节填充）通过。

### 轻微问题（不影响正确性，不阻碍通过）
- **[轻微]** 未校验 `data_offset >= 54`：若 data_offset 异常偏小，会读取文件头/DIB 头作为像素数据，产生错误解码而非明确报错。但有逐像素越界检查兜底，不会崩溃；且正常 BMP 数据 data_offset=54，测试覆盖正确路径。
- **[轻微]** 未拒绝负 width：BMP 规范要求 width > 0，代码用 `abs_width` 容忍负 width。不会崩溃，但不严格符合规范。测试数据 width 均为正，不影响正确性。
- **[轻微]** `pixel_count = abs_width * abs_height` 对超大图像存在 32 位溢出风险，属边界情况，常规图像尺寸不会触发。
- **[轻微]** `read_i32_le` 命名暗示有符号，但用于 `data_offset`/`dib_size`/`compression` 等语义上非负的字段。功能正确，仅命名语义略宽。

## 修改要求（仅 REJECTED 时）
无（APPROVED）。
