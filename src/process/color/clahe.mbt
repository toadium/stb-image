// CLAHE: 对比度受限自适应直方图均衡（纯 MoonBit）

///|
/// CLAHE（Contrast Limited Adaptive Histogram Equalization）。
/// 将图像分成 tile_size × tile_size 的块，每块做直方图均衡，用双线性插值平滑拼接。
/// clip_limit 控制对比度增强强度，值越大增强越强（典型值 2.0~4.0）。
/// 仅处理灰度图（channels=1）或 RGB 图（channels=3/4），alpha 通道不变。
pub fn clahe(
  img : @core.Image,
  tile_size : Int,
  clip_limit : Float,
) -> @core.Image raise @core.LoadError {
  if tile_size < 2 {
    raise @core.LoadError::DecodeFailed("tile_size 必须 >= 2")
  }
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("clahe 仅支持 channels=1/3/4")
  }
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { 1 }
  let n = img.width * img.height
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for c in 0..<color_ch {
    clahe_channel(img, out, c, ch, tile_size, clip_limit)
  }
  if ch == 4 {
    for i in 0..<n {
      out[i * 4 + 3] = img.data[i * 4 + 3]
    }
  }
  @core.Image::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
fn clahe_channel(
  img : @core.Image,
  out : Array[Byte],
  channel : Int,
  ch : Int,
  tile_size : Int,
  clip_limit : Float,
) -> Unit {
  let w = img.width
  let h = img.height
  // 块数
  let ntx = (w + tile_size - 1) / tile_size
  let nty = (h + tile_size - 1) / tile_size
  let n_tiles = ntx * nty
  let luts : Array[Array[Int]] = Array::make(n_tiles, Array::make(256, 0))
  // 计算每块的直方图和 LUT
  for ty in 0..<nty {
    for tx in 0..<ntx {
      let hist : Array[Int] = Array::make(256, 0)
      let x0 = tx * tile_size
      let y0 = ty * tile_size
      let x1 = if x0 + tile_size < w { x0 + tile_size } else { w }
      let y1 = if y0 + tile_size < h { y0 + tile_size } else { h }
      let tile_pixels = (x1 - x0) * (y1 - y0)
      for y in y0..<y1 {
        for x in x0..<x1 {
          let v = img.data[(y * w + x) * ch + channel].to_int()
          hist[v] += 1
        }
      }
      // 裁剪直方图
      let clip_count = (Float::from_int(tile_pixels) * clip_limit / 256.0).to_int()
      let mut excess = 0
      for i in 0..<256 {
        if hist[i] > clip_count {
          excess += hist[i] - clip_count
          hist[i] = clip_count
        }
      }
      // 均匀分配多余的像素
      let redistribute = excess / 256
      let mut remainder = excess - redistribute * 256
      for i in 0..<256 {
        hist[i] += redistribute
        if remainder > 0 {
          hist[i] += 1
          remainder -= 1
        }
      }
      // 计算 CDF 并归一化到 0-255
      let lut = luts[ty * ntx + tx]
      let mut cdf = 0
      for i in 0..<256 {
        cdf += hist[i]
        lut[i] = if tile_pixels > 0 {
          clamp_i(cdf * 255 / tile_pixels, 0, 255)
        } else {
          i
        }
      }
    }
  }
  // 双线性插值应用 LUT
  for y in 0..<h {
    for x in 0..<w {
      let v = img.data[(y * w + x) * ch + channel].to_int()
      // 计算块坐标（浮点）
      let fx = Float::from_int(x) / Float::from_int(tile_size) - 0.5
      let fy = Float::from_int(y) / Float::from_int(tile_size) - 0.5
      let tx = fx.to_int()
      let ty = fy.to_int()
      let wx = fx - Float::from_int(tx)
      let wy = fy - Float::from_int(ty)
      // 4 个相邻块
      let t00 = tile_clamp(tx, ty, ntx, nty)
      let t01 = tile_clamp(tx + 1, ty, ntx, nty)
      let t10 = tile_clamp(tx, ty + 1, ntx, nty)
      let t11 = tile_clamp(tx + 1, ty + 1, ntx, nty)
      let v00 = Float::from_int(luts[t00][v])
      let v01 = Float::from_int(luts[t01][v])
      let v10 = Float::from_int(luts[t10][v])
      let v11 = Float::from_int(luts[t11][v])
      let top = v00 * (1.0 - wx) + v01 * wx
      let bot = v10 * (1.0 - wx) + v11 * wx
      let result = clamp_i((top * (1.0 - wy) + bot * wy).to_int(), 0, 255)
      out[(y * w + x) * ch + channel] = result.to_byte()
    }
  }
}

///|
fn tile_clamp(tx : Int, ty : Int, ntx : Int, nty : Int) -> Int {
  let cx = if tx < 0 { 0 } else if tx >= ntx { ntx - 1 } else { tx }
  let cy = if ty < 0 { 0 } else if ty >= nty { nty - 1 } else { ty }
  cy * ntx + cx
}
