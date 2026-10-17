// 场通用算子：梯度、散度、旋度、拉普拉斯、积分、阈值、掩码、代数运算、等值提取。
// Field operators: gradient, divergence, curl, laplacian, integrate, clamp, mask, algebra, isosurface.
//
// 关键映射（GeoVerse 思想）：
//   gradient  = 边缘检测（Sobel/Canny 的数学本质）
//   laplacian = 模糊/锐化（LoG）
//   integrate = 直方图/总量积分
//   field_clamp = 阈值分割
//   isosurface  = 等值线提取 → 分割

///|
/// 梯度：中心差分计算标量场梯度，返回矢量场（dim=2，[gx, gy]）。
/// 边界使用单侧差分。
/// Gradient: central difference of a scalar field, returns VectorField (dim=2, [gx, gy]).
/// Boundary uses one-sided difference.
pub fn field_gradient(
  field : ScalarField,
) -> VectorField raise @types.LoadError {
  let w = field.width
  let h = field.height
  let n = w * h
  let data = Array::make(n * 2, 0.0F)
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let gx = if x == 0 {
        field.data[idx + 1] - field.data[idx]
      } else if x == w - 1 {
        field.data[idx] - field.data[idx - 1]
      } else {
        (field.data[idx + 1] - field.data[idx - 1]) * 0.5F
      }
      let gy = if y == 0 {
        field.data[idx + w] - field.data[idx]
      } else if y == h - 1 {
        field.data[idx] - field.data[idx - w]
      } else {
        (field.data[idx + w] - field.data[idx - w]) * 0.5F
      }
      data[idx * 2] = gx
      data[idx * 2 + 1] = gy
    }
  }
  VectorField::make(w, h, 2, data)
}

///|
/// 散度：计算 2D 矢量场（dim=2）的散度，返回标量场。
/// div = du/dx + dv/dy。边界使用单侧差分。
/// Divergence of a 2D vector field (dim=2), returns ScalarField.
/// div = du/dx + dv/dy. Boundary uses one-sided difference.
pub fn field_divergence(
  field : VectorField,
) -> ScalarField raise @types.LoadError {
  if field.dim != 2 {
    raise @types.LoadError::DecodeFailed(
      "field_divergence: 矢量场维度必须为2",
    )
  }
  let w = field.width
  let h = field.height
  let n = w * h
  let data = Array::make(n, 0.0F)
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let u_here = field.data[idx * 2]
      let v_here = field.data[idx * 2 + 1]
      let du_dx = if x == 0 {
        field.data[(idx + 1) * 2] - u_here
      } else if x == w - 1 {
        u_here - field.data[(idx - 1) * 2]
      } else {
        (field.data[(idx + 1) * 2] - field.data[(idx - 1) * 2]) * 0.5F
      }
      let dv_dy = if y == 0 {
        field.data[(idx + w) * 2 + 1] - v_here
      } else if y == h - 1 {
        v_here - field.data[(idx - w) * 2 + 1]
      } else {
        (field.data[(idx + w) * 2 + 1] - field.data[(idx - w) * 2 + 1]) * 0.5F
      }
      data[idx] = du_dx + dv_dy
    }
  }
  ScalarField::make(w, h, data)
}

///|
/// 旋度：计算 2D 矢量场（dim=2）的标量旋度，返回标量场。
/// curl = dv/dx - du/dy（2D 中的标量旋度）。边界使用单侧差分。
/// Scalar curl of a 2D vector field (dim=2), returns ScalarField.
/// curl = dv/dx - du/dy. Boundary uses one-sided difference.
pub fn field_curl(field : VectorField) -> ScalarField raise @types.LoadError {
  if field.dim != 2 {
    raise @types.LoadError::DecodeFailed(
      "field_curl: 矢量场维度必须为2",
    )
  }
  let w = field.width
  let h = field.height
  let n = w * h
  let data = Array::make(n, 0.0F)
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let u_here = field.data[idx * 2]
      let v_here = field.data[idx * 2 + 1]
      let dv_dx = if x == 0 {
        field.data[(idx + 1) * 2 + 1] - v_here
      } else if x == w - 1 {
        v_here - field.data[(idx - 1) * 2 + 1]
      } else {
        (field.data[(idx + 1) * 2 + 1] - field.data[(idx - 1) * 2 + 1]) * 0.5F
      }
      let du_dy = if y == 0 {
        field.data[(idx + w) * 2] - u_here
      } else if y == h - 1 {
        u_here - field.data[(idx - w) * 2]
      } else {
        (field.data[(idx + w) * 2] - field.data[(idx - w) * 2]) * 0.5F
      }
      data[idx] = dv_dx - du_dy
    }
  }
  ScalarField::make(w, h, data)
}

///|
/// 拉普拉斯：计算标量场拉普拉斯，返回标量场。
/// lap = f[x+1,y] + f[x-1,y] + f[x,y+1] + f[x,y-1] - 4*f[x,y]。
/// 边界使用钳制（复制边界值）。
/// Laplacian of a scalar field, returns ScalarField.
/// lap = f[x+1,y] + f[x-1,y] + f[x,y+1] + f[x,y-1] - 4*f[x,y].
/// Boundary uses clamped (replicate edge) values.
pub fn field_laplacian(
  field : ScalarField,
) -> ScalarField raise @types.LoadError {
  let w = field.width
  let h = field.height
  let n = w * h
  let data = Array::make(n, 0.0F)
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let center = field.data[idx]
      let left = field.evaluate_clamped(x - 1, y)
      let right = field.evaluate_clamped(x + 1, y)
      let up = field.evaluate_clamped(x, y - 1)
      let down = field.evaluate_clamped(x, y + 1)
      data[idx] = left + right + up + down - 4.0F * center
    }
  }
  ScalarField::make(w, h, data)
}

///|
/// 积分：标量场全场求和（离散积分，相当于总量/面积积分）。
/// Integrate: sum all values (discrete integral = total / area integral).
pub fn field_integrate(field : ScalarField) -> Float {
  let mut sum = 0.0F
  for i in 0..<field.data.length() {
    sum = sum + field.data[i]
  }
  sum
}

///|
/// 区域积分：对标量场在 [x0,x1)×[y0,y1) 区域求和。
/// Regional integrate: sum values in the region [x0,x1)×[y0,y1).
pub fn field_integrate_region(
  field : ScalarField,
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
) -> Float {
  let mut sum = 0.0F
  let x_lo = x0.clamp(min=0, max=field.width)
  let x_hi = x1.clamp(min=0, max=field.width)
  let y_lo = y0.clamp(min=0, max=field.height)
  let y_hi = y1.clamp(min=0, max=field.height)
  for y in y_lo..<y_hi {
    for x in x_lo..<x_hi {
      sum = sum + field.data[y * field.width + x]
    }
  }
  sum
}

///|

///|
/// 阈值裁剪：将场值限制在 [lo, hi] 范围内。
/// Clamp field values to [lo, hi].
pub fn field_clamp(
  field : ScalarField,
  lo : Float,
  hi : Float,
) -> ScalarField raise @types.LoadError {
  let data = Array::make(field.data.length(), 0.0F)
  for i in 0..<field.data.length() {
    let v = field.data[i]
    data[i] = if v < lo { lo } else if v > hi { hi } else { v }
  }
  ScalarField::make(field.width, field.height, data)
}

///|
/// 掩码：按阈值生成二值掩码场（value >= threshold → 1.0，否则 0.0）。
/// Mask: binary mask field (value >= threshold → 1.0, else 0.0).
pub fn field_mask(
  field : ScalarField,
  threshold : Float,
) -> ScalarField raise @types.LoadError {
  let data = Array::make(field.data.length(), 0.0F)
  for i in 0..<field.data.length() {
    data[i] = if field.data[i] >= threshold { 1.0F } else { 0.0F }
  }
  ScalarField::make(field.width, field.height, data)
}

///|
/// 场加法：a + b（逐元素）。两场尺寸必须一致。
/// Field addition: a + b (element-wise). Both fields must have the same size.
pub fn field_add(
  a : ScalarField,
  b : ScalarField,
) -> ScalarField raise @types.LoadError {
  if a.width != b.width || a.height != b.height {
    raise @types.LoadError::DecodeFailed("field_add: 两场尺寸必须一致")
  }
  let data = Array::make(a.data.length(), 0.0F)
  for i in 0..<a.data.length() {
    data[i] = a.data[i] + b.data[i]
  }
  ScalarField::make(a.width, a.height, data)
}

///|
/// 场减法：a - b（逐元素）。两场尺寸必须一致。
/// Field subtraction: a - b (element-wise). Both fields must have the same size.
pub fn field_sub(
  a : ScalarField,
  b : ScalarField,
) -> ScalarField raise @types.LoadError {
  if a.width != b.width || a.height != b.height {
    raise @types.LoadError::DecodeFailed("field_sub: 两场尺寸必须一致")
  }
  let data = Array::make(a.data.length(), 0.0F)
  for i in 0..<a.data.length() {
    data[i] = a.data[i] - b.data[i]
  }
  ScalarField::make(a.width, a.height, data)
}

///|
/// 场标量乘法：field * scalar（逐元素）。
/// Field scalar multiplication: field * scalar (element-wise).
pub fn field_mul_scalar(
  field : ScalarField,
  scalar : Float,
) -> ScalarField raise @types.LoadError {
  let data = Array::make(field.data.length(), 0.0F)
  for i in 0..<field.data.length() {
    data[i] = field.data[i] * scalar
  }
  ScalarField::make(field.width, field.height, data)
}

///|
/// 场逐元素乘法：a * b（逐元素）。两场尺寸必须一致。
/// Field element-wise multiplication: a * b. Both fields must have the same size.
pub fn field_mul(
  a : ScalarField,
  b : ScalarField,
) -> ScalarField raise @types.LoadError {
  if a.width != b.width || a.height != b.height {
    raise @types.LoadError::DecodeFailed("field_mul: 两场尺寸必须一致")
  }
  let data = Array::make(a.data.length(), 0.0F)
  for i in 0..<a.data.length() {
    data[i] = a.data[i] * b.data[i]
  }
  ScalarField::make(a.width, a.height, data)
}

///|
/// 场混合：(1 - alpha) * a + alpha * b。两场尺寸必须一致，alpha 通常在 [0, 1]。
/// Field blend: (1 - alpha) * a + alpha * b. Same size required; alpha typically in [0, 1].
pub fn field_blend(
  a : ScalarField,
  b : ScalarField,
  alpha : Float,
) -> ScalarField raise @types.LoadError {
  if a.width != b.width || a.height != b.height {
    raise @types.LoadError::DecodeFailed(
      "field_blend: 两场尺寸必须一致",
    )
  }
  let data = Array::make(a.data.length(), 0.0F)
  let one_minus = 1.0F - alpha
  for i in 0..<a.data.length() {
    data[i] = one_minus * a.data[i] + alpha * b.data[i]
  }
  ScalarField::make(a.width, a.height, data)
}

///|
/// 等值面提取：标记 |value - level| < epsilon 的点为 1.0，否则 0.0。
/// 在 2D 中即等值线提取，可用于分割。
/// Isosurface: mark points where |value - level| < epsilon as 1.0, else 0.0.
/// In 2D this is isoline extraction, usable for segmentation.
pub fn field_isosurface(
  field : ScalarField,
  level : Float,
  epsilon : Float,
) -> ScalarField raise @types.LoadError {
  let data = Array::make(field.data.length(), 0.0F)
  for i in 0..<field.data.length() {
    let diff = field.data[i] - level
    let abs_diff = if diff < 0.0F { -diff } else { diff }
    data[i] = if abs_diff < epsilon { 1.0F } else { 0.0F }
  }
  ScalarField::make(field.width, field.height, data)
}

///|
/// 直方图：统计标量场值落在 [min_val, max_val) 分成 bins 个桶的计数。
/// Histogram: count values falling into bins buckets over [min_val, max_val).
pub fn field_histogram(
  field : ScalarField,
  min_val : Float,
  max_val : Float,
  bins : Int,
) -> Array[Int] raise @types.LoadError {
  if bins <= 0 {
    raise @types.LoadError::DecodeFailed("field_histogram: bins 必须大于0")
  }
  let hist = Array::make(bins, 0)
  let range = max_val - min_val
  if range <= 0.0F {
    return hist
  }
  for i in 0..<field.data.length() {
    let v = field.data[i]
    if v >= min_val && v < max_val {
      let idx = ((v - min_val) / range * Float::from_int(bins)).to_int()
      let clamped_idx = idx.clamp(min=0, max=bins - 1)
      hist[clamped_idx] = hist[clamped_idx] + 1
    }
  }
  hist
}
