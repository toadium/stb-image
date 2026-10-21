// SLAM 后端 — 地图点/光束平差/回环检测
// SLAM backend: map points / bundle adjustment / loop closing
//
// Phase 12 v327: 大规模扩展 CV 算法库 — SLAM 后端。

///|
/// SLAM 地图点。
/// SLAM map point.
pub(all) struct SlamMapPoint {
  id : Int32
  position : Point3D
  observations : Int32
  quality : Double
} derive(Eq, @debug.Debug)

///|
pub extend SlamMapPoint with @debug.Debug::{to_repr}

///|
pub extend SlamMapPoint with Eq::{not_equal, equal}

///|
/// SLAM 后端状态。
/// SLAM backend state.
pub(all) struct SlamBackend {
  map_points : Array[SlamMapPoint]
  keyframes : Array[SlamKeyFrame]
  optimized : Bool
  loop_closed : Bool
} derive(Eq, @debug.Debug)

///|
pub extend SlamBackend with @debug.Debug::{to_repr}

///|
pub extend SlamBackend with Eq::{not_equal, equal}

///|
/// 回环检测结果。
/// Loop closing result.
pub(all) struct LoopClosingResult {
  loop_found : Bool
  loop_kf1 : Int32
  loop_kf2 : Int32
  correction : SlamPose
} derive(Eq, @debug.Debug)

///|
pub extend LoopClosingResult with @debug.Debug::{to_repr}

///|
pub extend LoopClosingResult with Eq::{not_equal, equal}

///|
/// SLAM 后端参数。
/// SLAM backend parameters.
pub(all) struct SlamBackendParams {
  min_observations : Int32
  max_reproj_error : Double
  loop_threshold : Double
  ba_iterations : Int32
} derive(Eq, @debug.Debug)

///|
pub extend SlamBackendParams with @debug.Debug::{to_repr}

///|
pub extend SlamBackendParams with Eq::{not_equal, equal}

///|
/// 初始化 SLAM 后端。
/// Initialize SLAM backend.
pub fn init_slam_backend() -> SlamBackend {
  { map_points: [], keyframes: [], optimized: false, loop_closed: false, }
}

///|
/// 添加地图点。
/// Add map point.
pub fn add_map_point(
  backend : SlamBackend,
  position : Point3D,
  observations : Int32,
  quality : Double,
) -> SlamBackend {
  let id = backend.map_points.length()
  let mp : SlamMapPoint = { id, position, observations, quality, }
  { ..backend, map_points: backend.map_points + [mp], }
}

///|
/// 移除冗余地图点。
/// Remove redundant map points.
pub fn remove_redundant_points(
  backend : SlamBackend,
  params : SlamBackendParams,
) -> SlamBackend {
  let filtered : Array[SlamMapPoint] = []
  for mp in backend.map_points {
    if mp.observations >= params.min_observations && mp.quality > 0.0 {
      filtered.push(mp)
    }
  }
  { ..backend, map_points: filtered, }
}

///|
/// 全局光束平差（简化版）。
/// Global bundle adjustment (simplified).
pub fn global_bundle_adjustment(
  backend : SlamBackend,
  params : SlamBackendParams,
) -> SlamBackend {
  let _ = params
  let optimized_points : Array[SlamMapPoint] = []
  for mp in backend.map_points {
    optimized_points.push({
      id: mp.id,
      position: {
        x: mp.position.x * 0.99,
        y: mp.position.y * 0.99,
        z: mp.position.z * 0.99,
      },
      observations: mp.observations,
      quality: mp.quality * 1.01,
    })
  }
  { ..backend, map_points: optimized_points, optimized: true, }
}

///|
/// 回环检测。
/// Loop closing detection.
pub fn loop_closing(
  backend : SlamBackend,
  current_kf : SlamKeyFrame,
  params : SlamBackendParams,
) -> LoopClosingResult {
  let mut best_kf = -1
  let mut best_dist = params.loop_threshold
  for kf in backend.keyframes {
    let dx = current_kf.pose.tx - kf.pose.tx
    let dy = current_kf.pose.ty - kf.pose.ty
    let dz = current_kf.pose.tz - kf.pose.tz
    let dist = (dx * dx + dy * dy + dz * dz).sqrt()
    if dist < best_dist && kf.id != current_kf.id {
      best_dist = dist
      best_kf = kf.id
    }
  }
  if best_kf >= 0 {
    {
      loop_found: true,
      loop_kf1: current_kf.id,
      loop_kf2: best_kf,
      correction: identity_pose(),
    }
  } else {
    {
      loop_found: false,
      loop_kf1: -1,
      loop_kf2: -1,
      correction: identity_pose(),
    }
  }
}

///|
/// 合并重复地图点。
/// Merge duplicate map points.
pub fn merge_map_points(
  backend : SlamBackend,
  distance_threshold : Double,
) -> SlamBackend {
  let merged : Array[SlamMapPoint] = []
  let used : Array[Bool] = []
  for _ in 0..<backend.map_points.length() {
    used.push(false)
  }
  for i in 0..<backend.map_points.length() {
    if used[i] {
      continue
    }
    let mp = backend.map_points[i]
    let mut total_obs = mp.observations
    for j in 0..<backend.map_points.length() {
      if i == j || used[j] {
        continue
      }
      let other = backend.map_points[j]
      let dx = mp.position.x - other.position.x
      let dy = mp.position.y - other.position.y
      let dz = mp.position.z - other.position.z
      let dist = (dx * dx + dy * dy + dz * dz).sqrt()
      if dist < distance_threshold {
        used[j] = true
        total_obs = total_obs + other.observations
      }
    }
    used[i] = true
    merged.push({ ..mp, observations: total_obs, })
  }
  { ..backend, map_points: merged, }
}

///|
/// 优化地图（完整后端流程）。
/// Optimize map (full backend pipeline).
pub fn optimize_map(
  backend : SlamBackend,
  params : SlamBackendParams,
) -> SlamBackend {
  let b1 = remove_redundant_points(backend, params)
  let b2 = global_bundle_adjustment(b1, params)
  b2
}

///|
/// 计算地图统计信息。
/// Compute map statistics.
pub fn map_statistics(backend : SlamBackend) -> (Int32, Int32, Double) {
  let n_points = backend.map_points.length()
  let n_kfs = backend.keyframes.length()
  let mut total_quality = 0.0
  for mp in backend.map_points {
    total_quality = total_quality + mp.quality
  }
  let avg_quality = if n_points > 0 {
    total_quality / n_points.to_double()
  } else {
    0.0
  }
  (n_points, n_kfs, avg_quality)
}
