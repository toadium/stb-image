// 边缘检测 16-bit/float 变体：edge_detect_sobel
// 支持 Image16 / ImageF 两种类型

///|
fn read_u16_le_e(data : Bytes, offset : Int) -> Int {
  data[offset].to_int() + data[offset + 1].to_int() * 256
}

///|
fn write_u16_le_e(buf : Array[Byte], offset : Int, val : Int) -> Unit {
  buf[offset] = (val & 0xFF).to_byte()
  buf[offset + 1] = ((val >> 8) & 0xFF).to_byte()
}

///|
fn read_f32_le_e(data : Bytes, offset : Int) -> Float {
  let b0 = data[offset].to_int()
  let b1 = data[offset + 1].to_int()
  let b2 = data[offset + 2].to_int()
  let b3 = data[offset + 3].to_int()
  let bits = b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
  Float::reinterpret_from_int(bits)
}

///|
fn write_f32_le_e(buf : Array[Byte], offset : Int, val : Float) -> Unit {
  let bits = val.reinterpret_as_int()
  buf[offset] = (bits & 0xFF).to_byte()
  buf[offset + 1] = ((bits >> 8) & 0xFF).to_byte()
  buf[offset + 2] = ((bits >> 16) & 0xFF).to_byte()
  buf[offset + 3] = ((bits >> 24) & 0xFF).to_byte()
}

///|
/// 16-bit Sobel 边缘检测。先转灰度，然后计算梯度幅值。
/// 输出为单通道灰度图（channels=1）的 Image16。
pub fn edge_detect_sobel_16(img : @types.Image16) -> @types.Image16 {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let n = w * h
  let bpp = ch * 2
  // 先转灰度
  let gray : Array[Int] = Array::make(n, 0)
  for i in 0..<n {
    if ch == 1 {
      gray[i] = read_u16_le_e(img.data, i * bpp)
    } else {
      let r = read_u16_le_e(img.data, i * bpp)
      let g = read_u16_le_e(img.data, i * bpp + 2)
      let b = read_u16_le_e(img.data, i * bpp + 4)
      gray[i] = (r * 299 + g * 587 + b * 114) / 1000
    }
  }
  // Sobel 卷积
  let out : Array[Byte] = Array::make(n * 2, b'\x00')
  // 内部区域
  for y in 1..<(h - 1) {
    for x in 1..<(w - 1) {
      let idx = y * w + x
      let idx_l = idx - 1
      let idx_r = idx + 1
      let idx_t = idx - w
      let idx_b = idx + w
      let gx = -gray[idx_t - 1] +
        gray[idx_t + 1] -
        2 * gray[idx_l] +
        2 * gray[idx_r] -
        gray[idx_b - 1] +
        gray[idx_b + 1]
      let gy = -gray[idx_t - 1] -
        2 * gray[idx_t] -
        gray[idx_t + 1] +
        gray[idx_b - 1] +
        2 * gray[idx_b] +
        gray[idx_b + 1]
      let mag = Float::from_int(gx * gx + gy * gy).sqrt()
      let v = (mag + 0.5F).to_int().clamp(min=0, max=65535)
      write_u16_le_e(out, idx * 2, v)
    }
  }
  // 边界区域
  for y in 0..<h {
    for x in 0..<w {
      if x >= 1 && x < w - 1 && y >= 1 && y < h - 1 {
        continue
      }
      let x_l = clamp_i(x - 1, 0, w - 1)
      let x_r = clamp_i(x + 1, 0, w - 1)
      let y_t = clamp_i(y - 1, 0, h - 1)
      let y_b = clamp_i(y + 1, 0, h - 1)
      let gx = -gray[y_t * w + x_l] +
        gray[y_t * w + x_r] -
        2 * gray[y * w + x_l] +
        2 * gray[y * w + x_r] -
        gray[y_b * w + x_l] +
        gray[y_b * w + x_r]
      let gy = -gray[y_t * w + x_l] -
        2 * gray[y_t * w + x] -
        gray[y_t * w + x_r] +
        gray[y_b * w + x_l] +
        2 * gray[y_b * w + x] +
        gray[y_b * w + x_r]
      let mag = Float::from_int(gx * gx + gy * gy).sqrt()
      let v = (mag + 0.5F).to_int().clamp(min=0, max=65535)
      write_u16_le_e(out, (y * w + x) * 2, v)
    }
  }
  @types.Image16::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(out),
  }
}

///|
/// float Sobel 边缘检测。先转灰度，然后计算梯度幅值。
/// 输出为单通道灰度图（channels=1）的 ImageF。
pub fn edge_detect_sobel_f(img : @types.ImageF) -> @types.ImageF {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let n = w * h
  let bpp = ch * 4
  // 先转灰度
  let gray : Array[Float] = Array::make(n, 0.0F)
  for i in 0..<n {
    if ch == 1 {
      gray[i] = read_f32_le_e(img.data, i * bpp)
    } else {
      let r = read_f32_le_e(img.data, i * bpp)
      let g = read_f32_le_e(img.data, i * bpp + 4)
      let b = read_f32_le_e(img.data, i * bpp + 8)
      gray[i] = r * 0.299F + g * 0.587F + b * 0.114F
    }
  }
  // Sobel 卷积
  let out : Array[Byte] = Array::make(n * 4, b'\x00')
  // 内部区域
  for y in 1..<(h - 1) {
    for x in 1..<(w - 1) {
      let idx = y * w + x
      let idx_l = idx - 1
      let idx_r = idx + 1
      let idx_t = idx - w
      let idx_b = idx + w
      let gx = -gray[idx_t - 1] +
        gray[idx_t + 1] -
        2.0F * gray[idx_l] +
        2.0F * gray[idx_r] -
        gray[idx_b - 1] +
        gray[idx_b + 1]
      let gy = -gray[idx_t - 1] -
        2.0F * gray[idx_t] -
        gray[idx_t + 1] +
        gray[idx_b - 1] +
        2.0F * gray[idx_b] +
        gray[idx_b + 1]
      let mag = (gx * gx + gy * gy).sqrt()
      write_f32_le_e(out, idx * 4, mag)
    }
  }
  // 边界区域
  for y in 0..<h {
    for x in 0..<w {
      if x >= 1 && x < w - 1 && y >= 1 && y < h - 1 {
        continue
      }
      let x_l = clamp_i(x - 1, 0, w - 1)
      let x_r = clamp_i(x + 1, 0, w - 1)
      let y_t = clamp_i(y - 1, 0, h - 1)
      let y_b = clamp_i(y + 1, 0, h - 1)
      let gx = -gray[y_t * w + x_l] +
        gray[y_t * w + x_r] -
        2.0F * gray[y * w + x_l] +
        2.0F * gray[y * w + x_r] -
        gray[y_b * w + x_l] +
        gray[y_b * w + x_r]
      let gy = -gray[y_t * w + x_l] -
        2.0F * gray[y_t * w + x] -
        gray[y_t * w + x_r] +
        gray[y_b * w + x_l] +
        2.0F * gray[y_b * w + x] +
        gray[y_b * w + x_r]
      let mag = (gx * gx + gy * gy).sqrt()
      write_f32_le_e(out, (y * w + x) * 4, mag)
    }
  }
  @types.ImageF::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(out),
  }
}
