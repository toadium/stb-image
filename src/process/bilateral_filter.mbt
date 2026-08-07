// 双边滤波（纯 MoonBit）

///|
/// 双边滤波。保边去噪滤波器，同时考虑空间距离和像素值差异。
/// radius 为滤波半径，sigma_space 为空间高斯标准差，sigma_color 为值域高斯标准差。
/// 仅处理灰度图（channels=1）或 RGB 图（channels=3/4），alpha 通道不变。
pub fn bilateral_filter(
  img : @core.Image,
  radius : Int,
  sigma_space : Float,
  sigma_color : Float,
) -> @core.Image raise @core.LoadError {
  if radius < 1 {
    raise @core.LoadError::DecodeFailed("radius 必须 >= 1")
  }
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed(
      "bilateral_filter 仅支持 channels=1/3/4",
    )
  }
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { 1 }
  let w = img.width
  let h = img.height
  let n = w * h
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  let two_sps_sq = 2.0F * sigma_space * sigma_space
  let two_spc_sq = 2.0F * sigma_color * sigma_color
  // 预计算空间权重表
  let spatial_weights : Array[Array[Float]] = Array::make(
    2 * radius + 1,
    Array::make(2 * radius + 1, 0.0F),
  )
  for dy in -radius..<=radius {
    for dx in -radius..<=radius {
      let dist_sq = Float::from_int(dx * dx + dy * dy)
      spatial_weights[dy + radius][dx + radius] = @math.expf(
        -dist_sq / two_sps_sq,
      )
    }
  }
  for c in 0..<color_ch {
    for y in 0..<h {
      for x in 0..<w {
        let center_val = Float::from_int(
          img.data[(y * w + x) * ch + c].to_int(),
        )
        let mut weight_sum = 0.0F
        let mut value_sum = 0.0F
        for dy in -radius..<=radius {
          for dx in -radius..<=radius {
            let ny = y + dy
            let nx = x + dx
            if ny < 0 || ny >= h || nx < 0 || nx >= w {
              continue
            }
            let neighbor_val = Float::from_int(
              img.data[(ny * w + nx) * ch + c].to_int(),
            )
            let color_diff = neighbor_val - center_val
            let color_weight = @math.expf(
              -(color_diff * color_diff) / two_spc_sq,
            )
            let weight = spatial_weights[dy + radius][dx + radius] *
              color_weight
            value_sum += neighbor_val * weight
            weight_sum += weight
          }
        }
        let v = if weight_sum > 0.0F {
          value_sum / weight_sum
        } else {
          center_val
        }
        let clamped = if v < 0.0F {
          0
        } else if v > 255.0F {
          255
        } else {
          v.to_int()
        }
        out[(y * w + x) * ch + c] = clamped.to_byte()
      }
    }
  }
  if ch == 4 {
    for i in 0..<n {
      out[i * 4 + 3] = img.data[i * 4 + 3]
    }
  }
  @core.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 快速双边滤波（使用降采样近似）。适用于大半径场景。
/// downsample 为降采样倍数（1=不降采样，2=降采样到 1/2）。
pub fn bilateral_filter_fast(
  img : @core.Image,
  radius : Int,
  sigma_space : Float,
  sigma_color : Float,
  downsample : Int,
) -> @core.Image raise @core.LoadError {
  if downsample <= 1 {
    return bilateral_filter(img, radius, sigma_space, sigma_color)
  }
  // 降采样
  let mut small = img
  for _ in 0..<downsample {
    if small.width < 4 || small.height < 4 {
      break
    }
    small = pyr_down(small)
  }
  // 在小图上做双边滤波
  let small_filtered = bilateral_filter(
    small,
    (radius / downsample).clamp(min=1, max=radius),
    sigma_space,
    sigma_color,
  )
  // 放大回原尺寸
  let mut result = small_filtered
  let target_w = img.width
  let target_h = img.height
  while result.width < target_w || result.height < target_h {
    result = pyr_up(result)
  }
  // 裁剪到原尺寸
  if result.width != target_w || result.height != target_h {
    crop_bilateral(result, target_w, target_h)
  } else {
    result
  }
}

///|
fn crop_bilateral(img : @core.Image, w : Int, h : Int) -> @core.Image {
  let ch = img.channels
  let out : Array[Byte] = Array::make(w * h * ch, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        out[(y * w + x) * ch + c] = img.data[(y * img.width + x) * ch + c]
      }
    }
  }
  @core.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}
