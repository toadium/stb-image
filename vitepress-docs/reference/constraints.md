# 约束与限制

| 限制 | 说明 |
|------|------|
| **I/O 回调未实现** | `stbi_io_callbacks` 未实现，MoonBit FFI 不支持闭包作为 C 函数指针 |
| **零拷贝未实现** | 所有加载路径通过 `memcpy` 复制像素数据，C 侧分配后立即释放 |
| **目标平台差异** | native（C FFI，10+ 格式）vs wasm/js（纯 MoonBit，6 解码器 + 3 编码器） |
| **错误区分不精确** | `UnsupportedFormat` 与 `DecodeFailed` 无法精确区分，stb 返回 NULL 默认 `DecodeFailed` |
| **pure 后端格式有限** | PNG/JPEG/HDR/WebP 在 wasm/js 下不可用；P1-P4 ASCII PNM 不支持 |
| **TGA 自动检测不可用** | TGA 无固定 magic bytes，需显式调用 `@codec.decode_tga_pure` |
| **FFI 仅 native** | `src/core/` 的 `supported_targets = "native"`，wasm/js 不能使用 core 包 |
