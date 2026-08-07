///|
/// 将图像写入 PNG 文件
pub fn write_png_to_path(path : String, img : Image) -> Unit raise LoadError {
  let path_bytes = @encoding/utf8.encode(path)
  let stride = img.width * img.channels
  let result = stb_image_mbt_write_png_to_path(path_bytes, path_bytes.length(), img.width, img.height, img.channels, img.data, stride)
  if result == 0 {
    raise LoadError::DecodeFailed("stb_image_write PNG 写入失败")
  }
}

///|
/// 将图像写入 BMP 文件
pub fn write_bmp_to_path(path : String, img : Image) -> Unit raise LoadError {
  let path_bytes = @encoding/utf8.encode(path)
  let result = stb_image_mbt_write_bmp_to_path(path_bytes, path_bytes.length(), img.width, img.height, img.channels, img.data)
  if result == 0 {
    raise LoadError::DecodeFailed("stb_image_write BMP 写入失败")
  }
}

///|
/// 将图像写入 TGA 文件
pub fn write_tga_to_path(path : String, img : Image) -> Unit raise LoadError {
  let path_bytes = @encoding/utf8.encode(path)
  let result = stb_image_mbt_write_tga_to_path(path_bytes, path_bytes.length(), img.width, img.height, img.channels, img.data)
  if result == 0 {
    raise LoadError::DecodeFailed("stb_image_write TGA 写入失败")
  }
}

///|
/// 将图像写入 JPEG 文件
pub fn write_jpeg_to_path(path : String, img : Image, quality~ : Int = 90) -> Unit raise LoadError {
  let path_bytes = @encoding/utf8.encode(path)
  let result = stb_image_mbt_write_jpg_to_path(path_bytes, path_bytes.length(), img.width, img.height, img.channels, img.data, quality)
  if result == 0 {
    raise LoadError::DecodeFailed("stb_image_write JPEG 写入失败")
  }
}

///|
/// 将图像编码为 PNG 字节序列
pub fn write_png_to_bytes(img : Image) -> Bytes raise LoadError {
  let stride = img.width * img.channels
  let result = stb_image_mbt_write_png_to_bytes(img.width, img.height, img.channels, img.data, stride)
  if result.length() == 0 {
    raise LoadError::DecodeFailed("stb_image_write PNG 编码失败")
  }
  result
}

///|
/// 将图像编码为 BMP 字节序列
pub fn write_bmp_to_bytes(img : Image) -> Bytes raise LoadError {
  let result = stb_image_mbt_write_bmp_to_bytes(img.width, img.height, img.channels, img.data)
  if result.length() == 0 {
    raise LoadError::DecodeFailed("stb_image_write BMP 编码失败")
  }
  result
}

///|
/// 将图像编码为 TGA 字节序列
pub fn write_tga_to_bytes(img : Image) -> Bytes raise LoadError {
  let result = stb_image_mbt_write_tga_to_bytes(img.width, img.height, img.channels, img.data)
  if result.length() == 0 {
    raise LoadError::DecodeFailed("stb_image_write TGA 编码失败")
  }
  result
}

///|
/// 将图像编码为 JPEG 字节序列
pub fn write_jpeg_to_bytes(img : Image, quality~ : Int = 90) -> Bytes raise LoadError {
  let result = stb_image_mbt_write_jpg_to_bytes(img.width, img.height, img.channels, img.data, quality)
  if result.length() == 0 {
    raise LoadError::DecodeFailed("stb_image_write JPEG 编码失败")
  }
  result
}

///|
/// 将 HDR float 图像写入 HDR 文件
pub fn write_hdr_to_path(path : String, img : ImageF) -> Unit raise LoadError {
  let path_bytes = @encoding/utf8.encode(path)
  let result = stb_image_mbt_write_hdr_to_path(path_bytes, path_bytes.length(), img.width, img.height, img.channels, img.data)
  if result == 0 {
    raise LoadError::DecodeFailed("stb_image_write HDR 写入失败")
  }
}

///|
/// 将 HDR float 图像编码为 HDR 字节序列
pub fn write_hdr_to_bytes(img : ImageF) -> Bytes raise LoadError {
  let result = stb_image_mbt_write_hdr_to_bytes(img.width, img.height, img.channels, img.data)
  if result.length() == 0 {
    raise LoadError::DecodeFailed("stb_image_write HDR 编码失败")
  }
  result
}

///|
/// 设置加载时是否垂直翻转图像
pub fn set_flip_vertically_on_load(flag : Bool) -> Unit {
  stb_image_mbt_set_flip_vertically_on_load(if flag { 1 } else { 0 })
}

///|
/// 设置写入时是否垂直翻转图像
pub fn flip_vertically_on_write(flag : Bool) -> Unit {
  stb_image_mbt_flip_vertically_on_write(if flag { 1 } else { 0 })
}