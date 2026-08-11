// 示例通用辅助函数：构造测试用图像

///|
fn make_rgb_image(
  width : Int,
  height : Int,
  pixels : Array[(Int, Int, Int)],
) -> @types.Image {
  let data : Array[Byte] = []
  for p in pixels {
    data.push(p.0.to_byte())
    data.push(p.1.to_byte())
    data.push(p.2.to_byte())
  }
  @types.Image::{ width, height, channels: 3, data: Bytes::from_array(data) }
}

///|
fn make_gray_image(
  width : Int,
  height : Int,
  values : Array[Int],
) -> @types.Image {
  @types.Image::{
    width,
    height,
    channels: 1,
    data: Bytes::from_array(values.map(fn(v) { v.to_byte() })),
  }
}

///|
fn make_gradient_image(width : Int, height : Int) -> @types.Image {
  let data : Array[Byte] = []
  for y in 0..<height {
    for x in 0..<width {
      let v = ((x + y) * 255 / (width + height - 2)).clamp(min=0, max=255)
      data.push(v.to_byte())
    }
  }
  @types.Image::{ width, height, channels: 1, data: Bytes::from_array(data) }
}

///|
fn has_non_zero_pixel(img : @types.Image) -> Bool {
  let len = img.data.length()
  for i in 0..<len {
    if img.data[i].to_int() > 0 {
      return true
    }
  }
  false
}

///|
fn is_binary_image(img : @types.Image) -> Bool {
  let len = img.data.length()
  for i in 0..<len {
    let v = img.data[i].to_int()
    if v != 0 && v != 255 {
      return false
    }
  }
  true
}

///|
fn images_differ(a : @types.Image, b : @types.Image) -> Bool {
  let len = a.data.length()
  for i in 0..<len {
    if a.data[i] != b.data[i] {
      return true
    }
  }
  false
}
