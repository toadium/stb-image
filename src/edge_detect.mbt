// 边缘检测扩展（纯 MoonBit）：edge_detect_laplacian / edge_detect_prewitt
// clamp_b 来自 pixel_advanced.mbt，clamp_i 来自 morphology.mbt

///|
/// Laplacian 边缘检测。使用 3x3 Laplacian 核：
/// [0, 1, 0; 1, -4, 1; 0, 1, 0]
/// 返回灰度图（channels=1）。
pub fn edge_detect_laplacian(img : Image) -> Image {
  let ch = img.channels
  let w = img.width
  let h = img.height
  let out : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      let cx = clamp_i(x, 0, w - 1)
      let cy = clamp_i(y, 0, h - 1)
      let up = clamp_i(y - 1, 0, h - 1)
      let down = clamp_i(y + 1, 0, h - 1)
      let left = clamp_i(x - 1, 0, w - 1)
      let right = clamp_i(x + 1, 0, w - 1)
      let luminance = fn(px : Int, py : Int) -> Int {
        if ch >= 3 {
          let r = img.data[(py * w + px) * ch].to_int()
          let g = img.data[(py * w + px) * ch + 1].to_int()
          let b = img.data[(py * w + px) * ch + 2].to_int()
          (r * 77 + g * 150 + b * 29) / 256
        } else {
          img.data[(py * w + px) * ch].to_int()
        }
      }
      let center = luminance(cx, cy)
      let u = luminance(cx, up)
      let d = luminance(cx, down)
      let l = luminance(left, cy)
      let r = luminance(right, cy)
      let lap = u + d + l + r - 4 * center
      out[y * w + x] = clamp_b(lap.abs())
    }
  }
  Image::{ width: w, height: h, channels: 1, data: Bytes::from_array(out) }
}

///|
/// Prewitt 边缘检测。使用两个 3x3 Prewitt 核计算梯度幅值。
/// Gx = [-1, 0, 1; -1, 0, 1; -1, 0, 1]
/// Gy = [-1, -1, -1; 0, 0, 0; 1, 1, 1]
/// 返回灰度图（channels=1）。
pub fn edge_detect_prewitt(img : Image) -> Image {
  let ch = img.channels
  let w = img.width
  let h = img.height
  let out : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      let up = clamp_i(y - 1, 0, h - 1)
      let down = clamp_i(y + 1, 0, h - 1)
      let left = clamp_i(x - 1, 0, w - 1)
      let right = clamp_i(x + 1, 0, w - 1)
      let luminance = fn(px : Int, py : Int) -> Int {
        if ch >= 3 {
          let r = img.data[(py * w + px) * ch].to_int()
          let g = img.data[(py * w + px) * ch + 1].to_int()
          let b = img.data[(py * w + px) * ch + 2].to_int()
          (r * 77 + g * 150 + b * 29) / 256
        } else {
          img.data[(py * w + px) * ch].to_int()
        }
      }
      let gx = luminance(right, up) + luminance(right, y) + luminance(right, down) - luminance(left, up) - luminance(left, y) - luminance(left, down)
      let gy = luminance(left, down) + luminance(x, down) + luminance(right, down) - luminance(left, up) - luminance(x, up) - luminance(right, up)
      let mag = @math.powf(Float::from_int(gx * gx + gy * gy), 0.5F)
      out[y * w + x] = clamp_b(mag.to_int())
    }
  }
  Image::{ width: w, height: h, channels: 1, data: Bytes::from_array(out) }
}
