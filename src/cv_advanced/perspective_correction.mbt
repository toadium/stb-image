// 透视校正 — 透视变换/文档扫描/边缘检测
// Perspective correction: transform / document scan / edge detection
//
// Phase 16 v390: 计算摄影大扩展 — 透视校正。

///|
/// 2D 点。
/// 2D point.
pub(all) struct Point2D {
  x : Double
  y : Double
} derive(Eq, @debug.Debug)

///|
pub extend Point2D with @debug.Debug::{to_repr}

///|
pub extend Point2D with Eq::{not_equal, equal}

///|
/// 透视变换参数（3x3 单应矩阵，简化为 8 参数）。
/// Perspective transform parameters (homography, 8 DOF).
pub(all) struct PerspectiveTransform {
  h00 : Double
  h01 : Double
  h02 : Double
  h10 : Double
  h11 : Double
  h12 : Double
  h20 : Double
  h21 : Double
  // h22 = 1.0
} derive(Eq, @debug.Debug)

///|
pub extend PerspectiveTransform with @debug.Debug::{to_repr}

///|
pub extend PerspectiveTransform with Eq::{not_equal, equal}

///|
/// 文档检测结果。
/// Document detection result.
pub(all) struct DocumentDetectionResult {
  corners : Array[Point2D] // 四个角点
  confidence : Double // 检测置信度
  width : Int32
  height : Int32
} derive(Eq, @debug.Debug)

///|
pub extend DocumentDetectionResult with @debug.Debug::{to_repr}

///|
pub extend DocumentDetectionResult with Eq::{not_equal, equal}

///|
/// 从 4 对对应点计算透视变换矩阵。
/// Compute perspective transform from 4 point correspondences.
/// src -> dst 的单应变换。
pub fn compute_perspective_transform(
  src : Array[Point2D],
  dst : Array[Point2D],
) -> PerspectiveTransform {
  // 简化：用最小二乘法解 8 参数
  // 对于 4 对点，可以精确求解
  // 这里用简化方法：假设主要是仿射变换 + 透视分量
  if src.length() < 4 || dst.length() < 4 {
    return {
      h00: 1.0,
      h01: 0.0,
      h02: 0.0,
      h10: 0.0,
      h11: 1.0,
      h12: 0.0,
      h20: 0.0,
      h21: 0.0,
    }
  }
  // 简化：计算仿射变换 + 透视分量
  let sx0 = src[0].x
  let sy0 = src[0].y
  let sx1 = src[1].x
  let sy1 = src[1].y
  let sx2 = src[2].x
  let sy2 = src[2].y
  let sx3 = src[3].x
  let sy3 = src[3].y
  let dx0 = dst[0].x
  let dy0 = dst[0].y
  let dx1 = dst[1].x
  let dy1 = dst[1].y
  let dx2 = dst[2].x
  let dy2 = dst[2].y
  let dx3 = dst[3].x
  let dy3 = dst[3].y
  // 简化：用 4 个点计算仿射变换（忽略透视分量）
  // h00 * sx + h01 * sy + h02 = dx
  // h10 * sx + h11 * sy + h12 = dy
  // 用前 3 个点解仿射，第 4 个点估计透视
  let det = (sx0 - sx2) * (sy1 - sy2) - (sx1 - sx2) * (sy0 - sy2)
  if det.abs() < 0.001 {
    return {
      h00: 1.0,
      h01: 0.0,
      h02: 0.0,
      h10: 0.0,
      h11: 1.0,
      h12: 0.0,
      h20: 0.0,
      h21: 0.0,
    }
  }
  let inv_det = 1.0 / det
  let h00 = ((dx0 - dx2) * (sy1 - sy2) - (dx1 - dx2) * (sy0 - sy2)) * inv_det
  let h01 = ((sx0 - sx2) * (dx1 - dx2) - (sx1 - sx2) * (dx0 - dx2)) * inv_det
  let h02 = dx0 - h00 * sx0 - h01 * sy0
  let h10 = ((dy0 - dy2) * (sy1 - sy2) - (dy1 - dy2) * (sy0 - sy2)) * inv_det
  let h11 = ((sx0 - sx2) * (dy1 - dy2) - (sx1 - sx2) * (dy0 - dy2)) * inv_det
  let h12 = dy0 - h10 * sx0 - h11 * sy0
  // 透视分量：用第 4 个点估计
  let dx3_pred = h00 * sx3 + h01 * sy3 + h02
  let dy3_pred = h10 * sx3 + h11 * sy3 + h12
  let persp_err = (dx3 - dx3_pred).abs() + (dy3 - dy3_pred).abs()
  // 简化透视分量
  let h20 = if persp_err > 0.1 {
    (dx3 - dx3_pred) / (sx3 * persp_err)
  } else {
    0.0
  }
  let h21 = if persp_err > 0.1 {
    (dy3 - dy3_pred) / (sy3 * persp_err)
  } else {
    0.0
  }
  { h00, h01, h02, h10, h11, h12, h20, h21, }
}

///|
/// 应用透视变换到点。
/// Apply perspective transform to a point.
pub fn apply_perspective(
  transform : PerspectiveTransform,
  pt : Point2D,
) -> Point2D {
  let x = transform.h00 * pt.x + transform.h01 * pt.y + transform.h02
  let y = transform.h10 * pt.x + transform.h11 * pt.y + transform.h12
  let w = transform.h20 * pt.x + transform.h21 * pt.y + 1.0
  if w.abs() < 0.0001 {
    { x: pt.x, y: pt.y, }
  } else {
    { x: x / w, y: y / w, }
  }
}

///|
/// 透视校正图像。
/// Apply perspective correction to image.
pub fn correct_perspective(
  img : @types.Image,
  transform : PerspectiveTransform,
  out_width : Int32,
  out_height : Int32,
) -> @types.Image {
  let ch = img.channels
  let data : Array[Byte] = []
  for oy in 0..<out_height {
    for ox in 0..<out_width {
      // 逆映射：从输出坐标找输入坐标
      let out_pt : Point2D = { x: ox.to_double(), y: oy.to_double(), }
      let in_pt = apply_perspective(transform, out_pt)
      let ix = in_pt.x
      let iy = in_pt.y
      // 双线性插值
      let x0 = ix.to_int().clamp(min=0, max=img.width - 1)
      let y0 = iy.to_int().clamp(min=0, max=img.height - 1)
      let x1 = (x0 + 1).clamp(min=0, max=img.width - 1)
      let y1 = (y0 + 1).clamp(min=0, max=img.height - 1)
      let fx = ix - x0.to_double()
      let fy = iy - y0.to_double()
      for c in 0..<ch {
        let p00 = img.data[(y0 * img.width + x0) * ch + c].to_int().to_double()
        let p01 = img.data[(y0 * img.width + x1) * ch + c].to_int().to_double()
        let p10 = img.data[(y1 * img.width + x0) * ch + c].to_int().to_double()
        let p11 = img.data[(y1 * img.width + x1) * ch + c].to_int().to_double()
        let val = p00 * (1.0 - fx) * (1.0 - fy) +
          p01 * fx * (1.0 - fy) +
          p10 * (1.0 - fx) * fy +
          p11 * fx * fy
        data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  {
    width: out_width,
    height: out_height,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
/// 检测文档边缘（简化版：找最大对比度区域）。
/// Detect document edges (simplified).
pub fn detect_document_edges(img : @types.Image) -> DocumentDetectionResult {
  let w = img.width
  let h = img.height
  let ch = img.channels
  // 简化：用边缘梯度找文档上下边界
  let mut top_y = 0.0
  let bottom_y = (h - 1).to_double()
  let mut max_grad = 0.0
  for y in 0..<h {
    let mut grad = 0.0
    for x in 0..<w {
      let pi = (y * w + x) * ch
      let val = img.data[pi].to_int().to_double()
      if y + 1 < h {
        let next = img.data[((y + 1) * w + x) * ch].to_int().to_double()
        grad = grad + (next - val).abs()
      }
    }
    if grad > max_grad {
      max_grad = grad
      top_y = y.to_double()
    }
  }
  // 简化角点：用检测到的上下边界 + 左右边界
  let margin = 2
  let corners : Array[Point2D] = [
    { x: margin.to_double(), y: top_y + margin.to_double(), },
    { x: (w - margin - 1).to_double(), y: top_y + margin.to_double(), },
    { x: (w - margin - 1).to_double(), y: bottom_y - margin.to_double(), },
    { x: margin.to_double(), y: bottom_y - margin.to_double(), },
  ]
  let confidence = if max_grad > 0.0 { 1.0 } else { 0.0 }
  { corners, confidence, width: w, height: h, }
}

///|
/// 文档扫描：检测文档边缘 + 透视校正。
/// Document scan: detect edges + perspective correction.
pub fn document_scan(
  img : @types.Image,
  out_width : Int32,
  out_height : Int32,
) -> @types.Image {
  let detection = detect_document_edges(img)
  if detection.corners.length() < 4 {
    return img
  }
  // 目标四角
  let dst : Array[Point2D] = [
    { x: 0.0, y: 0.0, },
    { x: out_width.to_double() - 1.0, y: 0.0, },
    { x: out_width.to_double() - 1.0, y: out_height.to_double() - 1.0, },
    { x: 0.0, y: out_height.to_double() - 1.0, },
  ]
  // 计算逆变换（dst -> src）
  let transform = compute_perspective_transform(dst, detection.corners)
  correct_perspective(img, transform, out_width, out_height)
}

///|
/// 创建恒等透视变换。
/// Create identity perspective transform.
pub fn identity_perspective_transform() -> PerspectiveTransform {
  {
    h00: 1.0,
    h01: 0.0,
    h02: 0.0,
    h10: 0.0,
    h11: 1.0,
    h12: 0.0,
    h20: 0.0,
    h21: 0.0,
  }
}

///|
/// 透视校正流水线。
/// Perspective correction pipeline.
pub fn perspective_correction_pipeline(
  img : @types.Image,
  src_corners : Array[Point2D],
  out_width : Int32,
  out_height : Int32,
) -> @types.Image {
  if src_corners.length() < 4 {
    return img
  }
  let dst : Array[Point2D] = [
    { x: 0.0, y: 0.0, },
    { x: out_width.to_double() - 1.0, y: 0.0, },
    { x: out_width.to_double() - 1.0, y: out_height.to_double() - 1.0, },
    { x: 0.0, y: out_height.to_double() - 1.0, },
  ]
  let transform = compute_perspective_transform(dst, src_corners)
  correct_perspective(img, transform, out_width, out_height)
}
