// DCT (离散余弦变换) 公共 API：dct_2d + idct_2d
// 2D DCT-II 和 IDCT-III，用于频域分析和图像压缩

///|
/// 2D DCT-II。将灰度图变换为 DCT 系数矩阵。
/// 输入图像转为灰度，输出 N×M 的系数矩阵。
pub fn dct_2d(img : @types.Image) -> Array[Array[Double]] {
  let ch = img.channels
  let w = img.width
  let h = img.height
  let n = w * h
  let src : Array[Float] = Array::make(n, 0.0F)
  for i in 0..<n {
    let v = if ch == 1 {
      Float::from_int(img.data[i].to_int())
    } else {
      let r = Float::from_int(img.data[i * ch].to_int())
      let g = Float::from_int(img.data[i * ch + 1].to_int())
      let b = Float::from_int(img.data[i * ch + 2].to_int())
      r * 0.299F + g * 0.587F + b * 0.114F
    }
    src[i] = v
  }
  let result : Array[Array[Double]] = Array::make(h, [])
  for y in 0..<h {
    result[y] = Array::make(w, 0.0)
  }
  let pi = 3.14159265358979F
  let wf = Float::from_int(w)
  let hf = Float::from_int(h)
  for u in 0..<w {
    let uf = Float::from_int(u)
    let cu = if u == 0 { (1.0F / wf).sqrt() } else { (2.0F / wf).sqrt() }
    for v in 0..<h {
      let vf = Float::from_int(v)
      let cv = if v == 0 { (1.0F / hf).sqrt() } else { (2.0F / hf).sqrt() }
      let mut sum = 0.0F
      for x in 0..<w {
        let xf = Float::from_int(2 * x + 1)
        for y in 0..<h {
          let yf = Float::from_int(2 * y + 1)
          let cos1 = @math.cosf(pi * xf * uf / (2.0F * wf))
          let cos2 = @math.cosf(pi * yf * vf / (2.0F * hf))
          sum += src[y * w + x] * cos1 * cos2
        }
      }
      result[v][u] = (cu * cv * sum).to_double()
    }
  }
  result
}

///|
/// 2D IDCT-III。将 DCT 系数矩阵逆变换为灰度图。
pub fn idct_2d(coeffs : Array[Array[Double]]) -> @types.Image {
  let h = coeffs.length()
  let w = if h == 0 { 0 } else { coeffs[0].length() }
  let pi = 3.14159265358979F
  let wf = Float::from_int(w)
  let hf = Float::from_int(h)
  let out : Array[Byte] = Array::make(w * h, b'\x00')
  for x in 0..<w {
    let xf = Float::from_int(2 * x + 1)
    for y in 0..<h {
      let yf = Float::from_int(2 * y + 1)
      let mut sum = 0.0F
      for u in 0..<w {
        let uf = Float::from_int(u)
        let cu = if u == 0 { (1.0F / wf).sqrt() } else { (2.0F / wf).sqrt() }
        for v in 0..<h {
          let vf = Float::from_int(v)
          let cv = if v == 0 { (1.0F / hf).sqrt() } else { (2.0F / hf).sqrt() }
          let cos1 = @math.cosf(pi * xf * uf / (2.0F * wf))
          let cos2 = @math.cosf(pi * yf * vf / (2.0F * hf))
          sum += cu * cv * Float::from_double(coeffs[v][u]) * cos1 * cos2
        }
      }
      let val = (sum + 0.5F).to_int().clamp(min=0, max=255)
      out[y * w + x] = val.to_byte()
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(out),
  }
}
