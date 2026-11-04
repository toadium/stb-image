// 运动估计 — 块匹配/亚像素/分数像素
// Motion estimation: block matching / subpixel / fractional
//
// Phase 17 v395: 视频处理大扩展 — 运动估计。

///|
/// 运动估计方法。
/// Motion estimation method.
pub(all) enum MotionEstimationMethod {
  FullSearch // 全搜索
  DiamondSearch // 菱形搜索
  HexSearch // 六边形搜索
  ThreeStep // 三步搜索
} derive(Eq, @debug.Debug)

///|
pub extend MotionEstimationMethod with @debug.Debug::{to_repr}

///|
pub extend MotionEstimationMethod with Eq::{not_equal, equal}

///|
/// 运动矢量。
/// Motion vector.
pub(all) struct MotionVector {
  dx : Int32
  dy : Int32
  sad : Double // 绝对误差和
} derive(Eq, @debug.Debug)

///|
pub extend MotionVector with @debug.Debug::{to_repr}

///|
pub extend MotionVector with Eq::{not_equal, equal}

///|
/// 亚像素运动矢量。
/// Subpixel motion vector.
pub(all) struct SubpixelMotionVector {
  dx : Double
  dy : Double
  sad : Double
} derive(Eq, @debug.Debug)

///|
pub extend SubpixelMotionVector with @debug.Debug::{to_repr}

///|
pub extend SubpixelMotionVector with Eq::{not_equal, equal}

///|
/// 搜索配置。
/// Search configuration.
pub(all) struct SearchConfig {
  me_method : MotionEstimationMethod
  block_size : Int32
  search_range : Int32
  subpixel_refinement : Bool // 是否启用亚像素精化
} derive(Eq, @debug.Debug)

///|
pub extend SearchConfig with @debug.Debug::{to_repr}

///|
pub extend SearchConfig with Eq::{not_equal, equal}

///|
/// 默认搜索配置。
/// Default search configuration.
pub fn default_search_config() -> SearchConfig {
  {
    me_method: DiamondSearch,
    block_size: 8,
    search_range: 16,
    subpixel_refinement: true,
  }
}

///|
/// 计算块的 SAD（绝对误差和）。
/// Compute SAD (Sum of Absolute Differences) for a block.
fn compute_sad(
  current : @types.Image,
  reference : @types.Image,
  bx : Int32,
  by : Int32,
  dx : Int32,
  dy : Int32,
  block_size : Int32,
) -> Double {
  let w = current.width
  let h = current.height
  let ch = current.channels
  let mut sad = 0.0
  for py in 0..<block_size {
    for px in 0..<block_size {
      let cx = bx + px
      let cy = by + py
      let rx = cx + dx
      let ry = cy + dy
      if cx >= w || cy >= h || rx < 0 || rx >= w || ry < 0 || ry >= h {
        sad = sad + 255.0
        continue
      }
      for c in 0..<ch {
        let ci = (cy * w + cx) * ch + c
        let ri = (ry * w + rx) * ch + c
        let diff = current.data[ci].to_int() - reference.data[ri].to_int()
        sad = sad + diff.to_double().abs()
      }
    }
  }
  sad
}

///|
/// 全搜索运动估计。
/// Full search motion estimation.
pub fn estimate_motion_full_search(
  current : @types.Image,
  reference : @types.Image,
  bx : Int32,
  by : Int32,
  block_size : Int32,
  search_range : Int32,
) -> MotionVector {
  let mut best : MotionVector = { dx: 0, dy: 0, sad: 999999999.0, }
  for dy in [-search_range, 0, search_range] {
    for dx in [-search_range, 0, search_range] {
      let sad = compute_sad(current, reference, bx, by, dx, dy, block_size)
      if sad < best.sad {
        best = ({ dx, dy, sad, } : MotionVector)
      }
    }
  }
  best
}

///|
/// 菱形搜索运动估计。
/// Diamond search motion estimation.
pub fn estimate_motion_diamond(
  current : @types.Image,
  reference : @types.Image,
  bx : Int32,
  by : Int32,
  block_size : Int32,
  search_range : Int32,
) -> MotionVector {
  // 大菱形搜索模式: (0,±1), (±1,0)
  let mut best_dx = 0
  let mut best_dy = 0
  let mut best_sad = compute_sad(current, reference, bx, by, 0, 0, block_size)
  let mut step = 1
  while step <= search_range {
    let mut new_dx = best_dx
    let mut new_dy = best_dy
    let mut new_sad = best_sad
    for (dx, dy) in [(0, step), (0, -step), (step, 0), (-step, 0)] {
      let cand_dx = best_dx + dx
      let cand_dy = best_dy + dy
      let sad = compute_sad(
        current, reference, bx, by, cand_dx, cand_dy, block_size,
      )
      if sad < new_sad {
        new_dx = cand_dx
        new_dy = cand_dy
        new_sad = sad
      }
    }
    if new_sad < best_sad {
      best_dx = new_dx
      best_dy = new_dy
      best_sad = new_sad
    } else {
      step = step * 2
    }
  }
  { dx: best_dx, dy: best_dy, sad: best_sad, }
}

///|
/// 六边形搜索运动估计。
/// Hexagonal search motion estimation.
pub fn estimate_motion_hex(
  current : @types.Image,
  reference : @types.Image,
  bx : Int32,
  by : Int32,
  block_size : Int32,
  search_range : Int32,
) -> MotionVector {
  // 六边形搜索: 6个点
  let mut best_dx = 0
  let mut best_dy = 0
  let mut best_sad = compute_sad(current, reference, bx, by, 0, 0, block_size)
  let step = (search_range / 2).clamp(min=1, max=search_range)
  for
    (dx, dy) in [
      (step, 0),
      (-step, 0),
      (step / 2, step),
      (-step / 2, step),
      (step / 2, -step),
      (-step / 2, -step),
    ] {
    let sad = compute_sad(current, reference, bx, by, dx, dy, block_size)
    if sad < best_sad {
      best_dx = dx
      best_dy = dy
      best_sad = sad
    }
  }
  { dx: best_dx, dy: best_dy, sad: best_sad, }
}

///|
/// 三步搜索运动估计。
/// Three-step search motion estimation.
pub fn estimate_motion_three_step(
  current : @types.Image,
  reference : @types.Image,
  bx : Int32,
  by : Int32,
  block_size : Int32,
  search_range : Int32,
) -> MotionVector {
  let mut best_dx = 0
  let mut best_dy = 0
  let mut best_sad = compute_sad(current, reference, bx, by, 0, 0, block_size)
  let mut step = search_range
  while step >= 1 {
    for
      (dx, dy) in [
        (0, 0),
        (step, 0),
        (-step, 0),
        (0, step),
        (0, -step),
        (step, step),
        (step, -step),
        (-step, step),
        (-step, -step),
      ] {
      let cand_dx = best_dx + dx
      let cand_dy = best_dy + dy
      let sad = compute_sad(
        current, reference, bx, by, cand_dx, cand_dy, block_size,
      )
      if sad < best_sad {
        best_dx = cand_dx
        best_dy = cand_dy
        best_sad = sad
      }
    }
    step = step / 2
  }
  { dx: best_dx, dy: best_dy, sad: best_sad, }
}

///|
/// 亚像素精化（半像素）。
/// Subpixel refinement (half-pixel).
pub fn refine_subpixel(
  current : @types.Image,
  reference : @types.Image,
  bx : Int32,
  by : Int32,
  mv : MotionVector,
  block_size : Int32,
) -> SubpixelMotionVector {
  // 在整像素最优解周围搜索半像素位置
  let mut best : SubpixelMotionVector = {
    dx: mv.dx.to_double(),
    dy: mv.dy.to_double(),
    sad: mv.sad,
  }
  for frac_dx in [-0.5, 0.0, 0.5] {
    for frac_dy in [-0.5, 0.0, 0.5] {
      let cand_dx = mv.dx.to_double() + frac_dx
      let cand_dy = mv.dy.to_double() + frac_dy
      // 简化：用插值 SAD
      let ix = cand_dx.to_int()
      let iy = cand_dy.to_int()
      let fx = cand_dx - ix.to_double()
      let fy = cand_dy - iy.to_double()
      let sad0 = compute_sad(current, reference, bx, by, ix, iy, block_size)
      let sad1 = compute_sad(current, reference, bx, by, ix + 1, iy, block_size)
      let sad2 = compute_sad(current, reference, bx, by, ix, iy + 1, block_size)
      let sad3 = compute_sad(
        current,
        reference,
        bx,
        by,
        ix + 1,
        iy + 1,
        block_size,
      )
      let interpolated_sad = sad0 * (1.0 - fx) * (1.0 - fy) +
        sad1 * fx * (1.0 - fy) +
        sad2 * (1.0 - fx) * fy +
        sad3 * fx * fy
      if interpolated_sad < best.sad {
        best = (
          { dx: cand_dx, dy: cand_dy, sad: interpolated_sad, } :
          SubpixelMotionVector)
      }
    }
  }
  best
}

///|
/// 计算运动场。
/// Compute motion field for entire image.
pub fn compute_motion_field(
  current : @types.Image,
  reference : @types.Image,
  config : SearchConfig,
) -> Array[MotionVector] {
  let field : Array[MotionVector] = []
  let block = config.block_size
  let mut by = 0
  while by < current.height {
    let mut bx = 0
    while bx < current.width {
      let mv = match config.me_method {
        FullSearch =>
          estimate_motion_full_search(
            current,
            reference,
            bx,
            by,
            block,
            config.search_range,
          )
        DiamondSearch =>
          estimate_motion_diamond(
            current,
            reference,
            bx,
            by,
            block,
            config.search_range,
          )
        HexSearch =>
          estimate_motion_hex(
            current,
            reference,
            bx,
            by,
            block,
            config.search_range,
          )
        ThreeStep =>
          estimate_motion_three_step(
            current,
            reference,
            bx,
            by,
            block,
            config.search_range,
          )
      }
      field.push(mv)
      bx = bx + block
    }
    by = by + block
  }
  field
}

///|
/// 运动补偿。
/// Motion compensation.
pub fn motion_compensation(
  reference : @types.Image,
  motion_field : Array[MotionVector],
  block_size : Int32,
) -> @types.Image {
  let w = reference.width
  let h = reference.height
  let ch = reference.channels
  let data : Array[Byte] = []
  let mut mv_idx = 0
  let mut by = 0
  while by < h {
    let mut bx = 0
    while bx < w {
      let mv = if mv_idx < motion_field.length() {
        motion_field[mv_idx]
      } else {
        { dx: 0, dy: 0, sad: 0.0, }
      }
      mv_idx = mv_idx + 1
      for py in 0..<block_size {
        for px in 0..<block_size {
          let cx = bx + px
          let cy = by + py
          if cx >= w || cy >= h {
            for _ in 0..<ch {
              data.push((0 : Byte))
            }
            continue
          }
          let rx = (cx + mv.dx).clamp(min=0, max=w - 1)
          let ry = (cy + mv.dy).clamp(min=0, max=h - 1)
          for c in 0..<ch {
            data.push(reference.data[(ry * w + rx) * ch + c])
          }
        }
      }
      bx = bx + block_size
    }
    by = by + block_size
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 估计运动并补偿。
/// Estimate motion and compensate.
pub fn motion_estimate_and_compensate(
  current : @types.Image,
  reference : @types.Image,
  config : SearchConfig,
) -> @types.Image {
  let field = compute_motion_field(current, reference, config)
  motion_compensation(reference, field, config.block_size)
}

///|
/// 计算运动场平均 SAD。
/// Compute average SAD of motion field.
pub fn average_motion_sad(motion_field : Array[MotionVector]) -> Double {
  if motion_field.length() == 0 {
    return 0.0
  }
  let mut total = 0.0
  for mv in motion_field {
    total = total + mv.sad
  }
  total / motion_field.length().to_double()
}

///|
/// 计算运动矢量零率。
/// Compute fraction of zero motion vectors.
pub fn zero_motion_ratio(motion_field : Array[MotionVector]) -> Double {
  if motion_field.length() == 0 {
    return 0.0
  }
  let mut zero_count = 0
  for mv in motion_field {
    if mv.dx == 0 && mv.dy == 0 {
      zero_count = zero_count + 1
    }
  }
  zero_count.to_double() / motion_field.length().to_double()
}
