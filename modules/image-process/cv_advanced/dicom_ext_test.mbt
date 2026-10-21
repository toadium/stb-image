// DICOM 扩展测试 — DICOM extension tests
// Phase 14 v346: 医学影像大扩展 — DICOM 扩展。

///|
fn make_dicom_metadata() -> @cv_advanced.DicomMetadata {
  @cv_advanced.parse_dicom_metadata(
    "P001", "S001", "SE001", "I001", "CT", 4, 4, 16,
  )
}

///|
test "parse_dicom_metadata: 基本元数据" {
  let meta = make_dicom_metadata()
  assert_true(meta.patient_id == "P001")
  assert_true(meta.modality == "CT")
  assert_true(meta.rows == 4)
  assert_true(meta.cols == 4)
}

///|
test "extract_dicom_pixels: 像素提取" {
  let raw = [
    100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500,
    1600,
  ]
  let pixels = @cv_advanced.extract_dicom_pixels(raw, 4, 4)
  assert_true(pixels.length() == 16)
  assert_true(pixels[0] == 100.0)
}

///|
test "extract_dicom_pixels: 不足数据" {
  let raw = [100, 200]
  let pixels = @cv_advanced.extract_dicom_pixels(raw, 2, 2)
  assert_true(pixels.length() == 4)
  assert_true(pixels[2] == 0.0)
}

///|
test "dicom_window_level: 窗宽窗位" {
  let result = @cv_advanced.dicom_window_level(100.0, 50.0, 100.0)
  assert_true(result >= 0.0 && result <= 255.0)
}

///|
test "dicom_window_level: 零窗宽" {
  let result = @cv_advanced.dicom_window_level(100.0, 50.0, 0.0)
  assert_true(result == 0.0)
}

///|
test "dicom_to_image: 转图像" {
  let meta = @cv_advanced.set_window_level(make_dicom_metadata(), 50.0, 100.0)
  let dicom : @cv_advanced.DicomImage = {
    metadata: meta,
    pixel_data: [10.0, 50.0, 100.0, 150.0],
    num_frames: 1,
  }
  let img = @cv_advanced.dicom_to_image(dicom)
  assert_true(img.length() == 4)
}

///|
test "dicom_multiframe_extract: 多帧提取" {
  let meta = make_dicom_metadata()
  let dicom : @cv_advanced.DicomImage = {
    metadata: meta,
    pixel_data: [
      1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0,
      15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0,
      28.0, 29.0, 30.0, 31.0, 32.0,
    ],
    num_frames: 2,
  }
  let frame0 = @cv_advanced.dicom_multiframe_extract(dicom, 0)
  let frame1 = @cv_advanced.dicom_multiframe_extract(dicom, 1)
  assert_true(frame0.length() == 16)
  assert_true(frame1.length() == 16)
  assert_true(frame1[0] == 17.0)
}

///|
test "dicom_multiframe_extract: 无效帧" {
  let meta = make_dicom_metadata()
  let dicom : @cv_advanced.DicomImage = {
    metadata: meta,
    pixel_data: [1.0, 2.0, 3.0, 4.0],
    num_frames: 1,
  }
  let frame = @cv_advanced.dicom_multiframe_extract(dicom, 5)
  assert_true(frame.length() == 0)
}

///|
test "set_window_level: 设置窗宽窗位" {
  let meta = make_dicom_metadata()
  let updated = @cv_advanced.set_window_level(meta, 100.0, 200.0)
  assert_true(updated.window_center == 100.0)
  assert_true(updated.window_width == 200.0)
}
