// 纯 MoonBit 图像缩放（全目标可用：native/wasm/js）
// 仅依赖 @types，不依赖 @core/FFI
// 支持最近邻 + 双线性插值
// v190.0.0 性能优化：预计算坐标权重 + 消除 data_int 拷贝

///|
/// resize 8-bit 图像（纯 MoonBit，全目标可用）。
/// 使用双线性插值（filter = PointSample 时使用最近邻）。
/// edge 参数目前统一按 Clamp 处理（边缘像素重复）。
/// v190.0.0 优化：预计算坐标权重数组，消除 data_int 转换，
/// 直接在 Bytes 上操作，减少 O(n) 内存拷贝和重复浮点运算。
pub fn resize_pure(
  img : @types.Image,
  out_w : Int,
  out_h : Int,
  filter? : @types.ResizeFilter = @types.ResizeFilter::Default,
  edge? : @types.ResizeEdge = @types.ResizeEdge::Clamp,
) -> @types.Image raise @types.LoadError {
  let _ = edge
  if out_w <= 0 || out_h <= 0 {
    raise @types.LoadError::DecodeFailed("resize 输出尺寸必须为正数")
  }
  let ch = img.channels
  let w = img.width
  let h = img.height
  let scale_x = Float::from_int(w) / Float::from_int(out_w)
  let scale_y = Float::from_int(h) / Float::from_int(out_h)
  let use_nearest = match filter {
    PointSample => true
    _ => false
  }
  let w_minus_1 = w - 1
  let h_minus_1 = h - 1
  let out : Array[Byte] = Array::make(out_w * out_h * ch, b'\x00')
  if use_nearest {
    let sx_xi : Array[Int] = Array::make(out_w, 0)
    for dx in 0..<out_w {
      let sx = (Float::from_int(dx) + 0.5F) * scale_x - 0.5F
      sx_xi[dx] = (sx + 0.5F).to_int().clamp(min=0, max=w_minus_1)
    }
    let sy_yi : Array[Int] = Array::make(out_h, 0)
    for dy in 0..<out_h {
      let sy = (Float::from_int(dy) + 0.5F) * scale_y - 0.5F
      sy_yi[dy] = (sy + 0.5F).to_int().clamp(min=0, max=h_minus_1)
    }
    for dy in 0..<out_h {
      let yi = sy_yi[dy]
      for dx in 0..<out_w {
        let xi = sx_xi[dx]
        let src_idx = (yi * w + xi) * ch
        let dst_idx = (dy * out_w + dx) * ch
        for ci in 0..<ch {
          out[dst_idx + ci] = img.data[src_idx + ci]
        }
      }
    }
  } else {
    let sx_x0c : Array[Int] = Array::make(out_w, 0)
    let sx_x1 : Array[Int] = Array::make(out_w, 0)
    let sx_fx : Array[Float] = Array::make(out_w, 0.0F)
    for dx in 0..<out_w {
      let sx = (Float::from_int(dx) + 0.5F) * scale_x - 0.5F
      let x0 = sx.to_int()
      sx_x0c[dx] = x0.clamp(min=0, max=w_minus_1)
      sx_x1[dx] = (x0 + 1).clamp(min=0, max=w_minus_1)
      sx_fx[dx] = sx - Float::from_int(x0)
    }
    let sy_y0c : Array[Int] = Array::make(out_h, 0)
    let sy_y1 : Array[Int] = Array::make(out_h, 0)
    let sy_fy : Array[Float] = Array::make(out_h, 0.0F)
    for dy in 0..<out_h {
      let sy = (Float::from_int(dy) + 0.5F) * scale_y - 0.5F
      let y0 = sy.to_int()
      sy_y0c[dy] = y0.clamp(min=0, max=h_minus_1)
      sy_y1[dy] = (y0 + 1).clamp(min=0, max=h_minus_1)
      sy_fy[dy] = sy - Float::from_int(y0)
    }
    for dy in 0..<out_h {
      let y0c = sy_y0c[dy]
      let y1 = sy_y1[dy]
      let fy = sy_fy[dy]
      let one_minus_fy = 1.0F - fy
      for dx in 0..<out_w {
        let x0c = sx_x0c[dx]
        let x1 = sx_x1[dx]
        let fx = sx_fx[dx]
        let one_minus_fx = 1.0F - fx
        let dst_idx = (dy * out_w + dx) * ch
        for ci in 0..<ch {
          let p00 = img.data[(y0c * w + x0c) * ch + ci].to_int()
          let p10 = img.data[(y0c * w + x1) * ch + ci].to_int()
          let p01 = img.data[(y1 * w + x0c) * ch + ci].to_int()
          let p11 = img.data[(y1 * w + x1) * ch + ci].to_int()
          let top = Float::from_int(p00) * one_minus_fx +
            Float::from_int(p10) * fx
          let bot = Float::from_int(p01) * one_minus_fx +
            Float::from_int(p11) * fx
          let val = (top * one_minus_fy + bot * fy + 0.5F).to_int()
          out[dst_idx + ci] = val.clamp(min=0, max=255).to_byte()
        }
      }
    }
  }
  @types.Image::{
    width: out_w,
    height: out_h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}
