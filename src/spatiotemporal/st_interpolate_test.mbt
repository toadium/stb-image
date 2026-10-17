// 帧间插值 + 时序快照测试。

///|
fn make_img(value : Int) -> @types.Image {
  {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([value.to_byte()]),
  }
}

///|
test "st_interpolate_linear: alpha=0 返回 frame1" {
  let f1 = make_img(100)
  let f2 = make_img(200)
  let result = @spatiotemporal.st_interpolate_linear(f1, f2, 0.0F)
  assert_eq(result.data[0].to_int(), 100)
}

///|
test "st_interpolate_linear: alpha=1 返回 frame2" {
  let f1 = make_img(100)
  let f2 = make_img(200)
  let result = @spatiotemporal.st_interpolate_linear(f1, f2, 1.0F)
  assert_eq(result.data[0].to_int(), 200)
}

///|
test "st_interpolate_linear: alpha=0.5 返回中间值" {
  let f1 = make_img(0)
  let f2 = make_img(100)
  let result = @spatiotemporal.st_interpolate_linear(f1, f2, 0.5F)
  assert_eq(result.data[0].to_int(), 50)
}

///|
test "st_interpolate_linear: 尺寸不一致抛异常" {
  let f1 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([b'\x00']),
  }
  let f2 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([b'\x00', b'\x00']),
  }
  try {
    ignore(@spatiotemporal.st_interpolate_linear(f1, f2, 0.5F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "st_interpolate_at: 单帧返回该帧" {
  let img = make_img(42)
  let ti = @spatiotemporal.TImage::from_static(img)
  let result = @spatiotemporal.st_interpolate_at(ti, 0.5F)
  assert_eq(result.data[0].to_int(), 42)
}

///|
test "st_interpolate_at: 多帧插值" {
  let f1 = @spatiotemporal.TFrame::make(make_img(0), 0.0F, 1.0F)
  let f2 = @spatiotemporal.TFrame::make(make_img(100), 1.0F, 1.0F)
  let ti = @spatiotemporal.TImage::make([f1, f2], 2.0F)
  // time=0.5 → alpha=0.5 → 0*0.5 + 100*0.5 = 50
  let result = @spatiotemporal.st_interpolate_at(ti, 0.5F)
  assert_eq(result.data[0].to_int(), 50)
}

///|
test "st_snapshot: 取最近帧" {
  let f1 = @spatiotemporal.TFrame::make(make_img(10), 0.0F, 0.5F)
  let f2 = @spatiotemporal.TFrame::make(make_img(20), 0.5F, 0.5F)
  let ti = @spatiotemporal.TImage::make([f1, f2], 2.0F)
  // time=0.3 在第一帧区间 [0, 0.5)
  let snap = @spatiotemporal.st_snapshot(ti, 0.3F)
  assert_eq(snap.data[0].to_int(), 10)
  // time=0.7 在第二帧区间 [0.5, 1.0)
  let snap2 = @spatiotemporal.st_snapshot(ti, 0.7F)
  assert_eq(snap2.data[0].to_int(), 20)
}

///|
test "st_snapshot: 超出范围返回最后一帧" {
  let f1 = @spatiotemporal.TFrame::make(make_img(10), 0.0F, 0.5F)
  let f2 = @spatiotemporal.TFrame::make(make_img(20), 0.5F, 0.5F)
  let ti = @spatiotemporal.TImage::make([f1, f2], 2.0F)
  let snap = @spatiotemporal.st_snapshot(ti, 100.0F)
  assert_eq(snap.data[0].to_int(), 20)
}

///|
test "st_extract_frame: 按索引取帧" {
  let f1 = @spatiotemporal.TFrame::make(make_img(10), 0.0F, 0.5F)
  let f2 = @spatiotemporal.TFrame::make(make_img(20), 0.5F, 0.5F)
  let ti = @spatiotemporal.TImage::make([f1, f2], 2.0F)
  assert_eq(@spatiotemporal.st_extract_frame(ti, 0).data[0].to_int(), 10)
  assert_eq(@spatiotemporal.st_extract_frame(ti, 1).data[0].to_int(), 20)
}

///|
test "st_extract_frame: 索引越界抛异常" {
  let ti = @spatiotemporal.TImage::from_static(make_img(0))
  try {
    ignore(@spatiotemporal.st_extract_frame(ti, 5))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "st_subclip: 截取子片段" {
  let f1 = @spatiotemporal.TFrame::make(make_img(10), 0.0F, 1.0F)
  let f2 = @spatiotemporal.TFrame::make(make_img(20), 1.0F, 1.0F)
  let f3 = @spatiotemporal.TFrame::make(make_img(30), 2.0F, 1.0F)
  let ti = @spatiotemporal.TImage::make([f1, f2, f3], 3.0F)
  // 截取 [0.5, 2.5)
  let sub = @spatiotemporal.st_subclip(ti, 0.5F, 2.5F)
  assert_true(sub.frame_count() >= 2)
}

///|
test "st_subclip: start >= end 抛异常" {
  let ti = @spatiotemporal.TImage::from_static(make_img(0))
  try {
    ignore(@spatiotemporal.st_subclip(ti, 1.0F, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
