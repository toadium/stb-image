// 场与 Image 双向转换：Image ↔ ScalarField / VectorField。
// Field-Image bidirectional binding: Image ↔ ScalarField / VectorField.
//
// 映射关系：
//   灰度 Image (channels=1) ↔ ScalarField
//   RGB  Image (channels=3) ↔ VectorField (dim=3)
//   RGBA Image (channels=4) ↔ VectorField (dim=4)

///|
/// Image 转标量场：将灰度图（channels=1）转为标量场，像素值归一化到 [0, 1]。
/// 若 channels > 1，先转灰度（加权平均：0.299R + 0.587G + 0.114B）。
/// Convert Image to ScalarField; grayscale (channels=1) normalized to [0, 1].
/// For channels > 1, convert to grayscale first (0.299R + 0.587G + 0.114B).
pub fn image_to_scalar_field(
  img : @types.Image,
) -> ScalarField raise @types.LoadError {
  if img.width <= 0 || img.height <= 0 {
    raise @types.LoadError::DecodeFailed(
      "image_to_scalar_field: 图像尺寸必须大于0",
    )
  }
  let w = img.width
  let h = img.height
  let ch = img.channels
  let n = w * h
  let data = Array::make(n, 0.0F)
  for i in 0..<n {
    let base = i * ch
    let v = if ch == 1 {
      Float::from_int(img.data[base].to_int())
    } else if ch >= 3 {
      let r = Float::from_int(img.data[base].to_int())
      let g = Float::from_int(img.data[base + 1].to_int())
      let b = Float::from_int(img.data[base + 2].to_int())
      0.299F * r + 0.587F * g + 0.114F * b
    } else {
      Float::from_int(img.data[base].to_int())
    }
    data[i] = v * (1.0F / 255.0F)
  }
  ScalarField::make(w, h, data)
}

///|
/// 标量场转 Image：将标量场转为单通道灰度图，值钳制到 [0, 1] 后映射到 [0, 255]。
/// Convert ScalarField to single-channel grayscale Image; values clamped to [0, 1] then mapped to [0, 255].
pub fn scalar_field_to_image(field : ScalarField) -> @types.Image {
  let n = field.width * field.height
  let buf : Array[Byte] = Array::make(n, b'0')
  for i in 0..<n {
    let v = field.data[i]
    let clamped = if v < 0.0F { 0.0F } else if v > 1.0F { 1.0F } else { v }
    buf[i] = (clamped * 255.0F + 0.5F).to_int().clamp(min=0, max=255).to_byte()
  }
  {
    width: field.width,
    height: field.height,
    channels: 1,
    data: Bytes::from_array(buf),
  }
}

///|
/// Image 转矢量场：将 RGB/RGBA 图转为矢量场（dim=channels），像素值归一化到 [0, 1]。
/// Convert Image to VectorField (dim=channels); pixel values normalized to [0, 1].
pub fn image_to_vector_field(
  img : @types.Image,
) -> VectorField raise @types.LoadError {
  if img.width <= 0 || img.height <= 0 || img.channels <= 0 {
    raise @types.LoadError::DecodeFailed(
      "image_to_vector_field: 图像尺寸和通道数必须大于0",
    )
  }
  let w = img.width
  let h = img.height
  let ch = img.channels
  let n = w * h * ch
  let data = Array::make(n, 0.0F)
  for i in 0..<n {
    data[i] = Float::from_int(img.data[i].to_int()) * (1.0F / 255.0F)
  }
  VectorField::make(w, h, ch, data)
}

///|
/// 矢量场转 Image：将矢量场转为多通道图，值钳制到 [0, 1] 后映射到 [0, 255]。
/// Convert VectorField to multi-channel Image; values clamped to [0, 1] then mapped to [0, 255].
pub fn vector_field_to_image(field : VectorField) -> @types.Image {
  let n = field.width * field.height * field.dim
  let buf : Array[Byte] = Array::make(n, b'0')
  for i in 0..<n {
    let v = field.data[i]
    let clamped = if v < 0.0F { 0.0F } else if v > 1.0F { 1.0F } else { v }
    buf[i] = (clamped * 255.0F + 0.5F).to_int().clamp(min=0, max=255).to_byte()
  }
  {
    width: field.width,
    height: field.height,
    channels: field.dim,
    data: Bytes::from_array(buf),
  }
}

///|
/// Image16 转标量场：16-bit 图转标量场，归一化到 [0, 1]（除以 65535）。
/// Convert Image16 to ScalarField; normalized to [0, 1] (divided by 65535).
pub fn image16_to_scalar_field(
  img : @types.Image16,
) -> ScalarField raise @types.LoadError {
  if img.width <= 0 || img.height <= 0 {
    raise @types.LoadError::DecodeFailed(
      "image16_to_scalar_field: 图像尺寸必须大于0",
    )
  }
  let w = img.width
  let h = img.height
  let ch = img.channels
  let n = w * h
  let data = Array::make(n, 0.0F)
  let inv = 1.0F / 65535.0F
  for i in 0..<n {
    let base = i * ch * 2
    let lo = img.data[base].to_int()
    let hi = img.data[base + 1].to_int()
    let v = lo | (hi << 8)
    data[i] = Float::from_int(v) * inv
  }
  ScalarField::make(w, h, data)
}

///|
/// ImageF 转标量场：HDR float 图转标量场，取第一通道，钳制到 [0, 1]。
/// Convert ImageF to ScalarField; takes first channel, clamped to [0, 1].
pub fn imagef_to_scalar_field(
  img : @types.ImageF,
) -> ScalarField raise @types.LoadError {
  if img.width <= 0 || img.height <= 0 {
    raise @types.LoadError::DecodeFailed(
      "imagef_to_scalar_field: 图像尺寸必须大于0",
    )
  }
  let w = img.width
  let h = img.height
  let ch = img.channels
  let n = w * h
  let data = Array::make(n, 0.0F)
  for i in 0..<n {
    let base = i * ch * 4
    let bits = img.data[base].to_int() |
      (img.data[base + 1].to_int() << 8) |
      (img.data[base + 2].to_int() << 16) |
      (img.data[base + 3].to_int() << 24)
    let v = Float::reinterpret_from_int(bits)
    data[i] = if v < 0.0F { 0.0F } else if v > 1.0F { 1.0F } else { v }
  }
  ScalarField::make(w, h, data)
}
