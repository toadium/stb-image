///|
/// TIFF 扩展信息（包含压缩方式、光度解释、方向、分辨率等）
pub struct TiffInfoExtended {
  width : Int32
  height : Int32
  bit_depth : Int32
  samples_per_pixel : Int32
  num_channels : Int32
  has_alpha : Bool
  compression : Int32
  compression_name : String
  photometric : Int32
  photometric_name : String
  orientation : Int32
  resolution_unit : Int32
  is_little_endian : Bool
}

///|
/// 检测数据是否为 TIFF 格式
pub fn is_tiff_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 8 {
    return false
  }
  // Little-endian: II + 42
  if data[0].to_int() == 0x49 &&
    data[1].to_int() == 0x49 &&
    data[2].to_int() == 0x2A &&
    data[3].to_int() == 0x00 {
    return true
  }
  // Big-endian: MM + 42
  data[0].to_int() == 0x4D &&
  data[1].to_int() == 0x4D &&
  data[2].to_int() == 0x00 &&
  data[3].to_int() == 0x2A
}

///|
fn tiff_compression_name(c : Int32) -> String {
  match c {
    1 => "none"
    2 => "CCITT RLE"
    5 => "LZW"
    6 => "JPEG"
    7 => "JPEG lossy"
    8 => "Deflate"
    32773 => "PackBits"
    32946 => "Deflate (old)"
    _ => "unknown"
  }
}

///|
fn tiff_photometric_name(p : Int32) -> String {
  match p {
    0 => "WhiteIsZero"
    1 => "BlackIsZero"
    2 => "RGB"
    3 => "Palette"
    4 => "TransparencyMask"
    5 => "CMYK"
    6 => "YCbCr"
    8 => "CIELab"
    _ => "unknown"
  }
}

///|
/// 解析 TIFF 扩展头部信息
///
/// 遍历 IFD 标签，提取尺寸、位深、压缩方式、光度解释、方向、分辨率单位等
pub fn tiff_info_extended(
  data : Bytes,
) -> TiffInfoExtended raise @types.LoadError {
  if !is_tiff_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not a TIFF file")
  }
  let len = data.length()
  let little_endian = data[0].to_int() == 0x49
  let ctx = TiffContext::{ data, little_endian, }
  let ifd_offset = tiff_read_u32(ctx, 4)
  if ifd_offset < 0 || ifd_offset >= len {
    raise @types.LoadError::DecodeFailed("TIFF IFD 偏移无效")
  }
  let entries = tiff_parse_ifd(ctx, ifd_offset)
  let width = match tiff_get_value(entries, ctx, 256) {
    Some(w) => w
    None => raise @types.LoadError::DecodeFailed("TIFF 缺少 ImageWidth")
  }
  let height = match tiff_get_value(entries, ctx, 257) {
    Some(h) => h
    None => raise @types.LoadError::DecodeFailed("TIFF 缺少 ImageLength")
  }
  let bits_per_sample = match tiff_get_values(entries, ctx, 258) {
    Some(arr) => if arr.length() > 0 { arr[0] } else { 8 }
    None => 8
  }
  let compression = match tiff_get_value(entries, ctx, 259) {
    Some(c) => c
    None => 1
  }
  let photometric = match tiff_get_value(entries, ctx, 262) {
    Some(p) => p
    None => 1
  }
  let samples_per_pixel = match tiff_get_value(entries, ctx, 277) {
    Some(s) => s
    None => 1
  }
  let orientation = match tiff_get_value(entries, ctx, 274) {
    Some(o) => o
    None => 1
  }
  let resolution_unit = match tiff_get_value(entries, ctx, 296) {
    Some(r) => r
    None => 2
  }
  let extra_samples = match tiff_get_value(entries, ctx, 338) {
    Some(e) => e
    None => 0
  }
  if width <= 0 || height <= 0 {
    raise @types.LoadError::DecodeFailed("TIFF 尺寸无效")
  }
  let has_alpha = extra_samples > 0 ||
    samples_per_pixel == 4 ||
    (samples_per_pixel == 2 && photometric == 1)
  let num_channels = if has_alpha {
    samples_per_pixel
  } else {
    samples_per_pixel
  }
  TiffInfoExtended::{
    width,
    height,
    bit_depth: bits_per_sample,
    samples_per_pixel,
    num_channels,
    has_alpha,
    compression,
    compression_name: tiff_compression_name(compression),
    photometric,
    photometric_name: tiff_photometric_name(photometric),
    orientation,
    resolution_unit,
    is_little_endian: little_endian,
  }
}
