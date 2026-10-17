// ImgIR 操作类型 + 管道：统一图像/场/时空操作的表达式。
// IR operation types + pipeline: unified image/field/spatiotemporal operations.
//
// 操作分类：
//   图像变换: Resize / Rotate90 / FlipH / FlipV / Crop / ToGray
//   色彩调整: Brightness / GaussianBlur / BoxBlur / Sharpen
//   场操作:   ToScalarField / FieldGradient / FieldLaplacian / FieldIntegrate /
//             FieldClamp / FieldMask / ScalarFieldToImage
//   时空操作: STSnapshot / STInterpolate

///|
/// IR 操作：统一图像/场/时空操作枚举。
/// IR operation: unified image/field/spatiotemporal operation enum.
pub(all) enum IROp {
  // 图像变换
  Resize(Int, Int) // 缩放到 (w, h)
  Rotate90 // 旋转 90°
  FlipH // 水平翻转
  FlipV // 垂直翻转
  Crop(Int, Int, Int, Int) // 裁剪 (x, y, w, h)
  ToGray // 转灰度
  // 色彩/滤波
  Brightness(Int) // 亮度调整 delta
  GaussianBlur(Int, Float) // 高斯模糊 (radius, sigma)
  BoxBlur(Int) // 均值模糊 (radius)
  Sharpen(Float) // 锐化 (amount)
  // 场操作
  ToScalarField // Image → ScalarField
  FieldGradient // ScalarField → VectorField
  FieldLaplacian // ScalarField → ScalarField
  FieldIntegrate // ScalarField → Float
  FieldClamp(Float, Float) // ScalarField → ScalarField (lo, hi)
  FieldMask(Float) // ScalarField → ScalarField (threshold)
  ScalarFieldToImage // ScalarField → Image
  // 时空操作
  STSnapshot(Float) // TImage → Image (time)
  STInterpolate(Float) // TImage → Image (time)
} derive(Eq, @debug.Debug)

///|
pub extend IROp with @debug.Debug::{to_repr}

///|
pub extend IROp with Eq::{not_equal, equal}

///|
/// IR 管道：线性操作序列，按顺序执行。
/// IR pipeline: linear sequence of operations, executed in order.
pub(all) struct IRPipeline {
  ops : Array[IROp]
} derive(Eq, @debug.Debug)

///|
pub extend IRPipeline with @debug.Debug::{to_repr}

///|
pub extend IRPipeline with Eq::{not_equal, equal}

///|
/// 创建空管道。
/// Create an empty pipeline.
pub fn IRPipeline::new() -> IRPipeline {
  { ops: [], }
}

///|
/// 管道操作数。
/// Number of operations in the pipeline.
pub fn IRPipeline::length(self : IRPipeline) -> Int {
  self.ops.length()
}

///|
/// 追加操作到管道末尾，返回新管道。
/// Append an operation to the pipeline, returns a new pipeline.
pub fn IRPipeline::add(self : IRPipeline, op : IROp) -> IRPipeline {
  let new_ops = []
  for i in 0..<self.ops.length() {
    new_ops.push(self.ops[i])
  }
  new_ops.push(op)
  { ops: new_ops, }
}

///|
/// 获取操作类型标签字符串。
/// Get operation type tag string.
pub fn IROp::tag(self : IROp) -> String {
  match self {
    Resize(_, _) => "Resize"
    Rotate90 => "Rotate90"
    FlipH => "FlipH"
    FlipV => "FlipV"
    Crop(_, _, _, _) => "Crop"
    ToGray => "ToGray"
    Brightness(_) => "Brightness"
    GaussianBlur(_, _) => "GaussianBlur"
    BoxBlur(_) => "BoxBlur"
    Sharpen(_) => "Sharpen"
    ToScalarField => "ToScalarField"
    FieldGradient => "FieldGradient"
    FieldLaplacian => "FieldLaplacian"
    FieldIntegrate => "FieldIntegrate"
    FieldClamp(_, _) => "FieldClamp"
    FieldMask(_) => "FieldMask"
    ScalarFieldToImage => "ScalarFieldToImage"
    STSnapshot(_) => "STSnapshot"
    STInterpolate(_) => "STInterpolate"
  }
}

///|
/// 获取操作的输入类型标签。
/// Get expected input type tag for an operation.
pub fn IROp::input_tag(self : IROp) -> String {
  match self {
    Resize(_, _) => "Image"
    Rotate90 => "Image"
    FlipH => "Image"
    FlipV => "Image"
    Crop(_, _, _, _) => "Image"
    ToGray => "Image"
    Brightness(_) => "Image"
    GaussianBlur(_, _) => "Image"
    BoxBlur(_) => "Image"
    Sharpen(_) => "Image"
    ToScalarField => "Image"
    FieldGradient => "ScalarField"
    FieldLaplacian => "ScalarField"
    FieldIntegrate => "ScalarField"
    FieldClamp(_, _) => "ScalarField"
    FieldMask(_) => "ScalarField"
    ScalarFieldToImage => "ScalarField"
    STSnapshot(_) => "TImage"
    STInterpolate(_) => "TImage"
  }
}

///|
/// 获取操作的输出类型标签。
/// Get expected output type tag for an operation.
pub fn IROp::output_tag(self : IROp) -> String {
  match self {
    Resize(_, _) => "Image"
    Rotate90 => "Image"
    FlipH => "Image"
    FlipV => "Image"
    Crop(_, _, _, _) => "Image"
    ToGray => "Image"
    Brightness(_) => "Image"
    GaussianBlur(_, _) => "Image"
    BoxBlur(_) => "Image"
    Sharpen(_) => "Image"
    ToScalarField => "ScalarField"
    FieldGradient => "VectorField"
    FieldLaplacian => "ScalarField"
    FieldIntegrate => "Float"
    FieldClamp(_, _) => "ScalarField"
    FieldMask(_) => "ScalarField"
    ScalarFieldToImage => "Image"
    STSnapshot(_) => "Image"
    STInterpolate(_) => "Image"
  }
}
