///|
/// 图像统一接口 trait，抽象 8-bit / 16-bit / float 三种像素精度
///
/// 所有图像类型（Image / Image16 / ImageF / AnyImage）均实现此 trait，
/// 允许泛型算法以统一方式访问图像几何信息与像素数据
pub(open) trait ImageLike {
  fn width(Self) -> Int
  fn height(Self) -> Int
  fn channels(Self) -> Int
  fn data(Self) -> Bytes
  fn bytes_per_pixel(Self) -> Int
  fn pixel_count(Self) -> Int = _
  fn byte_count(Self) -> Int = _
  fn is_grayscale(Self) -> Bool = _
  fn is_rgb(Self) -> Bool = _
  fn is_rgba(Self) -> Bool = _
}

///|
impl ImageLike with fn pixel_count(self) {
  ImageLike::width(self) * ImageLike::height(self) * ImageLike::channels(self)
}

///|
impl ImageLike with fn byte_count(self) {
  ImageLike::pixel_count(self) * ImageLike::bytes_per_pixel(self)
}

///|
impl ImageLike with fn is_grayscale(self) {
  ImageLike::channels(self) == 1
}

///|
impl ImageLike with fn is_rgb(self) {
  ImageLike::channels(self) == 3
}

///|
impl ImageLike with fn is_rgba(self) {
  ImageLike::channels(self) == 4
}

// Image (8-bit) 实现 ImageLike

///|
pub impl ImageLike for Image with fn width(self) {
  self.width
}

///|
pub impl ImageLike for Image with fn height(self) {
  self.height
}

///|
pub impl ImageLike for Image with fn channels(self) {
  self.channels
}

///|
pub impl ImageLike for Image with fn data(self) {
  self.data
}

///|
pub impl ImageLike for Image with fn bytes_per_pixel(_) {
  1
}

///|
pub extend Image with ImageLike::{
  width,
  height,
  channels,
  data,
  bytes_per_pixel,
  pixel_count,
  byte_count,
  is_grayscale,
  is_rgb,
  is_rgba,
}

// Image16 (16-bit) 实现 ImageLike

///|
pub impl ImageLike for Image16 with fn width(self) {
  self.width
}

///|
pub impl ImageLike for Image16 with fn height(self) {
  self.height
}

///|
pub impl ImageLike for Image16 with fn channels(self) {
  self.channels
}

///|
pub impl ImageLike for Image16 with fn data(self) {
  self.data
}

///|
pub impl ImageLike for Image16 with fn bytes_per_pixel(_) {
  2
}

///|
pub extend Image16 with ImageLike::{
  width,
  height,
  channels,
  data,
  bytes_per_pixel,
  pixel_count,
  byte_count,
  is_grayscale,
  is_rgb,
  is_rgba,
}

// ImageF (32-bit float) 实现 ImageLike

///|
pub impl ImageLike for ImageF with fn width(self) {
  self.width
}

///|
pub impl ImageLike for ImageF with fn height(self) {
  self.height
}

///|
pub impl ImageLike for ImageF with fn channels(self) {
  self.channels
}

///|
pub impl ImageLike for ImageF with fn data(self) {
  self.data
}

///|
pub impl ImageLike for ImageF with fn bytes_per_pixel(_) {
  4
}

///|
pub extend ImageF with ImageLike::{
  width,
  height,
  channels,
  data,
  bytes_per_pixel,
  pixel_count,
  byte_count,
  is_grayscale,
  is_rgb,
  is_rgba,
}

///|
/// 统一图像容器，包装三种像素精度的图像
///
/// 用于需要统一处理不同精度图像的场景，如编解码器接口
pub(all) enum AnyImage {
  U8(Image)
  U16(Image16)
  F32(ImageF)
} derive(Eq, @debug.Debug)

///|
pub extend AnyImage with @debug.Debug::{to_repr}

///|
pub extend AnyImage with Eq::{not_equal, equal}

// AnyImage 实现 ImageLike

///|
pub impl ImageLike for AnyImage with fn width(self) {
  match self {
    U8(img) => img.width
    U16(img) => img.width
    F32(img) => img.width
  }
}

///|
pub impl ImageLike for AnyImage with fn height(self) {
  match self {
    U8(img) => img.height
    U16(img) => img.height
    F32(img) => img.height
  }
}

///|
pub impl ImageLike for AnyImage with fn channels(self) {
  match self {
    U8(img) => img.channels
    U16(img) => img.channels
    F32(img) => img.channels
  }
}

///|
pub impl ImageLike for AnyImage with fn data(self) {
  match self {
    U8(img) => img.data
    U16(img) => img.data
    F32(img) => img.data
  }
}

///|
pub impl ImageLike for AnyImage with fn bytes_per_pixel(self) {
  match self {
    U8(_) => 1
    U16(_) => 2
    F32(_) => 4
  }
}

///|
pub extend AnyImage with ImageLike::{
  width,
  height,
  channels,
  data,
  bytes_per_pixel,
  pixel_count,
  byte_count,
  is_grayscale,
  is_rgb,
  is_rgba,
}

///|
/// 将 Image 升级为 AnyImage::U8
pub fn image_to_any(img : Image) -> AnyImage {
  U8(img)
}

///|
/// 将 Image16 升级为 AnyImage::U16
pub fn image16_to_any(img : Image16) -> AnyImage {
  U16(img)
}

///|
/// 将 ImageF 升级为 AnyImage::F32
pub fn imagef_to_any(img : ImageF) -> AnyImage {
  F32(img)
}

///|
/// 将 AnyImage 转换为 8-bit Image
///
/// U8 直接返回；U16 截断高位；F32 量化到 [0,255]
pub fn any_image_to_u8(img : AnyImage) -> Image {
  match img {
    U8(im) => im
    U16(im) => {
      let w = im.width
      let h = im.height
      let c = im.channels
      let n = w * h * c
      let buf : Array[Byte] = []
      for i in 0..<n {
        let lo = im.data[i * 2].to_int()
        let hi = im.data[i * 2 + 1].to_int()
        let v = (hi << 8) | lo
        let clamped = if v > 255 { 255 } else { v }
        buf.push(clamped.to_byte())
      }
      Image::{ width: w, height: h, channels: c, data: Bytes::from_array(buf), }
    }
    F32(im) => {
      let w = im.width
      let h = im.height
      let c = im.channels
      let n = w * h * c
      let buf : Array[Byte] = []
      for i in 0..<n {
        let idx = i * 4
        let bits = (im.data[idx + 3].to_int() << 24) |
          (im.data[idx + 2].to_int() << 16) |
          (im.data[idx + 1].to_int() << 8) |
          im.data[idx].to_int()
        let f = Float::reinterpret_from_int(bits)
        let v = (f * 255.0F + 0.5F).to_int()
        let clamped = if v > 255 { 255 } else if v < 0 { 0 } else { v }
        buf.push(clamped.to_byte())
      }
      Image::{ width: w, height: h, channels: c, data: Bytes::from_array(buf), }
    }
  }
}

///|
/// 将 8-bit Image 转换为 ImageF（归一化到 [0,1]）
pub fn hdr_from_u8(img : Image) -> ImageF {
  let w = img.width
  let h = img.height
  let c = img.channels
  let n = w * h * c
  let buf : Array[Byte] = []
  for i in 0..<n {
    let f = Float::from_int(img.data[i].to_int()) / 255.0F
    let bytes = f.to_le_bytes()
    for j in 0..<4 {
      buf.push(bytes[j])
    }
  }
  ImageF::{ width: w, height: h, channels: c, data: Bytes::from_array(buf), }
}
