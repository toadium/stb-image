// 局部二值模式（LBP，纯 MoonBit）

///|
/// 基本局部二值模式（LBP）。对每个像素，与其 3x3 邻域的 8 个像素比较，
/// 大于等于中心记 1，否则记 0，按顺时针顺序组成 8 位二进制数。
/// 仅处理灰度图（channels=1）或 RGB 图（channels=3/4），alpha 通道不变。
pub fn lbp(img : @core.Image) -> @core.Image raise @core.LoadError {
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("lbp 仅支持 channels=1/3/4")
  }
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { 1 }
  let w = img.width
  let h = img.height
  let n = w * h
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for c in 0..<color_ch {
    for y in 0..<h {
      for x in 0..<w {
        let center = img.data[(y * w + x) * ch + c].to_int()
        // 8 邻域，从左上顺时针：左上、上、右上、右、右下、下、左下、左
        let neighbors : Array[Int] = [
          get_pixel(img, x - 1, y - 1, c, ch, w, h),
          get_pixel(img, x, y - 1, c, ch, w, h),
          get_pixel(img, x + 1, y - 1, c, ch, w, h),
          get_pixel(img, x + 1, y, c, ch, w, h),
          get_pixel(img, x + 1, y + 1, c, ch, w, h),
          get_pixel(img, x, y + 1, c, ch, w, h),
          get_pixel(img, x - 1, y + 1, c, ch, w, h),
          get_pixel(img, x - 1, y, c, ch, w, h),
        ]
        let mut lbp_val = 0
        for i in 0..<8 {
          if neighbors[i] >= center {
            lbp_val = lbp_val | (1 << i)
          }
        }
        out[(y * w + x) * ch + c] = lbp_val.to_byte()
      }
    }
  }
  if ch == 4 {
    for i in 0..<n {
      out[i * 4 + 3] = img.data[i * 4 + 3]
    }
  }
  @core.Image::{ width: w, height: h, channels: ch, data: Bytes::from_array(out) }
}

///|
/// 均匀局部二值模式（Uniform LBP）。
/// 均匀模式指 0→1 和 1→0 跳变次数 <= 2 的模式，共有 58 种均匀模式。
/// 非均匀模式统一映射为 59。输出范围 0~59。
pub fn lbp_uniform(img : @core.Image) -> @core.Image raise @core.LoadError {
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("lbp_uniform 仅支持 channels=1/3/4")
  }
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { 1 }
  let w = img.width
  let h = img.height
  let n = w * h
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  // 预计算均匀模式映射表
  let uniform_map = build_uniform_map()
  for c in 0..<color_ch {
    for y in 0..<h {
      for x in 0..<w {
        let center = img.data[(y * w + x) * ch + c].to_int()
        let neighbors : Array[Int] = [
          get_pixel(img, x - 1, y - 1, c, ch, w, h),
          get_pixel(img, x, y - 1, c, ch, w, h),
          get_pixel(img, x + 1, y - 1, c, ch, w, h),
          get_pixel(img, x + 1, y, c, ch, w, h),
          get_pixel(img, x + 1, y + 1, c, ch, w, h),
          get_pixel(img, x, y + 1, c, ch, w, h),
          get_pixel(img, x - 1, y + 1, c, ch, w, h),
          get_pixel(img, x - 1, y, c, ch, w, h),
        ]
        let mut lbp_val = 0
        for i in 0..<8 {
          if neighbors[i] >= center {
            lbp_val = lbp_val | (1 << i)
          }
        }
        out[(y * w + x) * ch + c] = uniform_map[lbp_val].to_byte()
      }
    }
  }
  if ch == 4 {
    for i in 0..<n {
      out[i * 4 + 3] = img.data[i * 4 + 3]
    }
  }
  @core.Image::{ width: w, height: h, channels: ch, data: Bytes::from_array(out) }
}

///|
fn get_pixel(
  img : @core.Image,
  x : Int,
  y : Int,
  c : Int,
  ch : Int,
  w : Int,
  h : Int
) -> Int {
  if x < 0 || x >= w || y < 0 || y >= h {
    return 0
  }
  img.data[(y * w + x) * ch + c].to_int()
}

///|
fn build_uniform_map() -> Array[Int] {
  let map : Array[Int] = Array::make(256, 59)
  let mut label = 0
  for v in 0..<256 {
    if count_transitions(v) <= 2 {
      map[v] = label
      label += 1
    }
  }
  map
}

///|
fn count_transitions(v : Int) -> Int {
  let mut count = 0
  for i in 0..<8 {
    let bit_i = (v >> i) & 1
    let bit_next = (v >> ((i + 1) % 8)) & 1
    if bit_i != bit_next {
      count += 1
    }
  }
  count
}