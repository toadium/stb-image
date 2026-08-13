# 项目申报书：stb-image — 纯 MoonBit 图像处理库

## 一、项目现有基础说明

本项目已完成 **v4.8.0** 版本，具备以下基础：

- **代码规模**：~24,000 行有效 MoonBit 代码，283 个公开 API + 47 个公开类型
- **格式覆盖**：15 种图像格式编解码（PNG/JPEG/BMP/GIF/QOI/TGA/PSD/HDR/PNM/TIFF/ICO/CUR/ICNS/APNG/WebP）
- **多目标支持**：native / wasm-gc / js / wasm 四目标共用同一套纯 MoonBit 代码，各 1177 个测试全部通过
- **测试覆盖**：1177 × 4 = 4708 个测试，覆盖率 90.4%
- **高级算法**：50+ 计算机视觉算法（Canny/Harris/ORB/SIFT/模板匹配/光流/RANSAC/grabCut/分水岭/SLIC/FFT/DCT/Haar小波/Retinex/去雾/图像修复等）
- **CI/CD**：GitHub Actions 四目标 check + test + bench
- **mooncakes.io 发布**：`moon publish --dry-run` 验证通过
- **许可证**：MIT
- **提交记录**：131 次，开发过程完整可追踪

## 二、本次计划开发或新增的内容

本次 8 月黑客松期间，在已有基础上完成以下合规性优化和功能完善：

1. **mooncakes.io 发布合规** — 修复 moon.mod 版本号（`3.0.0` → `0.4.8`），重构 testdata 依赖使 `moon publish --dry-run` 通过
2. **边界测试补充** — 新增 38 个边界/错误路径测试（GIF 动画 roundtrip、TIFF/PNG 错误路径、zlib fixed Huffman），覆盖率从 88.x% 提升至 90.4%
3. **示例代码完善** — 新增 13 个示例测试覆盖 WebP/流式/SIFT/ORB/修复/光流/grabCut/Retinex/去雾/FFT/质量评估/安全解码
4. **文档优化** — README 补充移植说明章节，所有文档同步更新至 1177 测试
5. **一页申报书** — 本文档

## 三、项目预期目标和技术路线

### 预期目标

- ✅ mooncakes.io 发布合规（版本号、依赖、`moon publish --dry-run` 通过）
- ✅ 四目标 1177 测试全部通过
- ✅ 覆盖率 ≥ 90%
- ✅ README 清晰完整，含移植说明
- ✅ CI 持续集成配置
- ✅ 可运行示例
- ✅ 明确功能边界和维护价值

### 技术路线

```
纯 MoonBit 实现（零 C FFI）
        │
        ├── types/     → 全目标类型定义（Image/Image16/ImageF/LoadError）
        ├── pure/      → 纯后端编解码（15 格式）+ 颜色操作 + 工具
        ├── lib/       → 高层封装（自动格式分派）+ 流式解码
        ├── meta/      → 元数据（EXIF/PNG meta）
        ├── process/   → 高级算法（7 子包：color/edge/feature/filter/frequency/segment/transform）
        ├── util/      → 工具函数
        └── reexport   → 顶层 API 统一导出（283 pub fn + 47 pub type）
```

**核心设计决策**：
- 四目标共用同一代码库，不使用条件编译
- 多子包架构，编译并行化
- `pub(all)` 类型对外可构造，普通 `pub` 仅暴露函数
- 流式解码支持逐行/分块回调，大图零内存峰值

## 四、预计完成的功能、测试和文档

| 类别 | 状态 | 数量 |
|------|------|------|
| 格式编解码 | ✅ 已完成 | 15 种 |
| 公开 API | ✅ 已完成 | 283 函数 + 47 类型 |
| 测试 | ✅ 已完成 | 1177 × 4 目标 |
| 覆盖率 | ✅ 已完成 | 90.4% |
| 示例 | ✅ 已完成 | 32 个示例测试 |
| CI/CD | ✅ 已完成 | GitHub Actions 四目标 |
| 文档 | ✅ 已完成 | README + 8 个文档 + API 参考 |
| mooncakes.io 发布 | ✅ 已验证 | `moon publish --dry-run` 通过 |

## 五、移植说明

### 原项目信息

| 属性 | 值 |
|------|-----|
| 原项目 | [stb](https://github.com/nothings/stb) — `stb_image.h` |
| 原项目链接 | <https://github.com/nothings/stb> |
| 原作者 | Sean Barrett (@nothings) |
| 原许可证 | MIT / Public Domain |
| 原语言 | C（单头文件库） |

### 移植范围

以 `stb_image.h` 为参考基础，将其核心图像编解码能力用纯 MoonBit 重新实现：

- **格式编解码**：PNG / JPEG / BMP / GIF / QOI / TGA / PSD / HDR / PNM / TIFF / ICO / CUR / ICNS / APNG / WebP
- **像素深度**：8 位 `Image`、16 位 `Image16`、HDR 浮点 `ImageF`
- **基础操作**：缩放 / 裁剪 / 旋转 / 翻转 / 色彩转换 / 通道操作 / 绘制 / 合成

### 超越原项目的扩展

在移植基础上新增了原 `stb_image.h` 不具备的高级能力：流式解码、50+ 计算机视觉算法（Canny/Harris/ORB/SIFT/光流/RANSAC/grabCut/分水岭/SLIC/FFT/DCT/Haar小波/Retinex/去雾/图像修复等）、WebP lossy (VP8) 编码。

### 许可证兼容性

原项目 MIT / Public Domain 许可证允许移植和再分发。本项目以 MIT 许可证开源，与原项目兼容。
