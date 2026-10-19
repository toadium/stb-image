// DICOM 扩展 — 元数据/嵌套/多帧
// DICOM extensions
//
// Phase 14 v346: 医学影像大扩展 — DICOM 扩展。

///|
/// DICOM 值表示。
/// DICOM value representation.
pub(all) enum DicomVR {
  US
  SS
  UI
  CS
  DA
  TM
  PN
  LO
  SH
  OB
  OW
  OF
  SQ
} derive(Eq, @debug.Debug)

///|
pub extend DicomVR with @debug.Debug::{to_repr}

///|
pub extend DicomVR with Eq::{not_equal, equal}

///|
/// DICOM 标签。
/// DICOM tag.
pub(all) struct DicomTag {
  group : Int
  element : Int
  vr : DicomVR
  value : String
} derive(Eq, @debug.Debug)

///|
pub extend DicomTag with @debug.Debug::{to_repr}

///|
pub extend DicomTag with Eq::{not_equal, equal}

///|
/// DICOM 元数据。
/// DICOM metadata.
pub(all) struct DicomMetadata {
  patient_id : String
  study_id : String
  series_id : String
  instance_id : String
  modality : String
  rows : Int
  cols : Int
  bits_allocated : Int
  window_center : Double
  window_width : Double
} derive(Eq, @debug.Debug)

///|
pub extend DicomMetadata with @debug.Debug::{to_repr}

///|
pub extend DicomMetadata with Eq::{not_equal, equal}

///|
/// DICOM 图像。
/// DICOM image.
pub(all) struct DicomImage {
  metadata : DicomMetadata
  pixel_data : Array[Double]
  num_frames : Int
} derive(Eq, @debug.Debug)

///|
pub extend DicomImage with @debug.Debug::{to_repr}

///|
pub extend DicomImage with Eq::{not_equal, equal}

///|
/// 解析 DICOM 元数据。
/// Parse DICOM metadata.
pub fn parse_dicom_metadata(
  patient_id : String,
  study_id : String,
  series_id : String,
  instance_id : String,
  modality : String,
  rows : Int,
  cols : Int,
  bits_allocated : Int,
) -> DicomMetadata {
  DicomMetadata::{
    patient_id,
    study_id,
    series_id,
    instance_id,
    modality,
    rows,
    cols,
    bits_allocated,
    window_center: 0.0,
    window_width: 1.0,
  }
}

///|
/// 提取 DICOM 像素数据。
/// Extract DICOM pixel data.
pub fn extract_dicom_pixels(
  raw_data : Array[Int],
  rows : Int,
  cols : Int,
) -> Array[Double] {
  let result : Array[Double] = []
  let n = rows * cols
  let len = if n < raw_data.length() { n } else { raw_data.length() }
  for i in 0..<len {
    result.push(raw_data[i].to_double())
  }
  for _ in len..<n {
    result.push(0.0)
  }
  result
}

///|
/// DICOM 窗宽窗位调整。
/// DICOM window/level adjustment.
pub fn dicom_window_level(
  pixel : Double,
  window_center : Double,
  window_width : Double,
) -> Double {
  if window_width <= 0.0 {
    return 0.0
  }
  let min_val = window_center - window_width / 2.0
  let max_val = window_center + window_width / 2.0
  if pixel <= min_val {
    0.0
  } else if pixel >= max_val {
    255.0
  } else {
    255.0 * (pixel - min_val) / window_width
  }
}

///|
/// DICOM 转图像。
/// DICOM to image.
pub fn dicom_to_image(dicom : DicomImage) -> Array[Double] {
  let result : Array[Double] = []
  for pixel in dicom.pixel_data {
    result.push(
      dicom_window_level(
        pixel,
        dicom.metadata.window_center,
        dicom.metadata.window_width,
      ),
    )
  }
  result
}

///|
/// DICOM 多帧提取。
/// DICOM multiframe extract.
pub fn dicom_multiframe_extract(
  dicom : DicomImage,
  frame_idx : Int,
) -> Array[Double] {
  if frame_idx < 0 || frame_idx >= dicom.num_frames {
    return []
  }
  let frame_size = dicom.metadata.rows * dicom.metadata.cols
  let start = frame_idx * frame_size
  let result : Array[Double] = []
  for i in 0..<frame_size {
    let idx = start + i
    if idx < dicom.pixel_data.length() {
      result.push(dicom.pixel_data[idx])
    } else {
      result.push(0.0)
    }
  }
  result
}

///|
/// 设置窗宽窗位。
/// Set window/level.
pub fn set_window_level(
  metadata : DicomMetadata,
  window_center : Double,
  window_width : Double,
) -> DicomMetadata {
  DicomMetadata::{
    patient_id: metadata.patient_id,
    study_id: metadata.study_id,
    series_id: metadata.series_id,
    instance_id: metadata.instance_id,
    modality: metadata.modality,
    rows: metadata.rows,
    cols: metadata.cols,
    bits_allocated: metadata.bits_allocated,
    window_center,
    window_width,
  }
}
