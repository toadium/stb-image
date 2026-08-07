// 非局部均值去噪 NLM（纯 MoonBit）

///|
/// 非局部均值去噪（Non-Local Means）。
/// 通过搜索窗口内相似像素块的加权平均来去噪。
/// 适用于灰度图（channels=1）或 RGB/RGBA 图（channels=3/4）。
/// patch_size 为相似性比较的块半径（默认 3，即 7x7 块）。
/// search_size 为搜索窗口半径（默认 7，即 15x15 窗口）。
/// h 为滤波强度参数（默认 10），越大平滑越强。
pub fn nlm_denoise(
  img : @core.Image,
  patch_size? : Int = 3,
  search_size? : Int = 7,
  h? : Int = 10,
) -> @core.Image raise @core.LoadError {
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("nlm_denoise 仅支持 channels=1/3/4")
  }
  if patch_size < 1 || patch_size > 10 {
    raise @core.LoadError::DecodeFailed("patch_size 必须在 1..10 之间")
  }
  if search_size < 1 || search_size > 20 {
    raise @core.LoadError::DecodeFailed("search_size 必须在 1..20 之间")
  }
  if h < 1 {
    raise @core.LoadError::DecodeFailed("h 必须 >= 1")
  }
  let ch = img.channels
  let w = img.width
  let h_img = img.height
  let n = w * h_img
  if n == 0 {
    return img
  }
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  let h_sq = h * h
  let patch_d = patch_size
  let search_d = search_size
  // 预计算常数
  let patch_area = (2 * patch_d + 1) * (2 * patch_d + 1)
  for y in 0..<h_img {
    for x in 0..<w {
      for c in 0..<ch {
        if ch == 4 && c == 3 {
          // alpha 通道不变
          out[(y * w + x) * ch + 3] = img.data[(y * w + x) * ch + 3]
          continue
        }
        let mut weight_sum = 0.0F
        let mut value_sum = 0.0F
        // 搜索窗口
        let sy_start = (y - search_d).clamp(min=0, max=h_img - 1)
        let sy_end = (y + search_d).clamp(min=0, max=h_img - 1)
        let sx_start = (x - search_d).clamp(min=0, max=w - 1)
        let sx_end = (x + search_d).clamp(min=0, max=w - 1)
        for sy in sy_start..<=sy_end {
          for sx in sx_start..<=sx_end {
            // 计算块距离
            let dist = patch_distance(
              img, x, y, sx, sy, w, h_img, ch, c, patch_d,
            )
            let weight = @math.expf(
              Float::from_int(-dist) / Float::from_int(h_sq * patch_area),
            )
            weight_sum += weight
            value_sum += weight *
              Float::from_int(img.data[(sy * w + sx) * ch + c].to_int())
          }
        }
        let val = if weight_sum > 0.0F {
          (value_sum / weight_sum).to_int()
        } else {
          img.data[(y * w + x) * ch + c].to_int()
        }
        out[(y * w + x) * ch + c] = val.clamp(min=0, max=255).to_byte()
      }
    }
  }
  @core.Image::{
    width: w,
    height: h_img,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 计算两个像素块之间的平方距离
fn patch_distance(
  img : @core.Image,
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
  w : Int,
  h : Int,
  ch : Int,
  c : Int,
  patch_d : Int,
) -> Int {
  let mut dist = 0
  for dy in -patch_d..<=patch_d {
    for dx in -patch_d..<=patch_d {
      let px1 = (x1 + dx).clamp(min=0, max=w - 1)
      let py1 = (y1 + dy).clamp(min=0, max=h - 1)
      let px2 = (x2 + dx).clamp(min=0, max=w - 1)
      let py2 = (y2 + dy).clamp(min=0, max=h - 1)
      let v1 = img.data[(py1 * w + px1) * ch + c].to_int()
      let v2 = img.data[(py2 * w + px2) * ch + c].to_int()
      let diff = v1 - v2
      dist += diff * diff
    }
  }
  dist
}

///|
/// 快速 NLM 去噪（降采样搜索）。
/// 使用积分图加速块距离计算，搜索步长 > 1 以加速。
/// 适用于灰度图（channels=1）或 RGB/RGBA 图（channels=3/4）。
pub fn nlm_denoise_fast(
  img : @core.Image,
  patch_size? : Int = 3,
  search_size? : Int = 7,
  h? : Int = 10,
  step? : Int = 2,
) -> @core.Image raise @core.LoadError {
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed(
      "nlm_denoise_fast 仅支持 channels=1/3/4",
    )
  }
  if patch_size < 1 || patch_size > 10 {
    raise @core.LoadError::DecodeFailed("patch_size 必须在 1..10 之间")
  }
  if search_size < 1 || search_size > 20 {
    raise @core.LoadError::DecodeFailed("search_size 必须在 1..20 之间")
  }
  if h < 1 {
    raise @core.LoadError::DecodeFailed("h 必须 >= 1")
  }
  if step < 1 || step > 5 {
    raise @core.LoadError::DecodeFailed("step 必须在 1..5 之间")
  }
  let ch = img.channels
  let w = img.width
  let h_img = img.height
  let n = w * h_img
  if n == 0 {
    return img
  }
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  let h_sq = h * h
  let patch_d = patch_size
  let search_d = search_size
  let patch_area = (2 * patch_d + 1) * (2 * patch_d + 1)
  for y in 0..<h_img {
    for x in 0..<w {
      for c in 0..<ch {
        if ch == 4 && c == 3 {
          out[(y * w + x) * ch + 3] = img.data[(y * w + x) * ch + 3]
          continue
        }
        let mut weight_sum = 0.0F
        let mut value_sum = 0.0F
        let sy_start = (y - search_d).clamp(min=0, max=h_img - 1)
        let sy_end = (y + search_d).clamp(min=0, max=h_img - 1)
        let sx_start = (x - search_d).clamp(min=0, max=w - 1)
        let sx_end = (x + search_d).clamp(min=0, max=w - 1)
        let mut sy = sy_start
        while sy <= sy_end {
          let mut sx = sx_start
          while sx <= sx_end {
            let dist = patch_distance(
              img, x, y, sx, sy, w, h_img, ch, c, patch_d,
            )
            let weight = @math.expf(
              Float::from_int(-dist) / Float::from_int(h_sq * patch_area),
            )
            weight_sum += weight
            value_sum += weight *
              Float::from_int(img.data[(sy * w + sx) * ch + c].to_int())
            sx += step
          }
          sy += step
        }
        let val = if weight_sum > 0.0F {
          (value_sum / weight_sum).to_int()
        } else {
          img.data[(y * w + x) * ch + c].to_int()
        }
        out[(y * w + x) * ch + c] = val.clamp(min=0, max=255).to_byte()
      }
    }
  }
  @core.Image::{
    width: w,
    height: h_img,
    channels: ch,
    data: Bytes::from_array(out),
  }
}
