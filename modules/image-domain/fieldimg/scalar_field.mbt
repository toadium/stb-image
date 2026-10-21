// 标量场：2D 标量场，将每个点 (x, y) 映射到 Float 值。
// Scalar field: a 2D field mapping each point (x, y) to a Float value.
// 灰度图可视为 2D 标量场；场是一等几何对象。

///|
/// 标量场：2D 标量场，data 为行主序 Float 数组，长度 = width * height。
/// Scalar field: 2D scalar field, data is row-major Float array, length = width * height.
pub(all) struct ScalarField {
  width : Int32
  height : Int32
  data : Array[Float]
} derive(Eq, @debug.Debug)

///|
pub extend ScalarField with @debug.Debug::{to_repr}

///|
pub extend ScalarField with Eq::{not_equal, equal}

///|
/// 创建标量场，数据长度必须等于 width * height。
/// Create a scalar field; data length must equal width * height.
pub fn ScalarField::make(
  width : Int32,
  height : Int32,
  data : Array[Float],
) -> ScalarField raise @types.LoadError {
  if width <= 0 || height <= 0 {
    raise @types.LoadError::DecodeFailed(
      "ScalarField::make: width 和 height 必须大于0",
    )
  }
  if data.length() != width * height {
    raise @types.LoadError::DecodeFailed(
      "ScalarField::make: 数据长度必须等于 width * height",
    )
  }
  { width, height, data, }
}

///|
/// 创建全零标量场。
/// Create an all-zero scalar field.
pub fn ScalarField::zeros(
  width : Int32,
  height : Int32,
) -> ScalarField raise @types.LoadError {
  if width <= 0 || height <= 0 {
    raise @types.LoadError::DecodeFailed(
      "ScalarField::zeros: width 和 height 必须大于0",
    )
  }
  { width, height, data: Array::make(width * height, 0.0F), }
}

///|
/// 创建常量标量场（所有点值相同）。
/// Create a constant scalar field (all points share the same value).
pub fn ScalarField::constant(
  width : Int32,
  height : Int32,
  value : Float,
) -> ScalarField raise @types.LoadError {
  if width <= 0 || height <= 0 {
    raise @types.LoadError::DecodeFailed(
      "ScalarField::constant: width 和 height 必须大于0",
    )
  }
  { width, height, data: Array::make(width * height, value), }
}

///|
/// 求值：获取点 (x, y) 处的场值，边界外返回 0。
/// Evaluate the field at (x, y); returns 0 for out-of-bounds.
pub fn ScalarField::evaluate(self : ScalarField, x : Int32, y : Int32) -> Float {
  if x < 0 || x >= self.width || y < 0 || y >= self.height {
    return 0.0F
  }
  self.data[y * self.width + x]
}

///|
/// 求值（边界钳制）：边界外取最近边界点的值。
/// Evaluate with clamped boundary: out-of-bounds takes nearest edge value.
pub fn ScalarField::evaluate_clamped(
  self : ScalarField,
  x : Int32,
  y : Int32,
) -> Float {
  let cx = x.clamp(min=0, max=self.width - 1)
  let cy = y.clamp(min=0, max=self.height - 1)
  self.data[cy * self.width + cx]
}

///|
/// 设值：设置点 (x, y) 处的场值，越界则忽略。
/// Set the value at (x, y); out-of-bounds is ignored.
pub fn ScalarField::set(
  self : ScalarField,
  x : Int32,
  y : Int32,
  value : Float,
) -> Unit {
  if x < 0 || x >= self.width || y < 0 || y >= self.height {
    return
  }
  self.data[y * self.width + x] = value
}

///|
/// 场的像素总数。
/// Total number of points in the field.
pub fn ScalarField::size(self : ScalarField) -> Int32 {
  self.width * self.height
}

///|
/// 场的最小值。
/// Minimum value in the field.
pub fn ScalarField::min_value(self : ScalarField) -> Float {
  let mut m = self.data[0]
  for i in 1..<self.data.length() {
    if self.data[i] < m {
      m = self.data[i]
    }
  }
  m
}

///|
/// 场的最大值。
/// Maximum value in the field.
pub fn ScalarField::max_value(self : ScalarField) -> Float {
  let mut m = self.data[0]
  for i in 1..<self.data.length() {
    if self.data[i] > m {
      m = self.data[i]
    }
  }
  m
}
