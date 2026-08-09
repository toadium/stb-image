// 纯 MoonBit 图像混合（全目标可用：native/wasm/js）
// 仅依赖 @types，不依赖 @core/FFI
// 移植自 src/util/pixel_ops.mbt:103-478 的 13 个 blend 混合模式函数
// @pixel.clamp_byte_v 复用自 @pixel 子包

///|
/// 乘法混合（纯 MoonBit，全目标可用）。result = base * blend / 255。
/// 两图必须尺寸和通道数相同。
pub fn blend_multiply_pure(
  base : @types.Image,
  blend : @types.Image,
) -> @types.Image raise @types.LoadError {
  if base.width != blend.width ||
    base.height != blend.height ||
    base.channels != blend.channels {
    raise @types.LoadError::DecodeFailed(
      "blend 两图尺寸/通道数必须相同",
    )
  }
  let n = base.width * base.height * base.channels
  let out : Array[Byte] = Array::make(n, b'\x00')
  for i in 0..<n {
    let b = base.data[i].to_int()
    let l = blend.data[i].to_int()
    out[i] = (b * l / 255).to_byte()
  }
  @types.Image::{
    width: base.width,
    height: base.height,
    channels: base.channels,
    data: Bytes::from_array(out),
  }
}

///|
/// 滤色混合（纯 MoonBit，全目标可用）。result = 255 - (255 - base) * (255 - blend) / 255。
pub fn blend_screen_pure(
  base : @types.Image,
  blend : @types.Image,
) -> @types.Image raise @types.LoadError {
  if base.width != blend.width ||
    base.height != blend.height ||
    base.channels != blend.channels {
    raise @types.LoadError::DecodeFailed(
      "blend 两图尺寸/通道数必须相同",
    )
  }
  let n = base.width * base.height * base.channels
  let out : Array[Byte] = Array::make(n, b'\x00')
  for i in 0..<n {
    let b = base.data[i].to_int()
    let l = blend.data[i].to_int()
    out[i] = (255 - (255 - b) * (255 - l) / 255).to_byte()
  }
  @types.Image::{
    width: base.width,
    height: base.height,
    channels: base.channels,
    data: Bytes::from_array(out),
  }
}

///|
/// 叠加混合（纯 MoonBit，全目标可用）。暗部用乘法，亮部用滤色。
/// result = if base < 128: 2*base*blend/255 else: 255 - 2*(255-base)*(255-blend)/255
pub fn blend_overlay_pure(
  base : @types.Image,
  blend : @types.Image,
) -> @types.Image raise @types.LoadError {
  if base.width != blend.width ||
    base.height != blend.height ||
    base.channels != blend.channels {
    raise @types.LoadError::DecodeFailed(
      "blend 两图尺寸/通道数必须相同",
    )
  }
  let n = base.width * base.height * base.channels
  let out : Array[Byte] = Array::make(n, b'\x00')
  for i in 0..<n {
    let b = base.data[i].to_int()
    let l = blend.data[i].to_int()
    out[i] = if b < 128 {
      (2 * b * l / 255).to_byte()
    } else {
      @pixel.clamp_byte_v(255 - 2 * (255 - b) * (255 - l) / 255)
    }
  }
  @types.Image::{
    width: base.width,
    height: base.height,
    channels: base.channels,
    data: Bytes::from_array(out),
  }
}

///|
/// 变暗混合（纯 MoonBit，全目标可用）。result = min(base, blend)。
pub fn blend_darken_pure(
  base : @types.Image,
  blend : @types.Image,
) -> @types.Image raise @types.LoadError {
  if base.width != blend.width ||
    base.height != blend.height ||
    base.channels != blend.channels {
    raise @types.LoadError::DecodeFailed(
      "blend 两图尺寸/通道数必须相同",
    )
  }
  let n = base.width * base.height * base.channels
  let out : Array[Byte] = Array::make(n, b'\x00')
  for i in 0..<n {
    let b = base.data[i].to_int()
    let l = blend.data[i].to_int()
    out[i] = (if b < l { b } else { l }).to_byte()
  }
  @types.Image::{
    width: base.width,
    height: base.height,
    channels: base.channels,
    data: Bytes::from_array(out),
  }
}

///|
/// 变亮混合（纯 MoonBit，全目标可用）。result = max(base, blend)。
pub fn blend_lighten_pure(
  base : @types.Image,
  blend : @types.Image,
) -> @types.Image raise @types.LoadError {
  if base.width != blend.width ||
    base.height != blend.height ||
    base.channels != blend.channels {
    raise @types.LoadError::DecodeFailed(
      "blend 两图尺寸/通道数必须相同",
    )
  }
  let n = base.width * base.height * base.channels
  let out : Array[Byte] = Array::make(n, b'\x00')
  for i in 0..<n {
    let b = base.data[i].to_int()
    let l = blend.data[i].to_int()
    out[i] = (if b > l { b } else { l }).to_byte()
  }
  @types.Image::{
    width: base.width,
    height: base.height,
    channels: base.channels,
    data: Bytes::from_array(out),
  }
}

///|
/// 差值混合（纯 MoonBit，全目标可用）。result = |base - blend|。
pub fn blend_difference_pure(
  base : @types.Image,
  blend : @types.Image,
) -> @types.Image raise @types.LoadError {
  if base.width != blend.width ||
    base.height != blend.height ||
    base.channels != blend.channels {
    raise @types.LoadError::DecodeFailed(
      "blend 两图尺寸/通道数必须相同",
    )
  }
  let n = base.width * base.height * base.channels
  let out : Array[Byte] = Array::make(n, b'\x00')
  for i in 0..<n {
    let b = base.data[i].to_int()
    let l = blend.data[i].to_int()
    out[i] = (if b > l { b - l } else { l - b }).to_byte()
  }
  @types.Image::{
    width: base.width,
    height: base.height,
    channels: base.channels,
    data: Bytes::from_array(out),
  }
}

///|
/// 排除混合（纯 MoonBit，全目标可用）。result = base + blend - 2 * base * blend / 255。
pub fn blend_exclusion_pure(
  base : @types.Image,
  blend : @types.Image,
) -> @types.Image raise @types.LoadError {
  if base.width != blend.width ||
    base.height != blend.height ||
    base.channels != blend.channels {
    raise @types.LoadError::DecodeFailed(
      "blend 两图尺寸/通道数必须相同",
    )
  }
  let n = base.width * base.height * base.channels
  let out : Array[Byte] = Array::make(n, b'\x00')
  for i in 0..<n {
    let b = base.data[i].to_int()
    let l = blend.data[i].to_int()
    out[i] = @pixel.clamp_byte_v(b + l - 2 * b * l / 255)
  }
  @types.Image::{
    width: base.width,
    height: base.height,
    channels: base.channels,
    data: Bytes::from_array(out),
  }
}

///|
/// 颜色减淡（纯 MoonBit，全目标可用）。result = base * 255 / (255 - blend)，blend=255 时结果为 255。
pub fn blend_color_dodge_pure(
  base : @types.Image,
  blend : @types.Image,
) -> @types.Image raise @types.LoadError {
  if base.width != blend.width ||
    base.height != blend.height ||
    base.channels != blend.channels {
    raise @types.LoadError::DecodeFailed(
      "blend 两图尺寸/通道数必须相同",
    )
  }
  let n = base.width * base.height * base.channels
  let out : Array[Byte] = Array::make(n, b'\x00')
  for i in 0..<n {
    let b = base.data[i].to_int()
    let l = blend.data[i].to_int()
    out[i] = if l == 255 {
      b'\xFF'
    } else {
      @pixel.clamp_byte_v(b * 255 / (255 - l))
    }
  }
  @types.Image::{
    width: base.width,
    height: base.height,
    channels: base.channels,
    data: Bytes::from_array(out),
  }
}

///|
/// 颜色加深（纯 MoonBit，全目标可用）。result = 255 - (255 - base) * 255 / blend，blend=0 时结果为 0。
pub fn blend_color_burn_pure(
  base : @types.Image,
  blend : @types.Image,
) -> @types.Image raise @types.LoadError {
  if base.width != blend.width ||
    base.height != blend.height ||
    base.channels != blend.channels {
    raise @types.LoadError::DecodeFailed(
      "blend 两图尺寸/通道数必须相同",
    )
  }
  let n = base.width * base.height * base.channels
  let out : Array[Byte] = Array::make(n, b'\x00')
  for i in 0..<n {
    let b = base.data[i].to_int()
    let l = blend.data[i].to_int()
    out[i] = if l == 0 {
      b'\x00'
    } else {
      @pixel.clamp_byte_v(255 - (255 - b) * 255 / l)
    }
  }
  @types.Image::{
    width: base.width,
    height: base.height,
    channels: base.channels,
    data: Bytes::from_array(out),
  }
}

///|
/// 强光（纯 MoonBit，全目标可用）。blend < 128 时用乘法，否则用滤色。
pub fn blend_hard_light_pure(
  base : @types.Image,
  blend : @types.Image,
) -> @types.Image raise @types.LoadError {
  if base.width != blend.width ||
    base.height != blend.height ||
    base.channels != blend.channels {
    raise @types.LoadError::DecodeFailed(
      "blend 两图尺寸/通道数必须相同",
    )
  }
  let n = base.width * base.height * base.channels
  let out : Array[Byte] = Array::make(n, b'\x00')
  for i in 0..<n {
    let b = base.data[i].to_int()
    let l = blend.data[i].to_int()
    out[i] = if l < 128 {
      @pixel.clamp_byte_v(2 * b * l / 255)
    } else {
      @pixel.clamp_byte_v(255 - 2 * (255 - b) * (255 - l) / 255)
    }
  }
  @types.Image::{
    width: base.width,
    height: base.height,
    channels: base.channels,
    data: Bytes::from_array(out),
  }
}

///|
/// 柔光（纯 MoonBit，全目标可用）。基于 blend 的亮度在乘法和滤色之间平滑过渡。
/// result = (1 - 2*blend/255) * base^2/255 + (2*blend/255) * base
pub fn blend_soft_light_pure(
  base : @types.Image,
  blend : @types.Image,
) -> @types.Image raise @types.LoadError {
  if base.width != blend.width ||
    base.height != blend.height ||
    base.channels != blend.channels {
    raise @types.LoadError::DecodeFailed(
      "blend 两图尺寸/通道数必须相同",
    )
  }
  let n = base.width * base.height * base.channels
  let out : Array[Byte] = Array::make(n, b'\x00')
  for i in 0..<n {
    let b = base.data[i].to_int()
    let l = blend.data[i].to_int()
    let w = 2 * l
    out[i] = @pixel.clamp_byte_v((255 - w) * b * b / (255 * 255) + w * b / 255)
  }
  @types.Image::{
    width: base.width,
    height: base.height,
    channels: base.channels,
    data: Bytes::from_array(out),
  }
}

///|
/// 线性减淡（相加，纯 MoonBit，全目标可用）。result = min(base + blend, 255)。
pub fn blend_linear_dodge_pure(
  base : @types.Image,
  blend : @types.Image,
) -> @types.Image raise @types.LoadError {
  if base.width != blend.width ||
    base.height != blend.height ||
    base.channels != blend.channels {
    raise @types.LoadError::DecodeFailed(
      "blend 两图尺寸/通道数必须相同",
    )
  }
  let n = base.width * base.height * base.channels
  let out : Array[Byte] = Array::make(n, b'\x00')
  for i in 0..<n {
    let b = base.data[i].to_int()
    let l = blend.data[i].to_int()
    out[i] = @pixel.clamp_byte_v(b + l)
  }
  @types.Image::{
    width: base.width,
    height: base.height,
    channels: base.channels,
    data: Bytes::from_array(out),
  }
}

///|
/// 线性加深（相减，纯 MoonBit，全目标可用）。result = max(base + blend - 255, 0)。
pub fn blend_linear_burn_pure(
  base : @types.Image,
  blend : @types.Image,
) -> @types.Image raise @types.LoadError {
  if base.width != blend.width ||
    base.height != blend.height ||
    base.channels != blend.channels {
    raise @types.LoadError::DecodeFailed(
      "blend 两图尺寸/通道数必须相同",
    )
  }
  let n = base.width * base.height * base.channels
  let out : Array[Byte] = Array::make(n, b'\x00')
  for i in 0..<n {
    let b = base.data[i].to_int()
    let l = blend.data[i].to_int()
    out[i] = @pixel.clamp_byte_v(b + l - 255)
  }
  @types.Image::{
    width: base.width,
    height: base.height,
    channels: base.channels,
    data: Bytes::from_array(out),
  }
}
