---
name: stb-image
description: 基于 stb-image 自动生成的知识库 skill。Use when 查询 stb-image 知识、stb-image 文档、stb-image wiki、MoonBit 图像处理库。
version: "1.0.0"
template: basic
author: llm-wiki
triggers:
  - 查询 stb-image 知识
  - stb-image 文档
  - stb-image wiki
  - MoonBit 图像处理库
allowed-tools: Read
---

# stb-image 知识库

## Purpose

基于 `MoonBit-Toadium/stb-image` 仓库自动生成的知识库，将 stb-image 的知识结构化为可检索的 Wiki 文档，供大模型高效检索领域知识。

## 路由逻辑

用户查询 → 检索 references/ 下相关文档 → 返回知识内容

## 核心原则

🔒 基于 references 中的 Wiki 回答，不臆造
🔒 忠实提取：所有内容基于源仓库提取
🔒 结构优先：按目录结构检索对应主题

## 加载策略

- 查询项目概述 → `references/overview.md`
- 查询技术栈 → `references/tech-stack.md`
- 查询架构 → `references/architecture.md`
- 查询核心概念 → `references/concepts/*.md`
- 查询 API → `references/api/*.md`
- 查询使用方法 → `references/guides/*.md`
- 查询限制 → `references/reference/constraints.md`

## 知识索引

- [概述](./references/overview.md)
- [技术栈](./references/tech-stack.md)
- [架构设计](./references/architecture.md)
- [核心概念](./references/concepts/index.md)
  - [像素类型](./references/concepts/pixel-types.md)
  - [编解码](./references/concepts/encode-decode.md)
  - [格式检测](./references/concepts/format-detection.md)
  - [缩放](./references/concepts/resize.md)
  - [图像处理分类](./references/concepts/image-processing.md)
- [API 参考](./references/api/index.md)
  - [统一 API 层](./references/api/lib-api.md)
  - [Core API](./references/api/core-api.md)
  - [Pure API](./references/api/pure-api.md)
  - [Process API](./references/api/process-api.md)
- [使用指南](./references/guides/index.md)
  - [安装](./references/guides/installation.md)
  - [编解码流程](./references/guides/decode-encode.md)
  - [图像处理](./references/guides/processing.md)
  - [多目标支持](./references/guides/multi-target.md)
- [约束与限制](./references/reference/constraints.md)
