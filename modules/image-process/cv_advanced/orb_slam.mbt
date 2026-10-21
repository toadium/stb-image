// ORB-SLAM 核心 — 完整 SLAM 系统
// ORB-SLAM core: complete SLAM system
//
// Phase 12 v328: 大规模扩展 CV 算法库 — ORB-SLAM 核心。

///|
/// ORB-SLAM 模式。
/// ORB-SLAM mode.
pub(all) enum OrbSlamMode {
  Monocular
  Stereo
  RGBD
} derive(Eq, @debug.Debug)

///|
pub extend OrbSlamMode with @debug.Debug::{to_repr}

///|
pub extend OrbSlamMode with Eq::{not_equal, equal}

///|
/// ORB-SLAM 配置。
/// ORB-SLAM configuration.
pub(all) struct OrbSlamConfig {
  mode : OrbSlamMode
  vocab_size : Int32
  n_features : Int32
  scale_levels : Int32
  init_threshold : Int32
} derive(Eq, @debug.Debug)

///|
pub extend OrbSlamConfig with @debug.Debug::{to_repr}

///|
pub extend OrbSlamConfig with Eq::{not_equal, equal}

///|
/// ORB-SLAM 系统状态。
/// ORB-SLAM system state.
pub(all) struct OrbSlamSystem {
  config : OrbSlamConfig
  frontend : SlamFrontend
  backend : SlamBackend
  trajectory : Array[SlamPose]
  initialized : Bool
  frame_count : Int32
} derive(Eq, @debug.Debug)

///|
pub extend OrbSlamSystem with @debug.Debug::{to_repr}

///|
pub extend OrbSlamSystem with Eq::{not_equal, equal}

///|
/// ORB-SLAM 统计信息。
/// ORB-SLAM statistics.
pub(all) struct OrbSlamStats {
  total_frames : Int32
  total_keyframes : Int32
  total_map_points : Int32
  trajectory_length : Double
  fps : Double
} derive(Eq, @debug.Debug)

///|
pub extend OrbSlamStats with @debug.Debug::{to_repr}

///|
pub extend OrbSlamStats with Eq::{not_equal, equal}

///|
/// 初始化 ORB-SLAM 系统。
/// Initialize ORB-SLAM system.
pub fn init_orb_slam(config : OrbSlamConfig) -> OrbSlamSystem {
  {
    config,
    frontend: init_slam_frontend(),
    backend: init_slam_backend(),
    trajectory: [],
    initialized: false,
    frame_count: 0,
  }
}

///|
/// 运行 ORB-SLAM（处理一帧）。
/// Run ORB-SLAM (process one frame).
pub fn run_orb_slam(
  system : OrbSlamSystem,
  pose : SlamPose,
  feature_count : Int32,
  timestamp : Double,
) -> OrbSlamSystem {
  let frame_count = system.frame_count + 1
  let mut initialized = system.initialized
  let mut frontend = system.frontend
  let mut backend = system.backend
  let mut trajectory = system.trajectory
  if !initialized {
    if feature_count >= system.config.init_threshold && frame_count >= 2 {
      initialized = true
      frontend = process_keyframe(
        frontend, pose, timestamp, feature_count, feature_count,
      )
      trajectory = trajectory + [pose]
    }
  } else {
    let params : SlamFrontendParams = {
      min_features: system.config.init_threshold / 2,
      max_features: system.config.n_features,
      keyframe_distance: 0.1,
      keyframe_angle: 0.1,
      lost_threshold: 5,
    }
    let prev_pose = if trajectory.length() > 0 {
      trajectory[trajectory.length() - 1]
    } else {
      pose
    }
    let (new_frontend, tracking) = track_keyframe(
      frontend,
      prev_pose,
      (pose.tx - prev_pose.tx, pose.ty - prev_pose.ty, pose.tz - prev_pose.tz),
      feature_count,
      params,
    )
    frontend = new_frontend
    if tracking {
      trajectory = trajectory + [pose]
      if keyframe_selection(frontend, pose, params) {
        frontend = process_keyframe(
          frontend,
          pose,
          timestamp,
          feature_count,
          feature_count / 2,
        )
        let mp_pos : Point3D = { x: pose.tx, y: pose.ty, z: pose.tz, }
        backend = add_map_point(backend, mp_pos, feature_count, 1.0)
      }
    }
  }
  {
    config: system.config,
    frontend,
    backend,
    trajectory,
    initialized,
    frame_count,
  }
}

///|
/// 获取 ORB-SLAM 轨迹。
/// Get ORB-SLAM trajectory.
pub fn get_orb_trajectory(system : OrbSlamSystem) -> Array[SlamPose] {
  system.trajectory
}

///|
/// 获取 ORB-SLAM 地图。
/// Get ORB-SLAM map.
pub fn get_orb_map(system : OrbSlamSystem) -> Array[SlamMapPoint] {
  system.backend.map_points
}

///|
/// 保存 ORB-SLAM 轨迹（返回字符串格式）。
/// Save ORB-SLAM trajectory (returns string format).
pub fn save_orb_trajectory(system : OrbSlamSystem) -> String {
  let mut result = "# ORB-SLAM trajectory\n# timestamp tx ty tz qw qx qy qz\n"
  for i in 0..<system.trajectory.length() {
    let p = system.trajectory[i]
    let ts = i.to_double() * 0.033
    result = result +
      ts.to_string() +
      " " +
      p.tx.to_string() +
      " " +
      p.ty.to_string() +
      " " +
      p.tz.to_string() +
      " " +
      p.qw.to_string() +
      " " +
      p.qx.to_string() +
      " " +
      p.qy.to_string() +
      " " +
      p.qz.to_string() +
      "\n"
  }
  result
}

///|
/// 获取 ORB-SLAM 统计信息。
/// Get ORB-SLAM statistics.
pub fn orb_slam_stats(system : OrbSlamSystem) -> OrbSlamStats {
  let mut length = 0.0
  for i in 1..<system.trajectory.length() {
    let p0 = system.trajectory[i - 1]
    let p1 = system.trajectory[i]
    let dx = p1.tx - p0.tx
    let dy = p1.ty - p0.ty
    let dz = p1.tz - p0.tz
    length = length + (dx * dx + dy * dy + dz * dz).sqrt()
  }
  let fps = if system.frame_count > 0 {
    system.frame_count.to_double() / 30.0
  } else {
    0.0
  }
  {
    total_frames: system.frame_count,
    total_keyframes: system.frontend.keyframes.length(),
    total_map_points: system.backend.map_points.length(),
    trajectory_length: length,
    fps,
  }
}

///|
/// 重置 ORB-SLAM 系统。
/// Reset ORB-SLAM system.
pub fn reset_orb_slam(system : OrbSlamSystem) -> OrbSlamSystem {
  {
    config: system.config,
    frontend: init_slam_frontend(),
    backend: init_slam_backend(),
    trajectory: [],
    initialized: false,
    frame_count: 0,
  }
}

///|
/// 关闭 ORB-SLAM 系统（执行最终优化）。
/// Shutdown ORB-SLAM system (perform final optimization).
pub fn shutdown_orb_slam(
  system : OrbSlamSystem,
  params : SlamBackendParams,
) -> OrbSlamSystem {
  let optimized_backend = optimize_map(system.backend, params)
  { ..system, backend: optimized_backend, }
}
