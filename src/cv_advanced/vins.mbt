// VINS — 视觉惯性导航系统
// VINS: Visual-Inertial Navigation System
//
// Phase 12 v329: 大规模扩展 CV 算法库 — VINS。

///|
/// IMU 测量数据。
/// IMU measurement data.
pub(all) struct ImuData {
  timestamp : Double
  ax : Double
  ay : Double
  az : Double
  gx : Double
  gy : Double
  gz : Double
} derive(Eq, @debug.Debug)

///|
pub extend ImuData with @debug.Debug::{to_repr}

///|
pub extend ImuData with Eq::{not_equal, equal}

///|
/// VINS 配置。
/// VINS configuration.
pub(all) struct VinsConfig {
  gravity : Double
  imu_freq : Double
  cam_freq : Double
  init_period : Double
  max_iterations : Int
} derive(Eq, @debug.Debug)

///|
pub extend VinsConfig with @debug.Debug::{to_repr}

///|
pub extend VinsConfig with Eq::{not_equal, equal}

///|
/// VINS 状态。
/// VINS state.
pub(all) struct VinsState {
  pose : SlamPose
  velocity : (Double, Double, Double)
  ba : (Double, Double, Double)
  bg : (Double, Double, Double)
  initialized : Bool
  imu_count : Int
  frame_count : Int
} derive(Eq, @debug.Debug)

///|
pub extend VinsState with @debug.Debug::{to_repr}

///|
pub extend VinsState with Eq::{not_equal, equal}

///|
/// VINS 统计信息。
/// VINS statistics.
pub(all) struct VinsStats {
  total_imu : Int
  total_frames : Int
  trajectory_length : Double
  avg_velocity : Double
  initialized : Bool
} derive(Eq, @debug.Debug)

///|
pub extend VinsStats with @debug.Debug::{to_repr}

///|
pub extend VinsStats with Eq::{not_equal, equal}

///|
/// 初始化 VINS。
/// Initialize VINS.
pub fn init_vins(config : VinsConfig) -> (VinsState, VinsConfig) {
  (
    {
      pose: identity_pose(),
      velocity: (0.0, 0.0, 0.0),
      ba: (0.0, 0.0, 0.0),
      bg: (0.0, 0.0, 0.0),
      initialized: false,
      imu_count: 0,
      frame_count: 0,
    },
    config,
  )
}

///|
/// 处理 IMU 测量（积分）。
/// Process IMU measurement (integration).
pub fn process_imu(
  state : VinsState,
  config : VinsConfig,
  imu : ImuData,
  dt : Double,
) -> VinsState {
  let (vx, vy, vz) = state.velocity
  let (bax, bay, baz) = state.ba
  let ax_corrected = imu.ax - bax
  let ay_corrected = imu.ay - bay
  let az_corrected = imu.az - baz - config.gravity
  let new_vx = vx + ax_corrected * dt
  let new_vy = vy + ay_corrected * dt
  let new_vz = vz + az_corrected * dt
  let new_tx = state.pose.tx + vx * dt + 0.5 * ax_corrected * dt * dt
  let new_ty = state.pose.ty + vy * dt + 0.5 * ay_corrected * dt * dt
  let new_tz = state.pose.tz + vz * dt + 0.5 * az_corrected * dt * dt
  let imu_count = state.imu_count + 1
  let initialized = if !state.initialized &&
    imu_count.to_double() / config.imu_freq >= config.init_period {
    true
  } else {
    state.initialized
  }
  {
    pose: { ..state.pose, tx: new_tx, ty: new_ty, tz: new_tz, },
    velocity: (new_vx, new_vy, new_vz),
    ba: state.ba,
    bg: state.bg,
    initialized,
    imu_count,
    frame_count: state.frame_count,
  }
}

///|
/// 处理图像帧（视觉更新）。
/// Process image frame (visual update).
pub fn process_image_vins(
  state : VinsState,
  pose : SlamPose,
  timestamp : Double,
) -> VinsState {
  let _ = timestamp
  {
    pose,
    velocity: state.velocity,
    ba: state.ba,
    bg: state.bg,
    initialized: state.initialized,
    imu_count: state.imu_count,
    frame_count: state.frame_count + 1,
  }
}

///|
/// VINS 优化（简化版）。
/// VINS optimization (simplified).
pub fn vins_optimize(state : VinsState, config : VinsConfig) -> VinsState {
  let _ = config
  let (bax, bay, baz) = state.ba
  {
    pose: state.pose,
    velocity: state.velocity,
    ba: (bax * 0.99, bay * 0.99, baz * 0.99),
    bg: state.bg,
    initialized: state.initialized,
    imu_count: state.imu_count,
    frame_count: state.frame_count,
  }
}

///|
/// 获取 VINS 状态。
/// Get VINS state.
pub fn get_vins_state(state : VinsState) -> SlamPose {
  state.pose
}

///|
/// 获取 VINS 统计信息。
/// Get VINS statistics.
pub fn vins_stats(state : VinsState, trajectory : Array[SlamPose]) -> VinsStats {
  let mut length = 0.0
  for i in 1..<trajectory.length() {
    let p0 = trajectory[i - 1]
    let p1 = trajectory[i]
    let dx = p1.tx - p0.tx
    let dy = p1.ty - p0.ty
    let dz = p1.tz - p0.tz
    length = length + (dx * dx + dy * dy + dz * dz).sqrt()
  }
  let (vx, vy, vz) = state.velocity
  let vel_mag = (vx * vx + vy * vy + vz * vz).sqrt()
  {
    total_imu: state.imu_count,
    total_frames: state.frame_count,
    trajectory_length: length,
    avg_velocity: vel_mag,
    initialized: state.initialized,
  }
}

///|
/// 重置 VINS。
/// Reset VINS.
pub fn reset_vins(config : VinsConfig) -> (VinsState, VinsConfig) {
  init_vins(config)
}

///|
/// VINS 初始化检查。
/// VINS initialization check.
pub fn vins_check_initialization(state : VinsState) -> Bool {
  state.initialized && state.imu_count > 0
}
