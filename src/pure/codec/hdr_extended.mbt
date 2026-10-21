///|
/// HDR 扩展信息（包含尺寸、通道数等）
pub struct HdrInfoExtended {
  width : Int32
  height : Int32
  num_channels : Int32
  has_alpha : Bool
  format : String
}

///|
/// 检测数据是否为 HDR (Radiance RGBE) 格式
pub fn is_hdr_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 2 {
    return false
  }
  data[0].to_int() == 0x23 && data[1].to_int() == 0x3F
}

///|
/// 解析 HDR 扩展头部信息
pub fn hdr_info_extended(
  data : Bytes,
) -> HdrInfoExtended raise @types.LoadError {
  if !is_hdr_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not an HDR file")
  }
  let len = data.length()
  let mut pos = 2
  // 跳过 magic 行
  while pos < len && data[pos].to_int() != 0x0A {
    pos += 1
  }
  pos += 1
  // 跳过 header 行，查找尺寸行
  let mut format = "RGBE"
  while pos < len {
    let b = data[pos].to_int()
    if b == 0x2D || b == 0x2B {
      break
    }
    // 检查 FORMAT= 行
    if pos + 7 <= len &&
      data[pos].to_int() == 0x46 &&
      data[pos + 1].to_int() == 0x4F &&
      data[pos + 2].to_int() == 0x52 &&
      data[pos + 3].to_int() == 0x4D &&
      data[pos + 4].to_int() == 0x41 &&
      data[pos + 5].to_int() == 0x54 &&
      data[pos + 6].to_int() == 0x3D {
      // FORMAT= 后面的值
      let fmt_start = pos + 7
      let mut fmt_end = fmt_start
      while fmt_end < len && data[fmt_end].to_int() != 0x0A {
        fmt_end += 1
      }
      let fmt_bytes : Array[Byte] = []
      for i in fmt_start..<fmt_end {
        fmt_bytes.push(data[i])
      }
      format = @encoding/utf8.decode(Bytes::from_array(fmt_bytes)) catch {
        _ => "RGBE"
      }
    }
    // 跳过当前行
    while pos < len && data[pos].to_int() != 0x0A {
      pos += 1
    }
    pos += 1
  }
  // 解析尺寸行: "-Y HEIGHT +X WIDTH\n"
  let mut width = 0
  let mut height = 0
  let vals : Array[Int32] = []
  while pos < len && data[pos].to_int() != 0x0A {
    let b = data[pos].to_int()
    if b == 0x2D || b == 0x2B {
      pos += 1
      // 跳过字母 (Y/X)
      while pos < len &&
            data[pos].to_int() != 0x2D &&
            data[pos].to_int() != 0x2B &&
            data[pos].to_int() != 0x0A {
        let c = data[pos].to_int()
        if c >= 0x30 && c <= 0x39 {
          let mut num = 0
          while pos < len {
            let d = data[pos].to_int()
            if d >= 0x30 && d <= 0x39 {
              num = num * 10 + (d - 0x30)
              pos += 1
            } else {
              break
            }
          }
          vals.push(num)
        } else {
          pos += 1
        }
      }
    } else {
      pos += 1
    }
  }
  if vals.length() >= 2 {
    height = vals[0]
    width = vals[1]
  }
  if width == 0 || height == 0 {
    raise @types.LoadError::DecodeFailed("HDR 尺寸无效")
  }
  HdrInfoExtended::{ width, height, num_channels: 3, has_alpha: false, format, }
}
