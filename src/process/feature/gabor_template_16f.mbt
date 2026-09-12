// Gabor 滤波 + 模板匹配 16-bit/float 变体

// ========== 辅助函数 ==========

fn read_u16_le_gabor(data : Bytes, offset : Int) -> Int {
  data[offset].to_int() + data[offset + 1].to_int() * 256
}

fn write_u16_le_gabor(buf : Array[Byte], offset : Int, val : Int) -> Unit {
  buf[offset] = (val & 0xFF).to_byte()
  buf[offset + 1] = ((val >> 8) & 0xFF).to_byte()
}

fn read_float_le_gabor(data : Bytes, offset : Int) -> Float {
  let b0 = data[offset].to_int()
  let b1 = data[offset + 1].to_int()
  let b2 = data[offset + 2].to_int()
  let b3 = data[offset + 3].to_int()
  let bits = b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
  Float::reinterpret_from_int(bits)
}

fn write_f32_le_gabor(buf : Array[Byte], offset : Int, val : Float) -> Unit {
  let bits = val.reinterpret_as_int()
  buf[offset] = (bits & 0xFF).to_byte()
  buf[offset + 1] = ((bits >> 8) & 0xFF).to_byte()
  buf[offset + 2] = ((bits >> 16) & 0xFF).to_byte()
  buf[offset + 3] = ((bits >> 24) & 0xFF).to_byte()
}

fn clamp_int_gabor(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo { lo } else if v > hi { hi } else { v }
}

fn img16_to_img8_gabor(img : @types.Image16) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data8 : Array[Byte] = Array::make(w * h * ch, b'\x00')
  for i in 0..<(w * h * ch) {
    let v16 = read_u16_le_gabor(img.data, i * 2)
    data8[i] = (v16 / 257).to_byte()
  }
  @types.Image::{ width: w, height: h, channels: ch, data: Bytes::from_array(data8) }
}

fn imgf_to_img8_gabor(img : @types.ImageF) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data8 : Array[Byte] = Array::make(w * h * ch, b'\x00')
  for i in 0..<(w * h * ch) {
    let vf = read_float_le_gabor(img.data, i * 4)
    let v8 = clamp_int_gabor((vf * 255.0F).to_int(), 0, 255)
    data8[i] = v8.to_byte()
  }
  @types.Image::{ width: w, height: h, channels: ch, data: Bytes::from_array(data8) }
}

fn img8_to_img16_gabor(img : @types.Image) -> @types.Image16 {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data16 : Array[Byte] = Array::make(w * h * ch * 2, b'\x00')
  for i in 0..<(w * h * ch) {
    let v8 = img.data[i].to_int()
    write_u16_le_gabor(data16, i * 2, v8 * 257)
  }
  @types.Image16::{ width: w, height: h, channels: ch, data: Bytes::from_array(data16) }
}

fn img8_to_imgf_gabor(img : @types.Image) -> @types.ImageF {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let dataf : Array[Byte] = Array::make(w * h * ch * 4, b'\x00')
  for i in 0..<(w * h * ch) {
    let v8 = img.data[i].to_int()
    write_f32_le_gabor(dataf, i * 4, Float::from_int(v8) / 255.0F)
  }
  @types.ImageF::{ width: w, height: h, channels: ch, data: Bytes::from_array(dataf) }
}

// ========== Gabor 16-bit ==========

///|
/// 16-bit Gabor 滤波。
pub fn gabor_filter_16(
  img : @types.Image16,
  ksize : Int,
  sigma : Float,
  theta : Float,
  lambda? : Float = 10.0F,
  gamma? : Float = 0.5F,
  phi? : Float = 0.0F,
) -> @types.Image16 raise @types.LoadError {
  let img8 = img16_to_img8_gabor(img)
  let result8 = gabor_filter(img8, ksize, sigma, theta, lambda~, gamma~, phi~)
  img8_to_img16_gabor(result8)
}

// ========== Gabor float ==========

///|
/// float Gabor 滤波。
pub fn gabor_filter_f(
  img : @types.ImageF,
  ksize : Int,
  sigma : Float,
  theta : Float,
  lambda? : Float = 10.0F,
  gamma? : Float = 0.5F,
  phi? : Float = 0.0F,
) -> @types.ImageF raise @types.LoadError {
  let img8 = imgf_to_img8_gabor(img)
  let result8 = gabor_filter(img8, ksize, sigma, theta, lambda~, gamma~, phi~)
  img8_to_imgf_gabor(result8)
}

// ========== Gabor Bank 16-bit ==========

///|
/// 16-bit Gabor 滤波器组。
pub fn gabor_filter_bank_16(
  img : @types.Image16,
  ksize : Int,
  sigma : Float,
  num_orientations? : Int = 4,
  lambda? : Float = 10.0F,
  gamma? : Float = 0.5F,
) -> @types.Image16 raise @types.LoadError {
  let img8 = img16_to_img8_gabor(img)
  let result8 = gabor_filter_bank(img8, ksize, sigma, num_orientations~, lambda~, gamma~)
  img8_to_img16_gabor(result8)
}

// ========== Gabor Bank float ==========

///|
/// float Gabor 滤波器组。
pub fn gabor_filter_bank_f(
  img : @types.ImageF,
  ksize : Int,
  sigma : Float,
  num_orientations? : Int = 4,
  lambda? : Float = 10.0F,
  gamma? : Float = 0.5F,
) -> @types.ImageF raise @types.LoadError {
  let img8 = imgf_to_img8_gabor(img)
  let result8 = gabor_filter_bank(img8, ksize, sigma, num_orientations~, lambda~, gamma~)
  img8_to_imgf_gabor(result8)
}

// ========== Template Match 16-bit ==========

///|
/// 16-bit 模板匹配。
pub fn template_match_16(
  img : @types.Image16,
  template : @types.Image16,
  match_method? : TemplateMatchMethod = TemplateMatchMethod::CCoeffNormed,
) -> Array[TemplateMatchResult] raise @types.LoadError {
  let img8 = img16_to_img8_gabor(img)
  let tpl8 = img16_to_img8_gabor(template)
  template_match(img8, tpl8, match_method~)
}

// ========== Template Match float ==========

///|
/// float 模板匹配。
pub fn template_match_f(
  img : @types.ImageF,
  template : @types.ImageF,
  match_method? : TemplateMatchMethod = TemplateMatchMethod::CCoeffNormed,
) -> Array[TemplateMatchResult] raise @types.LoadError {
  let img8 = imgf_to_img8_gabor(img)
  let tpl8 = imgf_to_img8_gabor(template)
  template_match(img8, tpl8, match_method~)
}

// ========== Template Match Best 16-bit ==========

///|
/// 16-bit 模板匹配（最佳匹配）。
pub fn template_match_best_16(
  img : @types.Image16,
  template : @types.Image16,
  match_method? : TemplateMatchMethod = TemplateMatchMethod::CCoeffNormed,
) -> TemplateMatchResult? raise @types.LoadError {
  let img8 = img16_to_img8_gabor(img)
  let tpl8 = img16_to_img8_gabor(template)
  template_match_best(img8, tpl8, match_method~)
}

// ========== Template Match Best float ==========

///|
/// float 模板匹配（最佳匹配）。
pub fn template_match_best_f(
  img : @types.ImageF,
  template : @types.ImageF,
  match_method? : TemplateMatchMethod = TemplateMatchMethod::CCoeffNormed,
) -> TemplateMatchResult? raise @types.LoadError {
  let img8 = imgf_to_img8_gabor(img)
  let tpl8 = imgf_to_img8_gabor(template)
  template_match_best(img8, tpl8, match_method~)
}
