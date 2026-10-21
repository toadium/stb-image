///|
/// Bayer CFA 排列模式
pub(all) enum BayerPattern {
  RGGB
  GBRG
  GRBG
  BGGR
} derive(Eq, @debug.Debug)

///|
pub extend BayerPattern with @debug.Debug::{to_repr}

///|
pub extend BayerPattern with Eq::{not_equal, equal}

///|
/// 白平衡方法
pub(all) enum WhiteBalanceMethod {
  GrayWorld
  Auto
  Manual
} derive(Eq, @debug.Debug)

///|
pub extend WhiteBalanceMethod with @debug.Debug::{to_repr}

///|
pub extend WhiteBalanceMethod with Eq::{not_equal, equal}

///|
/// RAW 处理参数
pub(all) struct RawParams {
  pattern : BayerPattern
  wb_method : WhiteBalanceMethod
  wb_r_gain : Double
  wb_g_gain : Double
  wb_b_gain : Double
  black_level : Int32
  white_level : Int32
} derive(Eq, @debug.Debug)

///|
pub extend RawParams with @debug.Debug::{to_repr}

///|
pub extend RawParams with Eq::{not_equal, equal}

///|
/// 构建 RAW 处理参数
pub fn raw_build_params(
  pattern : BayerPattern,
  wb_method : WhiteBalanceMethod,
  wb_r_gain~ : Double = 1.0,
  wb_g_gain~ : Double = 1.0,
  wb_b_gain~ : Double = 1.0,
  black_level~ : Int32 = 0,
  white_level~ : Int32 = 65535,
) -> RawParams {
  RawParams::{
    pattern,
    wb_method,
    wb_r_gain,
    wb_g_gain,
    wb_b_gain,
    black_level,
    white_level,
  }
}

///|
/// 获取 Bayer 模式下指定位置的通道索引（0=R, 1=G, 2=B）
pub fn bayer_channel_at(pattern : BayerPattern, x : Int32, y : Int32) -> Int32 {
  let row = y % 2
  let col = x % 2
  match pattern {
    RGGB =>
      if row == 0 && col == 0 {
        0
      } else if row == 0 && col == 1 {
        1
      } else if row == 1 && col == 0 {
        1
      } else {
        2
      }
    GBRG =>
      if row == 0 && col == 0 {
        1
      } else if row == 0 && col == 1 {
        2
      } else if row == 1 && col == 0 {
        0
      } else {
        1
      }
    GRBG =>
      if row == 0 && col == 0 {
        1
      } else if row == 0 && col == 1 {
        0
      } else if row == 1 && col == 0 {
        2
      } else {
        1
      }
    BGGR =>
      if row == 0 && col == 0 {
        2
      } else if row == 0 && col == 1 {
        1
      } else if row == 1 && col == 0 {
        1
      } else {
        0
      }
  }
}

///|
/// 双线性插值解马赛克：将 Bayer 模式 RAW 数据插值为 RGB 图像
///
/// 输入为单通道 Image（width×height），输出为 3 通道 RGB Image
pub fn raw_demosaic_bilinear(
  raw : @types.Image,
  pattern : BayerPattern,
) -> @types.Image {
  let w = raw.width
  let h = raw.height
  let out : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let ch = bayer_channel_at(pattern, x, y)
      let r = if ch == 0 {
        raw.data[y * w + x].to_int()
      } else {
        bilinear_interp(raw, x, y, pattern, 0, w, h)
      }
      let g = if ch == 1 {
        raw.data[y * w + x].to_int()
      } else {
        bilinear_interp(raw, x, y, pattern, 1, w, h)
      }
      let b = if ch == 2 {
        raw.data[y * w + x].to_int()
      } else {
        bilinear_interp(raw, x, y, pattern, 2, w, h)
      }
      out.push(clamp_u8(r).to_byte())
      out.push(clamp_u8(g).to_byte())
      out.push(clamp_u8(b).to_byte())
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(out),
  }
}

///|
fn bilinear_interp(
  raw : @types.Image,
  x : Int32,
  y : Int32,
  pattern : BayerPattern,
  target_ch : Int32,
  w : Int32,
  h : Int32,
) -> Int32 {
  let mut sum = 0
  let mut count = 0
  for dy in [-1, 0, 1] {
    for dx in [-1, 0, 1] {
      let nx = x + dx
      let ny = y + dy
      if nx >= 0 && nx < w && ny >= 0 && ny < h {
        let ch = bayer_channel_at(pattern, nx, ny)
        if ch == target_ch {
          sum = sum + raw.data[ny * w + nx].to_int()
          count = count + 1
        }
      }
    }
  }
  if count > 0 {
    sum / count
  } else {
    0
  }
}

///|
fn clamp_u8(v : Int32) -> Int32 {
  if v > 255 {
    255
  } else if v < 0 {
    0
  } else {
    v
  }
}

///|
/// 灰度世界白平衡：计算 R/G/B 通道均值并校正使均值相等
pub fn raw_white_balance_grayworld(img : @types.Image) -> @types.Image {
  if img.channels < 3 {
    return img
  }
  let w = img.width
  let h = img.height
  let n = w * h
  let mut sum_r = 0
  let mut sum_g = 0
  let mut sum_b = 0
  for i in 0..<n {
    sum_r = sum_r + img.data[i * 3].to_int()
    sum_g = sum_g + img.data[i * 3 + 1].to_int()
    sum_b = sum_b + img.data[i * 3 + 2].to_int()
  }
  let avg_r = if n > 0 { sum_r / n } else { 1 }
  let avg_g = if n > 0 { sum_g / n } else { 1 }
  let avg_b = if n > 0 { sum_b / n } else { 1 }
  let gray = (avg_r + avg_g + avg_b) / 3
  let gain_r = if avg_r > 0 {
    gray.to_double() / avg_r.to_double()
  } else {
    1.0
  }
  let gain_g = if avg_g > 0 {
    gray.to_double() / avg_g.to_double()
  } else {
    1.0
  }
  let gain_b = if avg_b > 0 {
    gray.to_double() / avg_b.to_double()
  } else {
    1.0
  }
  apply_wb_gains(img, gain_r, gain_g, gain_b)
}

///|
/// 自动白平衡：基于灰度世界 + 亮像素加权
pub fn raw_white_balance_auto(img : @types.Image) -> @types.Image {
  if img.channels < 3 {
    return img
  }
  let w = img.width
  let h = img.height
  let n = w * h
  let mut sum_r = 0.0
  let mut sum_g = 0.0
  let mut sum_b = 0.0
  let mut count = 0.0
  let threshold = 200
  for i in 0..<n {
    let r = img.data[i * 3].to_int()
    let g = img.data[i * 3 + 1].to_int()
    let b = img.data[i * 3 + 2].to_int()
    let brightness = (r + g + b) / 3
    if brightness > threshold {
      sum_r = sum_r + r.to_double()
      sum_g = sum_g + g.to_double()
      sum_b = sum_b + b.to_double()
      count = count + 1.0
    }
  }
  if count < 1.0 {
    return img
  }
  let avg_r = sum_r / count
  let avg_g = sum_g / count
  let avg_b = sum_b / count
  let gray = (avg_r + avg_g + avg_b) / 3.0
  let gain_r = if avg_r > 0.0 { gray / avg_r } else { 1.0 }
  let gain_g = if avg_g > 0.0 { gray / avg_g } else { 1.0 }
  let gain_b = if avg_b > 0.0 { gray / avg_b } else { 1.0 }
  apply_wb_gains(img, gain_r, gain_g, gain_b)
}

///|
/// 手动白平衡：使用指定增益
pub fn raw_white_balance_manual(
  img : @types.Image,
  gain_r : Double,
  gain_g : Double,
  gain_b : Double,
) -> @types.Image {
  if img.channels < 3 {
    return img
  }
  apply_wb_gains(img, gain_r, gain_g, gain_b)
}

///|
fn apply_wb_gains(
  img : @types.Image,
  gain_r : Double,
  gain_g : Double,
  gain_b : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let n = w * h
  let out : Array[Byte] = []
  for i in 0..<n {
    let r = img.data[i * 3].to_int()
    let g = img.data[i * 3 + 1].to_int()
    let b = img.data[i * 3 + 2].to_int()
    out.push(clamp_u8((r.to_double() * gain_r).to_int()).to_byte())
    out.push(clamp_u8((g.to_double() * gain_g).to_int()).to_byte())
    out.push(clamp_u8((b.to_double() * gain_b).to_int()).to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(out),
  }
}

///|
/// 色彩校正：应用 3x3 色彩矩阵
pub fn raw_color_correction(
  img : @types.Image,
  matrix : Array[Array[Double]],
) -> @types.Image {
  if img.channels < 3 {
    return img
  }
  let w = img.width
  let h = img.height
  let n = w * h
  let out : Array[Byte] = []
  for i in 0..<n {
    let r = img.data[i * 3].to_int().to_double()
    let g = img.data[i * 3 + 1].to_int().to_double()
    let b = img.data[i * 3 + 2].to_int().to_double()
    let nr = matrix[0][0] * r + matrix[0][1] * g + matrix[0][2] * b
    let ng = matrix[1][0] * r + matrix[1][1] * g + matrix[1][2] * b
    let nb = matrix[2][0] * r + matrix[2][1] * g + matrix[2][2] * b
    out.push(clamp_u8(nr.to_int()).to_byte())
    out.push(clamp_u8(ng.to_int()).to_byte())
    out.push(clamp_u8(nb.to_int()).to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(out),
  }
}

///|
/// 黑白电平校正：将像素值从 [black, white] 范围映射到 [0, 255]
pub fn raw_level_correction(
  img : @types.Image,
  black_level : Int32,
  white_level : Int32,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let c = img.channels
  let n = w * h * c
  let range = white_level - black_level
  let scale = if range > 0 { 255.0 / range.to_double() } else { 1.0 }
  let out : Array[Byte] = []
  for i in 0..<n {
    let v = img.data[i].to_int() - black_level
    out.push(clamp_u8((v.to_double() * scale).to_int()).to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: c,
    data: Bytes::from_array(out),
  }
}

///|
/// RAW 处理流水线：解马赛克 → 白平衡 → 色彩校正 → 电平校正
pub fn raw_pipeline(raw : @types.Image, params : RawParams) -> @types.Image {
  let demosaiced = raw_demosaic_bilinear(raw, params.pattern)
  let balanced = match params.wb_method {
    GrayWorld => raw_white_balance_grayworld(demosaiced)
    Auto => raw_white_balance_auto(demosaiced)
    Manual =>
      raw_white_balance_manual(
        demosaiced,
        params.wb_r_gain,
        params.wb_g_gain,
        params.wb_b_gain,
      )
  }
  let corrected = raw_color_correction(balanced, [
    [1.0, 0.0, 0.0],
    [0.0, 1.0, 0.0],
    [0.0, 0.0, 1.0],
  ])
  raw_level_correction(corrected, params.black_level, params.white_level)
}

///|
/// 生成模拟 Bayer RAW 数据（从 RGB 图像中抽取）
pub fn raw_extract_bayer(
  img : @types.Image,
  pattern : BayerPattern,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let out : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let ch = bayer_channel_at(pattern, x, y)
      out.push(img.data[y * w * 3 + x * 3 + ch])
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(out),
  }
}
