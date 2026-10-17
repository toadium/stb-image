// ImgIR 执行器：在 IR 值上按顺序执行管道操作。
// IR executor: executes pipeline operations on IR values in order.
//
// 执行规则：
//   Image 操作要求输入为 IRValue::VImage
//   Field 操作要求输入为 IRValue::VScalarField（ToScalarField 除外，它要求 VImage）
//   ST 操作要求输入为 IRValue::VTImage
//   类型不匹配时抛 LoadError::DecodeFailed

///|
/// 执行单个操作：根据操作类型变换 IR 值。
/// Execute a single operation: transform IR value according to operation type.
pub fn ir_execute_op(
  op : IROp,
  input : IRValue,
) -> IRValue raise @types.LoadError {
  match op {
    // === 图像变换 ===
    Resize(w, h) => {
      let img = input.as_image()
      let resized = @pure_util.resize_pure(img, w, h)
      VImage(resized)
    }
    Rotate90 => {
      let img = input.as_image()
      VImage(@transform.rotate_90(img))
    }
    FlipH => {
      let img = input.as_image()
      VImage(@transform.flip_horizontal(img))
    }
    FlipV => {
      let img = input.as_image()
      VImage(@transform.flip_vertical(img))
    }
    Crop(x, y, w, h) => {
      let img = input.as_image()
      VImage(@transform.crop(img, x, y, w, h))
    }
    ToGray => {
      let img = input.as_image()
      VImage(@color.to_grayscale(img))
    }
    // === 色彩/滤波 ===
    Brightness(delta) => {
      let img = input.as_image()
      VImage(@color.adjust_brightness(img, delta))
    }
    GaussianBlur(radius, sigma) => {
      let img = input.as_image()
      VImage(@filter.gaussian_blur(img, radius, sigma))
    }
    BoxBlur(radius) => {
      let img = input.as_image()
      VImage(@filter.box_blur(img, radius))
    }
    Sharpen(amount) => {
      let img = input.as_image()
      VImage(@filter.sharpen(img, amount))
    }
    // === 场操作 ===
    ToScalarField => {
      let img = input.as_image()
      VScalarField(@fieldimg.image_to_scalar_field(img))
    }
    FieldGradient => {
      let f = input.as_scalar_field()
      VVectorField(@fieldimg.field_gradient(f))
    }
    FieldLaplacian => {
      let f = input.as_scalar_field()
      VScalarField(@fieldimg.field_laplacian(f))
    }
    FieldIntegrate => {
      let f = input.as_scalar_field()
      VFloat(@fieldimg.field_integrate(f))
    }
    FieldClamp(lo, hi) => {
      let f = input.as_scalar_field()
      VScalarField(@fieldimg.field_clamp(f, lo, hi))
    }
    FieldMask(threshold) => {
      let f = input.as_scalar_field()
      VScalarField(@fieldimg.field_mask(f, threshold))
    }
    ScalarFieldToImage => {
      let f = input.as_scalar_field()
      VImage(@fieldimg.scalar_field_to_image(f))
    }
    // === 时空操作 ===
    STSnapshot(time) => {
      let ti = input.as_timage()
      VImage(@spatiotemporal.st_snapshot(ti, time))
    }
    STInterpolate(time) => {
      let ti = input.as_timage()
      VImage(@spatiotemporal.st_interpolate_at(ti, time))
    }
  }
}

///|
/// 执行管道：按顺序在输入值上执行所有操作。
/// Execute pipeline: run all operations in order on the input value.
pub fn ir_execute(
  pipeline : IRPipeline,
  input : IRValue,
) -> IRValue raise @types.LoadError {
  let mut current = input
  for i in 0..<pipeline.ops.length() {
    current = ir_execute_op(pipeline.ops[i], current)
  }
  current
}

///|
/// 类型检查：验证管道在给定输入类型下是否类型安全。
/// Type check: verify pipeline is type-safe for the given input type.
/// 返回最终输出类型标签，或在不匹配处抛异常。
pub fn ir_type_check(
  pipeline : IRPipeline,
  input_tag : String,
) -> String raise @types.LoadError {
  let mut current_tag = input_tag
  for i in 0..<pipeline.ops.length() {
    let op = pipeline.ops[i]
    let expected = op.input_tag()
    if current_tag != expected {
      raise @types.LoadError::DecodeFailed(
        "ir_type_check: 操作 " +
        op.tag() +
        " 期望输入 " +
        expected +
        "，实际 " +
        current_tag,
      )
    }
    current_tag = op.output_tag()
  }
  current_tag
}

///|
/// 管道描述：生成人类可读的操作序列描述。
/// Pipeline description: generate human-readable operation sequence.
pub fn ir_describe(pipeline : IRPipeline) -> String {
  if pipeline.ops.length() == 0 {
    return "empty pipeline"
  }
  let mut desc = ""
  for i in 0..<pipeline.ops.length() {
    let op = pipeline.ops[i]
    if i > 0 {
      desc = desc + " → "
    }
    desc = desc + op.tag()
  }
  desc
}
