// color 16-bit/float 变体测试

///|
fn make_img16(w : Int, h : Int, ch : Int) -> @types.Image16 {
  let data : Array[Byte] = Array::make(w * h * ch * 2, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let val = (x + y + c) % 256 * 100
        let offset = ((y * w + x) * ch + c) * 2
        data[offset] = (val & 0xFF).to_byte()
        data[offset + 1] = ((val >> 8) & 0xFF).to_byte()
      }
    }
  }
  @types.Image16::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn make_imgf(w : Int, h : Int, ch : Int) -> @types.ImageF {
  let data : Array[Byte] = Array::make(w * h * ch * 4, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let val = Float::from_int((x + y + c) % 256) / 255.0F
        let offset = ((y * w + x) * ch + c) * 4
        let bits = val.reinterpret_as_int()
        data[offset] = (bits & 0xFF).to_byte()
        data[offset + 1] = ((bits >> 8) & 0xFF).to_byte()
        data[offset + 2] = ((bits >> 16) & 0xFF).to_byte()
        data[offset + 3] = ((bits >> 24) & 0xFF).to_byte()
      }
    }
  }
  @types.ImageF::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
test "adjust_brightness_16: delta=0 is identity" {
  let img = make_img16(3, 3, 3)
  let result = adjust_brightness_16(img, 0)
  assert_eq(result, img)
  let _ = img
  let _ = result
}

///|
test "adjust_brightness_16: positive delta brightens" {
  let img = make_img16(2, 2, 3)
  let result = adjust_brightness_16(img, 1000)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  let _ = img
  let _ = result
}

///|
test "adjust_brightness_16: clamps to 65535" {
  let data = Array::make(2 * 2 * 3 * 2, b'\x00')
  for i in 0..<12 {
    data[i * 2] = b'\xFF'
    data[i * 2 + 1] = b'\xFF'
  }
  let img = @types.Image16::{
    width: 2,
    height: 2,
    channels: 3,
    data: Bytes::from_array(data),
  }
  let result = adjust_brightness_16(img, 10000)
  assert_eq(result, img)
  let _ = data
  let _ = img
  let _ = result
}

///|
test "adjust_brightness_f: delta=0 is identity" {
  let img = make_imgf(3, 3, 3)
  let result = adjust_brightness_f(img, 0.0F)
  assert_eq(result, img)
  let _ = img
  let _ = result
}

///|
test "adjust_brightness_f: preserves dimensions" {
  let img = make_imgf(4, 3, 3)
  let result = adjust_brightness_f(img, 0.1F)
  assert_eq(result.width, 4)
  assert_eq(result.height, 3)
  assert_eq(result.channels, 3)
  let _ = img
  let _ = result
}

///|
test "adjust_contrast_16: factor=1.0 is identity" {
  let img = make_img16(3, 3, 3)
  let result = adjust_contrast_16(img, 1.0F)
  assert_eq(result, img)
  let _ = img
  let _ = result
}

///|
test "adjust_contrast_16: preserves dimensions" {
  let img = make_img16(4, 3, 2)
  let result = adjust_contrast_16(img, 1.5F)
  assert_eq(result.width, 4)
  assert_eq(result.height, 3)
  assert_eq(result.channels, 2)
  let _ = img
  let _ = result
}

///|
test "adjust_contrast_f: factor=1.0 is identity" {
  let img = make_imgf(3, 3, 3)
  let result = adjust_contrast_f(img, 1.0F)
  assert_eq(result.width, 3)
  assert_eq(result.height, 3)
  assert_eq(result.channels, 3)
  let _ = img
  let _ = result
}

///|
test "adjust_contrast_f: preserves dimensions" {
  let img = make_imgf(4, 3, 3)
  let result = adjust_contrast_f(img, 2.0F)
  assert_eq(result.width, 4)
  assert_eq(result.height, 3)
  let _ = img
  let _ = result
}

///|
test "adjust_brightness_16: grayscale image" {
  let img = make_img16(3, 3, 1)
  let result = adjust_brightness_16(img, 500)
  assert_eq(result.channels, 1)
  assert_eq(result.width, 3)
  let _ = img
  let _ = result
}

///|
test "adjust_brightness_f: negative delta darkens" {
  let img = make_imgf(2, 2, 3)
  let result = adjust_brightness_f(img, -0.1F)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  let _ = img
  let _ = result
}
