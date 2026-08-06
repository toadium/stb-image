// 色彩调整操作（纯 MoonBit）
// 亮度/对比度/gamma/反色 + HSV/HSL 色彩空间转换

///|
fn clamp_byte(v : Int) -> Byte {
  if v < 0 {
    b'\x00'
  } else if v > 255 {
    b'\xFF'
  } else {
    v.to_byte()
  }
}

///|
/// 亮度调整。delta ∈ [-255, 255]，正值变亮，负值变暗。
/// 仅影响颜色通道（前 min(channels,3) 个），alpha 通道不变。
pub fn adjust_brightness(img : Image, delta : Int) -> Image {
  let n = img.width * img.height
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for i in 0..<n {
    for c in 0..<color_ch {
      out[i * ch + c] = clamp_byte(img.data[i * ch + c].to_int() + delta)
    }
    if ch == 4 {
      out[i * ch + 3] = img.data[i * ch + 3]
    }
  }
  Image::{ width: img.width, height: img.height, channels: ch, data: Bytes::from_array(out) }
}

///|
/// 对比度调整。factor=1.0 为原图，>1 增加对比度，<1 降低。
/// 以 128 为中心缩放。仅影响颜色通道，alpha 不变。
pub fn adjust_contrast(img : Image, factor : Float) -> Image {
  let n = img.width * img.height
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for i in 0..<n {
    for c in 0..<color_ch {
      let v = img.data[i * ch + c].to_int()
      let adjusted = (Float::from_int(v - 128) * factor + 128.0F).to_int()
      out[i * ch + c] = clamp_byte(adjusted)
    }
    if ch == 4 {
      out[i * ch + 3] = img.data[i * ch + 3]
    }
  }
  Image::{ width: img.width, height: img.height, channels: ch, data: Bytes::from_array(out) }
}

///|
/// Gamma 校正。gamma=1.0 为原图，>1 变暗，<1 变亮。
/// 使用查找表加速。仅影响颜色通道，alpha 不变。
pub fn adjust_gamma(img : Image, gamma : Float) -> Image {
  // 预计算 256 项查找表
  let lut : Array[Byte] = Array::make(256, b'\x00')
  for i in 0..<256 {
    let normalized = Float::from_int(i) / 255.0F
    let corrected = @math.powf(normalized, gamma)
    let val = (corrected * 255.0F + 0.5F).to_int()
    lut[i] = clamp_byte(val)
  }
  let n = img.width * img.height
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for i in 0..<n {
    for c in 0..<color_ch {
      out[i * ch + c] = lut[img.data[i * ch + c].to_int()]
    }
    if ch == 4 {
      out[i * ch + 3] = img.data[i * ch + 3]
    }
  }
  Image::{ width: img.width, height: img.height, channels: ch, data: Bytes::from_array(out) }
}

///|
/// 反色（负片）。new = 255 - old。仅影响颜色通道，alpha 不变。
pub fn invert(img : Image) -> Image {
  let n = img.width * img.height
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for i in 0..<n {
    for c in 0..<color_ch {
      out[i * ch + c] = (255 - img.data[i * ch + c].to_int()).to_byte()
    }
    if ch == 4 {
      out[i * ch + 3] = img.data[i * ch + 3]
    }
  }
  Image::{ width: img.width, height: img.height, channels: ch, data: Bytes::from_array(out) }
}

///|
/// RGB → HSV 色彩空间转换。
/// 输入 r,g,b ∈ [0,255]，输出 h ∈ [0,360), s ∈ [0,1], v ∈ [0,1]
pub fn rgb_to_hsv(r : Int, g : Int, b : Int) -> (Float, Float, Float) {
  let rf = Float::from_int(r) / 255.0F
  let gf = Float::from_int(g) / 255.0F
  let bf = Float::from_int(b) / 255.0F
  let mx = rf.max(gf).max(bf)
  let mn = rf.min(gf).min(bf)
  let delta = mx - mn
  let v = mx
  let s = if mx == 0.0F { 0.0F } else { delta / mx }
  let h = if delta == 0.0F {
    0.0F
  } else if mx == rf {
    60.0F * ((gf - bf) / delta)
  } else if mx == gf {
    60.0F * ((bf - rf) / delta + 2.0F)
  } else {
    60.0F * ((rf - gf) / delta + 4.0F)
  }
  let h_norm = if h < 0.0F { h + 360.0F } else { h }
  (h_norm, s, v)
}

///|
/// HSV → RGB 色彩空间转换。
/// 输入 h ∈ [0,360), s ∈ [0,1], v ∈ [0,1]，输出 r,g,b ∈ [0,255]
pub fn hsv_to_rgb(h : Float, s : Float, v : Float) -> (Int, Int, Int) {
  let c = v * s
  // 归一化 h 到 [0,6)
  let mut hp = h / 60.0F
  while hp >= 6.0F {
    hp = hp - 6.0F
  }
  while hp < 0.0F {
    hp = hp + 6.0F
  }
  // hp % 2.0
  let hp_mod2 = if hp < 2.0F {
    hp
  } else if hp < 4.0F {
    hp - 2.0F
  } else {
    hp - 4.0F
  }
  let x = c * (1.0F - (hp_mod2 - 1.0F).abs())
  let m = v - c
  let (r1, g1, b1) = if hp < 1.0F {
    (c, x, 0.0F)
  } else if hp < 2.0F {
    (x, c, 0.0F)
  } else if hp < 3.0F {
    (0.0F, c, x)
  } else if hp < 4.0F {
    (0.0F, x, c)
  } else if hp < 5.0F {
    (x, 0.0F, c)
  } else {
    (c, 0.0F, x)
  }
  (
    ((r1 + m) * 255.0F + 0.5F).to_int(),
    ((g1 + m) * 255.0F + 0.5F).to_int(),
    ((b1 + m) * 255.0F + 0.5F).to_int(),
  )
}

///|
/// RGB → HSL 色彩空间转换。
/// 输入 r,g,b ∈ [0,255]，输出 h ∈ [0,360), s ∈ [0,1], l ∈ [0,1]
pub fn rgb_to_hsl(r : Int, g : Int, b : Int) -> (Float, Float, Float) {
  let rf = Float::from_int(r) / 255.0F
  let gf = Float::from_int(g) / 255.0F
  let bf = Float::from_int(b) / 255.0F
  let mx = rf.max(gf).max(bf)
  let mn = rf.min(gf).min(bf)
  let delta = mx - mn
  let l = (mx + mn) / 2.0F
  let s = if delta == 0.0F {
    0.0F
  } else {
    delta / (1.0F - (2.0F * l - 1.0F).abs())
  }
  let h = if delta == 0.0F {
    0.0F
  } else if mx == rf {
    60.0F * ((gf - bf) / delta)
  } else if mx == gf {
    60.0F * ((bf - rf) / delta + 2.0F)
  } else {
    60.0F * ((rf - gf) / delta + 4.0F)
  }
  let h_norm = if h < 0.0F { h + 360.0F } else { h }
  (h_norm, s, l)
}

///|
/// HSL → RGB 色彩空间转换。
/// 输入 h ∈ [0,360), s ∈ [0,1], l ∈ [0,1]，输出 r,g,b ∈ [0,255]
pub fn hsl_to_rgb(h : Float, s : Float, l : Float) -> (Int, Int, Int) {
  let c = (1.0F - (2.0F * l - 1.0F).abs()) * s
  // 归一化 h 到 [0,6)
  let mut hp = h / 60.0F
  while hp >= 6.0F {
    hp = hp - 6.0F
  }
  while hp < 0.0F {
    hp = hp + 6.0F
  }
  let hp_mod2 = if hp < 2.0F {
    hp
  } else if hp < 4.0F {
    hp - 2.0F
  } else {
    hp - 4.0F
  }
  let x = c * (1.0F - (hp_mod2 - 1.0F).abs())
  let m = l - c / 2.0F
  let (r1, g1, b1) = if hp < 1.0F {
    (c, x, 0.0F)
  } else if hp < 2.0F {
    (x, c, 0.0F)
  } else if hp < 3.0F {
    (0.0F, c, x)
  } else if hp < 4.0F {
    (0.0F, x, c)
  } else if hp < 5.0F {
    (x, 0.0F, c)
  } else {
    (c, 0.0F, x)
  }
  (
    ((r1 + m) * 255.0F + 0.5F).to_int(),
    ((g1 + m) * 255.0F + 0.5F).to_int(),
    ((b1 + m) * 255.0F + 0.5F).to_int(),
  )
}
