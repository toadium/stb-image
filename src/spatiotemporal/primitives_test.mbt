///|
test "TInterval::make: 有效构造" {
  let iv = @spatiotemporal.TInterval::make(0.0F, 1.5F)
  assert_eq(iv.start, 0.0F)
  assert_eq(iv.end, 1.5F)
  assert_eq(iv.duration(), 1.5F)
}

///|
test "TInterval::make: end < start 抛异常" {
  try {
    ignore(@spatiotemporal.TInterval::make(2.0F, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "TInterval::duration: 零长度" {
  let iv = @spatiotemporal.TInterval::make(1.0F, 1.0F)
  assert_eq(iv.duration(), 0.0F)
}

///|
test "TFrame::make: 有效构造" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([b'\x80']),
  }
  let frame = @spatiotemporal.TFrame::make(img, 0.5F, 0.1F)
  assert_eq(frame.timestamp, 0.5F)
  assert_eq(frame.duration, 0.1F)
}

///|
test "TFrame::make: 负 duration 抛异常" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([b'\x00']),
  }
  try {
    ignore(@spatiotemporal.TFrame::make(img, 0.0F, -1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "TImage::make: 单帧构造" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([b'\x00', b'\x40', b'\x80', b'\xff']),
  }
  let frame = @spatiotemporal.TFrame::make(img, 0.0F, 1.0F)
  let ti = @spatiotemporal.TImage::make([frame], 30.0F)
  assert_eq(ti.frame_count(), 1)
  assert_eq(ti.width, 2)
  assert_eq(ti.fps, 30.0F)
}

///|
test "TImage::make: 空帧序列抛异常" {
  try {
    ignore(@spatiotemporal.TImage::make([], 30.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "TImage::make: 零 fps 抛异常" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([b'\x00']),
  }
  let frame = @spatiotemporal.TFrame::make(img, 0.0F, 1.0F)
  try {
    ignore(@spatiotemporal.TImage::make([frame], 0.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "TImage::total_duration: 多帧总时长" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([b'\x00']),
  }
  let f1 = @spatiotemporal.TFrame::make(img, 0.0F, 0.5F)
  let f2 = @spatiotemporal.TFrame::make(img, 0.5F, 0.3F)
  let f3 = @spatiotemporal.TFrame::make(img, 0.8F, 0.2F)
  let ti = @spatiotemporal.TImage::make([f1, f2, f3], 10.0F)
  assert_eq(ti.total_duration(), 1.0F)
}

///|
test "TImage::from_static: 静态图转时变" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([b'\xff']),
  }
  let ti = @spatiotemporal.TImage::from_static(img)
  assert_eq(ti.frame_count(), 1)
  assert_eq(ti.width, 1)
}

///|
test "TVideo::from_timage: 视频包装" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([b'\x00']),
  }
  let ti = @spatiotemporal.TImage::from_static(img)
  let vid = @spatiotemporal.TVideo::from_timage(ti, "test")
  assert_eq(vid.codec_name, "test")
  assert_eq(vid.total_duration, 0.0F)
}
