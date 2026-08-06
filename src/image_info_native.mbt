///|
/// 查询内存字节序列中图像的几何信息（宽、高、通道数），不加载像素数据
pub fn info_from_bytes(data : Bytes) -> ImageInfo? raise LoadError {
  if data.length() == 0 {
    raise LoadError::DecodeFailed("输入数据为空")
  }
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let result = stb_image_mbt_info_from_memory(data, data.length(), w, h, c)
  if result == 0 {
    None
  } else {
    Some(ImageInfo::{ width: w.val, height: h.val, channels: c.val })
  }
}

///|
/// 查询文件路径中图像的几何信息（宽、高、通道数），不加载像素数据
pub fn info_from_path(path : String) -> ImageInfo? {
  let path_bytes = @encoding/utf8.encode(path)
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let result = stb_image_mbt_info_from_path(path_bytes, path_bytes.length(), w, h, c)
  if result == 0 {
    None
  } else {
    Some(ImageInfo::{ width: w.val, height: h.val, channels: c.val })
  }
}

///|
/// 判断内存字节序列中的图像是否为 16-bit
pub fn is_16_bit_from_bytes(data : Bytes) -> Bool {
  stb_image_mbt_is_16_bit_from_memory(data, data.length()) != 0
}

///|
/// 判断文件路径中的图像是否为 16-bit
pub fn is_16_bit_from_path(path : String) -> Bool {
  let path_bytes = @encoding/utf8.encode(path)
  stb_image_mbt_is_16_bit_from_path(path_bytes, path_bytes.length()) != 0
}

///|
/// 判断内存字节序列中的图像是否为 HDR 格式
pub fn is_hdr_from_bytes(data : Bytes) -> Bool {
  stb_image_mbt_is_hdr_from_memory(data, data.length()) != 0
}

///|
/// 判断文件路径中的图像是否为 HDR 格式
pub fn is_hdr_from_path(path : String) -> Bool {
  let path_bytes = @encoding/utf8.encode(path)
  stb_image_mbt_is_hdr_from_path(path_bytes, path_bytes.length()) != 0
}

///|
/// 获取最近一次 stb_image 失败的原因字符串（UTF-8 解码，失败时返回空字符串）
pub fn failure_reason() -> String {
  let bytes = stb_image_mbt_failure_reason()
  if bytes.length() == 0 {
    return ""
  }
  try @encoding/utf8.decode(bytes[:]) catch {
    _ => "<utf8_decode_failed>"
  }
}

///|

/// 设置加载时是否对预乘 alpha 的图像进行反预乘处理
pub fn set_unpremultiply_on_load(flag : Bool) -> Unit {
  stb_image_mbt_set_unpremultiply_on_load(if flag { 1 } else { 0 })
}

///|
/// 设置是否将 iPhone PNG 转换为 RGB
pub fn convert_iphone_png_to_rgb(flag : Bool) -> Unit {
  stb_image_mbt_convert_iphone_png_to_rgb(if flag { 1 } else { 0 })
}