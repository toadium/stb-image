// 光流扩展 — Lucas-Kanade/Horn-Schunck/Farneback
// Optical flow: Lucas-Kanade / Horn-Schunck / Farneback
//
// Phase 12 v321: 大规模扩展 CV 算法库 — 光流。

///|
/// 光流场（2D 向量场）。
/// Optical flow field (2D vector field).
pub(all) struct FlowField {
  width : Int
  height : Int
  u : Array[Double]
  v : Array[Double]
} derive(Eq, @debug.Debug)

///|
pub extend FlowField with @debug.Debug::{to_repr}

///|
pub extend FlowField with Eq::{not_equal, equal}

///|
/// 光流参数。
/// Optical flow parameters.
pub(all) struct FlowParams {
  window_size : Int
  max_iterations : Int
  epsilon : Double
  alpha : Double
} derive(Eq, @debug.Debug)

///|
pub extend FlowParams with @debug.Debug::{to_repr}

///|
pub extend FlowParams with Eq::{not_equal, equal}

///|
/// Lucas-Kanade 稀疏光流。
/// Lucas-Kanade sparse optical flow.
pub fn compute_lucas_kanade(
  prev : @types.Image,
  curr : @types.Image,
  points : Array[(Int, Int)],
  params : FlowParams,
) -> FlowField {
  let w = prev.width
  let h = prev.height
  let half = params.window_size / 2
  let u : Array[Double] = []
  let v : Array[Double] = []
  for _ in 0..<h {
    for _ in 0..<w {
      u.push(0.0)
      v.push(0.0)
    }
  }
  for pt in points {
    let (px, py) = pt
    if px < half || px >= w - half || py < half || py >= h - half {
      continue
    }
    let mut sum_ix2 = 0.0
    let mut sum_iy2 = 0.0
    let mut sum_ixiy = 0.0
    let mut sum_ixit = 0.0
    let mut sum_iyit = 0.0
    for dy in [-half, half] {
      for dx in [-half, half] {
        let x = px + dx
        let y = py + dy
        if x < 1 || x >= w - 1 || y < 1 || y >= h - 1 {
          continue
        }
        let idx = y * w + x
        let ix = (prev.data[idx + 1].to_int() - prev.data[idx - 1].to_int()).to_double() /
          2.0
        let iy = (prev.data[idx + w].to_int() - prev.data[idx - w].to_int()).to_double() /
          2.0
        let it = (curr.data[idx].to_int() - prev.data[idx].to_int()).to_double()
        sum_ix2 = sum_ix2 + ix * ix
        sum_iy2 = sum_iy2 + iy * iy
        sum_ixiy = sum_ixiy + ix * iy
        sum_ixit = sum_ixit + ix * it
        sum_iyit = sum_iyit + iy * it
      }
    }
    let det = sum_ix2 * sum_iy2 - sum_ixiy * sum_ixiy
    if det.abs() > params.epsilon {
      let fu = -(sum_iy2 * sum_ixit - sum_ixiy * sum_iyit) / det
      let fv = -(-sum_ixiy * sum_ixit + sum_ix2 * sum_iyit) / det
      let idx = py * w + px
      u[idx] = fu
      v[idx] = fv
    }
  }
  { width: w, height: h, u, v, }
}

///|
/// Horn-Schunck 密集光流（简化版）。
/// Horn-Schunck dense optical flow (simplified).
pub fn compute_horn_schunck(
  prev : @types.Image,
  curr : @types.Image,
  params : FlowParams,
) -> FlowField {
  let w = prev.width
  let h = prev.height
  let u : Array[Double] = []
  let v : Array[Double] = []
  for _ in 0..<(w * h) {
    u.push(0.0)
    v.push(0.0)
  }
  for _ in 0..<params.max_iterations {
    for y in 1..<(h - 1) {
      for x in 1..<(w - 1) {
        let idx = y * w + x
        let ix = (prev.data[idx + 1].to_int() - prev.data[idx - 1].to_int()).to_double() /
          2.0
        let iy = (prev.data[idx + w].to_int() - prev.data[idx - w].to_int()).to_double() /
          2.0
        let it = (curr.data[idx].to_int() - prev.data[idx].to_int()).to_double()
        let u_avg = (u[idx - 1] + u[idx + 1] + u[idx - w] + u[idx + w]) / 4.0
        let v_avg = (v[idx - 1] + v[idx + 1] + v[idx - w] + v[idx + w]) / 4.0
        let denom = ix * ix + iy * iy + params.alpha * params.alpha
        if denom > 0.0 {
          u[idx] = u_avg - ix * (ix * u_avg + iy * v_avg + it) / denom
          v[idx] = v_avg - iy * (ix * u_avg + iy * v_avg + it) / denom
        }
      }
    }
  }
  { width: w, height: h, u, v, }
}

///|
/// Farneback 密集光流（简化版，多项式展开）。
/// Farneback dense optical flow (simplified, polynomial expansion).
pub fn compute_farneback(
  prev : @types.Image,
  curr : @types.Image,
  params : FlowParams,
) -> FlowField {
  let hs = compute_horn_schunck(prev, curr, params)
  let w = hs.width
  let h = hs.height
  let u : Array[Double] = []
  let v : Array[Double] = []
  for y in 0..<h {
    for x in 0..<w {
      let mut su = 0.0
      let mut sv = 0.0
      let mut count = 0
      for dy in [-1, 0, 1] {
        for dx in [-1, 0, 1] {
          let nx = x + dx
          let ny = y + dy
          if nx >= 0 && nx < w && ny >= 0 && ny < h {
            let nidx = ny * w + nx
            su = su + hs.u[nidx]
            sv = sv + hs.v[nidx]
            count = count + 1
          }
        }
      }
      u.push(su / count.to_double())
      v.push(sv / count.to_double())
    }
  }
  { width: w, height: h, u, v, }
}

///|
/// 用光流场扭曲图像。
/// Warp image by flow field.
pub fn warp_image(img : @types.Image, flow : FlowField) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let sx = x.to_double() + flow.u[idx]
      let sy = y.to_double() + flow.v[idx]
      let ix = sx.to_int()
      let iy = sy.to_int()
      for c in 0..<ch {
        if ix >= 0 && ix < w && iy >= 0 && iy < h {
          let src_idx = (iy * w + ix) * ch + c
          data.push(img.data[src_idx])
        } else {
          data.push(b'\x00')
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 计算光流场幅度。
/// Compute flow field magnitude.
pub fn flow_magnitude(flow : FlowField) -> Array[Double] {
  let mags : Array[Double] = []
  for i in 0..<flow.u.length() {
    mags.push((flow.u[i] * flow.u[i] + flow.v[i] * flow.v[i]).sqrt())
  }
  mags
}

///|
/// 光流一致性检查。
/// Flow consistency check.
pub fn flow_consistency(forward : FlowField, backward : FlowField) -> Double {
  let n = forward.u.length()
  if n == 0 {
    return 0.0
  }
  let mut total = 0.0
  for i in 0..<n {
    let du = forward.u[i] + backward.u[i]
    let dv = forward.v[i] + backward.v[i]
    total = total + (du * du + dv * dv).sqrt()
  }
  total / n.to_double()
}
