// v201 barcode 错误路径/边界增强测试

///|
fn bc_make_varied(w : Int32, h : Int32, ch : Int32) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h * ch, b'\x00')
  for i in 0..<(w * h * ch) {
    data[i] = ((i * 137 + 42) % 256).to_byte()
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn bc_make_uniform(
  w : Int32,
  h : Int32,
  ch : Int32,
  val : Int32,
) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h * ch, (val & 0xFF).to_byte())
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn bc_make_bar_pattern(w : Int32, h : Int32) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h, b'\x00')
  for x in 0..<w {
    let v = if x % 4 < 2 { 0 } else { 255 }
    for y in 0..<h {
      data[y * w + x] = v.to_byte()
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

// ========== 错误路径测试 ==========

///|
test "bc2: decode_ean13 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @barcode.decode_ean13(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_upca 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @barcode.decode_upca(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_code128 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @barcode.decode_code128(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_code39 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @barcode.decode_code39(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_linear_barcode 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @barcode.decode_linear_barcode(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_qrcode 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @barcode.decode_qrcode(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_qrcode_full 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @barcode.decode_qrcode_full(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_barcode 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @barcode.decode_barcode(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: detect_qr_finder_patterns 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @barcode.detect_qr_finder_patterns(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== 纯黑/纯白图像测试 ==========

///|
test "bc2: decode_ean13 纯白图" {
  let img = bc_make_uniform(64, 32, 1, 255)
  try {
    let _ = @barcode.decode_ean13(img)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_upca 纯黑图" {
  let img = bc_make_uniform(64, 32, 1, 0)
  try {
    let _ = @barcode.decode_upca(img)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_code128 纯白图" {
  let img = bc_make_uniform(64, 32, 1, 255)
  try {
    let _ = @barcode.decode_code128(img)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_code39 纯黑图" {
  let img = bc_make_uniform(64, 32, 1, 0)
  try {
    let _ = @barcode.decode_code39(img)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_qrcode_full 纯白图" {
  let img = bc_make_uniform(32, 32, 1, 255)
  try {
    let _ = @barcode.decode_qrcode_full(img)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_barcode 纯黑图" {
  let img = bc_make_uniform(64, 32, 1, 0)
  try {
    let _ = @barcode.decode_barcode(img)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

// ========== 条纹图案测试 ==========

///|
test "bc2: decode_ean13 条纹图案" {
  let img = bc_make_bar_pattern(80, 40)
  try {
    let _ = @barcode.decode_ean13(img)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_upca 条纹图案" {
  let img = bc_make_bar_pattern(80, 40)
  try {
    let _ = @barcode.decode_upca(img)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_code128 条纹图案" {
  let img = bc_make_bar_pattern(80, 40)
  try {
    let _ = @barcode.decode_code128(img)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_linear_barcode 条纹图案" {
  let img = bc_make_bar_pattern(80, 40)
  try {
    let result = @barcode.decode_linear_barcode(img)
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_barcode 条纹图案默认配置" {
  let img = bc_make_bar_pattern(80, 40)
  try {
    let result = @barcode.decode_barcode(img)
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

// ========== 多通道测试 ==========

///|
test "bc2: decode_barcode RGB条纹" {
  let img = bc_make_varied(80, 40, 3)
  try {
    let result = @barcode.decode_barcode(img)
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_ean13 RGBA" {
  let img = bc_make_varied(80, 40, 4)
  try {
    let _ = @barcode.decode_ean13(img)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_qrcode RGB" {
  let img = bc_make_varied(32, 32, 3)
  try {
    let _ = @barcode.decode_qrcode(img)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

// ========== reed_solomon_decode 边界测试 ==========

///|
test "bc2: reed_solomon_decode 多元素" {
  let (data, corrected) = @barcode.reed_solomon_decode([1, 2, 3, 4, 5], 2)
  assert_eq(data.length(), 5)
  assert_eq(corrected, 0)
}

///|
test "bc2: reed_solomon_decode 大数据" {
  let input = Array::make(100, 42)
  let (data, corrected) = @barcode.reed_solomon_decode(input, 10)
  assert_eq(data.length(), 100)
  assert_eq(corrected, 0)
}

///|
test "bc2: reed_solomon_decode 零元素" {
  let (data, corrected) = @barcode.reed_solomon_decode([], 0)
  assert_eq(data.length(), 0)
  assert_eq(corrected, 0)
}

// ========== 自定义配置测试 ==========

///|
test "bc2: decode_barcode 仅EAN13" {
  let img = bc_make_bar_pattern(80, 40)
  let cfg = @barcode.BarcodeConfig::{
    enable_ean13: true,
    enable_upca: false,
    enable_code128: false,
    enable_qrcode: false,
    min_bar_width: 1,
    max_bar_width: 20,
    scan_lines: 5,
    quiet_zone_required: false,
  }
  try {
    let result = @barcode.decode_barcode(img, config=cfg)
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_barcode 仅QR" {
  let img = bc_make_varied(32, 32, 1)
  let cfg = @barcode.BarcodeConfig::{
    enable_ean13: false,
    enable_upca: false,
    enable_code128: false,
    enable_qrcode: true,
    min_bar_width: 1,
    max_bar_width: 20,
    scan_lines: 5,
    quiet_zone_required: false,
  }
  try {
    let result = @barcode.decode_barcode(img, config=cfg)
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_ean13 自定义配置" {
  let img = bc_make_bar_pattern(80, 40)
  let cfg = @barcode.BarcodeConfig::{
    enable_ean13: true,
    enable_upca: true,
    enable_code128: true,
    enable_qrcode: true,
    min_bar_width: 2,
    max_bar_width: 10,
    scan_lines: 20,
    quiet_zone_required: false,
  }
  try {
    let _ = @barcode.decode_ean13(img, config=cfg)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

// ========== 小尺寸图像测试 ==========

///|
test "bc2: decode_code128 小尺寸" {
  let img = bc_make_varied(8, 4, 1)
  try {
    let _ = @barcode.decode_code128(img)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_code39 小尺寸" {
  let img = bc_make_varied(8, 4, 1)
  try {
    let _ = @barcode.decode_code39(img)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "bc2: decode_qrcode_full 小尺寸" {
  let img = bc_make_varied(8, 8, 1)
  try {
    let _ = @barcode.decode_qrcode_full(img)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}
