# agent_kit — 自然语言 API（GeoVerse Phase 3）

> **层级**：六层 · Agent-Kit 自然语言接口
> **定位**：自然语言转 ImgIR 查询，"给这张图去噪并检测边缘" → 引擎原生算子。

## 核心思想

用户不需要知道 ImgIR 管道、场算子或时空操作的具体 API。Agent-Kit 将自然语言查询自动编译为 ImgIR 管道并执行：

```
"denoise and detect edges" → [Denoise, EdgeDetect] → GaussianBlur → ToScalarField → FieldGradient → 执行
```

## 模块结构

| 文件 | 内容 |
|------|------|
| `agent_intent.mbt` | Intent 枚举 + 关键词匹配（to_string/keyword/matches） |
| `agent_parser.mbt` | nl_parse — 自然语言 → 意图序列 + nl_describe |
| `agent_compiler.mbt` | compile — 意图序列 → IRPipeline + nl_to_pipeline/nl_to_description |
| `agent_kit.mbt` | 高层 API：nl_process/nl_process_value/nl_preview/nl_intents/nl_pipeline |

## 公共 API

### Intent

- `Intent::Denoise` / `EdgeDetect` / `Blur` / `Sharpen` / `Grayscale` / `Rotate` / `FlipH` / `FlipV` / `Identity`
- `Intent::matches(word)` → Bool — 关键词匹配

### 自然语言 API

```moonbit
let result = nl_process(image, "denoise and detect edges")
let preview = nl_preview("denoise sharpen flip")
let intents = nl_intents("grayscale blur")
```

- `nl_process(image, query)` → Image — 自然语言图像处理
- `nl_process_value(value, query)` → IRValue — 通用值处理
- `nl_preview(query)` → String — 预览查询描述
- `nl_intents(query)` → Array[Intent] — 提取意图
- `nl_pipeline(query)` → IRPipeline — 获取管道

## 测试

28 个测试覆盖：Intent/Parser/Compiler/高层API/E2E。