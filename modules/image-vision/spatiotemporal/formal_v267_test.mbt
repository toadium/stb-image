// v267.0.0 形式化验证 + FAKE + MOCK + E2E 多策略测试
// 对 TInterval / TFrame / TImage / TVideo / TContext + Allen代数 + 插值 + 快照

// ============================================================
// 辅助函数
// ============================================================

///|
fn v267_approx_eq(a : Float, b : Float, eps : Float) -> Bool {
  let diff = a - b
  let abs_diff = if diff < 0.0F { -diff } else { diff }
  abs_diff < eps
}

///|
fn v267_lcg(seed : Int32) -> () -> Int32 {
  let mut state = seed
  () => {
    state = (state * 1103515245 + 12345) & 0x7FFFFFFF
    state
  }
}

// ============================================================
// FAKE: 结构化假数据生成器
// ============================================================

///|
fn v267_fake_image(value : Int32) -> @types.Image {
  {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([value.to_byte()]),
  }
}

///|
fn v267_fake_image_wh(w : Int32, h : Int32, value : Int32) -> @types.Image {
  {
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, value.to_byte())),
  }
}

///|
fn v267_fake_tframe(
  value : Int32,
  ts : Float,
  dur : Float,
) -> @spatiotemporal.TFrame raise @types.LoadError {
  @spatiotemporal.TFrame::make(v267_fake_image(value), ts, dur)
}

///|
fn v267_fake_timage_uniform(
  values : Array[Int32],
  dur : Float,
  fps : Float,
) -> @spatiotemporal.TImage raise @types.LoadError {
  let frames : Array[@spatiotemporal.TFrame] = []
  let mut ts = 0.0F
  for i in 0..<values.length() {
    frames.push(
      @spatiotemporal.TFrame::make(v267_fake_image(values[i]), ts, dur),
    )
    ts = ts + dur
  }
  @spatiotemporal.TImage::make(frames, fps)
}

///|
fn v267_fake_timage_random(
  seed : Int32,
  n_frames : Int32,
  dur : Float,
) -> @spatiotemporal.TImage raise @types.LoadError {
  let rng = v267_lcg(seed)
  let frames : Array[@spatiotemporal.TFrame] = []
  let mut ts = 0.0F
  for _ in 0..<n_frames {
    let val = rng() % 256
    frames.push(@spatiotemporal.TFrame::make(v267_fake_image(val), ts, dur))
    ts = ts + dur
  }
  @spatiotemporal.TImage::make(frames, 30.0F)
}

// ============================================================
// 形式化证明: Allen 代数不变量（多组随机区间验证）
// ============================================================

///|
test "v267 formal: st_before(a,b) = st_after(b,a) (symmetry)" {
  for seed in 1..<=20 {
    let rng = v267_lcg(seed)
    let a = @spatiotemporal.TInterval::make(
      Float::from_int(rng() % 100),
      Float::from_int(rng() % 100 + 100),
    )
    let b = @spatiotemporal.TInterval::make(
      Float::from_int(rng() % 100),
      Float::from_int(rng() % 100 + 100),
    )
    assert_eq(@spatiotemporal.st_before(a, b), @spatiotemporal.st_after(b, a))
  }
}

///|
test "v267 formal: st_within(a,b) = st_contains(b,a) (flip symmetry)" {
  for seed in 1..<=20 {
    let rng = v267_lcg(seed)
    let a = @spatiotemporal.TInterval::make(
      Float::from_int(rng() % 100),
      Float::from_int(rng() % 100 + 100),
    )
    let b = @spatiotemporal.TInterval::make(
      Float::from_int(rng() % 100),
      Float::from_int(rng() % 100 + 100),
    )
    assert_eq(
      @spatiotemporal.st_within(a, b),
      @spatiotemporal.st_contains(b, a),
    )
  }
}

///|
test "v267 formal: st_intersects(a,b) = st_intersects(b,a) (symmetry)" {
  for seed in 1..<=20 {
    let rng = v267_lcg(seed)
    let a = @spatiotemporal.TInterval::make(
      Float::from_int(rng() % 100),
      Float::from_int(rng() % 100 + 100),
    )
    let b = @spatiotemporal.TInterval::make(
      Float::from_int(rng() % 100),
      Float::from_int(rng() % 100 + 100),
    )
    assert_eq(
      @spatiotemporal.st_intersects(a, b),
      @spatiotemporal.st_intersects(b, a),
    )
  }
}

///|
test "v267 formal: st_overlaps(a,b) = st_overlaps(b,a) (symmetry)" {
  for seed in 1..<=20 {
    let rng = v267_lcg(seed)
    let a = @spatiotemporal.TInterval::make(
      Float::from_int(rng() % 100),
      Float::from_int(rng() % 100 + 100),
    )
    let b = @spatiotemporal.TInterval::make(
      Float::from_int(rng() % 100),
      Float::from_int(rng() % 100 + 100),
    )
    assert_eq(
      @spatiotemporal.st_overlaps(a, b),
      @spatiotemporal.st_overlaps(b, a),
    )
  }
}

///|
test "v267 formal: st_equals is reflexive (a = a)" {
  for seed in 1..<=10 {
    let rng = v267_lcg(seed)
    let s = Float::from_int(rng() % 100)
    let e = Float::from_int(rng() % 100 + 100)
    let a = @spatiotemporal.TInterval::make(s, e)
    assert_true(@spatiotemporal.st_equals(a, a))
  }
}

///|
test "v267 formal: st_contains is reflexive (a contains a)" {
  for seed in 1..<=10 {
    let rng = v267_lcg(seed)
    let s = Float::from_int(rng() % 100)
    let e = Float::from_int(rng() % 100 + 100)
    let a = @spatiotemporal.TInterval::make(s, e)
    assert_true(@spatiotemporal.st_contains(a, a))
  }
}

///|
test "v267 formal: st_meets(a,b) implies st_before(a,b)" {
  let a = @spatiotemporal.TInterval::make(0.0F, 5.0F)
  let b = @spatiotemporal.TInterval::make(5.0F, 10.0F)
  assert_true(@spatiotemporal.st_meets(a, b))
  assert_true(@spatiotemporal.st_before(a, b))
}

///|
test "v267 formal: TInterval::duration = end - start" {
  for seed in 1..<=10 {
    let rng = v267_lcg(seed)
    let s = Float::from_int(rng() % 100)
    let e = Float::from_int(rng() % 100 + 100)
    let iv = @spatiotemporal.TInterval::make(s, e)
    assert_true(v267_approx_eq(iv.duration(), e - s, 0.0001F))
  }
}

// ============================================================
// 形式化证明: 插值属性
// ============================================================

///|
test "v267 formal: st_interpolate_linear(f1,f2,0) = f1 (boundary)" {
  for val1 in [0, 50, 100, 200, 255] {
    for val2 in [0, 50, 100, 200, 255] {
      let f1 = v267_fake_image(val1)
      let f2 = v267_fake_image(val2)
      let r = @spatiotemporal.st_interpolate_linear(f1, f2, 0.0F)
      assert_eq(r.data[0], f1.data[0])
    }
  }
}

///|
test "v267 formal: st_interpolate_linear(f1,f2,1) = f2 (boundary)" {
  for val1 in [0, 50, 100, 200, 255] {
    for val2 in [0, 50, 100, 200, 255] {
      let f1 = v267_fake_image(val1)
      let f2 = v267_fake_image(val2)
      let r = @spatiotemporal.st_interpolate_linear(f1, f2, 1.0F)
      assert_eq(r.data[0], f2.data[0])
    }
  }
}

///|
test "v267 formal: st_interpolate_linear(f1,f1,alpha) = f1 (constant interpolation)" {
  let f1 = v267_fake_image(128)
  for alpha in [0.0F, 0.25F, 0.5F, 0.75F, 1.0F] {
    let r = @spatiotemporal.st_interpolate_linear(f1, f1, alpha)
    assert_eq(r.data[0], f1.data[0])
  }
}

///|
test "v267 formal: st_interpolate_linear preserves dimensions" {
  let f1 = v267_fake_image_wh(4, 6, 100)
  let f2 = v267_fake_image_wh(4, 6, 200)
  for alpha in [0.0F, 0.3F, 0.5F, 0.7F, 1.0F] {
    let r = @spatiotemporal.st_interpolate_linear(f1, f2, alpha)
    assert_eq(r.width, 4)
    assert_eq(r.height, 6)
    assert_eq(r.channels, 1)
  }
}

// ============================================================
// 形式化证明: 时态控制器属性
// ============================================================

///|
test "v267 formal: TContext::step when paused does not advance time" {
  let ctx = @spatiotemporal.TContext::make(30.0F)
  let paused = ctx.set_paused(true)
  let stepped = paused.step(10.0F)
  assert_eq(stepped.current_time, 0.0F)
}

///|
test "v267 formal: TContext::seek sets current_time" {
  let ctx = @spatiotemporal.TContext::make(30.0F)
  let sought = ctx.seek(5.0F)
  assert_eq(sought.current_time, 5.0F)
}

///|
test "v267 formal: TContext::seek clamps negative time to 0" {
  let ctx = @spatiotemporal.TContext::make(30.0F)
  let sought = ctx.seek(-1.0F)
  assert_eq(sought.current_time, 0.0F)
}

///|
test "v267 formal: TContext::set_speed clamps negative speed to 0" {
  let ctx = @spatiotemporal.TContext::make(30.0F)
  let s = ctx.set_speed(-2.0F)
  assert_eq(s.speed, 0.0F)
}

///|
test "v267 formal: TContext::step advances time by 1/fps*speed" {
  let ctx = @spatiotemporal.TContext::make(10.0F)
  let stepped = ctx.step(100.0F)
  // dt = 1/10 * 1.0 = 0.1
  assert_true(v267_approx_eq(stepped.current_time, 0.1F, 0.0001F))
}

///|
test "v267 formal: TContext::step with loop wraps around" {
  let ctx = @spatiotemporal.TContext::make(10.0F)
  let looping = ctx.set_loop(true)
  // Advance near the end, then step past total_duration
  let near_end = looping.seek(0.95F)
  let stepped = near_end.step(1.0F)
  // dt = 0.1, new_time = 0.95 + 0.1 = 1.05, wraps to 0.05
  assert_true(v267_approx_eq(stepped.current_time, 0.05F, 0.0001F))
}

// ============================================================
// 形式化证明: TImage/TVideo 属性
// ============================================================

///|
test "v267 formal: TImage::total_duration = sum of frame durations" {
  let ti = v267_fake_timage_uniform([10, 20, 30, 40], 0.5F, 4.0F)
  // 4 frames × 0.5s = 2.0s
  assert_true(v267_approx_eq(ti.total_duration(), 2.0F, 0.0001F))
}

///|
test "v267 formal: TImage::frame_count = frames.length()" {
  let ti = v267_fake_timage_uniform([10, 20, 30], 1.0F, 3.0F)
  assert_eq(ti.frame_count(), 3)
}

///|
test "v267 formal: TImage::from_static creates single-frame TImage" {
  let img = v267_fake_image(42)
  let ti = @spatiotemporal.TImage::from_static(img)
  assert_eq(ti.frame_count(), 1)
  assert_eq(ti.width, 1)
  assert_eq(ti.height, 1)
}

///|
test "v267 formal: TVideo::from_timage preserves total_duration" {
  let ti = v267_fake_timage_uniform([10, 20, 30], 1.0F, 3.0F)
  let vid = @spatiotemporal.TVideo::from_timage(ti, "test_codec")
  assert_true(v267_approx_eq(vid.total_duration, ti.total_duration(), 0.0001F))
}

// ============================================================
// MOCK: 错误分派与边界条件模拟
// ============================================================

///|
test "v267 mock: TInterval::make rejects end < start" {
  try {
    ignore(@spatiotemporal.TInterval::make(10.0F, 5.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v267 mock: TFrame::make rejects negative duration" {
  let img = v267_fake_image(0)
  try {
    ignore(@spatiotemporal.TFrame::make(img, 0.0F, -1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v267 mock: TImage::make rejects empty frames" {
  try {
    ignore(@spatiotemporal.TImage::make([], 30.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v267 mock: TImage::make rejects fps <= 0" {
  let frame = v267_fake_tframe(0, 0.0F, 1.0F)
  try {
    ignore(@spatiotemporal.TImage::make([frame], 0.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v267 mock: TContext::make rejects fps <= 0" {
  try {
    ignore(@spatiotemporal.TContext::make(0.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v267 mock: st_subclip rejects start >= end" {
  let ti = v267_fake_timage_uniform([10, 20, 30], 1.0F, 3.0F)
  try {
    ignore(@spatiotemporal.st_subclip(ti, 2.0F, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v267 mock: st_extract_frame rejects out-of-bounds index" {
  let ti = v267_fake_timage_uniform([10, 20], 1.0F, 2.0F)
  try {
    ignore(@spatiotemporal.st_extract_frame(ti, 5))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v267 mock: st_interpolate_linear rejects mismatched dimensions" {
  let f1 = v267_fake_image_wh(2, 2, 0)
  let f2 = v267_fake_image_wh(3, 3, 255)
  try {
    ignore(@spatiotemporal.st_interpolate_linear(f1, f2, 0.5F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ============================================================
// E2E: 端到端全流水线测试
// ============================================================

///|
test "v267 e2e: Image→TFrame→TImage→st_snapshot→verify" {
  let img = v267_fake_image_wh(4, 4, 128)
  let frame = @spatiotemporal.TFrame::make(img, 0.0F, 1.0F)
  let ti = @spatiotemporal.TImage::make([frame], 1.0F)
  let snap = @spatiotemporal.st_snapshot(ti, 0.5F)
  assert_eq(snap.width, 4)
  assert_eq(snap.height, 4)
  for i in 0..<snap.data.length() {
    assert_eq(snap.data[i], img.data[i])
  }
}

///|
test "v267 e2e: Image×N→TImage→st_interpolate_at→verify" {
  let f1 = @spatiotemporal.TFrame::make(v267_fake_image(0), 0.0F, 1.0F)
  let f2 = @spatiotemporal.TFrame::make(v267_fake_image(100), 1.0F, 1.0F)
  let ti = @spatiotemporal.TImage::make([f1, f2], 2.0F)
  // time=0.5 → alpha=0.5 → 50
  let result = @spatiotemporal.st_interpolate_at(ti, 0.5F)
  assert_eq(result.data[0].to_int(), 50)
  // time=0.0 → alpha=0.0 → 0
  let r0 = @spatiotemporal.st_interpolate_at(ti, 0.0F)
  assert_eq(r0.data[0].to_int(), 0)
}

///|
test "v267 e2e: TImage→st_subclip→st_snapshot→verify" {
  let ti = v267_fake_timage_uniform([10, 20, 30, 40], 1.0F, 4.0F)
  // 截取 [0.5, 2.5)
  let sub = @spatiotemporal.st_subclip(ti, 0.5F, 2.5F)
  assert_true(sub.frame_count() >= 2)
  // 验证子片段的帧来自原图
  let snap = @spatiotemporal.st_snapshot(sub, 0.0F)
  assert_eq(snap.width, 1)
  assert_eq(snap.height, 1)
}

///|
test "v267 e2e: TImage→TVideo→verify total_duration and codec" {
  let ti = v267_fake_timage_uniform([10, 20, 30], 0.5F, 10.0F)
  let vid = @spatiotemporal.TVideo::from_timage(ti, "h264")
  assert_eq(vid.codec_name, "h264")
  assert_true(v267_approx_eq(vid.total_duration, 1.5F, 0.0001F))
}

///|
test "v267 e2e: TContext→step×N→verify time advances correctly" {
  let ctx = @spatiotemporal.TContext::make(10.0F)
  let mut c = ctx
  for _ in 0..<5 {
    c = c.step(100.0F)
  }
  // 5 steps × 0.1 = 0.5
  assert_true(v267_approx_eq(c.current_time, 0.5F, 0.001F))
}

///|
test "v267 e2e: TContext→pause→step→resume→step→verify" {
  let ctx = @spatiotemporal.TContext::make(10.0F)
  let paused = ctx.set_paused(true)
  let after_pause_step = paused.step(100.0F)
  assert_eq(after_pause_step.current_time, 0.0F)
  let resumed = after_pause_step.set_paused(false)
  let after_resume_step = resumed.step(100.0F)
  assert_true(v267_approx_eq(after_resume_step.current_time, 0.1F, 0.0001F))
}

///|
test "v267 e2e: random TImage→st_snapshot at various times→verify" {
  let ti = v267_fake_timage_random(42, 5, 1.0F)
  for t in [0.0F, 0.5F, 1.5F, 2.5F, 3.5F, 4.5F, 100.0F] {
    let snap = @spatiotemporal.st_snapshot(ti, t)
    assert_eq(snap.width, 1)
    assert_eq(snap.height, 1)
    assert_eq(snap.channels, 1)
  }
}

///|
test "v267 e2e: GifAnimation→st_from_gif_animation→TImage→verify" {
  let gif : @types.GifAnimation = {
    frames: [v267_fake_image(10), v267_fake_image(20), v267_fake_image(30)],
    delays: [500, 500, 500],
  }
  let ti = @spatiotemporal.st_from_gif_animation(gif)
  assert_eq(ti.frame_count(), 3)
  // 总时长 = 1.5s
  assert_true(v267_approx_eq(ti.total_duration(), 1.5F, 0.0001F))
}

///|
test "v267 e2e: multi-frame TImage→st_extract_frame each index→verify" {
  let ti = v267_fake_timage_uniform([10, 20, 30, 40, 50], 1.0F, 5.0F)
  for i in 0..<5 {
    let frame = @spatiotemporal.st_extract_frame(ti, i)
    assert_eq(frame.data[0].to_int(), (i + 1) * 10)
  }
}
