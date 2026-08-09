# 检查报告（v1）

## 结果
PASSED

## 检查项
| 检查项 | 方法 | 结果 |
|--------|------|------|
| 目录结构 `src/pure/{codec,pixel,color,process,util}/` 创建 | `ls src/pure/{codec,pixel,color,process,util}/` 列目录 | 通过：含 `moon.pkg`、`bmp_decode.mbt`、`bmp_decode_test.mbt` 三个文件 |
| `moon.pkg` 配置 | 读取文件内容对比任务要求 | 通过：`import @core` + `supported_targets = "native"`，与 `src/format/moon.pkg` 同构 |
| 函数签名 | 读取 `bmp_decode.mbt:8` | 通过：`pub fn decode_bmp_pure(data : Bytes) -> @core.Image raise @core.LoadError`，与 `decode_qoi` 惯例一致 |
| 24-bit 无压缩 BMP 支持 | 代码审查 `bmp_decode.mbt:31-37` + 测试 `1x1 24-bit`、`2x2 24-bit` | 通过：bpp=24 走 channels=3 分支，BGR→RGB 转换正确 |
| 32-bit 无压缩 BMP 支持 | 代码审查 `bmp_decode.mbt:31-37,77-80` + 测试 `1x1 32-bit` | 通过：bpp=32 走 channels=4 分支，BGRA→RGBA 转换正确 |
| BMP 文件头（14B）+ DIB 头（40B）解析 | 代码审查 `bmp_decode.mbt:11-29` | 通过：校验 magic "BM"、data_offset、dib_size=40、width/height/bpp/compression |
| 行填充 4 字节对齐 | 代码审查 `bmp_decode.mbt:49` | 通过：`row_size = ((abs_width * bytes_per_pixel + 3) / 4) * 4`，2x2 24-bit 测试覆盖含填充场景 |
| 行序处理（height>0 自下而上，height<0 自上而下） | 代码审查 `bmp_decode.mbt:45,58-62` + 测试 `top-down row order` | 通过：`bottom_up = height > 0`，顶行红底行绿验证行序正确 |
| 失败路径统一 `raise @core.LoadError::DecodeFailed(...)` 中文消息 | 代码审查 `bmp_decode.mbt:12,16,22,32,36,40,67` + 测试 `invalid magic`、`too short` | 通过：数据过短/magic/DIB 头/位深/压缩/尺寸/越界 7 条路径均中文消息 |
| 测试 1：1x1 24-bit 纯逻辑断言 | 运行 `moon test --target native -p .../src/pure` | 通过 |
| 测试 2：2x2 24-bit 含行填充纯逻辑断言 | 同上 | 通过 |
| 测试 3：1x1 32-bit 纯逻辑断言 | 同上 | 通过 |
| 测试 4：自上而下行序（height<0）纯逻辑断言 | 同上 | 通过 |
| 测试 5-6：与 `@core.load_from_bytes` 对比验证（1x1 + 2x2 逐字段比较） | 代码审查 `bmp_decode_test.mbt:88-107` + 运行测试 | 通过：width/height/channels/data 四字段全比较 |
| 测试 7-8：错误路径（invalid magic + too short） | 代码审查 `bmp_decode_test.mbt:110-132` + 运行测试 | 通过：均 catch `DecodeFailed` |
| pure 包测试总数 | `moon test --target native -p .../src/pure` | 通过：8 个测试全部 passed |
| `moon check --target native` | 执行命令 | 通过：Finished. moon: no work to do |
| `moon test --target native`（全量） | 执行命令 | 通过：Total tests: 554, passed: 554, failed: 0 |
| 不破坏现有测试 | 全量 554 测试 0 失败 | 通过：现有测试全部继续通过，新增 8 个 pure 测试 |

## 总结
产出完整满足 task_v1.md 全部具体要求：三件产出文件齐备且配置正确；BMP 解码器正确支持 24/32-bit 无压缩格式，行填充与行序处理逻辑正确，失败路径统一以中文消息 `raise @core.LoadError::DecodeFailed`；8 个测试覆盖纯逻辑断言与 FFI 对比验证；`moon check` 与 `moon test --target native` 全量通过（554/554），未破坏任何现有测试。架构决策与审查修正方向一致（pure 包 native-only，复用 @core 类型，与 qoi 包同构）。执行报告中"原有测试 + 新增 8 个 pure 测试 = 554"的表述与实际一致（原有 546 + 新增 8 = 554，任务文件中 533 为更早基线值，不影响本轮结论）。
