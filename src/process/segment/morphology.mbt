// 形态学操作（纯 MoonBit）：erode / dilate / morph_open / morph_close
// 使用 3x3 结构元素（八邻域）

///|
/// 腐蚀。每个像素取 3x3 邻域最小值。分离内部/边界区域以消除热点 clamp 调用。
pub fn erode(img : @types.Image) -> @types.Image {
  let ch = img.channels
  let w = img.width
  let h = img.height
  let n = w * h
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  // 预计算像素 Int 数组，避免内层循环重复类型转换
  let src : Array[Int] = Array::make(n * ch, 0)
  for i in 0..<(n * ch) {
    src[i] = img.data[i].to_int()
  }
  // 内部区域：x in [1, w-1), y in [1, h-1)，3x3 核完全在图像内
  for y in 1..<(h - 1) {
    for x in 1..<(w - 1) {
      for c in 0..<ch {
        let base = ((y - 1) * w + (x - 1)) * ch + c
        let mut min_v = src[base]
        if src[base + ch] < min_v {
          min_v = src[base + ch]
        }
        if src[base + 2 * ch] < min_v {
          min_v = src[base + 2 * ch]
        }
        let row1 = base + w * ch
        if src[row1] < min_v {
          min_v = src[row1]
        }
        if src[row1 + ch] < min_v {
          min_v = src[row1 + ch]
        }
        if src[row1 + 2 * ch] < min_v {
          min_v = src[row1 + 2 * ch]
        }
        let row2 = base + 2 * w * ch
        if src[row2] < min_v {
          min_v = src[row2]
        }
        if src[row2 + ch] < min_v {
          min_v = src[row2 + ch]
        }
        if src[row2 + 2 * ch] < min_v {
          min_v = src[row2 + 2 * ch]
        }
        out[(y * w + x) * ch + c] = min_v.to_byte()
      }
    }
  }
  // 边界区域：需要 clamp
  for y in 0..<h {
    let y_inner = y >= 1 && y < h - 1
    for x in 0..<w {
      if y_inner && x >= 1 && x < w - 1 {
        continue
      }
      for c in 0..<ch {
        let mut min_v = 255
        for dy in -1..<=1 {
          for dx in -1..<=1 {
            let sx = clamp_i(x + dx, 0, w - 1)
            let sy = clamp_i(y + dy, 0, h - 1)
            let v = src[(sy * w + sx) * ch + c]
            if v < min_v {
              min_v = v
            }
          }
        }
        out[(y * w + x) * ch + c] = min_v.to_byte()
      }
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 膨胀。每个像素取 3x3 邻域最大值。分离内部/边界区域以消除热点 clamp 调用。
pub fn dilate(img : @types.Image) -> @types.Image {
  let ch = img.channels
  let w = img.width
  let h = img.height
  let n = w * h
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  // 预计算像素 Int 数组
  let src : Array[Int] = Array::make(n * ch, 0)
  for i in 0..<(n * ch) {
    src[i] = img.data[i].to_int()
  }
  // 内部区域：x in [1, w-1), y in [1, h-1)
  for y in 1..<(h - 1) {
    for x in 1..<(w - 1) {
      for c in 0..<ch {
        let base = ((y - 1) * w + (x - 1)) * ch + c
        let mut max_v = src[base]
        if src[base + ch] > max_v {
          max_v = src[base + ch]
        }
        if src[base + 2 * ch] > max_v {
          max_v = src[base + 2 * ch]
        }
        let row1 = base + w * ch
        if src[row1] > max_v {
          max_v = src[row1]
        }
        if src[row1 + ch] > max_v {
          max_v = src[row1 + ch]
        }
        if src[row1 + 2 * ch] > max_v {
          max_v = src[row1 + 2 * ch]
        }
        let row2 = base + 2 * w * ch
        if src[row2] > max_v {
          max_v = src[row2]
        }
        if src[row2 + ch] > max_v {
          max_v = src[row2 + ch]
        }
        if src[row2 + 2 * ch] > max_v {
          max_v = src[row2 + 2 * ch]
        }
        out[(y * w + x) * ch + c] = max_v.to_byte()
      }
    }
  }
  // 边界区域：需要 clamp
  for y in 0..<h {
    let y_inner = y >= 1 && y < h - 1
    for x in 0..<w {
      if y_inner && x >= 1 && x < w - 1 {
        continue
      }
      for c in 0..<ch {
        let mut max_v = 0
        for dy in -1..<=1 {
          for dx in -1..<=1 {
            let sx = clamp_i(x + dx, 0, w - 1)
            let sy = clamp_i(y + dy, 0, h - 1)
            let v = src[(sy * w + sx) * ch + c]
            if v > max_v {
              max_v = v
            }
          }
        }
        out[(y * w + x) * ch + c] = max_v.to_byte()
      }
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 开运算（先腐蚀后膨胀）。去除小的明亮噪点。
pub fn morph_open(img : @types.Image) -> @types.Image {
  dilate(erode(img))
}

///|
/// 闭运算（先膨胀后腐蚀）。填充小的暗洞。
pub fn morph_close(img : @types.Image) -> @types.Image {
  erode(dilate(img))
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
