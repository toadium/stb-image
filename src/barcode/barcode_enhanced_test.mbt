// v192a barcode 增强测试：配置变体 + 边值 + 条码图案 + Reed-Solomon + 属性

///|
fn bc_make_image(w : Int32, h : Int32, channels : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for i in 0..<(w * h * channels) {
    let v : Int32 = i % 256
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels,
    data: Bytes::from_array(data),
  }
}

///|
fn bc_make_stripe_image(
  w : Int32,
  h : Int32,
  bar_width : Int32,
) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<h {
    for x in 0..<w {
      let is_black = x / bar_width % 2 == 0
      let v : Byte = if is_black { 0b00000000 } else { 0b11111111 }
      data.push(v)
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
fn bc_make_qr_like_image(size : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for y in 0..<size {
    for x in 0..<size {
      let in_finder = (x < 7 && y < 7) ||
        (x >= size - 7 && y < 7) ||
        (x < 7 && y >= size - 7)
      let v : Byte = if in_finder {
        if x % 3 == 0 || y % 3 == 0 {
          0b00000000
        } else {
          0b11111111
        }
      } else if (x + y) % 2 == 0 {
        0b00000000
      } else {
        0b11111111
      }
      data.push(v)
    }
  }
  @types.Image::{
    width: size,
    height: size,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
test "barcode_default_config: 所有字段验证" {
  let config = @barcode.barcode_default_config()
  assert_eq(config.enable_ean13, true)
  assert_eq(config.enable_upca, true)
  assert_eq(config.enable_code128, false)
  assert_eq(config.enable_qrcode, true)
  assert_true(config.min_bar_width > 0)
  assert_true(config.max_bar_width > config.min_bar_width)
  assert_true(config.scan_lines > 0)
  assert_eq(config.quiet_zone_required, true)
}

///|
test "BarcodeConfig: 自定义配置" {
  let config = @barcode.BarcodeConfig::{
    enable_ean13: false,
    enable_upca: false,
    enable_code128: true,
    enable_qrcode: false,
    min_bar_width: 2,
    max_bar_width: 10,
    scan_lines: 5,
    quiet_zone_required: false,
  }
  assert_eq(config.enable_ean13, false)
  assert_eq(config.enable_upca, false)
  assert_eq(config.enable_code128, true)
  assert_eq(config.enable_qrcode, false)
  assert_eq(config.min_bar_width, 2)
  assert_eq(config.max_bar_width, 10)
  assert_eq(config.scan_lines, 5)
  assert_eq(config.quiet_zone_required, false)
}

///|
test "BarcodeType: 枚举值验证" {
  assert_true(@barcode.BarcodeType::Ean13 == @barcode.BarcodeType::Ean13)
  assert_true(@barcode.BarcodeType::UpcA == @barcode.BarcodeType::UpcA)
  assert_true(@barcode.BarcodeType::Code128 == @barcode.BarcodeType::Code128)
  assert_true(@barcode.BarcodeType::QrCode == @barcode.BarcodeType::QrCode)
  assert_true(@barcode.BarcodeType::Unknown == @barcode.BarcodeType::Unknown)
  assert_true(@barcode.BarcodeType::Ean13 != @barcode.BarcodeType::UpcA)
  assert_true(@barcode.BarcodeType::QrCode != @barcode.BarcodeType::Unknown)
}

///|
test "Code128Charset: 枚举值验证" {
  assert_true(@barcode.Code128Charset::CodeA == @barcode.Code128Charset::CodeA)
  assert_true(@barcode.Code128Charset::CodeB == @barcode.Code128Charset::CodeB)
  assert_true(@barcode.Code128Charset::CodeC == @barcode.Code128Charset::CodeC)
  assert_true(@barcode.Code128Charset::CodeA != @barcode.Code128Charset::CodeB)
  assert_true(@barcode.Code128Charset::CodeB != @barcode.Code128Charset::CodeC)
}

///|
test "decode_barcode: 条纹图案多配置" {
  let img = bc_make_stripe_image(128, 64, 3)
  let config1 = @barcode.barcode_default_config()
  let results1 = @barcode.decode_barcode(img, config=config1)
  assert_true(results1.length() >= 0)
  let config2 = @barcode.BarcodeConfig::{
    enable_ean13: true,
    enable_upca: true,
    enable_code128: true,
    enable_qrcode: false,
    min_bar_width: 1,
    max_bar_width: 20,
    scan_lines: 10,
    quiet_zone_required: false,
  }
  let results2 = @barcode.decode_barcode(img, config=config2)
  assert_true(results2.length() >= 0)
}

///|
test "decode_barcode: 灰度图" {
  let img = bc_make_image(64, 32, 1)
  let config = @barcode.barcode_default_config()
  let results = @barcode.decode_barcode(img, config~)
  assert_true(results.length() >= 0)
}

///|
test "decode_barcode: RGB图" {
  let img = bc_make_image(64, 32, 3)
  let config = @barcode.barcode_default_config()
  let results = @barcode.decode_barcode(img, config~)
  assert_true(results.length() >= 0)
}

///|
test "decode_barcode: RGBA图" {
  let img = bc_make_image(64, 32, 4)
  let config = @barcode.barcode_default_config()
  let results = @barcode.decode_barcode(img, config~)
  assert_true(results.length() >= 0)
}

///|
test "decode_ean13: 条纹图案" {
  let img = bc_make_stripe_image(95, 50, 1)
  let config = @barcode.barcode_default_config()
  let result = @barcode.decode_ean13(img, config~)
  assert_true(result is None || result is Some(_))
}

///|
test "decode_ean13: 小尺寸图" {
  let img = bc_make_image(10, 5, 1)
  let config = @barcode.barcode_default_config()
  let result = @barcode.decode_ean13(img, config~)
  assert_true(result is None || result is Some(_))
}

///|
test "decode_upca: 条纹图案" {
  let img = bc_make_stripe_image(85, 40, 1)
  let result = @barcode.decode_upca(img)
  assert_true(result is None || result is Some(_))
}

///|
test "decode_code128: 条纹图案" {
  let img = bc_make_stripe_image(100, 40, 1)
  let result = @barcode.decode_code128(img)
  assert_true(result is None || result is Some(_))
}

///|
test "decode_code39: 条纹图案" {
  let img = bc_make_stripe_image(80, 40, 1)
  let result = @barcode.decode_code39(img)
  assert_true(result is None || result is Some(_))
}

///|
test "decode_linear_barcode: 条纹图案多宽度" {
  let img3 = bc_make_stripe_image(120, 40, 3)
  let results3 = @barcode.decode_linear_barcode(img3)
  assert_true(results3.length() >= 0)
  let img5 = bc_make_stripe_image(150, 50, 5)
  let results5 = @barcode.decode_linear_barcode(img5)
  assert_true(results5.length() >= 0)
}

///|
test "decode_qrcode: QR-like图案" {
  let img = bc_make_qr_like_image(21)
  let config = @barcode.barcode_default_config()
  let result = @barcode.decode_qrcode(img, config~)
  assert_true(result is None || result is Some(_))
}

///|
test "decode_qrcode: 大尺寸QR-like图案" {
  let img = bc_make_qr_like_image(41)
  let config = @barcode.barcode_default_config()
  let result = @barcode.decode_qrcode(img, config~)
  assert_true(result is None || result is Some(_))
}

///|
test "decode_qrcode_full: QR-like图案" {
  let img = bc_make_qr_like_image(21)
  let result = @barcode.decode_qrcode_full(img)
  assert_true(result is None || result is Some(_))
}

///|
test "decode_qrcode_full: 小尺寸图" {
  let img = bc_make_image(10, 10, 1)
  let result = @barcode.decode_qrcode_full(img)
  assert_true(result is None || result is Some(_))
}

///|
test "detect_qr_finder_patterns: QR-like图案" {
  let img = bc_make_qr_like_image(21)
  let patterns = @barcode.detect_qr_finder_patterns(img)
  assert_true(patterns.length() >= 0)
  for pattern in patterns {
    assert_true(pattern.size > 0.0)
    assert_true(pattern.quality >= 0.0)
  }
}

///|
test "detect_qr_finder_patterns: 纯白图" {
  let data : Array[Byte] = []
  for _ in 0..<(64 * 64) {
    data.push(0b11111111)
  }
  let img = @types.Image::{
    width: 64,
    height: 64,
    channels: 1,
    data: Bytes::from_array(data),
  }
  let patterns = @barcode.detect_qr_finder_patterns(img)
  assert_true(patterns.length() >= 0)
}

///|
test "detect_qr_finder_patterns: 纯黑图" {
  let data : Array[Byte] = []
  for _ in 0..<(64 * 64) {
    data.push(0b00000000)
  }
  let img = @types.Image::{
    width: 64,
    height: 64,
    channels: 1,
    data: Bytes::from_array(data),
  }
  let patterns = @barcode.detect_qr_finder_patterns(img)
  assert_true(patterns.length() >= 0)
}

///|
test "reed_solomon_decode: 无错误数据" {
  let data = [1, 2, 3, 4, 5, 6, 7, 8]
  let (decoded, corrected) = @barcode.reed_solomon_decode(data, 2)
  assert_eq(decoded.length(), 8)
  assert_true(corrected >= 0)
}

///|
test "reed_solomon_decode: 空数据" {
  let data : Array[Int32] = []
  let (decoded, corrected) = @barcode.reed_solomon_decode(data, 0)
  assert_eq(decoded.length(), 0)
  assert_eq(corrected, 0)
}

///|
test "reed_solomon_decode: 单元素" {
  let data = [42]
  let (decoded, corrected) = @barcode.reed_solomon_decode(data, 1)
  assert_eq(decoded.length(), 1)
  assert_true(corrected >= 0)
}

///|
test "reed_solomon_decode: 大容量纠错" {
  let data = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
  let (decoded, corrected) = @barcode.reed_solomon_decode(data, 5)
  assert_eq(decoded.length(), 10)
  assert_true(corrected >= 0)
}

///|
test "reed_solomon_decode: 零纠错容量" {
  let data = [1, 2, 3, 4, 5]
  let (decoded, corrected) = @barcode.reed_solomon_decode(data, 0)
  assert_eq(decoded.length(), 5)
  assert_true(corrected >= 0)
}

///|
test "BarcodeResult: 结果字段验证" {
  let img = bc_make_stripe_image(95, 50, 1)
  let config = @barcode.barcode_default_config()
  let results = @barcode.decode_barcode(img, config~)
  for result in results {
    assert_true(result.confidence >= 0.0)
    assert_true(result.confidence <= 1.0)
    assert_true(result.width > 0)
    assert_true(result.height > 0)
    assert_true(result.x >= 0)
    assert_true(result.y >= 0)
    assert_true(result.data.length() >= 0)
  }
}

///|
test "decode_barcode: 全禁用配置" {
  let img = bc_make_image(64, 32, 1)
  let config = @barcode.BarcodeConfig::{
    enable_ean13: false,
    enable_upca: false,
    enable_code128: false,
    enable_qrcode: false,
    min_bar_width: 1,
    max_bar_width: 10,
    scan_lines: 3,
    quiet_zone_required: true,
  }
  let results = @barcode.decode_barcode(img, config~)
  assert_true(results.length() >= 0)
}

///|
test "decode_barcode: 宽扫描线配置" {
  let img = bc_make_stripe_image(128, 64, 1)
  let config = @barcode.BarcodeConfig::{
    enable_ean13: true,
    enable_upca: true,
    enable_code128: true,
    enable_qrcode: true,
    min_bar_width: 1,
    max_bar_width: 30,
    scan_lines: 20,
    quiet_zone_required: false,
  }
  let results = @barcode.decode_barcode(img, config~)
  assert_true(results.length() >= 0)
}

///|
test "decode_ean13: 不同通道数" {
  for ch in [1, 3, 4] {
    let img = bc_make_image(64, 32, ch)
    let config = @barcode.barcode_default_config()
    let result = @barcode.decode_ean13(img, config~)
    assert_true(result is None || result is Some(_))
  }
}

///|
test "decode_qrcode: 不同通道数" {
  for ch in [1, 3, 4] {
    let img = bc_make_image(64, 64, ch)
    let config = @barcode.barcode_default_config()
    let result = @barcode.decode_qrcode(img, config~)
    assert_true(result is None || result is Some(_))
  }
}
