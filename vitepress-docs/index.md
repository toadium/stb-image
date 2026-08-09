---
layout: home

hero:
  name: "image"
  text: "MoonBit 图像处理库"
  tagline: "封装 stb_image.h v2.30 + stb_image_write.h v1.16 + stb_image_resize2.h v2.07，支持 native/wasm/js 多目标"
  actions:
    - theme: brand
      text: 快速开始
      link: /guides/installation
    - theme: alt
      text: API 参考
      link: /api/
    - theme: alt
      text: GitHub
      link: https://github.com/Toadium/image

features:
  - title: 多目标支持
    details: native 目标使用 C FFI（stb_image），wasm/js 目标使用纯 MoonBit 后端
    icon: 🌐
    link: /guides/multi-target
  - title: 10+ 格式解码
    details: PNG/JPEG/BMP/GIF/TGA/PSD/HDR/PNM/QOI（native）；BMP/QOI/TGA/PNM/PSD/GIF（pure）
    icon: 📦
    link: /concepts/encode-decode
  - title: 图像处理全套
    details: 变换/色彩/滤波/边缘/特征/频域/分割/形态学/直方图/混合模式
    icon: 🎨
    link: /concepts/image-processing
  - title: 三种像素类型
    details: Image（8-bit）、Image16（16-bit）、ImageF（HDR float）
    icon: 🖼️
    link: /concepts/pixel-types
  - title: 7 种缩放滤波器
    details: Box/Triangle/CubicBSPline/CatmullROM/Mitchell/PointSample × 4 种边缘模式
    icon: 📐
    link: /concepts/resize
  - title: 847 测试全通过
    details: 199 公开函数 + 29 类型，AddressSanitizer 验证
    icon: ✅
    link: /tech-stack
---

## 架构概览

```mermaid
graph TD
    A[用户代码] --> B{目标平台}
    B -->|native| C[src/core/]
    B -->|wasm/js| D[src/lib/]
    C --> E[C FFI]
    E --> F[stb_image.h]
    F --> G[memcpy → MoonBit Bytes]
    D --> H[src/pure/{codec,pixel,color,process,util}/]
    H --> I[纯 MoonBit 编解码]
    G --> J[图像处理]
    I --> J
```

## 快速导航

<CardGrid :columns="3">
  <Card href="/overview" title="概述" description="项目简介与核心特性" icon="📋" />
  <Card href="/tech-stack" title="技术栈" description="MoonBit + C FFI 技术详情" icon="🔧" />
  <Card href="/architecture" title="架构设计" description="子包结构与依赖关系" icon="🏗️" />
  <Card href="/concepts/pixel-types" title="核心概念" description="像素类型、编解码、格式检测" icon="💡" />
  <Card href="/api/" title="API 参考" description="lib/core/pure/process 完整 API" icon="📚" />
  <Card href="/guides/installation" title="使用指南" description="安装、编解码、图像处理" icon="🚀" />
  <Card href="/guides/decode-encode" title="编解码流程" description="加载/写入/自动检测" icon="🔄" />
  <Card href="/guides/processing" title="图像处理" description="变换/滤波/边缘/分割" icon="🎨" />
  <Card href="/reference/constraints" title="约束与限制" description="已知限制与注意事项" icon="⚠️" />
</CardGrid>
