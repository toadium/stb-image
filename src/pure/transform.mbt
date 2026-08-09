// 纯 MoonBit 图像几何变换（全目标可用：native/wasm/js）
// 仅依赖 @types，不依赖 @core/FFI
// 移植自 src/process/transform/transform.mbt:4-135 的 5 个 8-bit Image 操作

///|
/// 裁剪 8-bit Image 的指定区域（纯 MoonBit，全目标可用）
pub fn crop_pure(
  img : @types.Image,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> @types.Image raise @types.LoadError {
  if x < 0 ||
    y < 0 ||
    w <= 0 ||
    h <= 0 ||
    x + w > img.width ||
    y + h > img.height {
    raise @types.LoadError::DecodeFailed("crop 区域越界")
  }
  let ch = img.channels
  let out : Array[Byte] = Array::make(w * h * ch, b'\x00')
  for row in 0..<h {
    let src_off = ((y + row) * img.width + x) * ch
    let dst_off = row * w * ch
    for i in 0..<(w * ch) {
      out[dst_off + i] = img.data[src_off + i]
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
/// 顺时针旋转 90 度（纯 MoonBit，全目标可用）
pub fn rotate_90_pure(img : @types.Image) -> @types.Image {
  let ch = img.channels
  let new_w = img.height
  let new_h = img.width
  let out : Array[Byte] = Array::make(new_w * new_h * ch, b'\x00')
  for y in 0..<img.height {
    for x in 0..<img.width {
      let nx = img.height - 1 - y
      let ny = x
      let src = (y * img.width + x) * ch
      let dst = (ny * new_w + nx) * ch
      for c in 0..<ch {
        out[dst + c] = img.data[src + c]
      }
    }
  }
  @types.Image::{
    width: new_w,
    height: new_h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 旋转 180 度（纯 MoonBit，全目标可用）
pub fn rotate_180_pure(img : @types.Image) -> @types.Image {
  let ch = img.channels
  let out : Array[Byte] = Array::make(img.width * img.height * ch, b'\x00')
  for y in 0..<img.height {
    for x in 0..<img.width {
      let nx = img.width - 1 - x
      let ny = img.height - 1 - y
      let src = (y * img.width + x) * ch
      let dst = (ny * img.width + nx) * ch
      for c in 0..<ch {
        out[dst + c] = img.data[src + c]
      }
    }
  }
  @types.Image::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 顺时针旋转 270 度（逆时针 90 度）（纯 MoonBit，全目标可用）
pub fn rotate_270_pure(img : @types.Image) -> @types.Image {
  let ch = img.channels
  let new_w = img.height
  let new_h = img.width
  let out : Array[Byte] = Array::make(new_w * new_h * ch, b'\x00')
  for y in 0..<img.height {
    for x in 0..<img.width {
      let nx = y
      let ny = img.width - 1 - x
      let src = (y * img.width + x) * ch
      let dst = (ny * new_w + nx) * ch
      for c in 0..<ch {
        out[dst + c] = img.data[src + c]
      }
    }
  }
  @types.Image::{
    width: new_w,
    height: new_h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 水平翻转（左右镜像）（纯 MoonBit，全目标可用）
pub fn flip_horizontal_pure(img : @types.Image) -> @types.Image {
  let ch = img.channels
  let out : Array[Byte] = Array::make(img.width * img.height * ch, b'\x00')
  for y in 0..<img.height {
    for x in 0..<img.width {
      let nx = img.width - 1 - x
      let src = (y * img.width + x) * ch
      let dst = (y * img.width + nx) * ch
      for c in 0..<ch {
        out[dst + c] = img.data[src + c]
      }
    }
  }
  @types.Image::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(out),
  }
}
