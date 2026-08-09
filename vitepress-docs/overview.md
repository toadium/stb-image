# 概述

## image

MoonBit 图像处理库，封装 stb_image.h v2.30 + stb_image_write.h v1.16 + stb_image_resize2.h v2.07。

- **模块名**：`Toadium/image`（发布包 `toadium/image`）
- **版本**：2.0.0
- **许可证**：MIT（stb 头文件属公共领域）

## 核心特性

<CardGrid :columns="3">
  <Card href="/guides/multi-target" title="多目标支持" description="native C FFI + wasm/js 纯 MoonBit" icon="🌐" />
  <Card href="/concepts/encode-decode" title="10+ 格式解码" description="PNG/JPEG/BMP/GIF/TGA/PSD/HDR/PNM/QOI" icon="📦" />
  <Card href="/concepts/encode-decode" title="8 格式编码" description="PNG/BMP/TGA/JPEG/HDR/ICO/ICNS + QOI/PNM/GIF" icon="💾" />
  <Card href="/concepts/image-processing" title="图像处理全套" description="变换/色彩/滤波/边缘/特征/频域/分割" icon="🎨" />
  <Card href="/concepts/pixel-types" title="三种像素类型" description="Image（8-bit）/ Image16（16-bit）/ ImageF（HDR）" icon="🖼️" />
  <Card href="/concepts/resize" title="7 种缩放滤波器" description="× 4 种边缘模式，支持 8/16/float/sRGB" icon="📐" />
  <Card href="/api/" title="199 公开函数" description="+ 29 类型（native），78 pub fn（pure）" icon="📚" />
  <Card href="/tech-stack" title="847 测试全通过" description="+ 29 基准测试，AddressSanitizer 验证" icon="✅" />
  <Card href="/reference/constraints" title="已知限制" description="I/O 回调/零拷贝/格式覆盖" icon="⚠️" badge="注意" />
</CardGrid>

## 快速开始

<ActionButton href="/guides/installation" text="安装指南" type="brand" size="large" />
<ActionButton href="/guides/decode-encode" text="编解码流程" type="alt" size="large" />
<ActionButton href="https://github.com/Toadium/image" text="GitHub" type="subtle" size="large" external />
