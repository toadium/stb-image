// 字符分割完善
// 滴水算法、连通域分割、粘连字符处理、分割后处理

///|
/// 分割点结构体
pub(all) struct SplitPoint {
  x : Int
  y_top : Int
  y_bottom : Int
  confidence : Double
}

///|
/// 滴水算法分割结果
pub(all) struct DropFallResult {
  split_points : Array[SplitPoint]
  char_regions : Array[(Int, Int)]
  success : Bool
}

///|
/// 滴水算法（Drop Fall Algorithm）
/// 用于分割粘连字符，模拟水滴从顶部落下的路径
pub fn drop_fall_segmentation(
  img : @types.Image,
  start_x? : Int = -1,
) -> DropFallResult raise @types.LoadError {
  if img.channels != 1 {
    raise @types.LoadError::DecodeFailed("drop_fall_segmentation: 仅支持单通道二值图")
  }
  let w = img.width
  let h = img.height
  let data = img.data
  // 如果未指定起始x，使用中间位置
  let sx = if start_x < 0 { w / 2 } else { start_x }
  // 滴水路径
  let path : Array[(Int, Int)] = []
  let mut x = sx
  let mut y = 0
  let stuck = false
  let mut iterations = 0
  let max_iterations = w * h
  while y < h - 1 && !stuck && iterations < max_iterations {
    iterations += 1
    path.push((x, y))
    // 检查下方三个方向：左下、正下、右下
    let left = if x > 0 { data[(y + 1) * w + (x - 1)].to_int() } else { 255 }
    let center = data[(y + 1) * w + x].to_int()
    let right = if x < w - 1 { data[(y + 1) * w + (x + 1)].to_int() } else { 255 }
    // 水滴优先向黑色像素（前景）移动
    if center < 128 {
      // 正下是黑色，继续向下
      y += 1
    } else if left < 128 && right < 128 {
      // 左右都是黑色，随机选择（这里选择左）
      x -= 1
      y += 1
    } else if left < 128 {
      // 左下是黑色
      x -= 1
      y += 1
    } else if right < 128 {
      // 右下是黑色
      x += 1
      y += 1
    } else {
      // 下方都是白色，水滴在白色区域
      // 检查是否到达底部或卡住
      if y >= h - 1 {
        break
      }
      // 在白色区域，继续向下（模拟水滴穿透白色背景）
      y += 1
    }
    // 边界检查
    if x < 0 { x = 0 }
    if x >= w { x = w - 1 }
  }
  path.push((x, y))
  // 从路径中提取分割点
  let split_points : Array[SplitPoint] = []
  if path.length() > 0 {
    let (final_x, _) = path[path.length() - 1]
    split_points.push(SplitPoint::{
      x: final_x,
      y_top: 0,
      y_bottom: h - 1,
      confidence: 0.8,
    })
  }
  // 计算字符区域
  let char_regions : Array[(Int, Int)] = []
  if split_points.length() > 0 {
    let mut prev_x = 0
    for sp in split_points {
      char_regions.push((prev_x, sp.x))
      prev_x = sp.x
    }
    char_regions.push((prev_x, w - 1))
  } else {
    char_regions.push((0, w - 1))
  }
  DropFallResult::{
    split_points,
    char_regions,
    success: split_points.length() > 0,
  }
}

///|
/// 检测粘连字符（基于垂直投影的局部最小值分析）
/// 返回粘连位置列表
pub fn detect_touching_chars(
  img : @types.Image,
  min_char_width? : Int = 8,
  max_char_width? : Int = 50,
) -> Array[Int] raise @types.LoadError {
  if img.channels != 1 {
    raise @types.LoadError::DecodeFailed("detect_touching_chars: 仅支持单通道二值图")
  }
  let w = img.width
  let h = img.height
  let data = img.data
  // 垂直投影
  let projection : Array[Int] = Array::make(w, 0)
  for y in 0..<h {
    for x in 0..<w {
      if data[y * w + x].to_int() > 128 {
        projection[x] += 1
      }
    }
  }
  // 找局部最小值（可能的分割点）
  let minima : Array[Int] = []
  for x in 2..<(w - 2) {
    if projection[x] < projection[x - 1] && projection[x] <= projection[x + 1] &&
       projection[x] < projection[x - 2] && projection[x] <= projection[x + 2] {
      minima.push(x)
    }
  }
  // 过滤：只保留在合理字符宽度范围内的分割点
  let touching_points : Array[Int] = []
  let mut last_split = 0
  for x in minima {
    let width = x - last_split
    if width >= min_char_width && width <= max_char_width * 2 {
      // 检查这个位置是否真的是粘连点（投影值较低但不为0）
      if projection[x] > 0 && projection[x] < h / 4 {
        touching_points.push(x)
        last_split = x
      }
    }
  }
  touching_points
}

///|
/// 基于连通域的字符分割
/// 返回字符区域列表
pub fn segment_by_connected_components(
  img : @types.Image,
  min_area? : Int = 5,
  max_area? : Int = 10000,
) -> Array[(Int, Int, Int, Int)] raise @types.LoadError {
  if img.channels != 1 {
    raise @types.LoadError::DecodeFailed("segment_by_connected_components: 仅支持单通道二值图")
  }
  let w = img.width
  let h = img.height
  let data = img.data
  // 简单连通域标记（两遍扫描的简化版）
  let labels : Array[Int] = Array::make(w * h, 0)
  let mut next_label = 1
  // 第一遍
  for y in 0..<h {
    for x in 0..<w {
      if data[y * w + x].to_int() > 128 {
        let mut label = 0
        // 检查左和上
        if x > 0 && labels[y * w + x - 1] > 0 {
          label = labels[y * w + x - 1]
        }
        if y > 0 && labels[(y - 1) * w + x] > 0 {
          if label == 0 {
            label = labels[(y - 1) * w + x]
          }
        }
        if label == 0 {
          label = next_label
          next_label += 1
        }
        labels[y * w + x] = label
      }
    }
  }
  // 第二遍：合并等价标签（简化版，只处理4邻域）
  // 计算每个标签的边界框
  let min_x : Array[Int] = Array::make(next_label, w)
  let max_x : Array[Int] = Array::make(next_label, 0)
  let min_y : Array[Int] = Array::make(next_label, h)
  let max_y : Array[Int] = Array::make(next_label, 0)
  let area : Array[Int] = Array::make(next_label, 0)
  for y in 0..<h {
    for x in 0..<w {
      let label = labels[y * w + x]
      if label > 0 {
        area[label] += 1
        if x < min_x[label] { min_x[label] = x }
        if x > max_x[label] { max_x[label] = x }
        if y < min_y[label] { min_y[label] = y }
        if y > max_y[label] { max_y[label] = y }
      }
    }
  }
  // 过滤并返回
  let regions : Array[(Int, Int, Int, Int)] = []
  for label in 1..<next_label {
    if area[label] >= min_area && area[label] <= max_area {
      let rw = max_x[label] - min_x[label] + 1
      let rh = max_y[label] - min_y[label] + 1
      if rw > 0 && rh > 0 {
        regions.push((min_x[label], min_y[label], rw, rh))
      }
    }
  }
  regions
}

///|
/// 分割后处理：合并过小的分割区域
pub fn merge_small_segments(
  segments : Array[(Int, Int, Int, Int)],
  min_width : Int,
  min_height : Int,
) -> Array[(Int, Int, Int, Int)] {
  if segments.length() == 0 {
    return segments
  }
  let merged : Array[(Int, Int, Int, Int)] = []
  let mut current = segments[0]
  for i in 1..<segments.length() {
    let next = segments[i]
    let (cx, cy, cw, ch) = current
    let (nx, ny, nw, nh) = next
    // 检查当前区域是否过小
    if cw < min_width || ch < min_height {
      // 合并到下一个区域
      let new_x = min(cx, nx)
      let new_y = min(cy, ny)
      let new_max_x = max(cx + cw, nx + nw)
      let new_max_y = max(cy + ch, ny + nh)
      current = (new_x, new_y, new_max_x - new_x, new_max_y - new_y)
    } else {
      merged.push(current)
      current = next
    }
  }
  // 处理最后一个区域
  let (cx, cy, cw, ch) = current
  if cw >= min_width && ch >= min_height {
    merged.push(current)
  } else if merged.length() > 0 {
    // 合并到前一个区域
    let (px, py, pw, ph) = merged[merged.length() - 1]
    let new_x = min(px, cx)
    let new_y = min(py, cy)
    let new_max_x = max(px + pw, cx + cw)
    let new_max_y = max(py + ph, cy + ch)
    merged[merged.length() - 1] = (new_x, new_y, new_max_x - new_x, new_max_y - new_y)
  }
  merged
}

///|
/// 分割后处理：过滤噪声区域
pub fn filter_noise_segments(
  segments : Array[(Int, Int, Int, Int)],
  img_width : Int,
  img_height : Int,
  min_area_ratio? : Double = 0.001,
  max_area_ratio? : Double = 0.5,
) -> Array[(Int, Int, Int, Int)] {
  let img_area = img_width * img_height
  let min_area = (img_area.to_double() * min_area_ratio).to_int()
  let max_area = (img_area.to_double() * max_area_ratio).to_int()
  let filtered : Array[(Int, Int, Int, Int)] = []
  for (x, y, w, h) in segments {
    let area = w * h
    if area >= min_area && area <= max_area {
      filtered.push((x, y, w, h))
    }
  }
  filtered
}

///|
/// 完整字符分割流水线
/// 1. 连通域初步分割
/// 2. 粘连字符检测
/// 3. 滴水算法分割粘连字符
/// 4. 后处理（合并过小、过滤噪声）
pub fn complete_char_segmentation(
  img : @types.Image,
  min_char_width? : Int = 5,
  max_char_width? : Int = 60,
) -> Array[(Int, Int, Int, Int)] raise @types.LoadError {
  if img.channels != 1 {
    raise @types.LoadError::DecodeFailed("complete_char_segmentation: 仅支持单通道二值图")
  }
  let w = img.width
  let h = img.height
  // 1. 连通域初步分割
  let segments = segment_by_connected_components(img, min_area=5, max_area=100000)
  // 2. 检测粘连字符（宽度过大的区域）
  let final_segments : Array[(Int, Int, Int, Int)] = []
  for (x, y, sw, sh) in segments {
    if sw > max_char_width && sh > min_char_width {
      // 可能是粘连字符，尝试滴水算法分割
      // 裁剪这个区域
      let sub_img = crop_sub_image(img, x, y, sw, sh)
      match sub_img {
        Some(si) => {
          let drop_result = drop_fall_segmentation(si)
          if drop_result.success && drop_result.char_regions.length() > 1 {
            // 分割成功，添加子区域
            for (rx1, rx2) in drop_result.char_regions {
              let rw = rx2 - rx1 + 1
              if rw >= min_char_width {
                final_segments.push((x + rx1, y, rw, sh))
              }
            }
          } else {
            // 分割失败，保留原区域
            final_segments.push((x, y, sw, sh))
          }
        }
        None => {
          final_segments.push((x, y, sw, sh))
        }
      }
    } else {
      final_segments.push((x, y, sw, sh))
    }
  }
  // 3. 后处理：合并过小的区域
  let merged = merge_small_segments(final_segments, min_char_width, min_char_width)
  // 4. 过滤噪声
  let filtered = filter_noise_segments(merged, w, h, min_area_ratio=0.0005, max_area_ratio=0.8)
  filtered
}

///|
/// 裁剪子图像
fn crop_sub_image(
  img : @types.Image,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> @types.Image? {
  let w = img.width
  let h = img.height
  let ch = img.channels
  if x < 0 || y < 0 || x + width > w || y + height > h {
    return None
  }
  let out : Array[Byte] = Array::make(width * height * ch, b'\x00')
  let data = img.data
  for yy in 0..<height {
    for xx in 0..<width {
      for c in 0..<ch {
        out[(yy * width + xx) * ch + c] = data[((y + yy) * w + (x + xx)) * ch + c]
      }
    }
  }
  Some(@types.Image::{ width, height, channels: ch, data: Bytes::from_array(out) })
}

///|
/// 辅助函数：最小值
fn min_seg(a : Int, b : Int) -> Int {
  if a < b { a } else { b }
}

///|
/// 辅助函数：最大值
fn max_seg(a : Int, b : Int) -> Int {
  if a > b { a } else { b }
}
