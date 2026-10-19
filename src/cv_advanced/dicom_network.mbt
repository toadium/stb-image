// DICOM 网络 — PACS/查询/检索/存储
// DICOM network
//
// Phase 14 v359: 医学影像大扩展 — DICOM 网络。

///|
/// DICOM 网络操作类型。
/// DICOM network operation type.
pub(all) enum DicomNetOp {
  CStore
  CFind
  CGet
  CMove
  CEcho
} derive(Eq, @debug.Debug)

///|
pub extend DicomNetOp with @debug.Debug::{to_repr}

///|
pub extend DicomNetOp with Eq::{not_equal, equal}

///|
/// DICOM 查询级别。
/// DICOM query level.
pub(all) enum DicomQueryLevel {
  Patient
  Study
  Series
  Image
} derive(Eq, @debug.Debug)

///|
pub extend DicomQueryLevel with @debug.Debug::{to_repr}

///|
pub extend DicomQueryLevel with Eq::{not_equal, equal}

///|
/// PACS 连接配置。
/// PACS connection configuration.
pub(all) struct PACSConfig {
  ae_title : String
  host : String
  port : Int
  timeout : Int
} derive(Eq, @debug.Debug)

///|
pub extend PACSConfig with @debug.Debug::{to_repr}

///|
pub extend PACSConfig with Eq::{not_equal, equal}

///|
/// DICOM 查询请求。
/// DICOM query request.
pub(all) struct DicomQuery {
  level : DicomQueryLevel
  patient_id : String
  study_uid : String
  series_uid : String
  modality : String
} derive(Eq, @debug.Debug)

///|
pub extend DicomQuery with @debug.Debug::{to_repr}

///|
pub extend DicomQuery with Eq::{not_equal, equal}

///|
/// DICOM 查询结果。
/// DICOM query result.
pub(all) struct DicomQueryResult {
  found : Bool
  num_results : Int
  study_uids : Array[String]
  series_uids : Array[String]
  error_message : String
} derive(Eq, @debug.Debug)

///|
pub extend DicomQueryResult with @debug.Debug::{to_repr}

///|
pub extend DicomQueryResult with Eq::{not_equal, equal}

///|
/// 构建 PACS 连接配置。
/// Build PACS connection configuration.
pub fn dicom_net_build_config(
  ae_title : String,
  host : String,
  port : Int,
  timeout : Int,
) -> PACSConfig {
  PACSConfig::{ ae_title, host, port, timeout, }
}

///|
/// 构建查询请求。
/// Build query request.
pub fn dicom_net_build_query(
  level : DicomQueryLevel,
  patient_id : String,
  modality : String,
) -> DicomQuery {
  DicomQuery::{ level, patient_id, study_uid: "", series_uid: "", modality, }
}

///|
/// 模拟 C-FIND 操作。
/// Simulate C-FIND operation.
pub fn dicom_net_cfind(
  config : PACSConfig,
  query : DicomQuery,
  available_studies : Array[DicomQuery],
) -> DicomQueryResult {
  if config.port <= 0 {
    return DicomQueryResult::{
      found: false,
      num_results: 0,
      study_uids: [],
      series_uids: [],
      error_message: "Invalid config",
    }
  }
  let matching_uids : Array[String] = []
  let matching_series : Array[String] = []
  let mut count = 0
  for i in 0..<available_studies.length() {
    let study = available_studies[i]
    let patient_match = query.patient_id == "" ||
      study.patient_id == query.patient_id
    let modality_match = query.modality == "" ||
      study.modality == query.modality
    if patient_match && modality_match {
      count = count + 1
      matching_uids.push("1.2.840." + count.to_string())
      matching_series.push("1.2.840.100." + count.to_string())
    }
  }
  DicomQueryResult::{
    found: count > 0,
    num_results: count,
    study_uids: matching_uids,
    series_uids: matching_series,
    error_message: "",
  }
}

///|
/// 模拟 C-GET 操作。
/// Simulate C-GET operation.
pub fn dicom_net_cget(
  config : PACSConfig,
  study_uid : String,
  available_count : Int,
) -> DicomQueryResult {
  if config.port <= 0 {
    return DicomQueryResult::{
      found: false,
      num_results: 0,
      study_uids: [],
      series_uids: [],
      error_message: "Invalid config",
    }
  }
  let uids : Array[String] = []
  let series : Array[String] = []
  for i in 0..<available_count {
    uids.push(study_uid + "." + i.to_string())
    series.push(study_uid + ".series." + i.to_string())
  }
  DicomQueryResult::{
    found: available_count > 0,
    num_results: available_count,
    study_uids: uids,
    series_uids: series,
    error_message: "",
  }
}

///|
/// 模拟 C-MOVE 操作。
/// Simulate C-MOVE operation.
pub fn dicom_net_cmove(
  config : PACSConfig,
  destination_ae : String,
  study_uids : Array[String],
) -> DicomQueryResult {
  let _ = destination_ae
  if config.port <= 0 {
    return DicomQueryResult::{
      found: false,
      num_results: 0,
      study_uids: [],
      series_uids: [],
      error_message: "Invalid config",
    }
  }
  DicomQueryResult::{
    found: study_uids.length() > 0,
    num_results: study_uids.length(),
    study_uids,
    series_uids: [],
    error_message: "",
  }
}

///|
/// 模拟 C-ECHO 操作（验证连接）。
/// Simulate C-ECHO operation (verify connection).
pub fn dicom_net_cecho(config : PACSConfig) -> Bool {
  config.port > 0 &&
  config.timeout > 0 &&
  config.ae_title != "" &&
  config.host != ""
}

///|
/// 模拟 C-STORE 操作（存储影像）。
/// Simulate C-STORE operation (store image).
pub fn dicom_net_cstore(
  config : PACSConfig,
  study_uid : String,
  image_data : Array[Double],
) -> DicomQueryResult {
  if config.port <= 0 {
    return DicomQueryResult::{
      found: false,
      num_results: 0,
      study_uids: [],
      series_uids: [],
      error_message: "Invalid config",
    }
  }
  let uids : Array[String] = []
  uids.push(study_uid)
  DicomQueryResult::{
    found: image_data.length() > 0,
    num_results: image_data.length(),
    study_uids: uids,
    series_uids: [],
    error_message: if image_data.length() == 0 {
      "Empty image data"
    } else {
      ""
    },
  }
}

///|
/// 生成 DICOM UID。
/// Generate DICOM UID.
pub fn dicom_net_generate_uid(root : String, instance : Int) -> String {
  root + "." + instance.to_string()
}

///|
/// 解析 DICOM UID。
/// Parse DICOM UID.
pub fn dicom_net_parse_uid(uid : String) -> Array[String] {
  let parts : Array[String] = []
  let mut current = ""
  for ch in uid {
    if ch == '.' {
      parts.push(current)
      current = ""
    } else {
      current = current + ch.to_string()
    }
  }
  if current != "" {
    parts.push(current)
  }
  parts
}
