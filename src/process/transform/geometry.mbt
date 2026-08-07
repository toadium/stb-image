// 几何变换（纯 MoonBit）：仿射变换 + 任意角度旋转
// 使用双线性插值，边界 clamp 到边缘像素

///|
/// 双线性插值采样。在 (x, y) 处采样通道 c 的值。
fn sample_bilinear(
  data : Bytes,
  w : Int,
  h : Int,
  ch : Int,
  c : Int,
  x : Float,
  y : Float,
) -> Int {
  let x0 = x.to_int()
  let y0 = y.to_int()
  let x0c = x0.clamp(min=0, max=w - 1)
  let y0c = y0.clamp(min=0, max=h - 1)
  let x1 = (x0 + 1).clamp(min=0, max=w - 1)
  let y1 = (y0 + 1).clamp(min=0, max=h - 1)
  let fx = x - Float::from_int(x0)
  let fy = y - Float::from_int(y0)
  let p00 = data[(y0c * w + x0c) * ch + c].to_int()
  let p10 = data[(y0c * w + x1) * ch + c].to_int()
  let p01 = data[(y1 * w + x0c) * ch + c].to_int()
  let p11 = data[(y1 * w + x1) * ch + c].to_int()
  let top = Float::from_int(p00) * (1.0F - fx) + Float::from_int(p10) * fx
  let bot = Float::from_int(p01) * (1.0F - fx) + Float::from_int(p11) * fx
  (top * (1.0F - fy) + bot * fy + 0.5F).to_int()
}

///|
/// 仿射变换。matrix = (a, b, c, d, e, f) 映射 dst→src：
///   src_x = a * dst_x + b * dst_y + c
///   src_y = d * dst_x + e * dst_y + f
/// 使用双线性插值，超出边界的像素 clamp 到边缘。
/// 输出尺寸为 new_w × new_h，通道数与输入相同。
pub fn warp_affine(
  img : @core.Image,
  matrix : (Float, Float, Float, Float, Float, Float),
  new_w : Int,
  new_h : Int,
) -> @core.Image {
  let (a, b, c, d, e, f) = matrix
  let ch = img.channels
  let w = img.width
  let h = img.height
  let out : Array[Byte] = Array::make(new_w * new_h * ch, b'\x00')
  for dy in 0..<new_h {
    for dx in 0..<new_w {
      let sx = a * Float::from_int(dx) + b * Float::from_int(dy) + c
      let sy = d * Float::from_int(dx) + e * Float::from_int(dy) + f
      for ci in 0..<ch {
        let val = sample_bilinear(img.data, w, h, ch, ci, sx, sy)
        out[(dy * new_w + dx) * ch + ci] = val.clamp(min=0, max=255).to_byte()
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
/// 任意角度旋转（绕中心，保留原尺寸，角落填充黑色）。
/// angle 单位为度，正值逆时针旋转。使用双线性插值。
pub fn rotate(img : @core.Image, angle_degrees : Float) -> @core.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let rad = angle_degrees * 3.14159265F / 180.0F
  let cos_a = @math.cosf(rad)
  let sin_a = @math.sinf(rad)
  let cx = Float::from_int(w - 1) / 2.0F
  let cy = Float::from_int(h - 1) / 2.0F
  // 逆变换：dst → src（旋转 -angle）
  // src_x = cos*(dx-cx) + sin*(dy-cy) + cx
  // src_y = -sin*(dx-cx) + cos*(dy-cy) + cy
  // 即 matrix = (cos, sin, cx-cos*cx-sin*cy, -sin, cos, cy+sin*cx-cos*cy)
  let tx = cx - cos_a * cx - sin_a * cy
  let ty = cy + sin_a * cx - cos_a * cy
  let out : Array[Byte] = Array::make(w * h * ch, b'\x00')
  for dy in 0..<h {
    for dx in 0..<w {
      let fdx = Float::from_int(dx)
      let fdy = Float::from_int(dy)
      let sx = cos_a * fdx + sin_a * fdy + tx
      let sy = -sin_a * fdx + cos_a * fdy + ty
      // 超出边界的像素填黑（用 0.5 容差避免浮点误差）
      if sx < -0.5F ||
        sx > Float::from_int(w) - 0.5F ||
        sy < -0.5F ||
        sy > Float::from_int(h) - 0.5F {
        // 已经是 0
        continue
      }
      let sx_c = sx.clamp(min=0.0F, max=Float::from_int(w - 1))
      let sy_c = sy.clamp(min=0.0F, max=Float::from_int(h - 1))
      for ci in 0..<ch {
        let val = sample_bilinear(img.data, w, h, ch, ci, sx_c, sy_c)
        out[(dy * w + dx) * ch + ci] = val.clamp(min=0, max=255).to_byte()
      }
    }
  }
  @core.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}
