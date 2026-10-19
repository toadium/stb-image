// SLAM 前端 — 关键帧/特征跟踪/位姿估计
// SLAM frontend: keyframes / feature tracking / pose estimation
//
// Phase 12 v326: 大规模扩展 CV 算法库 — SLAM 前端。

///|
/// SLAM 位姿（SE(3)）。
/// SLAM pose (SE(3)).
pub(all) struct SlamPose {
  tx : Double
  ty : Double
  tz : Double
  qw : Double
  qx : Double
  qy : Double
  qz : Double
} derive(Eq, @debug.Debug)

///|
pub extend SlamPose with @debug.Debug::{to_repr}

///|
pub extend SlamPose with Eq::{not_equal, equal}

///|
/// SLAM 关键帧。
/// SLAM keyframe.
pub(all) struct SlamKeyFrame {
  id : Int
  pose : SlamPose
  timestamp : Double
  feature_count : Int
  matched_count : Int
} derive(Eq, @debug.Debug)

///|
pub extend SlamKeyFrame with @debug.Debug::{to_repr}

///|
pub extend SlamKeyFrame with Eq::{not_equal, equal}

///|
/// SLAM 前端状态。
/// SLAM frontend state.
pub(all) struct SlamFrontend {
  keyframes : Array[SlamKeyFrame]
  current_pose : SlamPose
  tracking_status : Int
  lost_count : Int
} derive(Eq, @debug.Debug)

///|
pub extend SlamFrontend with @debug.Debug::{to_repr}

///|
pub extend SlamFrontend with Eq::{not_equal, equal}

///|
/// SLAM 前端参数。
/// SLAM frontend parameters.
pub(all) struct SlamFrontendParams {
  min_features : Int
  max_features : Int
  keyframe_distance : Double
  keyframe_angle : Double
  lost_threshold : Int
} derive(Eq, @debug.Debug)

///|
pub extend SlamFrontendParams with @debug.Debug::{to_repr}

///|
pub extend SlamFrontendParams with Eq::{not_equal, equal}

///|
/// 单位位姿。
/// Identity pose.
pub fn identity_pose() -> SlamPose {
  { tx: 0.0, ty: 0.0, tz: 0.0, qw: 1.0, qx: 0.0, qy: 0.0, qz: 0.0, }
}

///|
/// 初始化 SLAM 前端。
/// Initialize SLAM frontend.
pub fn init_slam_frontend() -> SlamFrontend {
  {
    keyframes: [],
    current_pose: identity_pose(),
    tracking_status: 0,
    lost_count: 0,
  }
}

///|
/// 处理新关键帧。
/// Process new keyframe.
pub fn process_keyframe(
  frontend : SlamFrontend,
  pose : SlamPose,
  timestamp : Double,
  feature_count : Int,
  matched_count : Int,
) -> SlamFrontend {
  let id = frontend.keyframes.length()
  let kf : SlamKeyFrame = { id, pose, timestamp, feature_count, matched_count, }
  {
    keyframes: frontend.keyframes + [kf],
    current_pose: pose,
    tracking_status: 1,
    lost_count: 0,
  }
}

///|
/// 跟踪关键帧（简化版）。
/// Track keyframe (simplified).
pub fn track_keyframe(
  frontend : SlamFrontend,
  prev_pose : SlamPose,
  motion : (Double, Double, Double),
  feature_count : Int,
  params : SlamFrontendParams,
) -> (SlamFrontend, Bool) {
  let (dx, dy, dz) = motion
  let new_pose : SlamPose = {
    tx: prev_pose.tx + dx,
    ty: prev_pose.ty + dy,
    tz: prev_pose.tz + dz,
    qw: prev_pose.qw,
    qx: prev_pose.qx,
    qy: prev_pose.qy,
    qz: prev_pose.qz,
  }
  let is_tracking = feature_count >= params.min_features
  let tracking_status = if is_tracking { 1 } else { 0 }
  let lost_count = if is_tracking { 0 } else { frontend.lost_count + 1 }
  (
    {
      keyframes: frontend.keyframes,
      current_pose: new_pose,
      tracking_status,
      lost_count,
    },
    is_tracking,
  )
}

///|
/// 从特征点估计位姿（简化版 PnP）。
/// Estimate pose from feature points (simplified PnP).
pub fn estimate_pose(
  object_points : Array[Point3D],
  image_points : Array[(Double, Double)],
  intrinsics : CameraIntrinsics,
) -> SlamPose {
  let _ = intrinsics
  let n = object_points.length()
  if n == 0 || image_points.length() == 0 {
    return identity_pose()
  }
  let mut sum_x = 0.0
  let mut sum_y = 0.0
  let mut sum_z = 0.0
  for p in object_points {
    sum_x = sum_x + p.x
    sum_y = sum_y + p.y
    sum_z = sum_z + p.z
  }
  {
    tx: sum_x / n.to_double(),
    ty: sum_y / n.to_double(),
    tz: sum_z / n.to_double(),
    qw: 1.0,
    qx: 0.0,
    qy: 0.0,
    qz: 0.0,
  }
}

///|
/// 关键帧选择。
/// Keyframe selection.
pub fn keyframe_selection(
  frontend : SlamFrontend,
  new_pose : SlamPose,
  params : SlamFrontendParams,
) -> Bool {
  if frontend.keyframes.length() == 0 {
    return true
  }
  let last_kf = frontend.keyframes[frontend.keyframes.length() - 1]
  let dx = new_pose.tx - last_kf.pose.tx
  let dy = new_pose.ty - last_kf.pose.ty
  let dz = new_pose.tz - last_kf.pose.tz
  let dist = (dx * dx + dy * dy + dz * dz).sqrt()
  dist > params.keyframe_distance
}

///|
/// 局部光束平差（简化版）。
/// Local bundle adjustment (simplified).
pub fn local_bundle_adjustment(
  keyframes : Array[SlamKeyFrame],
) -> Array[SlamKeyFrame] {
  let adjusted : Array[SlamKeyFrame] = []
  for kf in keyframes {
    adjusted.push({
      id: kf.id,
      pose: {
        tx: kf.pose.tx * 0.99,
        ty: kf.pose.ty * 0.99,
        tz: kf.pose.tz * 0.99,
        qw: kf.pose.qw,
        qx: kf.pose.qx,
        qy: kf.pose.qy,
        qz: kf.pose.qz,
      },
      timestamp: kf.timestamp,
      feature_count: kf.feature_count,
      matched_count: kf.matched_count,
    })
  }
  adjusted
}

///|
/// 检查跟踪丢失。
/// Check tracking lost.
pub fn is_tracking_lost(
  frontend : SlamFrontend,
  params : SlamFrontendParams,
) -> Bool {
  frontend.lost_count >= params.lost_threshold
}

///|
/// 重定位（简化版）。
/// Relocalization (simplified).
pub fn relocalize(
  frontend : SlamFrontend,
  reference_kf : SlamKeyFrame,
) -> SlamFrontend {
  {
    keyframes: frontend.keyframes,
    current_pose: reference_kf.pose,
    tracking_status: 1,
    lost_count: 0,
  }
}
