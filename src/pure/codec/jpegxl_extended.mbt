///|
/// JPEG-XL 扩展信息
pub struct JpegXlInfoExtended {
  width : Int
  height : Int
  bit_depth : Int
  num_channels : Int
  has_alpha : Bool
  is_lossless : Bool
  is_codestream : Bool
  orientation : Int
}

///|
/// 位流读取器
priv struct JxlBitReader {
  data : Bytes
  mut byte_pos : Int
  mut bit_pos : Int
}

///|
fn JxlBitReader::new(data : Bytes, start : Int) -> JxlBitReader {
  JxlBitReader::{ data, byte_pos: start, bit_pos: 0, }
}

///|
fn JxlBitReader::read_bit(self : JxlBitReader) -> Int {
  if self.byte_pos >= self.data.length() {
    return 0
  }
  let byte = self.data[self.byte_pos].to_int()
  let bit = (byte >> (7 - self.bit_pos)) & 1
  self.bit_pos += 1
  if self.bit_pos == 8 {
    self.bit_pos = 0
    self.byte_pos += 1
  }
  bit
}

///|
fn JxlBitReader::read_bits(self : JxlBitReader, n : Int) -> Int {
  let mut result = 0
  for _ in 0..<n {
    result = (result << 1) | self.read_bit()
  }
  result
}

///|
fn JxlBitReader::read_u32(
  self : JxlBitReader,
  d0 : Int,
  d1 : Int,
  d2 : Int,
  d3 : Int,
) -> Int {
  let selector = self.read_bits(2)
  match selector {
    0 => d0
    1 => d1 + self.read_bits(8)
    2 => d2 + self.read_bits(16)
    _ => d3 + self.read_bits(24)
  }
}

///|
/// 从宽高比计算宽度
fn jxl_width_from_ratio(
  height : Int,
  ratio : Int,
  reader : JxlBitReader,
) -> Int {
  match ratio {
    0 => height
    1 => height * 4 / 3
    2 => height * 3 / 2
    3 => height * 16 / 9
    4 => height * 5 / 4
    5 => height * 2
    6 => if height >= 2 { height / 2 } else { 1 }
    _ => reader.read_u32(1, 257, 65793, 0) + 1
  }
}

///|
/// 解析 JPEG-XL 裸码流 SizeHeader
fn jxl_parse_size_header(data : Bytes, start : Int) -> (Int, Int) {
  let reader = JxlBitReader::new(data, start)
  let small = reader.read_bit()
  let height = if small == 1 {
    reader.read_bits(5) + 1
  } else {
    reader.read_u32(1, 257, 65793, 0) + 1
  }
  let ratio = reader.read_bits(3)
  let width = jxl_width_from_ratio(height, ratio, reader)
  (width, height)
}

///|
/// 在 ISOBMFF 容器中查找 codestream box 的偏移
fn jxl_find_codestream(data : Bytes) -> Int {
  let len = data.length()
  let mut offset = 0
  while offset + 8 <= len {
    let box_size = read_u32_be(data, offset)
    if box_size < 8 || offset + box_size > len {
      break
    }
    let btype = box_type_str(data, offset)
    // jxlc = codestream box, jxlp = partial codestream
    if btype == "jxlc" || btype == "jxlp" {
      return offset + 8
    }
    offset += box_size
  }
  -1
}

///|
/// 解析 JPEG-XL 扩展头部信息
///
/// 解析 SizeHeader 提取图像尺寸，支持裸码流和 ISOBMFF 容器两种格式
pub fn jpegxl_info_extended(
  data : Bytes,
) -> JpegXlInfoExtended raise @types.LoadError {
  if !is_jpegxl_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not a JPEG-XL file")
  }
  let is_cs = is_jpegxl_codestream(data)
  let codestream_start = if is_cs {
    2
  } else {
    let cs = jxl_find_codestream(data)
    if cs < 0 {
      raise @types.LoadError::DecodeFailed(
        "JPEG-XL: codestream box not found in container",
      )
    }
    cs
  }
  let (width, height) = jxl_parse_size_header(data, codestream_start)
  JpegXlInfoExtended::{
    width,
    height,
    bit_depth: 8,
    num_channels: 3,
    has_alpha: false,
    is_lossless: false,
    is_codestream: is_cs,
    orientation: 1,
  }
}
