# 安装

## 添加依赖

```bash
moon add toadium/image
```

## 构建与测试

```bash
moon check --target native     # 检查编译
moon test --target native      # 运行 847 个测试
moon bench --target native     # 运行 29 个基准测试
moon info                      # 重新生成 API 接口
```

## 下一步

<CardGrid :columns="2">
  <Card href="/guides/decode-encode" title="编解码流程" description="加载/写入/自动检测格式" icon="🔄" />
  <Card href="/guides/processing" title="图像处理" description="变换/滤波/边缘检测/分割" icon="🎨" />
  <Card href="/guides/multi-target" title="多目标支持" description="native/wasm/js 目标配置" icon="🌐" />
  <Card href="/api/" title="API 参考" description="完整 API 文档" icon="📚" />
</CardGrid>
