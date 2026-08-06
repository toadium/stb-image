///|
/// resize 滤波器类型
pub(all) enum ResizeFilter {
  Default
  Box
  Triangle
  CubicBSPline
  CatmullROM
  Mitchell
  PointSample
} derive(Eq, @debug.Debug)

///|
/// resize 边缘处理模式
pub(all) enum ResizeEdge {
  Clamp
  Reflect
  Wrap
  Zero
} derive(Eq, @debug.Debug)

fn filter_to_int(f : ResizeFilter) -> Int {
  match f {
    Default => 0
    Box => 1
    Triangle => 2
    CubicBSPline => 3
    CatmullROM => 4
    Mitchell => 5
    PointSample => 6
  }
}

fn edge_to_int(e : ResizeEdge) -> Int {
  match e {
    Clamp => 0
    Reflect => 1
    Wrap => 2
    Zero => 3
  }
}

///|
/// resize 8-bit 图像（linear colorspace）
pub fn resize(
  img : Image,
  out_w : Int,
  out_h : Int,
  filter~ : ResizeFilter = Default,
  edge~ : ResizeEdge = Clamp
) -> Image raise LoadError {
  if out_w <= 0 || out_h <= 0 {
    raise LoadError::DecodeFailed("resize 输出尺寸必须为正数")
  }
  let result = stb_image_mbt_resize(img.data, img.width, img.height, out_w, out_h, img.channels, 0, filter_to_int(filter), edge_to_int(edge))
  if result.length() == 0 {
    raise LoadError::DecodeFailed("stbir_resize 失败")
  }
  Image::{ width: out_w, height: out_h, channels: img.channels, data: result }
}

///|
/// resize 8-bit 图像（sRGB colorspace）
pub fn resize_srgb(
  img : Image,
  out_w : Int,
  out_h : Int,
  filter~ : ResizeFilter = Default,
  edge~ : ResizeEdge = Clamp
) -> Image raise LoadError {
  if out_w <= 0 || out_h <= 0 {
    raise LoadError::DecodeFailed("resize 输出尺寸必须为正数")
  }
  let result = stb_image_mbt_resize(img.data, img.width, img.height, out_w, out_h, img.channels, 1, filter_to_int(filter), edge_to_int(edge))
  if result.length() == 0 {
    raise LoadError::DecodeFailed("stbir_resize 失败")
  }
  Image::{ width: out_w, height: out_h, channels: img.channels, data: result }
}

///|
/// resize 16-bit 图像
pub fn resize_16(
  img : Image16,
  out_w : Int,
  out_h : Int,
  filter~ : ResizeFilter = Default,
  edge~ : ResizeEdge = Clamp
) -> Image16 raise LoadError {
  if out_w <= 0 || out_h <= 0 {
    raise LoadError::DecodeFailed("resize 输出尺寸必须为正数")
  }
  let result = stb_image_mbt_resize(img.data, img.width, img.height, out_w, out_h, img.channels, 3, filter_to_int(filter), edge_to_int(edge))
  if result.length() == 0 {
    raise LoadError::DecodeFailed("stbir_resize 失败")
  }
  Image16::{ width: out_w, height: out_h, channels: img.channels, data: result }
}

///|
/// resize float (HDR) 图像
pub fn resizef(
  img : ImageF,
  out_w : Int,
  out_h : Int,
  filter~ : ResizeFilter = Default,
  edge~ : ResizeEdge = Clamp
) -> ImageF raise LoadError {
  if out_w <= 0 || out_h <= 0 {
    raise LoadError::DecodeFailed("resize 输出尺寸必须为正数")
  }
  let result = stb_image_mbt_resize(img.data, img.width, img.height, out_w, out_h, img.channels, 4, filter_to_int(filter), edge_to_int(edge))
  if result.length() == 0 {
    raise LoadError::DecodeFailed("stbir_resize 失败")
  }
  ImageF::{ width: out_w, height: out_h, channels: img.channels, data: result }
}