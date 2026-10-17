///|
test "TContext::make: 默认状态" {
  let ctx = @spatiotemporal.TContext::make(30.0F)
  assert_eq(ctx.current_time, 0.0F)
  assert_eq(ctx.fps, 30.0F)
  assert_eq(ctx.is_loop, false)
  assert_eq(ctx.paused, false)
  assert_eq(ctx.speed, 1.0F)
}

///|
test "TContext::make: 零 fps 抛异常" {
  try {
    ignore(@spatiotemporal.TContext::make(0.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "TContext::step: 推进时间" {
  let ctx = @spatiotemporal.TContext::make(10.0F)
  let ctx2 = ctx.step(100.0F)
  // dt = 1/10 * 1.0 = 0.1
  assert_true(ctx2.current_time > 0.09F && ctx2.current_time < 0.11F)
}

///|
test "TContext::step: 暂停不推进" {
  let ctx = @spatiotemporal.TContext::make(10.0F)
  let paused = ctx.set_paused(true)
  let stepped = paused.step(100.0F)
  assert_eq(stepped.current_time, 0.0F)
}

///|
test "TContext::step: 循环回绕" {
  let ctx = @spatiotemporal.TContext::make(2.0F)
  let looping = ctx.set_loop(true)
  // total_duration = 1.0, dt = 0.5, 推进 3 次 = 1.5 → 循环回 0.5
  let s1 = looping.step(1.0F)
  let s2 = s1.step(1.0F)
  let s3 = s2.step(1.0F)
  assert_true(s3.current_time < 1.0F)
}

///|
test "TContext::seek: 跳转" {
  let ctx = @spatiotemporal.TContext::make(30.0F)
  let seeked = ctx.seek(5.0F)
  assert_eq(seeked.current_time, 5.0F)
}

///|
test "TContext::seek: 负时间钳制为零" {
  let ctx = @spatiotemporal.TContext::make(30.0F)
  let seeked = ctx.seek(-1.0F)
  assert_eq(seeked.current_time, 0.0F)
}

///|
test "TContext::set_speed: 设置速度" {
  let ctx = @spatiotemporal.TContext::make(10.0F)
  let fast = ctx.set_speed(2.0F)
  assert_eq(fast.speed, 2.0F)
}

///|
test "TContext::set_speed: 负速度钳制为零" {
  let ctx = @spatiotemporal.TContext::make(10.0F)
  let bad = ctx.set_speed(-1.0F)
  assert_eq(bad.speed, 0.0F)
}

///|
test "TContext::set_paused: 暂停恢复" {
  let ctx = @spatiotemporal.TContext::make(10.0F)
  let paused = ctx.set_paused(true)
  assert_eq(paused.paused, true)
  let resumed = paused.set_paused(false)
  assert_eq(resumed.paused, false)
}
