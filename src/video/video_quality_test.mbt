///|
test "VideoQualityMetric: 枚举值" {
  assert_true(@video.PSNRMetric is @video.PSNRMetric)
  assert_true(@video.SSIMMetric is @video.SSIMMetric)
  assert_true(@video.VMAFMetric is @video.VMAFMetric)
}

///|
test "compute_psnr: 完美匹配" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 150, 50, 200]),
  }
  let psnr = @video.compute_psnr(img, img)
  // 完美匹配时 PSNR 应为 100.0
  assert_eq(psnr, 100.0)
}

///|
test "compute_psnr: 有差异" {
  let ref_img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 150, 50, 200]),
  }
  let dis : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([110, 140, 60, 190]),
  }
  let psnr = @video.compute_psnr(ref_img, dis)
  // 有差异时 PSNR 应小于 100
  assert_true(psnr < 100.0)
  assert_true(psnr > 0.0)
}

///|
test "compute_psnr: 空图像" {
  let img : @types.Image = {
    width: 0,
    height: 0,
    channels: 1,
    data: Bytes::from_array([]),
  }
  let psnr = @video.compute_psnr(img, img)
  assert_eq(psnr, 0.0)
}

///|
test "compute_ssim: 完美匹配" {
  let img : @types.Image = {
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array([
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100,
    ]),
  }
  let ssim = @video.compute_ssim(img, img)
  // 完美匹配时 SSIM 应接近 1.0
  assert_true(ssim > 0.99)
}

///|
test "compute_ssim: 小图像" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 150, 50, 200]),
  }
  let ssim = @video.compute_ssim(img, img)
  assert_true(ssim > 0.0)
}

///|
test "compute_msssim: 完美匹配" {
  let img : @types.Image = {
    width: 16,
    height: 16,
    channels: 1,
    data: Bytes::from_array([
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100,
    ]),
  }
  let msssim = @video.compute_msssim(img, img)
  assert_true(msssim > 0.0)
  assert_true(msssim <= 1.0)
}

///|
test "compute_vmaf_score: 完美匹配" {
  let img : @types.Image = {
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array([
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100,
    ]),
  }
  let vmaf = @video.compute_vmaf_score(img, img)
  assert_true(vmaf > 0.9)
  assert_true(vmaf <= 1.0)
}

///|
test "compute_frame_quality: PSNR" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 150, 50, 200]),
  }
  let score = @video.compute_frame_quality(img, img, @video.PSNRMetric)
  assert_true(score > 0.99)
}

///|
test "compute_frame_quality: SSIM" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 150, 50, 200]),
  }
  let score = @video.compute_frame_quality(img, img, @video.SSIMMetric)
  assert_true(score > 0.0)
}

///|
test "compute_frame_quality: VMAF" {
  let img : @types.Image = {
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array([
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100,
    ]),
  }
  let score = @video.compute_frame_quality(img, img, @video.VMAFMetric)
  assert_true(score > 0.9)
}

///|
test "compute_video_quality: 多帧评估" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 150, 50, 200]),
  }
  let result = @video.compute_video_quality(
    [img, img, img],
    [img, img, img],
    @video.PSNRMetric,
  )
  assert_eq(result.per_frame_scores.length(), 3)
  assert_true(result.mean_score > 0.99)
  assert_true(result.min_score > 0.99)
  assert_true(result.max_score > 0.99)
}

///|
test "compute_video_quality: 空序列" {
  let result = @video.compute_video_quality([], [], @video.PSNRMetric)
  assert_eq(result.per_frame_scores.length(), 0)
  assert_eq(result.mean_score, 0.0)
}

///|
test "quality_pipeline: 多度量评估" {
  let img : @types.Image = {
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array([
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
      100, 100, 100, 100,
    ]),
  }
  let results = @video.quality_pipeline([img], [img])
  assert_eq(results.length(), 3)
  assert_true(results[0].metric is @video.PSNRMetric)
  assert_true(results[1].metric is @video.SSIMMetric)
  assert_true(results[2].metric is @video.VMAFMetric)
}

///|
test "VideoQualityResult: 构造与字段" {
  let result : @video.VideoQualityResult = {
    metric: @video.PSNRMetric,
    score: 0.95,
    per_frame_scores: [0.9, 0.95, 1.0],
    mean_score: 0.95,
    min_score: 0.9,
    max_score: 1.0,
  }
  assert_eq(result.score, 0.95)
  assert_eq(result.per_frame_scores.length(), 3)
  assert_eq(result.min_score, 0.9)
  assert_eq(result.max_score, 1.0)
}
