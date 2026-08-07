// 图像变换操作（纯 MoonBit）：crop / rotate / flip
// 支持 Image / Image16 / ImageF 三种类型

///|
/// 裁剪 8-bit Image 的指定区域
pub fn crop(
  img : @core.Image,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> @core.Image raise @core.LoadError {
  if x < 0 ||
    y < 0 ||
    w <= 0 ||
    h <= 0 ||
    x + w > img.width ||
    y + h > img.height {
    raise @core.LoadError::DecodeFailed("crop 区域越界")
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
  @core.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 顺时针旋转 90 度
pub fn rotate_90(img : @core.Image) -> @core.Image {
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
  @core.Image::{
    width: new_w,
    height: new_h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 旋转 180 度
pub fn rotate_180(img : @core.Image) -> @core.Image {
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
  @core.Image::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 顺时针旋转 270 度（逆时针 90 度）
pub fn rotate_270(img : @core.Image) -> @core.Image {
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
  @core.Image::{
    width: new_w,
    height: new_h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 水平翻转（左右镜像）
pub fn flip_horizontal(img : @core.Image) -> @core.Image {
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
  @core.Image::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 裁剪 16-bit Image16
pub fn crop_16(
  img : @core.Image16,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> @core.Image16 raise @core.LoadError {
  if x < 0 ||
    y < 0 ||
    w <= 0 ||
    h <= 0 ||
    x + w > img.width ||
    y + h > img.height {
    raise @core.LoadError::DecodeFailed("crop 区域越界")
  }
  let ch = img.channels
  let out : Array[Byte] = Array::make(w * h * ch * 2, b'\x00')
  for row in 0..<h {
    let src_off = ((y + row) * img.width + x) * ch * 2
    let dst_off = row * w * ch * 2
    for i in 0..<(w * ch * 2) {
      out[dst_off + i] = img.data[src_off + i]
    }
  }
  @core.Image16::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 裁剪 float ImageF
pub fn cropf(
  img : @core.ImageF,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> @core.ImageF raise @core.LoadError {
  if x < 0 ||
    y < 0 ||
    w <= 0 ||
    h <= 0 ||
    x + w > img.width ||
    y + h > img.height {
    raise @core.LoadError::DecodeFailed("crop 区域越界")
  }
  let ch = img.channels
  let out : Array[Byte] = Array::make(w * h * ch * 4, b'\x00')
  for row in 0..<h {
    let src_off = ((y + row) * img.width + x) * ch * 4
    let dst_off = row * w * ch * 4
    for i in 0..<(w * ch * 4) {
      out[dst_off + i] = img.data[src_off + i]
    }
  }
  @core.ImageF::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}
