# 多目标支持

## Native（C FFI）

- 首选目标，通过 C FFI 调用 stb 库
- 支持 10+ 格式解码 / 8 格式编码
- `src/core/` 的 `supported_targets = "native"`

```bash
moon test --target native
```

## Wasm/JS（纯 MoonBit）

- 使用 `src/pure/` + `src/lib/` 纯 MoonBit 后端
- 支持 6 解码器（BMP/QOI/TGA/PNM/PSD/GIF）+ 3 编码器（QOI/PNM/GIF）
- 图像处理功能子集

```bash
moon test --target wasm
moon test --target js
```

## 统一 API

- `src/lib/lib.mbt` 提供格式自动检测 + 编解码委托
- `src/reexport.mbt` 将 199 个函数 + 29 个类型重导出到根包
- 用户可直接从 `toadium/image` 导入所有 API
