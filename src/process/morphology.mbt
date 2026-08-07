// 形态学操作（纯 MoonBit）：erode / dilate / morph_open / morph_close
// 使用 3x3 结构元素（八邻域）

///|
/// 腐蚀。每个像素取 3x3 邻域最小值。
pub fn erode(img : @core.Image) -> @core.Image {
  let ch = img.channels
  let w = img.width
  let h = img.height
  let out : Array[Byte] = Array::make(w * h * ch, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let mut min_v = 255
        for dy in -1..<=1 {
          for dx in -1..<=1 {
            let sx = clamp_i(x + dx, 0, w - 1)
            let sy = clamp_i(y + dy, 0, h - 1)
            let v = img.data[(sy * w + sx) * ch + c].to_int()
            if v < min_v {
              min_v = v
            }
          }
        }
        out[(y * w + x) * ch + c] = min_v.to_byte()
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

///|
/// 膨胀。每个像素取 3x3 邻域最大值。
pub fn dilate(img : @core.Image) -> @core.Image {
  let ch = img.channels
  let w = img.width
  let h = img.height
  let out : Array[Byte] = Array::make(w * h * ch, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let mut max_v = 0
        for dy in -1..<=1 {
          for dx in -1..<=1 {
            let sx = clamp_i(x + dx, 0, w - 1)
            let sy = clamp_i(y + dy, 0, h - 1)
            let v = img.data[(sy * w + sx) * ch + c].to_int()
            if v > max_v {
              max_v = v
            }
          }
        }
        out[(y * w + x) * ch + c] = max_v.to_byte()
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

///|
/// 开运算（先腐蚀后膨胀）。去除小的明亮噪点。
pub fn morph_open(img : @core.Image) -> @core.Image {
  dilate(erode(img))
}

///|
/// 闭运算（先膨胀后腐蚀）。填充小的暗洞。
pub fn morph_close(img : @core.Image) -> @core.Image {
  erode(dilate(img))
}

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
fn clamp_i(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}
