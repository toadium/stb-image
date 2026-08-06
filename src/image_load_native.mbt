///|
/// 从内存字节序列加载图像
pub fn load_from_bytes(data : Bytes) -> Image raise LoadError {
  if data.length() == 0 {
    raise LoadError::DecodeFailed("输入数据为空")
  }
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = stb_image_mbt_load_from_memory(data, data.length(), w, h, c)
  if pixels.length() == 0 || w.val == 0 {
    raise LoadError::DecodeFailed("stb_image 解码返回 NULL，输入可能为不支持的格式或损坏数据")
  }
  Image::{ width: w.val, height: h.val, channels: c.val, data: pixels }
}

///|
/// 从文件路径加载图像
pub fn load_from_path(path : String) -> Image raise LoadError {
  let path_bytes = @encoding/utf8.encode(path)
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = stb_image_mbt_load_from_path(path_bytes, path_bytes.length(), w, h, c)
  if pixels.length() == 0 || w.val == 0 {
    raise LoadError::DecodeFailed("stb_image 解码返回 NULL，输入可能为不支持的格式或损坏数据")
  }
  Image::{ width: w.val, height: h.val, channels: c.val, data: pixels }
}