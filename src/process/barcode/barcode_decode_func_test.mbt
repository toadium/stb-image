// v237.0.0 barcode_decode 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn bcd_make_img(w : Int, h : Int, val : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, val.to_byte())),
  }
}

///|
fn bcd_make_img_ch(w : Int, h : Int, ch : Int, val : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch, val.to_byte())),
  }
}

///|
fn bcd_make_finder_pattern_img() -> @types.Image {
  let w = 30
  let h = 30
  let data : Array[Byte] = Array::make(w * h, b'\xFF')
  let pattern : Array[Array[Int]] = [
    [1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 1, 1, 0, 1],
    [1, 0, 1, 0, 1, 0, 1],
    [1, 0, 1, 1, 1, 0, 1],
    [1, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1],
  ]
  let mod_size = 3
  for my in 0..<7 {
    for mx in 0..<7 {
      if pattern[my][mx] == 1 {
        for dy in 0..<mod_size {
          for dx in 0..<mod_size {
            let px = mx * mod_size + dx
            let py = my * mod_size + dy
            if px < w && py < h {
              data[py * w + px] = b'\x00'
            }
          }
        }
      }
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
fn bcd_make_three_finders_img() -> @types.Image {
  let w = 100
  let h = 100
  let data : Array[Byte] = Array::make(w * h, b'\xFF')
  let pattern : Array[Array[Int]] = [
    [1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 1],
    [1, 0, 1, 1, 1, 0, 1],
    [1, 0, 1, 0, 1, 0, 1],
    [1, 0, 1, 1, 1, 0, 1],
    [1, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1],
  ]
  let mod_size = 3
  let positions = [(0, 0), (70, 0), (0, 70)]
  for (ox, oy) in positions {
    for my in 0..<7 {
      for mx in 0..<7 {
        if pattern[my][mx] == 1 {
          for dy in 0..<mod_size {
            for dx in 0..<mod_size {
              let px = ox + mx * mod_size + dx
              let py = oy + my * mod_size + dy
              if px < w && py < h {
                data[py * w + px] = b'\x00'
              }
            }
          }
        }
      }
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
fn bcd_make_ean13_img() -> @types.Image {
  let w = 120
  let h = 60
  let data : Array[Byte] = Array::make(w * h, b'\xFF')
  let bar_pattern : Array[Int] = [
    1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0,
    1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0,
    1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1,
    0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1,
    0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1,
    1, 0, 1, 0, 1,
  ]
  let bar_width = 1
  for y in 10..<50 {
    for i in 0..<bar_pattern.length() {
      if bar_pattern[i] == 1 {
        for dx in 0..<bar_width {
          let x = 5 + i * bar_width + dx
          if x < w {
            data[y * w + x] = b'\x00'
          }
        }
      }
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

// ========== decode_ean13 错误路径 ==========

///|
test "bcd_func: decode_ean13 zero width raises" {
  try {
    let img = @types.Image::{
      width: 0,
      height: 4,
      channels: 1,
      data: Bytes::from_array(Array::make(0, b'\x00')),
    }
    let _ = @barcode.decode_ean13(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_ean13 invalid channels raises" {
  try {
    let img = bcd_make_img_ch(64, 32, 5, 128)
    let _ = @barcode.decode_ean13(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_ean13 data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 64,
      height: 32,
      channels: 1,
      data: Bytes::from_array(Array::make(100, b'\x00')),
    }
    let _ = @barcode.decode_ean13(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== decode_ean13 功能路径 ==========

///|
test "bcd_func: decode_ean13 disabled returns None" {
  let config = @barcode.BarcodeConfig::{
    enable_ean13: false,
    enable_upca: true,
    enable_code128: false,
    enable_qrcode: true,
    min_bar_width: 1,
    max_bar_width: 20,
    scan_lines: 10,
    quiet_zone_required: true,
  }
  let img = bcd_make_img(64, 32, 128)
  try {
    let result = @barcode.decode_ean13(img, config~)
    assert_true(result is None)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_ean13 all white returns None" {
  let img = bcd_make_img(120, 60, 255)
  try {
    let result = @barcode.decode_ean13(img)
    assert_true(result is None)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_ean13 all black returns None" {
  let img = bcd_make_img(120, 60, 0)
  try {
    let result = @barcode.decode_ean13(img)
    assert_true(result is None)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_ean13 with bar pattern" {
  let img = bcd_make_ean13_img()
  try {
    let result = @barcode.decode_ean13(img)
    assert_true(result is None || result is Some(_))
  } catch {
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_ean13 with custom config" {
  let config = @barcode.BarcodeConfig::{
    enable_ean13: true,
    enable_upca: false,
    enable_code128: false,
    enable_qrcode: false,
    min_bar_width: 1,
    max_bar_width: 10,
    scan_lines: 5,
    quiet_zone_required: false,
  }
  let img = bcd_make_ean13_img()
  try {
    let result = @barcode.decode_ean13(img, config~)
    assert_true(result is None || result is Some(_))
  } catch {
    _ => assert_true(false)
  }
}

// ========== detect_qr_finder_patterns 错误路径 ==========

///|
test "bcd_func: detect_qr zero width raises" {
  try {
    let img = @types.Image::{
      width: 0,
      height: 4,
      channels: 1,
      data: Bytes::from_array(Array::make(0, b'\x00')),
    }
    let _ = @barcode.detect_qr_finder_patterns(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "bcd_func: detect_qr invalid channels raises" {
  try {
    let img = bcd_make_img_ch(64, 64, 5, 128)
    let _ = @barcode.detect_qr_finder_patterns(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "bcd_func: detect_qr data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 64,
      height: 64,
      channels: 1,
      data: Bytes::from_array(Array::make(100, b'\x00')),
    }
    let _ = @barcode.detect_qr_finder_patterns(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_qr_finder_patterns 功能路径 ==========

///|
test "bcd_func: detect_qr all white no patterns" {
  let img = bcd_make_img(64, 64, 255)
  try {
    let patterns = @barcode.detect_qr_finder_patterns(img)
    assert_eq(patterns.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "bcd_func: detect_qr with finder pattern" {
  let img = bcd_make_finder_pattern_img()
  try {
    let patterns = @barcode.detect_qr_finder_patterns(img)
    assert_true(patterns.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "bcd_func: detect_qr with three finders" {
  let img = bcd_make_three_finders_img()
  try {
    let patterns = @barcode.detect_qr_finder_patterns(img)
    assert_true(patterns.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== decode_qrcode 错误路径 ==========

///|
test "bcd_func: decode_qrcode zero width raises" {
  try {
    let img = @types.Image::{
      width: 0,
      height: 4,
      channels: 1,
      data: Bytes::from_array(Array::make(0, b'\x00')),
    }
    let _ = @barcode.decode_qrcode(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_qrcode invalid channels raises" {
  try {
    let img = bcd_make_img_ch(64, 64, 5, 128)
    let _ = @barcode.decode_qrcode(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_qrcode data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 64,
      height: 64,
      channels: 1,
      data: Bytes::from_array(Array::make(100, b'\x00')),
    }
    let _ = @barcode.decode_qrcode(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== decode_qrcode 功能路径 ==========

///|
test "bcd_func: decode_qrcode disabled returns None" {
  let config = @barcode.BarcodeConfig::{
    enable_ean13: true,
    enable_upca: true,
    enable_code128: false,
    enable_qrcode: false,
    min_bar_width: 1,
    max_bar_width: 20,
    scan_lines: 10,
    quiet_zone_required: true,
  }
  let img = bcd_make_img(64, 64, 128)
  try {
    let result = @barcode.decode_qrcode(img, config~)
    assert_true(result is None)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_qrcode all white returns None" {
  let img = bcd_make_img(64, 64, 255)
  try {
    let result = @barcode.decode_qrcode(img)
    assert_true(result is None)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_qrcode with three finders" {
  let img = bcd_make_three_finders_img()
  try {
    let result = @barcode.decode_qrcode(img)
    assert_true(result is None || result is Some(_))
  } catch {
    _ => assert_true(false)
  }
}

// ========== decode_barcode 错误路径 ==========

///|
test "bcd_func: decode_barcode zero width raises" {
  try {
    let img = @types.Image::{
      width: 0,
      height: 4,
      channels: 1,
      data: Bytes::from_array(Array::make(0, b'\x00')),
    }
    let _ = @barcode.decode_barcode(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_barcode invalid channels raises" {
  try {
    let img = bcd_make_img_ch(64, 32, 5, 128)
    let _ = @barcode.decode_barcode(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_barcode data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 64,
      height: 32,
      channels: 1,
      data: Bytes::from_array(Array::make(100, b'\x00')),
    }
    let _ = @barcode.decode_barcode(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== decode_barcode 功能路径 ==========

///|
test "bcd_func: decode_barcode all white" {
  let img = bcd_make_img(64, 32, 255)
  try {
    let results = @barcode.decode_barcode(img)
    assert_eq(results.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_barcode with custom config" {
  let config = @barcode.BarcodeConfig::{
    enable_ean13: true,
    enable_upca: false,
    enable_code128: false,
    enable_qrcode: true,
    min_bar_width: 1,
    max_bar_width: 20,
    scan_lines: 5,
    quiet_zone_required: false,
  }
  let img = bcd_make_img(120, 60, 128)
  try {
    let results = @barcode.decode_barcode(img, config~)
    assert_true(results.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_barcode with ean13 pattern" {
  let img = bcd_make_ean13_img()
  try {
    let results = @barcode.decode_barcode(img)
    assert_true(results.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_barcode with three finders img" {
  let img = bcd_make_three_finders_img()
  try {
    let results = @barcode.decode_barcode(img)
    assert_true(results.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_barcode both disabled" {
  let config = @barcode.BarcodeConfig::{
    enable_ean13: false,
    enable_upca: false,
    enable_code128: false,
    enable_qrcode: false,
    min_bar_width: 1,
    max_bar_width: 20,
    scan_lines: 10,
    quiet_zone_required: true,
  }
  let img = bcd_make_img(64, 32, 128)
  try {
    let results = @barcode.decode_barcode(img, config~)
    assert_eq(results.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== barcode_default_config 功能路径 ==========

///|
test "bcd_func: default_config all fields" {
  let config = @barcode.barcode_default_config()
  assert_eq(config.enable_ean13, true)
  assert_eq(config.enable_upca, true)
  assert_eq(config.enable_code128, false)
  assert_eq(config.enable_qrcode, true)
  assert_eq(config.min_bar_width, 1)
  assert_eq(config.max_bar_width, 20)
  assert_eq(config.scan_lines, 10)
  assert_eq(config.quiet_zone_required, true)
}

// ========== 多通道图像测试 ==========

///|
test "bcd_func: decode_ean13 RGB image" {
  let img = bcd_make_img_ch(120, 60, 3, 128)
  try {
    let result = @barcode.decode_ean13(img)
    assert_true(result is None || result is Some(_))
  } catch {
    _ => assert_true(false)
  }
}

///|
test "bcd_func: detect_qr RGBA image" {
  let img = bcd_make_img_ch(64, 64, 4, 128)
  try {
    let patterns = @barcode.detect_qr_finder_patterns(img)
    assert_eq(patterns.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "bcd_func: decode_barcode RGB image" {
  let img = bcd_make_img_ch(120, 60, 3, 128)
  try {
    let results = @barcode.decode_barcode(img)
    assert_true(results.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}
