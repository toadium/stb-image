// 特征检测扩展 — SURF/FAST/BRIEF/AKAZE
// Feature detection extension: SURF/FAST/BRIEF/AKAZE
//
// Phase 12 v316: 大规模扩展 CV 算法库 — 特征检测算法扩展。

///|
/// 特征点。
/// Key point.
pub(all) struct KeyPoint {
  x : Int
  y : Int
  response : Double
  size : Int
  angle : Double
  octave : Int
} derive(Eq, @debug.Debug)

///|
pub extend KeyPoint with @debug.Debug::{to_repr}

///|
pub extend KeyPoint with Eq::{not_equal, equal}

///|
/// 二进制描述子（BRIEF）。
/// Binary descriptor (BRIEF).
pub(all) struct BinaryDescriptor {
  bits : Array[Bool]
  keypoint : KeyPoint
} derive(Eq, @debug.Debug)

///|
pub extend BinaryDescriptor with @debug.Debug::{to_repr}

///|
pub extend BinaryDescriptor with Eq::{not_equal, equal}

///|
/// 浮点描述子（SURF）。
/// Float descriptor (SURF).
pub(all) struct FloatDescriptor {
  values : Array[Double]
  keypoint : KeyPoint
} derive(Eq, @debug.Debug)

///|
pub extend FloatDescriptor with @debug.Debug::{to_repr}

///|
pub extend FloatDescriptor with Eq::{not_equal, equal}

///|
/// FAST 角点检测的 16 像素圆环偏移量。
fn fast_ring_offsets() -> Array[(Int, Int)] {
  [
    (0, -3),
    (1, -3),
    (2, -2),
    (3, -1),
    (3, 0),
    (3, 1),
    (2, 2),
    (1, 3),
    (0, 3),
    (-1, 3),
    (-2, 2),
    (-3, 1),
    (-3, 0),
    (-3, -1),
    (-2, -2),
    (-1, -3),
  ]
}

///|
/// 获取图像像素值（灰度，取第一个通道）。
fn get_pixel(img : @types.Image, x : Int, y : Int) -> Int {
  let w = img.width
  let h = img.height
  if x < 0 || x >= w || y < 0 || y >= h {
    return 0
  }
  let idx = (y * w + x) * img.channels
  img.data[idx].to_int()
}

///|
/// FAST 角点检测（FAST-9）。
/// FAST corner detection (FAST-9).
pub fn detect_fast_corners(
  img : @types.Image,
  threshold : Int,
) -> Array[KeyPoint] {
  let w = img.width
  let h = img.height
  let ring = fast_ring_offsets()
  let result : Array[KeyPoint] = []
  for y in 3..<(h - 3) {
    for x in 3..<(w - 3) {
      let center = get_pixel(img, x, y)
      let mut brighter = 0
      let mut darker = 0
      let mut bright_seq = 0
      let mut dark_seq = 0
      let mut max_bright = 0
      let mut max_dark = 0
      for i in 0..<16 {
        let (dx, dy) = ring[i]
        let val = get_pixel(img, x + dx, y + dy)
        if val > center + threshold {
          bright_seq = bright_seq + 1
          dark_seq = 0
          if bright_seq > max_bright {
            max_bright = bright_seq
          }
          brighter = brighter + 1
        } else if val < center - threshold {
          dark_seq = dark_seq + 1
          bright_seq = 0
          if dark_seq > max_dark {
            max_dark = dark_seq
          }
          darker = darker + 1
        } else {
          bright_seq = 0
          dark_seq = 0
        }
      }
      let ring2 = ring
      for i in 0..<16 {
        let (dx, dy) = ring2[i]
        let val = get_pixel(img, x + dx, y + dy)
        if val > center + threshold {
          bright_seq = bright_seq + 1
          dark_seq = 0
          if bright_seq > max_bright {
            max_bright = bright_seq
          }
        } else if val < center - threshold {
          dark_seq = dark_seq + 1
          bright_seq = 0
          if dark_seq > max_dark {
            max_dark = dark_seq
          }
        } else {
          bright_seq = 0
          dark_seq = 0
        }
      }
      if max_bright >= 9 || max_dark >= 9 {
        let response = if max_bright >= max_dark {
          max_bright.to_double()
        } else {
          max_dark.to_double()
        }
        result.push({ x, y, response, size: 7, angle: 0.0, octave: 0, })
      }
      let _ = brighter
      let _ = darker
    }
  }
  result
}

///|
/// BRIEF 描述子生成。
/// Generate BRIEF descriptors.
pub fn compute_brief_descriptors(
  img : @types.Image,
  keypoints : Array[KeyPoint],
) -> Array[BinaryDescriptor] {
  let result : Array[BinaryDescriptor] = []
  let pairs = brief_sample_pairs()
  for kp in keypoints {
    let bits : Array[Bool] = []
    for i in 0..<pairs.length() {
      let (x1, y1, x2, y2) = pairs[i]
      let v1 = get_pixel(img, kp.x + x1, kp.y + y1)
      let v2 = get_pixel(img, kp.x + x2, kp.y + y2)
      bits.push(v1 < v2)
    }
    result.push({ bits, keypoint: kp, })
  }
  result
}

///|
/// BRIEF 采样点对（256 对）。
fn brief_sample_pairs() -> Array[(Int, Int, Int, Int)] {
  let pairs : Array[(Int, Int, Int, Int)] = []
  let pattern = [
    (0, 0),
    (1, 0),
    (0, 1),
    (1, 1),
    (-1, 0),
    (0, -1),
    (-1, -1),
    (1, -1),
    (-1, 1),
    (2, 0),
    (0, 2),
    (2, 1),
    (1, 2),
    (2, 2),
    (-2, 0),
    (0, -2),
    (-2, -1),
    (-1, -2),
    (-2, -2),
    (2, -1),
    (1, -2),
    (2, -2),
    (-2, 1),
    (-1, 2),
    (-2, 2),
    (3, 0),
    (0, 3),
    (3, 1),
    (1, 3),
    (3, 2),
    (2, 3),
    (3, 3),
  ]
  for i in 0..<pattern.length() {
    for j in 0..<pattern.length() {
      if i != j {
        let (x1, y1) = pattern[i]
        let (x2, y2) = pattern[j]
        pairs.push((x1, y1, x2, y2))
        if pairs.length() >= 256 {
          return pairs
        }
      }
    }
  }
  pairs
}

///|
/// Sobel 梯度计算。
fn sobel_gradients(img : @types.Image, x : Int, y : Int) -> (Double, Double) {
  let gx = (get_pixel(img, x + 1, y - 1) +
  2 * get_pixel(img, x + 1, y) +
  get_pixel(img, x + 1, y + 1) -
  get_pixel(img, x - 1, y - 1) -
  2 * get_pixel(img, x - 1, y) -
  get_pixel(img, x - 1, y + 1)).to_double()
  let gy = (get_pixel(img, x - 1, y + 1) +
  2 * get_pixel(img, x, y + 1) +
  get_pixel(img, x + 1, y + 1) -
  get_pixel(img, x - 1, y - 1) -
  2 * get_pixel(img, x, y - 1) -
  get_pixel(img, x + 1, y - 1)).to_double()
  (gx, gy)
}

///|
/// SURF 特征点检测（简化版，基于 Hessian 行列式）。
/// SURF keypoint detection (simplified, based on Hessian determinant).
pub fn detect_surf_keypoints(
  img : @types.Image,
  threshold : Double,
) -> Array[KeyPoint] {
  let w = img.width
  let h = img.height
  let result : Array[KeyPoint] = []
  for y in 2..<(h - 2) {
    for x in 2..<(w - 2) {
      let (gx, gy) = sobel_gradients(img, x, y)
      let gxx = (get_pixel(img, x + 1, y) -
      2 * get_pixel(img, x, y) +
      get_pixel(img, x - 1, y)).to_double()
      let gyy = (get_pixel(img, x, y + 1) -
      2 * get_pixel(img, x, y) +
      get_pixel(img, x, y - 1)).to_double()
      let (gxy1, _) = sobel_gradients(img, x + 1, y)
      let (gxy2, _) = sobel_gradients(img, x - 1, y)
      let gxy = (gxy1 - gxy2) / 2.0
      let det = gxx * gyy - gxy * gxy
      if det > threshold {
        let angle = @math.atan2(gy, gx)
        result.push({ x, y, response: det, size: 9, angle, octave: 0, })
      }
    }
  }
  result
}

///|
/// SURF 描述子生成（简化版，64 维）。
/// Generate SURF descriptors (simplified, 64-dim).
pub fn compute_surf_descriptors(
  img : @types.Image,
  keypoints : Array[KeyPoint],
) -> Array[FloatDescriptor] {
  let result : Array[FloatDescriptor] = []
  for kp in keypoints {
    let values : Array[Double] = []
    for dy in -4..<5 {
      for dx in -4..<5 {
        let (gx, gy) = sobel_gradients(img, kp.x + dx, kp.y + dy)
        values.push(gx)
        values.push(gy)
      }
    }
    while values.length() > 64 {
      values.pop() |> ignore
    }
    while values.length() < 64 {
      values.push(0.0)
    }
    result.push({ values, keypoint: kp, })
  }
  result
}

///|
/// AKAZE 特征点检测（简化版，基于非线性扩散 + Hessian）。
/// AKAZE keypoint detection (simplified, based on nonlinear diffusion + Hessian).
pub fn detect_akaze_keypoints(
  img : @types.Image,
  threshold : Double,
) -> Array[KeyPoint] {
  let w = img.width
  let h = img.height
  let result : Array[KeyPoint] = []
  for y in 2..<(h - 2) {
    for x in 2..<(w - 2) {
      let center = get_pixel(img, x, y).to_double()
      let mut sum = 0.0
      for dy in [-1, 0, 1] {
        for dx in [-1, 0, 1] {
          sum = sum + get_pixel(img, x + dx, y + dy).to_double()
        }
      }
      let blurred = sum / 9.0
      let gxx = get_pixel(img, x + 1, y).to_double() -
        2.0 * center +
        get_pixel(img, x - 1, y).to_double()
      let gyy = get_pixel(img, x, y + 1).to_double() -
        2.0 * center +
        get_pixel(img, x, y - 1).to_double()
      let gxy = (
          get_pixel(img, x + 1, y + 1).to_double() -
          get_pixel(img, x - 1, y + 1).to_double() -
          (
            get_pixel(img, x + 1, y - 1).to_double() -
            get_pixel(img, x - 1, y - 1).to_double()
          )
        ) /
        4.0
      let det = gxx * gyy - gxy * gxy
      let diff = (center - blurred).abs()
      if det > threshold && diff > 5.0 {
        let (gx, gy) = sobel_gradients(img, x, y)
        let angle = @math.atan2(gy, gx)
        result.push({ x, y, response: det, size: 5, angle, octave: 0, })
      }
    }
  }
  result
}

///|
/// AKAZE 描述子生成（简化版，M-LDB 128 维）。
/// Generate AKAZE descriptors (simplified, M-LDB 128-dim).
pub fn compute_akaze_descriptors(
  img : @types.Image,
  keypoints : Array[KeyPoint],
) -> Array[FloatDescriptor] {
  let result : Array[FloatDescriptor] = []
  for kp in keypoints {
    let values : Array[Double] = []
    for dy in -3..<4 {
      for dx in -3..<4 {
        let (gx, gy) = sobel_gradients(img, kp.x + dx, kp.y + dy)
        values.push(gx)
        values.push(gy)
      }
    }
    while values.length() > 128 {
      values.pop() |> ignore
    }
    while values.length() < 128 {
      values.push(0.0)
    }
    result.push({ values, keypoint: kp, })
  }
  result
}

///|
/// 汉明距离（BRIEF 描述子匹配）。
/// Hamming distance (BRIEF descriptor matching).
pub fn hamming_distance(d1 : BinaryDescriptor, d2 : BinaryDescriptor) -> Int {
  let mut dist = 0
  let len = if d1.bits.length() < d2.bits.length() {
    d1.bits.length()
  } else {
    d2.bits.length()
  }
  for i in 0..<len {
    if d1.bits[i] != d2.bits[i] {
      dist = dist + 1
    }
  }
  dist
}

///|
/// 欧氏距离（SURF/AKAZE 描述子匹配）。
/// Euclidean distance (SURF/AKAZE descriptor matching).
pub fn euclidean_distance(d1 : FloatDescriptor, d2 : FloatDescriptor) -> Double {
  let mut sum = 0.0
  let len = if d1.values.length() < d2.values.length() {
    d1.values.length()
  } else {
    d2.values.length()
  }
  for i in 0..<len {
    let diff = d1.values[i] - d2.values[i]
    sum = sum + diff * diff
  }
  sum.sqrt()
}
