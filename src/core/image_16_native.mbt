///|
/// 从内存字节序列加载 16-bit 图像，像素数据为 16-bit 无符号整数（little-endian，每像素 2 字节）
pub fn load_16_from_bytes(
  data : Bytes,
  req_channels? : Int? = None,
) -> Image16 raise LoadError {
  if data.length() == 0 {
    raise LoadError::DecodeFailed("输入数据为空")
  }
  let desired = match req_channels {
    Some(n) => n
    None => 0
  }
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = stb_image_mbt_load_16_from_memory(
    data,
    data.length(),
    desired,
    w,
    h,
    c,
  )
  if pixels.length() == 0 || w.val == 0 {
    raise LoadError::DecodeFailed(
      "stb_image 16-bit 解码返回 NULL，输入可能为不支持的格式或损坏数据",
    )
  }
  Image16::{ width: w.val, height: h.val, channels: c.val, data: pixels }
}

///|
/// 从文件路径加载 16-bit 图像，像素数据为 16-bit 无符号整数（little-endian，每像素 2 字节）
pub fn load_16_from_path(
  path : String,
  req_channels? : Int? = None,
) -> Image16 raise LoadError {
  let path_bytes = @encoding/utf8.encode(path)
  let desired = match req_channels {
    Some(n) => n
    None => 0
  }
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = stb_image_mbt_load_16_from_path(
    path_bytes,
    path_bytes.length(),
    desired,
    w,
    h,
    c,
  )
  if pixels.length() == 0 || w.val == 0 {
    raise LoadError::DecodeFailed(
      "stb_image 16-bit 解码返回 NULL，输入可能为不支持的格式或损坏数据",
    )
  }
  Image16::{ width: w.val, height: h.val, channels: c.val, data: pixels }
}
