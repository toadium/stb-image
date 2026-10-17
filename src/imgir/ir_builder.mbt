// ImgIR 管道构建器：链式 API 构建操作管道。
// IR pipeline builder: fluent API for constructing operation pipelines.
//
// 用法：
//   let p = IRPipeline::new()
//     .to_gray()
//     .gaussian_blur(2, 1.0F)
//     .sharpen(0.5F)
//   let result = ir_execute(p, IRValue::VImage(img))

///|
/// 追加 Resize 操作。
/// Append Resize operation.
pub fn IRPipeline::resize(self : IRPipeline, w : Int, h : Int) -> IRPipeline {
  self.add(Resize(w, h))
}

///|
/// 追加 Rotate90 操作。
/// Append Rotate90 operation.
pub fn IRPipeline::rotate_90(self : IRPipeline) -> IRPipeline {
  self.add(Rotate90)
}

///|
/// 追加 FlipH 操作。
/// Append FlipH operation.
pub fn IRPipeline::flip_h(self : IRPipeline) -> IRPipeline {
  self.add(FlipH)
}

///|
/// 追加 FlipV 操作。
/// Append FlipV operation.
pub fn IRPipeline::flip_v(self : IRPipeline) -> IRPipeline {
  self.add(FlipV)
}

///|
/// 追加 Crop 操作。
/// Append Crop operation.
pub fn IRPipeline::crop(
  self : IRPipeline,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> IRPipeline {
  self.add(Crop(x, y, w, h))
}

///|
/// 追加 ToGray 操作。
/// Append ToGray operation.
pub fn IRPipeline::to_gray(self : IRPipeline) -> IRPipeline {
  self.add(ToGray)
}

///|
/// 追加 Brightness 操作。
/// Append Brightness operation.
pub fn IRPipeline::brightness(self : IRPipeline, delta : Int) -> IRPipeline {
  self.add(Brightness(delta))
}

///|
/// 追加 GaussianBlur 操作。
/// Append GaussianBlur operation.
pub fn IRPipeline::gaussian_blur(
  self : IRPipeline,
  radius : Int,
  sigma : Float,
) -> IRPipeline {
  self.add(GaussianBlur(radius, sigma))
}

///|
/// 追加 BoxBlur 操作。
/// Append BoxBlur operation.
pub fn IRPipeline::box_blur(self : IRPipeline, radius : Int) -> IRPipeline {
  self.add(BoxBlur(radius))
}

///|
/// 追加 Sharpen 操作。
/// Append Sharpen operation.
pub fn IRPipeline::sharpen(self : IRPipeline, amount : Float) -> IRPipeline {
  self.add(Sharpen(amount))
}

///|
/// 追加 ToScalarField 操作。
/// Append ToScalarField operation.
pub fn IRPipeline::to_scalar_field(self : IRPipeline) -> IRPipeline {
  self.add(ToScalarField)
}

///|
/// 追加 FieldGradient 操作。
/// Append FieldGradient operation.
pub fn IRPipeline::field_gradient(self : IRPipeline) -> IRPipeline {
  self.add(FieldGradient)
}

///|
/// 追加 FieldLaplacian 操作。
/// Append FieldLaplacian operation.
pub fn IRPipeline::field_laplacian(self : IRPipeline) -> IRPipeline {
  self.add(FieldLaplacian)
}

///|
/// 追加 FieldIntegrate 操作。
/// Append FieldIntegrate operation.
pub fn IRPipeline::field_integrate(self : IRPipeline) -> IRPipeline {
  self.add(FieldIntegrate)
}

///|
/// 追加 FieldClamp 操作。
/// Append FieldClamp operation.
pub fn IRPipeline::field_clamp(
  self : IRPipeline,
  lo : Float,
  hi : Float,
) -> IRPipeline {
  self.add(FieldClamp(lo, hi))
}

///|
/// 追加 FieldMask 操作。
/// Append FieldMask operation.
pub fn IRPipeline::field_mask(
  self : IRPipeline,
  threshold : Float,
) -> IRPipeline {
  self.add(FieldMask(threshold))
}

///|
/// 追加 ScalarFieldToImage 操作。
/// Append ScalarFieldToImage operation.
pub fn IRPipeline::scalar_field_to_image(self : IRPipeline) -> IRPipeline {
  self.add(ScalarFieldToImage)
}

///|
/// 追加 STSnapshot 操作。
/// Append STSnapshot operation.
pub fn IRPipeline::st_snapshot(self : IRPipeline, time : Float) -> IRPipeline {
  self.add(STSnapshot(time))
}

///|
/// 追加 STInterpolate 操作。
/// Append STInterpolate operation.
pub fn IRPipeline::st_interpolate(
  self : IRPipeline,
  time : Float,
) -> IRPipeline {
  self.add(STInterpolate(time))
}

///|
/// 从操作列表构建管道。
/// Build a pipeline from a list of operations.
pub fn IRPipeline::from_ops(ops : Array[IROp]) -> IRPipeline {
  { ops, }
}
