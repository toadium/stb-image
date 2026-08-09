# 像素类型

三种像素类型，均含 `width/height/channels/data:Bytes` 字段：

<CardGrid :columns="3">
  <Card href="/api/core-api" title="Image" description="8-bit 无符号，1 字节/像素，常规 LDR 图像" icon="📷" badge="常用" />
  <Card href="/api/core-api" title="Image16" description="16-bit 无符号，2 字节/像素，高位深图像" icon="🖼️" />
  <Card href="/api/core-api" title="ImageF" description="32-bit IEEE float，4 字节/像素，HDR 图像" icon="🌅" />
</CardGrid>

## 辅助类型

| 类型 | 字段 | 用途 |
|------|------|------|
| `ImageInfo` | `width/height/channels` | 不解码像素仅读取信息 |
| `GifAnimation` | `frames: Array[Image]` + `delays: Array[Int]` | GIF 动画（延迟毫秒） |
| `LoadError` | `FileIO` / `UnsupportedFormat` / `DecodeFailed` | 错误类型 |

## 错误处理

```moonbit
try {
  let img = load_from_bytes(data)
} catch {
  LoadError::FileIO(msg) => ...
  LoadError::DecodeFailed(msg) => ...
  LoadError::UnsupportedFormat(msg) => ...
}
```

::: tip 提示
`UnsupportedFormat` 与 `DecodeFailed` 无法精确区分，stb 返回 NULL 默认 `DecodeFailed`，可用 `failure_reason()` 获取内部错误字符串。
:::

<ActionButton href="/api/core-api" text="查看 Core API" type="brand" />
<ActionButton href="/concepts/encode-decode" text="编解码概念" type="alt" />
