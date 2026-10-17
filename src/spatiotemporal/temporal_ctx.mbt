// 时态控制器：管理时变图像的播放状态。
// Temporal context: manages playback state of time-varying images.

///|
/// 时态控制器：当前时间、帧率、循环、暂停、播放速度。
/// Temporal context: current time, fps, is_loop, paused, playback speed.
pub(all) struct TContext {
  current_time : Float
  fps : Float
  is_loop : Bool
  paused : Bool
  speed : Float
} derive(Eq, @debug.Debug)

///|
pub extend TContext with @debug.Debug::{to_repr}

///|
pub extend TContext with Eq::{not_equal, equal}

///|
/// 创建时态控制器，默认播放速度 1.0，非暂停，非循环。
/// Create a temporal context with default speed=1.0, not paused, not looping.
pub fn TContext::make(fps : Float) -> TContext raise @types.LoadError {
  if fps <= 0.0F {
    raise @types.LoadError::DecodeFailed("TContext::make: fps 必须大于0")
  }
  { current_time: 0.0F, fps, is_loop: false, paused: false, speed: 1.0F, }
}

///|
/// 推进时间：按 fps 和 speed 推进 current_time，支持循环。
/// Advance time by one frame step, considering speed and is_loop.
pub fn TContext::step(self : TContext, total_duration : Float) -> TContext {
  if self.paused {
    return self
  }
  let dt = 1.0F / self.fps * self.speed
  let mut new_time = self.current_time + dt
  if self.is_loop && total_duration > 0.0F {
    while new_time >= total_duration {
      new_time = new_time - total_duration
    }
  }
  { ..self, current_time: new_time, }
}

///|
/// 跳转到指定时间。
/// Seek to a specific time.
pub fn TContext::seek(self : TContext, time : Float) -> TContext {
  { ..self, current_time: if time < 0.0F { 0.0F } else { time }, }
}

///|
/// 暂停/恢复。
/// Pause or resume.
pub fn TContext::set_paused(self : TContext, paused : Bool) -> TContext {
  { ..self, paused, }
}

///|
/// 设置播放速度。
/// Set playback speed.
pub fn TContext::set_speed(self : TContext, speed : Float) -> TContext {
  { ..self, speed: if speed < 0.0F { 0.0F } else { speed }, }
}

///|
/// 设置循环。
/// Set is_loop mode.
pub fn TContext::set_loop(self : TContext, is_loop : Bool) -> TContext {
  { ..self, is_loop, }
}
