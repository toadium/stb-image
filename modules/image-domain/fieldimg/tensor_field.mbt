// 张量场：2D 张量场，每个点 (x, y) 映射到 rows×cols 矩阵。
// Tensor field: 2D tensor field, each point (x, y) maps to a rows×cols matrix.
// 典型应用：结构张量（2×2 对称）用于角点检测，梯度张量用于边缘分析。

///|
/// 张量场：2D 张量场，data 为行主序，长度 = width * height * rows * cols。
/// Tensor field: 2D tensor field, row-major, length = width * height * rows * cols.
pub(all) struct TensorField {
  width : Int32
  height : Int32
  rows : Int32
  cols : Int32
  data : Array[Float]
} derive(Eq, @debug.Debug)

///|
pub extend TensorField with @debug.Debug::{to_repr}

///|
pub extend TensorField with Eq::{not_equal, equal}

///|
/// 创建张量场，数据长度必须等于 width * height * rows * cols。
/// Create a tensor field; data length must equal width * height * rows * cols.
pub fn TensorField::make(
  width : Int32,
  height : Int32,
  rows : Int32,
  cols : Int32,
  data : Array[Float],
) -> TensorField raise @types.LoadError {
  if width <= 0 || height <= 0 || rows <= 0 || cols <= 0 {
    raise @types.LoadError::DecodeFailed(
      "TensorField::make: width, height, rows, cols 必须大于0",
    )
  }
  if data.length() != width * height * rows * cols {
    raise @types.LoadError::DecodeFailed(
      "TensorField::make: 数据长度必须等于 width * height * rows * cols",
    )
  }
  { width, height, rows, cols, data, }
}

///|
/// 创建全零张量场。
/// Create an all-zero tensor field.
pub fn TensorField::zeros(
  width : Int32,
  height : Int32,
  rows : Int32,
  cols : Int32,
) -> TensorField raise @types.LoadError {
  if width <= 0 || height <= 0 || rows <= 0 || cols <= 0 {
    raise @types.LoadError::DecodeFailed(
      "TensorField::zeros: width, height, rows, cols 必须大于0",
    )
  }
  {
    width,
    height,
    rows,
    cols,
    data: Array::make(width * height * rows * cols, 0.0F),
  }
}

///|
/// 求值单元素：获取点 (x, y) 处矩阵第 (r, c) 元素，边界外返回 0。
/// Evaluate element (r, c) at (x, y); returns 0 for out-of-bounds.
pub fn TensorField::evaluate(
  self : TensorField,
  x : Int32,
  y : Int32,
  r : Int32,
  c : Int32,
) -> Float {
  if x < 0 ||
    x >= self.width ||
    y < 0 ||
    y >= self.height ||
    r < 0 ||
    r >= self.rows ||
    c < 0 ||
    c >= self.cols {
    return 0.0F
  }
  self.data[((y * self.width + x) * self.rows + r) * self.cols + c]
}

///|
/// 求值单元素（边界钳制）。
/// Evaluate element with clamped boundary.
pub fn TensorField::evaluate_clamped(
  self : TensorField,
  x : Int32,
  y : Int32,
  r : Int32,
  c : Int32,
) -> Float {
  let cx = x.clamp(min=0, max=self.width - 1)
  let cy = y.clamp(min=0, max=self.height - 1)
  let cr = r.clamp(min=0, max=self.rows - 1)
  let cc = c.clamp(min=0, max=self.cols - 1)
  self.data[((cy * self.width + cx) * self.rows + cr) * self.cols + cc]
}

///|
/// 设值单元素：设置点 (x, y) 处矩阵第 (r, c) 元素，越界则忽略。
/// Set element (r, c) at (x, y); out-of-bounds is ignored.
pub fn TensorField::set(
  self : TensorField,
  x : Int32,
  y : Int32,
  r : Int32,
  c : Int32,
  value : Float,
) -> Unit {
  if x < 0 ||
    x >= self.width ||
    y < 0 ||
    y >= self.height ||
    r < 0 ||
    r >= self.rows ||
    c < 0 ||
    c >= self.cols {
    return
  }
  self.data[((y * self.width + x) * self.rows + r) * self.cols + c] = value
}

///|
/// 由梯度矢量场构建结构张量场（2×2 对称）。
/// 结构张量 J = [[Ix², Ix*Iy], [Ix*Iy, Iy²]]，用于角点检测。
/// Build structure tensor field (2×2 symmetric) from a gradient vector field (dim=2).
/// Structure tensor J = [[Ix², Ix*Iy], [Ix*Iy, Iy²]], used for corner detection.
pub fn TensorField::structure_tensor(
  gradient : VectorField,
) -> TensorField raise @types.LoadError {
  if gradient.dim != 2 {
    raise @types.LoadError::DecodeFailed(
      "structure_tensor: 梯度场维度必须为2",
    )
  }
  let w = gradient.width
  let h = gradient.height
  let n = w * h
  let data = Array::make(n * 4, 0.0F)
  for i in 0..<n {
    let ix = gradient.data[i * 2]
    let iy = gradient.data[i * 2 + 1]
    data[i * 4] = ix * ix
    data[i * 4 + 1] = ix * iy
    data[i * 4 + 2] = ix * iy
    data[i * 4 + 3] = iy * iy
  }
  TensorField::make(w, h, 2, 2, data)
}

///|
/// 计算结构张量的两个特征值，返回矢量场（dim=2，[λ1, λ2]，λ1 ≥ λ2）。
/// 特征值用于 Harris 角点响应：R = det(J) - k * trace(J)² = λ1*λ2 - k*(λ1+λ2)²。
/// Compute eigenvalues of 2×2 structure tensors, returns VectorField (dim=2, [λ1, λ2], λ1 ≥ λ2).
pub fn TensorField::eigenvalues_2x2(
  self : TensorField,
) -> VectorField raise @types.LoadError {
  if self.rows != 2 || self.cols != 2 {
    raise @types.LoadError::DecodeFailed(
      "eigenvalues_2x2: 张量必须是 2×2",
    )
  }
  let n = self.width * self.height
  let data = Array::make(n * 2, 0.0F)
  for i in 0..<n {
    let a = self.data[i * 4]
    let b = self.data[i * 4 + 1]
    let c = self.data[i * 4 + 2]
    let d = self.data[i * 4 + 3]
    let trace = a + d
    let det = a * d - b * c
    let disc = trace * trace - 4.0F * det
    let sq = if disc >= 0.0F { disc.sqrt() } else { 0.0F }
    let l1 = (trace + sq) * 0.5F
    let l2 = (trace - sq) * 0.5F
    data[i * 2] = l1
    data[i * 2 + 1] = l2
  }
  VectorField::make(self.width, self.height, 2, data)
}
