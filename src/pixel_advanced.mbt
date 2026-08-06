// 高级像素操作（纯 MoonBit）：pixelate / replace_color / convolve / swap_channels

///|
fn clamp_b(v : Int) -> Byte {
  if v < 0 {
    b'\x00'
  } else if v > 255 {
    b'\xFF'
  } else {
    v.to_byte()
  }
}

///|
/// 马赛克/像素化效果。将图像分成 block_size × block_size 的块，每块取左上角像素值。
pub fn pixelate(img : Image, block_size : Int) -> Image raise LoadError {
  if block_size <= 0 {
    raise LoadError::DecodeFailed("block_size 必须为正数")
  }
  let ch = img.channels
  let w = img.width
  let h = img.height
  let out : Array[Byte] = Array::make(w * h * ch, b'\x00')
  for by in 0..<h {
    for bx in 0..<w {
      let src_x = (bx / block_size) * block_size
      let src_y = (by / block_size) * block_size
      let src_off = (src_y * w + src_x) * ch
      let dst_off = (by * w + bx) * ch
      for c in 0..<ch {
        out[dst_off + c] = img.data[src_off + c]
      }
    }
  }
  Image::{ width: w, height: h, channels: ch, data: Bytes::from_array(out) }
}

///|
/// 颜色替换。将 old_color 替换为 new_color（精确匹配或容差匹配）。
/// old_color 和 new_color 长度应等于 channels。
pub fn replace_color(
  img : Image,
  old_color : Array[Byte],
  new_color : Array[Byte],
  tolerance : Int
) -> Image raise LoadError {
  let ch = img.channels
  if old_color.length() < ch || new_color.length() < ch {
    raise LoadError::DecodeFailed("颜色数组长度必须 >= channels")
  }
  let n = img.width * img.height
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for i in 0..<n {
    let off = i * ch
    let is_match = check_color_match(img.data, off, ch, old_color, tolerance)
    if is_match {
      for c in 0..<ch {
        out[off + c] = new_color[c]
      }
    } else {
      for c in 0..<ch {
        out[off + c] = img.data[off + c]
      }
    }
  }
  Image::{ width: img.width, height: img.height, channels: ch, data: Bytes::from_array(out) }
}

///|
/// 通用卷积。kernel 为 3×3 卷积核（9 个 Float 值，行优先）。
/// 边缘采用 clamp 策略。bias 为偏移量，scale 为缩放因子。
pub fn convolve(
  img : Image,
  kernel : Array[Float],
  bias : Float,
  scale : Float
) -> Image raise LoadError {
  if kernel.length() < 9 {
    raise LoadError::DecodeFailed("kernel 必须为 9 个值（3x3）")
  }
  let ch = img.channels
  let w = img.width
  let h = img.height
  let color_ch = if ch >= 3 { 3 } else { ch }
  let out : Array[Byte] = Array::make(w * h * ch, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<color_ch {
        let mut acc = 0.0F
        for ky in 0..<3 {
          for kx in 0..<3 {
            let sx = clamp_int(x + kx - 1, 0, w - 1)
            let sy = clamp_int(y + ky - 1, 0, h - 1)
            let v = Float::from_int(img.data[(sy * w + sx) * ch + c].to_int())
            acc += kernel[ky * 3 + kx] * v
          }
        }
        let result = (acc * scale + bias).to_int()
        out[(y * w + x) * ch + c] = clamp_b(result)
      }
      if ch == 4 {
        out[(y * w + x) * ch + 3] = img.data[(y * w + x) * ch + 3]
      }
    }
  }
  Image::{ width: w, height: h, channels: ch, data: Bytes::from_array(out) }
}

///|
/// 交换两个通道。例如 swap_channels(img, 0, 2) 交换 R 和 B。
pub fn swap_channels(img : Image, ch1 : Int, ch2 : Int) -> Image raise LoadError {
  if ch1 < 0 || ch1 >= img.channels || ch2 < 0 || ch2 >= img.channels {
    raise LoadError::DecodeFailed("通道索引越界")
  }
  if ch1 == ch2 {
    return img
  }
  let ch = img.channels
  let n = img.width * img.height
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for i in 0..<n {
    let off = i * ch
    for c in 0..<ch {
      out[off + c] = img.data[off + c]
    }
    let tmp = out[off + ch1]
    out[off + ch1] = out[off + ch2]
    out[off + ch2] = tmp
  }
  Image::{ width: img.width, height: img.height, channels: ch, data: Bytes::from_array(out) }
}

///|
fn clamp_int(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn check_color_match(
  data : Bytes,
  off : Int,
  ch : Int,
  target : Array[Byte],
  tolerance : Int
) -> Bool {
  for c in 0..<ch {
    let diff = (data[off + c].to_int() - target[c].to_int()).abs()
    if diff > tolerance {
      return false
    }
  }
  true
}