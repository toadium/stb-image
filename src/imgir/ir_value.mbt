// ImgIR 统一中间表示：IR 值类型。
// Unified IR value type: represents any intermediate value in the IR pipeline.
//
// 设计思想（GeoVerse 五层）：
//   所有图像、场、时空上下文统一编码为 IRValue，
//   支持算子序列化、JIT 编译、GPU 向量化执行、分布式任务分发。

///|
/// IR 值类型：统一中间表示，可持有 Image / ScalarField / VectorField / TImage / Float / Int。
/// IR value type: unified representation holding Image / ScalarField / VectorField / TImage / Float / Int.
pub(all) enum IRValue {
  VImage(@types.Image)
  VScalarField(@fieldimg.ScalarField)
  VVectorField(@fieldimg.VectorField)
  VTImage(@spatiotemporal.TImage)
  VFloat(Float)
  VInt(Int)
  VUnit
} derive(Eq, @debug.Debug)

///|
pub extend IRValue with @debug.Debug::{to_repr}

///|
pub extend IRValue with Eq::{not_equal, equal}

///|
/// IR 值类型标签：用于类型检查和序列化。
/// IR value type tag: for type checking and serialization.
pub fn IRValue::type_tag(self : IRValue) -> String {
  match self {
    VImage(_) => "Image"
    VScalarField(_) => "ScalarField"
    VVectorField(_) => "VectorField"
    VTImage(_) => "TImage"
    VFloat(_) => "Float"
    VInt(_) => "Int"
    VUnit => "Unit"
  }
}

///|
/// 判断 IR 值是否为 Image。
/// Check if IR value is an Image.
pub fn IRValue::is_image(self : IRValue) -> Bool {
  match self {
    VImage(_) => true
    _ => false
  }
}

///|
/// 判断 IR 值是否为 ScalarField。
/// Check if IR value is a ScalarField.
pub fn IRValue::is_scalar_field(self : IRValue) -> Bool {
  match self {
    VScalarField(_) => true
    _ => false
  }
}

///|
/// 判断 IR 值是否为 VectorField。
/// Check if IR value is a VectorField.
pub fn IRValue::is_vector_field(self : IRValue) -> Bool {
  match self {
    VVectorField(_) => true
    _ => false
  }
}

///|
/// 判断 IR 值是否为 TImage。
/// Check if IR value is a TImage.
pub fn IRValue::is_timage(self : IRValue) -> Bool {
  match self {
    VTImage(_) => true
    _ => false
  }
}

///|
/// 提取 Image 值，类型不匹配则抛异常。
/// Extract Image value; raises on type mismatch.
pub fn IRValue::as_image(self : IRValue) -> @types.Image raise @types.LoadError {
  match self {
    VImage(img) => img
    _ =>
      raise @types.LoadError::DecodeFailed(
        "IRValue::as_image: 类型不匹配，期望 Image，实际 " +
        self.type_tag(),
      )
  }
}

///|
/// 提取 ScalarField 值，类型不匹配则抛异常。
/// Extract ScalarField value; raises on type mismatch.
pub fn IRValue::as_scalar_field(
  self : IRValue,
) -> @fieldimg.ScalarField raise @types.LoadError {
  match self {
    VScalarField(f) => f
    _ =>
      raise @types.LoadError::DecodeFailed(
        "IRValue::as_scalar_field: 类型不匹配，期望 ScalarField，实际 " +
        self.type_tag(),
      )
  }
}

///|
/// 提取 VectorField 值，类型不匹配则抛异常。
/// Extract VectorField value; raises on type mismatch.
pub fn IRValue::as_vector_field(
  self : IRValue,
) -> @fieldimg.VectorField raise @types.LoadError {
  match self {
    VVectorField(f) => f
    _ =>
      raise @types.LoadError::DecodeFailed(
        "IRValue::as_vector_field: 类型不匹配，期望 VectorField，实际 " +
        self.type_tag(),
      )
  }
}

///|
/// 提取 TImage 值，类型不匹配则抛异常。
/// Extract TImage value; raises on type mismatch.
pub fn IRValue::as_timage(
  self : IRValue,
) -> @spatiotemporal.TImage raise @types.LoadError {
  match self {
    VTImage(ti) => ti
    _ =>
      raise @types.LoadError::DecodeFailed(
        "IRValue::as_timage: 类型不匹配，期望 TImage，实际 " +
        self.type_tag(),
      )
  }
}

///|
/// 提取 Float 值，类型不匹配则抛异常。
/// Extract Float value; raises on type mismatch.
pub fn IRValue::as_float(self : IRValue) -> Float raise @types.LoadError {
  match self {
    VFloat(v) => v
    _ =>
      raise @types.LoadError::DecodeFailed(
        "IRValue::as_float: 类型不匹配，期望 Float，实际 " +
        self.type_tag(),
      )
  }
}
