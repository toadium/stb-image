// 矢量场：2D 矢量场，每个点 (x, y) 映射到 dim 维 Float 矢量。
// Vector field: 2D vector field, each point (x, y) maps to a dim-dimensional Float vector.
// RGB 图可视为 2D 矢量场（dim=3）；梯度场 dim=2。

///|
/// 矢量场：2D 矢量场，data 为行主序 Float 数组，长度 = width * height * dim。
/// Vector field: 2D vector field, data is row-major, length = width * height * dim.
pub(all) struct VectorField {
  width : Int32
  height : Int32
  dim : Int32
  data : Array[Float]
} derive(Eq, @debug.Debug)

///|
pub extend VectorField with @debug.Debug::{to_repr}

///|
pub extend VectorField with Eq::{not_equal, equal}

///|
/// 创建矢量场，数据长度必须等于 width * height * dim。
/// Create a vector field; data length must equal width * height * dim.
pub fn VectorField::make(
  width : Int32,
  height : Int32,
  dim : Int32,
  data : Array[Float],
) -> VectorField raise @types.LoadError {
  if width <= 0 || height <= 0 || dim <= 0 {
    raise @types.LoadError::DecodeFailed(
      "VectorField::make: width, height, dim 必须大于0",
    )
  }
  if data.length() != width * height * dim {
    raise @types.LoadError::DecodeFailed(
      "VectorField::make: 数据长度必须等于 width * height * dim",
    )
  }
  { width, height, dim, data, }
}

///|
/// 创建全零矢量场。
/// Create an all-zero vector field.
pub fn VectorField::zeros(
  width : Int32,
  height : Int32,
  dim : Int32,
) -> VectorField raise @types.LoadError {
  if width <= 0 || height <= 0 || dim <= 0 {
    raise @types.LoadError::DecodeFailed(
      "VectorField::zeros: width, height, dim 必须大于0",
    )
  }
  { width, height, dim, data: Array::make(width * height * dim, 0.0F), }
}

///|
/// 求值：获取点 (x, y) 处的矢量（返回 dim 维数组副本），边界外返回零矢量。
/// Evaluate the vector at (x, y); returns zero vector for out-of-bounds.
pub fn VectorField::evaluate(
  self : VectorField,
  x : Int32,
  y : Int32,
) -> Array[Float] {
  if x < 0 || x >= self.width || y < 0 || y >= self.height {
    return Array::make(self.dim, 0.0F)
  }
  let base = (y * self.width + x) * self.dim
  let result = Array::make(self.dim, 0.0F)
  for k in 0..<self.dim {
    result[k] = self.data[base + k]
  }
  result
}

///|
/// 求值单分量：获取点 (x, y) 处矢量第 k 分量，边界外返回 0。
/// Evaluate a single component k at (x, y); returns 0 for out-of-bounds.
pub fn VectorField::evaluate_component(
  self : VectorField,
  x : Int32,
  y : Int32,
  k : Int32,
) -> Float {
  if x < 0 ||
    x >= self.width ||
    y < 0 ||
    y >= self.height ||
    k < 0 ||
    k >= self.dim {
    return 0.0F
  }
  self.data[(y * self.width + x) * self.dim + k]
}

///|
/// 求值单分量（边界钳制）。
/// Evaluate a single component with clamped boundary.
pub fn VectorField::evaluate_component_clamped(
  self : VectorField,
  x : Int32,
  y : Int32,
  k : Int32,
) -> Float {
  let cx = x.clamp(min=0, max=self.width - 1)
  let cy = y.clamp(min=0, max=self.height - 1)
  let ck = k.clamp(min=0, max=self.dim - 1)
  self.data[(cy * self.width + cx) * self.dim + ck]
}

///|
/// 设值单分量：设置点 (x, y) 处矢量第 k 分量，越界则忽略。
/// Set component k at (x, y); out-of-bounds is ignored.
pub fn VectorField::set_component(
  self : VectorField,
  x : Int32,
  y : Int32,
  k : Int32,
  value : Float,
) -> Unit {
  if x < 0 ||
    x >= self.width ||
    y < 0 ||
    y >= self.height ||
    k < 0 ||
    k >= self.dim {
    return
  }
  self.data[(y * self.width + x) * self.dim + k] = value
}

///|
/// 矢量场幅值：返回每个点的矢量模长，形成标量场。
/// Vector magnitude: returns a scalar field of vector norms at each point.
pub fn VectorField::magnitude(
  self : VectorField,
) -> ScalarField raise @types.LoadError {
  let n = self.width * self.height
  let data = Array::make(n, 0.0F)
  for i in 0..<n {
    let base = i * self.dim
    let mut sum = 0.0F
    for k in 0..<self.dim {
      let v = self.data[base + k]
      sum = sum + v * v
    }
    data[i] = sum.sqrt()
  }
  ScalarField::make(self.width, self.height, data)
}
