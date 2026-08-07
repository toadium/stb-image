// 霍夫变换（直线检测，纯 MoonBit）

///|
/// 检测到的直线
pub(all) struct HoughLine {
  rho : Float // 极径（原点到直线的垂直距离）
  theta : Float // 极角（弧度）
  votes : Int // 累加器票数
}

///|
/// 霍夫直线变换。对二值图（非零为边缘点）检测直线。
/// theta_resolution 为角度分辨率（度数，默认 1.0），rho_resolution 为极径分辨率（像素，默认 1.0）。
/// threshold 为最小票数阈值，返回票数 >= threshold 的直线，按票数降序排列。
pub fn hough_lines(
  img : @core.Image,
  threshold : Int,
  theta_resolution~ : Float = 1.0F,
  rho_resolution~ : Float = 1.0F
) -> Array[HoughLine] raise @core.LoadError {
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("hough_lines 仅支持 channels=1/3/4")
  }
  let w = img.width
  let h = img.height
  let ch = img.channels
  // 角度范围 0~180 度
  let n_theta = (180.0F / theta_resolution).to_int()
  let diag = @math.powf(Float::from_int(w * w + h * h), 0.5F)
  let max_rho = (diag / rho_resolution).to_int() + 1
  let n_rho = 2 * max_rho + 1
  // 累加器
  let accumulator : Array[Array[Int]] = Array::make(n_rho, Array::make(n_theta, 0))
  // 预计算 sin/cos 表
  let cos_table : Array[Float] = Array::make(n_theta, 0.0F)
  let sin_table : Array[Float] = Array::make(n_theta, 0.0F)
  for t in 0..<n_theta {
    let angle = Float::from_int(t) * theta_resolution * 3.141592653589793F / 180.0F
    cos_table[t] = @math.cosf(angle)
    sin_table[t] = @math.sinf(angle)
  }
  // 遍历边缘点
  for y in 0..<h {
    for x in 0..<w {
      if img.data[(y * w + x) * ch].to_int() == 0 {
        continue
      }
      for t in 0..<n_theta {
        let rho = Float::from_int(x) * cos_table[t] + Float::from_int(y) * sin_table[t]
        let rho_idx = ((rho / rho_resolution).to_int() + max_rho).clamp(min=0, max=n_rho - 1)
        accumulator[rho_idx][t] += 1
      }
    }
  }
  // 收集结果
  let lines : Array[HoughLine] = []
  for r in 0..<n_rho {
    for t in 0..<n_theta {
      if accumulator[r][t] >= threshold {
        lines.push(HoughLine::{
          rho: (Float::from_int(r) - Float::from_int(max_rho)) * rho_resolution,
          theta: Float::from_int(t) * theta_resolution * 3.141592653589793F / 180.0F,
          votes: accumulator[r][t],
        })
      }
    }
  }
  // 按票数降序排序
  lines.sort_by(fn(a, b) { b.votes - a.votes })
  lines
}

///|
/// 非极大值抑制。对霍夫变换结果做 NMS，去除相近的重复直线。
pub fn hough_lines_nms(
  lines : Array[HoughLine],
  rho_threshold~ : Float = 5.0F,
  theta_threshold~ : Float = 0.1F
) -> Array[HoughLine] {
  let result : Array[HoughLine] = []
  let suppressed : Array[Bool] = Array::make(lines.length(), false)
  for i in 0..<lines.length() {
    if suppressed[i] {
      continue
    }
    result.push(lines[i])
    for j in (i + 1)..<lines.length() {
      if suppressed[j] {
        continue
      }
      let dr = (lines[i].rho - lines[j].rho).abs()
      let dt = (lines[i].theta - lines[j].theta).abs()
      if dr < rho_threshold && dt < theta_threshold {
        suppressed[j] = true
      }
    }
  }
  result
}