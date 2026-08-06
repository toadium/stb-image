///|
/// 从内存字节序列加载动画 GIF，返回多帧图像和每帧延迟（毫秒）
pub fn load_gif_from_bytes(
  data : Bytes,
  req_channels~ : Int? = None
) -> GifAnimation raise LoadError {
  if data.length() == 0 {
    raise LoadError::DecodeFailed("输入数据为空")
  }
  let desired = match req_channels {
    Some(n) => n
    None => 0
  }
  let w = Ref(0)
  let h = Ref(0)
  let z = Ref(0)
  let c = Ref(0)
  let delays_len = Ref(0)
  let combined = stb_image_mbt_load_gif_from_memory(data, data.length(), desired, w, h, z, c, delays_len)
  if combined.length() == 0 || z.val == 0 {
    raise LoadError::DecodeFailed("stb_image GIF 解码返回 NULL，输入可能不是 GIF 或损坏数据")
  }
  let delays_size = delays_len.val
  let frame_size = w.val * h.val * c.val
  // 解析 delays（每帧延迟，4 字节 little-endian int）
  let delays = Array::make(z.val, 0)
  for i in 0..<z.val {
    let offset = i * 4
    delays[i] = combined[offset].to_int() |
      (combined[offset + 1].to_int() << 8) |
      (combined[offset + 2].to_int() << 16) |
      (combined[offset + 3].to_int() << 24)
  }
  // 解析 frames（每帧像素数据）
  let frames = Array::make(z.val, Image::{ width: 0, height: 0, channels: 0, data: b"" })
  for i in 0..<z.val {
    let frame_arr = Array::make(frame_size, b'\x00')
    let base = delays_size + i * frame_size
    for j in 0..<frame_size {
      frame_arr[j] = combined[base + j]
    }
    frames[i] = Image::{ width: w.val, height: h.val, channels: c.val, data: Bytes::from_array(frame_arr) }
  }
  GifAnimation::{ frames, delays }
}

///|
/// 从文件路径加载动画 GIF，返回多帧图像和每帧延迟（毫秒）
pub fn load_gif_from_path(
  path : String,
  req_channels~ : Int? = None
) -> GifAnimation raise LoadError {
  let path_bytes = @encoding/utf8.encode(path)
  let desired = match req_channels {
    Some(n) => n
    None => 0
  }
  let w = Ref(0)
  let h = Ref(0)
  let z = Ref(0)
  let c = Ref(0)
  let delays_len = Ref(0)
  let combined = stb_image_mbt_load_gif_from_path(path_bytes, path_bytes.length(), desired, w, h, z, c, delays_len)
  if combined.length() == 0 || z.val == 0 {
    raise LoadError::DecodeFailed("stb_image GIF 解码返回 NULL，输入可能不是 GIF 或损坏数据")
  }
  let delays_size = delays_len.val
  let frame_size = w.val * h.val * c.val
  // 解析 delays（每帧延迟，4 字节 little-endian int）
  let delays = Array::make(z.val, 0)
  for i in 0..<z.val {
    let offset = i * 4
    delays[i] = combined[offset].to_int() |
      (combined[offset + 1].to_int() << 8) |
      (combined[offset + 2].to_int() << 16) |
      (combined[offset + 3].to_int() << 24)
  }
  // 解析 frames（每帧像素数据）
  let frames = Array::make(z.val, Image::{ width: 0, height: 0, channels: 0, data: b"" })
  for i in 0..<z.val {
    let frame_arr = Array::make(frame_size, b'\x00')
    let base = delays_size + i * frame_size
    for j in 0..<frame_size {
      frame_arr[j] = combined[base + j]
    }
    frames[i] = Image::{ width: w.val, height: h.val, channels: c.val, data: Bytes::from_array(frame_arr) }
  }
  GifAnimation::{ frames, delays }
}