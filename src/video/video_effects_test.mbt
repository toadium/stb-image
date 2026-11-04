///|
test "VideoFilterType: 枚举值" {
  assert_true(@video.Blur is @video.Blur)
  assert_true(@video.Sharpen is @video.Sharpen)
  assert_true(@video.Vintage is @video.Vintage)
  assert_true(@video.Grayscale is @video.Grayscale)
  assert_true(@video.Vignette is @video.Vignette)
  assert_true(@video.Sepia is @video.Sepia)
}

///|
test "TransitionType: 枚举值" {
  assert_true(@video.Fade is @video.Fade)
  assert_true(@video.Dissolve is @video.Dissolve)
  assert_true(@video.Slide is @video.Slide)
  assert_true(@video.Wipe is @video.Wipe)
  assert_true(@video.Push is @video.Push)
}

///|
test "VideoFilterParams: 构造与字段" {
  let p : @video.VideoFilterParams = {
    filter_type: @video.Blur,
    intensity: 0.7,
  }
  assert_eq(p.intensity, 0.7)
  assert_true(p.filter_type is @video.Blur)
}

///|
test "TransitionParams: 构造与字段" {
  let p : @video.TransitionParams = {
    transition_type: @video.Fade,
    duration: 5,
    direction: 1,
  }
  assert_eq(p.duration, 5)
  assert_eq(p.direction, 1)
  assert_true(p.transition_type is @video.Fade)
}

///|
test "default_video_filter_params: 默认值" {
  let p = @video.default_video_filter_params(@video.Vintage)
  assert_eq(p.intensity, 0.5)
  assert_true(p.filter_type is @video.Vintage)
}

///|
test "default_transition_params: 默认值" {
  let p = @video.default_transition_params(@video.Slide)
  assert_eq(p.duration, 10)
  assert_eq(p.direction, 0)
  assert_true(p.transition_type is @video.Slide)
}

///|
test "apply_video_filter: 模糊滤镜" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([0, 0, 0, 0, 255, 0, 0, 0, 0]),
  }
  let params = @video.default_video_filter_params(@video.Blur)
  let result = @video.apply_video_filter(img, params)
  assert_eq(result.width, 3)
  assert_eq(result.height, 3)
  assert_eq(result.channels, 1)
}

///|
test "apply_video_filter: 灰度滤镜" {
  let img : @types.Image = {
    width: 2,
    height: 1,
    channels: 3,
    data: Bytes::from_array([255, 0, 0, 0, 255, 0]),
  }
  let params = @video.default_video_filter_params(@video.Grayscale)
  let result = @video.apply_video_filter(img, params)
  assert_eq(result.data[0], result.data[1])
  assert_eq(result.data[1], result.data[2])
}

///|
test "apply_video_filter: 晕影滤镜" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([200, 200, 200, 200, 200, 200, 200, 200, 200]),
  }
  let params : @video.VideoFilterParams = {
    filter_type: @video.Vignette,
    intensity: 0.5,
  }
  let result = @video.apply_video_filter(img, params)
  // 中心像素应比角落像素亮
  assert_true(result.data[4].to_int() >= result.data[0].to_int())
}

///|
test "apply_video_filter: 复古滤镜" {
  let img : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 200]),
  }
  let params = @video.default_video_filter_params(@video.Vintage)
  let result = @video.apply_video_filter(img, params)
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
}

///|
test "apply_video_filter: 棕褐滤镜" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 3,
    data: Bytes::from_array([100, 150, 200]),
  }
  let params : @video.VideoFilterParams = {
    filter_type: @video.Sepia,
    intensity: 1.0,
  }
  let result = @video.apply_video_filter(img, params)
  assert_eq(result.width, 1)
  assert_eq(result.height, 1)
  assert_eq(result.channels, 3)
}

///|
test "create_transition_frame: 淡入淡出" {
  let from : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0, 0]),
  }
  let to_ : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 100]),
  }
  let params = @video.default_transition_params(@video.Fade)
  let mid = @video.create_transition_frame(from, to_, 0.5, params)
  assert_eq(mid.width, 2)
  assert_eq(mid.height, 1)
  // 中间值应约为 50
  assert_true(mid.data[0].to_int() > 40 && mid.data[0].to_int() < 60)
}

///|
test "create_transition_frame: 擦除" {
  let from : @types.Image = {
    width: 4,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0, 0, 0, 0]),
  }
  let to_ : @types.Image = {
    width: 4,
    height: 1,
    channels: 1,
    data: Bytes::from_array([255, 255, 255, 255]),
  }
  let params = @video.default_transition_params(@video.Wipe)
  let mid = @video.create_transition_frame(from, to_, 0.5, params)
  assert_eq(mid.width, 4)
  assert_eq(mid.height, 1)
}

///|
test "generate_transition: 生成帧序列" {
  let from : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0, 0]),
  }
  let to_ : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 100]),
  }
  let params : @video.TransitionParams = {
    transition_type: @video.Fade,
    duration: 5,
    direction: 0,
  }
  let frames = @video.generate_transition(from, to_, params)
  assert_eq(frames.length(), 5)
}

///|
test "add_text_overlay: 基本叠加" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
    ]),
  }
  let result = @video.add_text_overlay(img, 1, 1, 2, 2, (255 : Byte))
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  // 叠加区域应为 255
  assert_eq(result.data[5], 255)
  assert_eq(result.data[6], 255)
  // 非叠加区域应保持原值
  assert_eq(result.data[0], 10)
}

///|
test "add_timestamp: 进度条" {
  let img : @types.Image = {
    width: 10,
    height: 10,
    channels: 1,
    data: Bytes::from_array(Array::make(100, 50)),
  }
  let result = @video.add_timestamp(img, 5, 10)
  assert_eq(result.width, 10)
  assert_eq(result.height, 10)
  // 底部进度条区域 (y=7, x=0) 应被修改
  assert_true(result.data[70].to_int() != 50)
}

///|
test "add_watermark: 基本水印" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
    ]),
  }
  let wm : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([200, 200, 200, 200]),
  }
  let result = @video.add_watermark(img, wm, 0, 0, 0.5)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  // 水印区域应为混合值
  assert_true(result.data[0].to_int() > 50)
}

///|
test "video_effects_pipeline: 仅滤镜" {
  let frame1 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 100]),
  }
  let frame2 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([200, 200]),
  }
  let frames = [frame1, frame2]
  let filter_params = @video.default_video_filter_params(@video.Vintage)
  let result = @video.video_effects_pipeline(frames, Some(filter_params), None)
  assert_eq(result.length(), 2)
}

///|
test "video_effects_pipeline: 滤镜 + 转场" {
  let frame1 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 100]),
  }
  let frame2 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([200, 200]),
  }
  let frames = [frame1, frame2]
  let filter_params = @video.default_video_filter_params(@video.Blur)
  let transition_params : @video.TransitionParams = {
    transition_type: @video.Fade,
    duration: 3,
    direction: 0,
  }
  let result = @video.video_effects_pipeline(
    frames,
    Some(filter_params),
    Some(transition_params),
  )
  // 2 原始帧 + 3 转场帧 = 5
  assert_eq(result.length(), 5)
}

///|
test "video_effects_pipeline: 空视频" {
  let frames : Array[@types.Image] = []
  let result = @video.video_effects_pipeline(frames, None, None)
  assert_eq(result.length(), 0)
}
