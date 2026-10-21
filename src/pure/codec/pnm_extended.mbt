///|
/// PNM 扩展信息（包含格式类型、maxval、位深等）
pub struct PnmInfoExtended {
  width : Int32
  height : Int32
  format_type : String
  maxval : Int32
  bit_depth : Int32
  num_channels : Int32
  has_alpha : Bool
  is_binary : Bool
}

///|
/// 检测数据是否为 PNM 格式（P1-P6）
pub fn is_pnm_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 2 {
    return false
  }
  data[0].to_int() == 0x50 &&
  data[1].to_int() >= 0x31 &&
  data[1].to_int() <= 0x36
}

///|
/// 解析 PNM 扩展头部信息
///
/// 支持 P1(PBM)/P2(PGM ASCII)/P3(PPM ASCII)/P4(PBM binary)/P5(PGM binary)/P6(PPM binary)
pub fn pnm_info_extended(
  data : Bytes,
) -> PnmInfoExtended raise @types.LoadError {
  if !is_pnm_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not a PNM file")
  }
  let len = data.length()
  let magic1 = data[1].to_int()
  let format_type = "P" + (magic1 - 0x30).to_string()
  let is_binary = magic1 >= 0x34
  let num_channels = match magic1 {
    0x31 | 0x34 => 1 // PBM
    0x32 | 0x35 => 1 // PGM
    0x33 | 0x36 => 3 // PPM
    _ => 0
  }
  let pos = Ref(2)
  pnm_skip_ws_and_comments(data, pos, len)
  let width = pnm_read_ascii_int(data, pos, len)
  pnm_skip_ws_and_comments(data, pos, len)
  let height = pnm_read_ascii_int(data, pos, len)
  // PBM (P1/P4) 没有 maxval，固定为 1
  let maxval = if magic1 == 0x31 || magic1 == 0x34 {
    1
  } else {
    pnm_skip_ws_and_comments(data, pos, len)
    pnm_read_ascii_int(data, pos, len)
  }
  if width == 0 || height == 0 {
    raise @types.LoadError::DecodeFailed("PNM 尺寸无效")
  }
  let bit_depth = if maxval < 256 { 8 } else { 16 }
  PnmInfoExtended::{
    width,
    height,
    format_type,
    maxval,
    bit_depth,
    num_channels,
    has_alpha: false,
    is_binary,
  }
}
