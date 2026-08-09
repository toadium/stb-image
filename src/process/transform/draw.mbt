// 图像合成操作（纯 MoonBit）：draw_over / draw_copy

///|
/// 将 src 图像直接拷贝到 dst 的 (x, y) 位置
/// 返回新的 Image，不修改原图。要求 dst 和 src channels 相同。
pub fn draw_copy(
  dst : @types.Image,
  src : @types.Image,
  x : Int,
  y : Int,
) -> @types.Image raise @types.LoadError {
  if dst.channels != src.channels {
    raise @types.LoadError::DecodeFailed(
      "draw_copy 要求 dst 和 src channels 相同",
    )
  }
  if x < 0 || y < 0 || x + src.width > dst.width || y + src.height > dst.height {
    raise @types.LoadError::DecodeFailed("draw_copy 区域越界")
  }
  let ch = dst.channels
  let out : Array[Byte] = []
  for i in 0..<dst.data.length() {
    out.push(dst.data[i])
  }
  for row in 0..<src.height {
    for col in 0..<src.width {
      let src_off = (row * src.width + col) * ch
      let dst_off = ((y + row) * dst.width + (x + col)) * ch
      for c in 0..<ch {
        out[dst_off + c] = src.data[src_off + c]
      }
    }
  }
  @types.Image::{
    width: dst.width,
    height: dst.height,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// Alpha 混合合成（source over destination）
/// 将 src 图像合成到 dst 的 (x, y) 位置
/// 要求 dst 和 src 均为 RGBA (channels=4)
/// 公式: result = src * src_a + dst * (1 - src_a)
pub fn draw_over(
  dst : @types.Image,
  src : @types.Image,
  x : Int,
  y : Int,
) -> @types.Image raise @types.LoadError {
  if dst.channels != 4 || src.channels != 4 {
    raise @types.LoadError::DecodeFailed(
      "draw_over 要求 dst 和 src 均为 RGBA (channels=4)",
    )
  }
  if x < 0 || y < 0 || x + src.width > dst.width || y + src.height > dst.height {
    raise @types.LoadError::DecodeFailed("draw_over 区域越界")
  }
  let out : Array[Byte] = []
  for i in 0..<dst.data.length() {
    out.push(dst.data[i])
  }
  let src_n = src.width * src.height
  let src_int : Array[Int] = Array::make(src_n * 4, 0)
  for i in 0..<(src_n * 4) {
    src_int[i] = src.data[i].to_int()
  }
  for row in 0..<src.height {
    for col in 0..<src.width {
      let src_off = (row * src.width + col) * 4
      let dst_off = ((y + row) * dst.width + (x + col)) * 4
      let sr = src_int[src_off]
      let sg = src_int[src_off + 1]
      let sb = src_int[src_off + 2]
      let sa = src_int[src_off + 3]
      let dr = out[dst_off].to_int()
      let dg = out[dst_off + 1].to_int()
      let db = out[dst_off + 2].to_int()
      let da = out[dst_off + 3].to_int()
      let inv_sa = 255 - sa
      let rr = (sr * sa + dr * inv_sa) / 255
      let rg = (sg * sa + dg * inv_sa) / 255
      let rb = (sb * sa + db * inv_sa) / 255
      let ra = sa + da * inv_sa / 255
      out[dst_off] = rr.to_byte()
      out[dst_off + 1] = rg.to_byte()
      out[dst_off + 2] = rb.to_byte()
      out[dst_off + 3] = ra.to_byte()
    }
  }
  @types.Image::{
    width: dst.width,
    height: dst.height,
    channels: 4,
    data: Bytes::from_array(out),
  }
}
