///|
/// 解码结果值对象，承载图像几何元信息与像素数据
pub(all) struct Image {
  width : Int
  height : Int
  channels : Int
  data : Bytes
} derive(Eq, @debug.Debug)

///|
/// 加载失败领域错误
pub(all) suberror LoadError {
  FileIO(String)
  UnsupportedFormat(String)
  DecodeFailed(String)
}