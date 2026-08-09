///|
/// 解码结果值对象，承载图像几何元信息与像素数据（8-bit 无符号像素）
pub(all) struct Image {
  width : Int
  height : Int
  channels : Int
  data : Bytes
} derive(Eq, @debug.Debug)

///|
/// 16-bit 解码结果值对象，像素数据为 16-bit 无符号整数（little-endian，每像素 2 字节）
pub(all) struct Image16 {
  width : Int
  height : Int
  channels : Int
  data : Bytes
} derive(Eq, @debug.Debug)

///|
/// HDR float 解码结果值对象，像素数据为 32-bit IEEE float（little-endian，每像素 4 字节）
pub(all) struct ImageF {
  width : Int
  height : Int
  channels : Int
  data : Bytes
} derive(Eq, @debug.Debug)

///|
/// 图像信息查询结果，仅含几何元信息，不加载像素数据
pub(all) struct ImageInfo {
  width : Int
  height : Int
  channels : Int
} derive(Eq, @debug.Debug)

///|
/// 动画 GIF 解码结果，包含多帧图像和每帧延迟（毫秒）
pub(all) struct GifAnimation {
  frames : Array[Image]
  delays : Array[Int]
} derive(Eq, @debug.Debug)

///|
/// 加载失败领域错误
pub(all) suberror LoadError {
  FileIO(String)
  UnsupportedFormat(String)
  DecodeFailed(String)
}

///|
/// 图像格式枚举
pub(all) enum ImageFormat {
  Png
  Jpeg
  Bmp
  Gif
  Tga
  Psd
  Hdr
  Pnm
  Qoi
  Unknown
} derive(Eq, @debug.Debug)

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
