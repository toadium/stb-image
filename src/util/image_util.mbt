// 图像几何增强（纯 MoonBit）：pad / resize_to_cover / resize_to_contain / add_border

///|
/// 在图像四周填充指定颜色，生成新尺寸 (width+2*px, height+2*py) 的新图像。
/// pad_color 长度应等于 channels，不足则循环使用。
pub fn pad(
  img : @core.Image,
  px : Int,
  py : Int,
  pad_color : Array[Byte],
) -> @core.Image raise @core.LoadError {
  if px < 0 || py < 0 {
    raise @core.LoadError::DecodeFailed("pad 填充必须非负")
  }
  let ch = img.channels
  let new_w = img.width + 2 * px
  let new_h = img.height + 2 * py
  let out : Array[Byte] = Array::make(new_w * new_h * ch, b'\x00')
  let color_len = pad_color.length()
  if color_len == 0 {
    raise @core.LoadError::DecodeFailed("pad_color 不能为空")
  }
  // 填充
  for y in 0..<new_h {
    for x in 0..<new_w {
      let dst_off = (y * new_w + x) * ch
      if x >= px && x < px + img.width && y >= py && y < py + img.height {
        // 拷贝原始像素
        let src_off = ((y - py) * img.width + (x - px)) * ch
        for c in 0..<ch {
          out[dst_off + c] = img.data[src_off + c]
        }
      } else {
        // 填充颜色
        for c in 0..<ch {
          out[dst_off + c] = pad_color[c % color_len]
        }
      }
    }
  }
  @core.Image::{
    width: new_w,
    height: new_h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 添加边框。top/right/bottom/left 分别为四边边框宽度，border_color 为边框颜色。
pub fn add_border(
  img : @core.Image,
  top : Int,
  right : Int,
  bottom : Int,
  left : Int,
  border_color : Array[Byte],
) -> @core.Image raise @core.LoadError {
  if top < 0 || right < 0 || bottom < 0 || left < 0 {
    raise @core.LoadError::DecodeFailed("border 宽度必须非负")
  }
  let ch = img.channels
  let new_w = img.width + left + right
  let new_h = img.height + top + bottom
  let out : Array[Byte] = Array::make(new_w * new_h * ch, b'\x00')
  let color_len = border_color.length()
  if color_len == 0 {
    raise @core.LoadError::DecodeFailed("border_color 不能为空")
  }
  for y in 0..<new_h {
    for x in 0..<new_w {
      let dst_off = (y * new_w + x) * ch
      if x >= left && x < left + img.width && y >= top && y < top + img.height {
        let src_off = ((y - top) * img.width + (x - left)) * ch
        for c in 0..<ch {
          out[dst_off + c] = img.data[src_off + c]
        }
      } else {
        for c in 0..<ch {
          out[dst_off + c] = border_color[c % color_len]
        }
      }
    }
  }
  @core.Image::{
    width: new_w,
    height: new_h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// Resize 并裁剪到精确尺寸（cover 模式）。
/// 先按宽高比缩放使图像"覆盖"目标尺寸，然后居中裁剪多余部分。
pub fn resize_to_cover(
  img : @core.Image,
  target_w : Int,
  target_h : Int,
) -> @core.Image raise @core.LoadError {
  if target_w <= 0 || target_h <= 0 {
    raise @core.LoadError::DecodeFailed("目标尺寸必须为正数")
  }
  let scale_w = Float::from_int(target_w) / Float::from_int(img.width)
  let scale_h = Float::from_int(target_h) / Float::from_int(img.height)
  let scale = if scale_w > scale_h { scale_w } else { scale_h }
  let scaled_w = (Float::from_int(img.width) * scale).to_int()
  let scaled_h = (Float::from_int(img.height) * scale).to_int()
  let scaled = @core.resize(img, scaled_w, scaled_h)
  let x = (scaled_w - target_w) / 2
  let y = (scaled_h - target_h) / 2
  @process.crop(scaled, x, y, target_w, target_h)
}

///|
/// Resize 到目标尺寸内（contain 模式），保持宽高比，不足部分用 fill_color 填充。
pub fn resize_to_contain(
  img : @core.Image,
  target_w : Int,
  target_h : Int,
  fill_color : Array[Byte],
) -> @core.Image raise @core.LoadError {
  if target_w <= 0 || target_h <= 0 {
    raise @core.LoadError::DecodeFailed("目标尺寸必须为正数")
  }
  let scale_w = Float::from_int(target_w) / Float::from_int(img.width)
  let scale_h = Float::from_int(target_h) / Float::from_int(img.height)
  let scale = if scale_w < scale_h { scale_w } else { scale_h }
  let scaled_w = (Float::from_int(img.width) * scale).to_int()
  let scaled_h = (Float::from_int(img.height) * scale).to_int()
  let scaled = @core.resize(img, scaled_w, scaled_h)
  let px = (target_w - scaled_w) / 2
  let py = (target_h - scaled_h) / 2
  pad(scaled, px, py, fill_color)
}
