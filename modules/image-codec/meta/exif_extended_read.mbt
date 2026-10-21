// v248.0.0 扩展 EXIF 元数据读取
// 支持 GPS/曝光参数/白平衡/焦距/ISO/光圈/闪光灯等标签
// 保持原有 ExifInfo 不变，新增 ExifInfoExtended

///|
/// 扩展 EXIF 元数据信息
pub(all) struct ExifInfoExtended {
  make : String
  model : String
  orientation : Int32
  date_time : String
  exposure_time : String
  f_number : Double
  iso : Int32
  focal_length : Double
  exposure_mode : Int32
  white_balance : Int32
  flash : Int32
  gps_latitude : Double
  gps_longitude : Double
  gps_altitude : Double
  pixel_x_dim : Int32
  pixel_y_dim : Int32
} derive(Eq, @debug.Debug)

///|
pub extend ExifInfoExtended with Eq::{not_equal, equal}

///|
pub extend ExifInfoExtended with @debug.Debug::{to_repr}

///|
fn exif_read_u16_be(data : Bytes, offset : Int32) -> Int32 {
  data[offset].to_int() * 256 + data[offset + 1].to_int()
}

///|
fn exif_read_u16_le(data : Bytes, offset : Int32) -> Int32 {
  data[offset].to_int() + data[offset + 1].to_int() * 256
}

///|
fn exif_read_u32_be(data : Bytes, offset : Int32) -> Int32 {
  data[offset].to_int() * 16777216 +
  data[offset + 1].to_int() * 65536 +
  data[offset + 2].to_int() * 256 +
  data[offset + 3].to_int()
}

///|
fn exif_read_u32_le(data : Bytes, offset : Int32) -> Int32 {
  data[offset].to_int() +
  data[offset + 1].to_int() * 256 +
  data[offset + 2].to_int() * 65536 +
  data[offset + 3].to_int() * 16777216
}

///|
fn exif_read_u16(data : Bytes, offset : Int32, little : Bool) -> Int32 {
  if little {
    exif_read_u16_le(data, offset)
  } else {
    exif_read_u16_be(data, offset)
  }
}

///|
fn exif_read_u32(data : Bytes, offset : Int32, little : Bool) -> Int32 {
  if little {
    exif_read_u32_le(data, offset)
  } else {
    exif_read_u32_be(data, offset)
  }
}

///|
fn exif_read_string(
  data : Bytes,
  tiff_start : Int32,
  entry_offset : Int32,
  count : Int32,
  little : Bool,
) -> String {
  let val_offset = if count <= 4 {
    tiff_start + entry_offset + 8
  } else {
    let ptr = exif_read_u32(data, tiff_start + entry_offset + 8, little)
    tiff_start + ptr
  }
  let chars : Array[Byte] = []
  for i in 0..<count {
    if val_offset + i >= data.length() {
      break
    }
    let b = data[val_offset + i]
    if b == b'\x00' {
      break
    }
    chars.push(b)
  }
  @encoding/utf8.decode(Bytes::from_array(chars)[:]) catch {
    _ => ""
  }
}

///|
fn exif_read_rational(
  data : Bytes,
  tiff_start : Int32,
  entry_offset : Int32,
  little : Bool,
) -> Double {
  let ptr = exif_read_u32(data, tiff_start + entry_offset + 8, little)
  let val_offset = tiff_start + ptr
  if val_offset + 8 > data.length() {
    return 0.0
  }
  let num = exif_read_u32(data, val_offset, little)
  let den = exif_read_u32(data, val_offset + 4, little)
  if den == 0 {
    return 0.0
  }
  num.to_double() / den.to_double()
}

///|
fn exif_read_gps_coord(
  data : Bytes,
  tiff_start : Int32,
  entry_offset : Int32,
  little : Bool,
) -> Double {
  let ptr = exif_read_u32(data, tiff_start + entry_offset + 8, little)
  let val_offset = tiff_start + ptr
  if val_offset + 24 > data.length() {
    return 0.0
  }
  let d = exif_read_u32(data, val_offset, little)
  let d_den = exif_read_u32(data, val_offset + 4, little)
  let m = exif_read_u32(data, val_offset + 8, little)
  let m_den = exif_read_u32(data, val_offset + 12, little)
  let s = exif_read_u32(data, val_offset + 16, little)
  let s_den = exif_read_u32(data, val_offset + 20, little)
  let deg = if d_den == 0 { 0.0 } else { d.to_double() / d_den.to_double() }
  let min = if m_den == 0 { 0.0 } else { m.to_double() / m_den.to_double() }
  let sec = if s_den == 0 { 0.0 } else { s.to_double() / s_den.to_double() }
  deg + min / 60.0 + sec / 3600.0
}

///|
/// 从 JPEG 字节流读取扩展 EXIF 元数据
/// 返回 None 如果不含 EXIF 数据
pub fn read_exif_extended_from_bytes(data : Bytes) -> ExifInfoExtended? {
  let len = data.length()
  if len < 4 || data[0].to_int() != 0xFF || data[1].to_int() != 0xD8 {
    return None
  }
  let mut pos = 2
  let mut exif_start = -1
  let mut exif_len = 0
  while pos < len - 1 {
    if data[pos].to_int() == 0xFF && data[pos + 1].to_int() == 0xE1 {
      exif_len = exif_read_u16_be(data, pos + 2) - 2
      exif_start = pos + 4
      break
    }
    if data[pos].to_int() == 0xFF {
      let marker = data[pos + 1].to_int()
      if marker == 0xDA || marker == 0xD9 {
        break
      }
      let seg_len = exif_read_u16_be(data, pos + 2)
      pos += 2 + seg_len
    } else {
      pos += 1
    }
  }
  if exif_start < 0 || exif_start + exif_len > len {
    return None
  }
  if exif_len < 6 ||
    data[exif_start].to_int() != 0x45 ||
    data[exif_start + 1].to_int() != 0x78 ||
    data[exif_start + 2].to_int() != 0x69 ||
    data[exif_start + 3].to_int() != 0x66 {
    return None
  }
  let tiff_start = exif_start + 6
  if tiff_start + 8 > len {
    return None
  }
  let little = if data[tiff_start].to_int() == 0x49 &&
    data[tiff_start + 1].to_int() == 0x49 {
    true
  } else if data[tiff_start].to_int() == 0x4D &&
    data[tiff_start + 1].to_int() == 0x4D {
    false
  } else {
    return None
  }
  let ifd0_offset = exif_read_u32(data, tiff_start + 4, little)
  let ifd0_pos = tiff_start + ifd0_offset
  if ifd0_pos + 2 > len {
    return None
  }
  let entry_count = exif_read_u16(data, ifd0_pos, little)
  let mut make = ""
  let mut model = ""
  let mut orientation = 1
  let mut date_time = ""
  let mut exif_ifd_offset = 0
  let mut gps_ifd_offset = 0
  let mut pixel_x_dim = 0
  let mut pixel_y_dim = 0
  for i in 0..<entry_count {
    let entry_pos = ifd0_pos + 2 + i * 12
    if entry_pos + 12 > len {
      break
    }
    let tag = exif_read_u16(data, entry_pos, little)
    let count = exif_read_u32(data, entry_pos + 4, little)
    let entry_offset = entry_pos - tiff_start
    match tag {
      0x010F =>
        make = exif_read_string(data, tiff_start, entry_offset, count, little)
      0x0110 =>
        model = exif_read_string(data, tiff_start, entry_offset, count, little)
      0x0112 =>
        orientation = exif_read_u16(data, tiff_start + entry_offset + 8, little)
      0x0132 =>
        date_time = exif_read_string(
          data, tiff_start, entry_offset, count, little,
        )
      0x8769 =>
        exif_ifd_offset = exif_read_u32(
          data,
          tiff_start + entry_offset + 8,
          little,
        )
      0x8825 =>
        gps_ifd_offset = exif_read_u32(
          data,
          tiff_start + entry_offset + 8,
          little,
        )
      0xA002 =>
        pixel_x_dim = exif_read_u32(data, tiff_start + entry_offset + 8, little)
      0xA003 =>
        pixel_y_dim = exif_read_u32(data, tiff_start + entry_offset + 8, little)
      _ => ()
    }
  }
  let mut exposure_time = ""
  let mut f_number = 0.0
  let mut iso = 0
  let mut focal_length = 0.0
  let mut exposure_mode = 0
  let mut white_balance = 0
  let mut flash = 0
  if exif_ifd_offset > 0 {
    let exif_ifd_pos = tiff_start + exif_ifd_offset
    if exif_ifd_pos + 2 <= len {
      let exif_count = exif_read_u16(data, exif_ifd_pos, little)
      for i in 0..<exif_count {
        let entry_pos = exif_ifd_pos + 2 + i * 12
        if entry_pos + 12 > len {
          break
        }
        let tag = exif_read_u16(data, entry_pos, little)
        let entry_offset = entry_pos - tiff_start
        match tag {
          0x829A => {
            let r = exif_read_rational(data, tiff_start, entry_offset, little)
            if r > 0.0 {
              let den = (1.0 / r).to_int()
              if den > 0 {
                exposure_time = "1/" + den.to_string()
              } else {
                exposure_time = r.to_string()
              }
            }
          }
          0x829D =>
            f_number = exif_read_rational(
              data, tiff_start, entry_offset, little,
            )
          0x8827 =>
            iso = exif_read_u16(data, tiff_start + entry_offset + 8, little)
          0x920A =>
            focal_length = exif_read_rational(
              data, tiff_start, entry_offset, little,
            )
          0x88222 =>
            exposure_mode = exif_read_u16(
              data,
              tiff_start + entry_offset + 8,
              little,
            )
          0x88242 =>
            white_balance = exif_read_u16(
              data,
              tiff_start + entry_offset + 8,
              little,
            )
          0x9209 =>
            flash = exif_read_u16(data, tiff_start + entry_offset + 8, little)
          _ => ()
        }
      }
    }
  }
  let mut gps_latitude = 0.0
  let mut gps_longitude = 0.0
  let mut gps_altitude = 0.0
  if gps_ifd_offset > 0 {
    let gps_ifd_pos = tiff_start + gps_ifd_offset
    if gps_ifd_pos + 2 <= len {
      let gps_count = exif_read_u16(data, gps_ifd_pos, little)
      let mut lat_ref = b'\x00'
      let mut lon_ref = b'\x00'
      for i in 0..<gps_count {
        let entry_pos = gps_ifd_pos + 2 + i * 12
        if entry_pos + 12 > len {
          break
        }
        let tag = exif_read_u16(data, entry_pos, little)
        let entry_offset = entry_pos - tiff_start
        match tag {
          0x0001 => lat_ref = data[tiff_start + entry_offset + 8]
          0x0002 =>
            gps_latitude = exif_read_gps_coord(
              data, tiff_start, entry_offset, little,
            )
          0x0003 => lon_ref = data[tiff_start + entry_offset + 8]
          0x0004 =>
            gps_longitude = exif_read_gps_coord(
              data, tiff_start, entry_offset, little,
            )
          0x0006 =>
            gps_altitude = exif_read_rational(
              data, tiff_start, entry_offset, little,
            )
          _ => ()
        }
      }
      if lat_ref == b'\x53' {
        gps_latitude = -gps_latitude
      }
      if lon_ref == b'\x57' {
        gps_longitude = -gps_longitude
      }
    }
  }
  Some(ExifInfoExtended::{
    make,
    model,
    orientation,
    date_time,
    exposure_time,
    f_number,
    iso,
    focal_length,
    exposure_mode,
    white_balance,
    flash,
    gps_latitude,
    gps_longitude,
    gps_altitude,
    pixel_x_dim,
    pixel_y_dim,
  })
}
