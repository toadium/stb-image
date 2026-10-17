# imgir — 统一中间表示（GeoVerse Phase 3）

> **层级**：五层 · ImgIR 统一中间表示层
> **定位**：将图像操作、场操作、时空操作统一为 IR 管道，支持类型检查、序列化、执行。

## 核心思想

图像处理的本质是**数据流变换**。本模块将所有操作统一为 IR（中间表示）：

| IR 组件 | 含义 |
|---------|------|
| `IRValue` | 统一值类型（Image / ScalarField / VectorField / TImage / Float / Int / Unit） |
| `IROp` | 19 种操作枚举（图像 / 场 / 时空三大类） |
| `IRPipeline` | 线性管道 + 链式 Builder API |
| `ir_execute` | 管道执行器（操作分派 + 类型安全） |
| `ir_type_check` | 静态类型链检查 |
| `ir_serialize` | 二进制序列化（Float 缩放法，精度 1e-6） |

## 模块结构

| 文件 | 内容 |
|------|------|
| `ir_value.mbt` | IRValue 统一值类型 + type_tag / is_* / as_* 方法 |
| `ir_op.mbt` | IROp 操作枚举 + IRPipeline struct + tag / input_tag / output_tag |
| `ir_builder.mbt` | IRPipeline 链式 Builder API（19 个 builder 方法） |
| `ir_executor.mbt` | ir_execute_op / ir_execute / ir_type_check / ir_describe |
| `ir_serialize.mbt` | ir_serialize / ir_deserialize + 操作级序列化 |

## 公共 API

### 类型

- `IRValue` — 统一值类型（VImage / VScalarField / VVectorField / VTImage / VFloat / VInt / VUnit）
- `IROp` — 操作枚举（19 种：Resize / Rotate90 / FlipH / FlipV / Crop / ToGray / Brightness / GaussianBlur / BoxBlur / Sharpen / ToScalarField / FieldGradient / FieldLaplacian / FieldIntegrate / FieldClamp / FieldMask / ScalarFieldToImage / STSnapshot / STInterpolate）
- `IRPipeline` — 线性管道（ops : Array[IROp]）

### Builder API

```moonbit
let p = IRPipeline::new()
  .to_gray()
  .gaussian_blur(2, 1.0F)
  .sharpen(0.5F)
  .flip_h()
```

### 执行器

- `ir_execute(pipeline, value)` → IRValue — 执行管道
- `ir_type_check(pipeline, input_tag)` → String — 静态类型检查
- `ir_describe(pipeline)` → String — 可读描述

### 序列化

- `ir_serialize(pipeline)` → Bytes — 二进制序列化
- `ir_deserialize(bytes)` → IRPipeline — 反序列化

## 测试

40 个测试覆盖：IRValue 类型 / IROp 标签 / Builder / Executor / TypeCheck / Describe / Serializer 往返 / E2E 管道。