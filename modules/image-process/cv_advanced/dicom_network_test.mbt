// DICOM 网络测试
// DICOM network tests

///|
test "dicom_net_build_config: 构建配置" {
  let config = @cv_advanced.dicom_net_build_config(
    "TEST_AE", "192.168.1.1", 104, 30,
  )
  assert_eq(config.ae_title, "TEST_AE")
  assert_eq(config.host, "192.168.1.1")
  assert_eq(config.port, 104)
}

///|
test "dicom_net_build_query: 构建查询" {
  let query = @cv_advanced.dicom_net_build_query(
    @cv_advanced.DicomQueryLevel::Patient,
    "PAT001",
    "CT",
  )
  assert_eq(query.patient_id, "PAT001")
  assert_eq(query.modality, "CT")
}

///|
test "dicom_net_cfind: 匹配查询" {
  let config = @cv_advanced.dicom_net_build_config("AE", "host", 104, 30)
  let query = @cv_advanced.dicom_net_build_query(
    @cv_advanced.DicomQueryLevel::Patient,
    "PAT001",
    "CT",
  )
  let available : Array[@cv_advanced.DicomQuery] = []
  available.push(
    @cv_advanced.dicom_net_build_query(
      @cv_advanced.DicomQueryLevel::Patient,
      "PAT001",
      "CT",
    ),
  )
  available.push(
    @cv_advanced.dicom_net_build_query(
      @cv_advanced.DicomQueryLevel::Patient,
      "PAT002",
      "MR",
    ),
  )
  let result = @cv_advanced.dicom_net_cfind(config, query, available)
  assert_eq(result.found, true)
  assert_eq(result.num_results, 1)
}

///|
test "dicom_net_cfind: 无匹配" {
  let config = @cv_advanced.dicom_net_build_config("AE", "host", 104, 30)
  let query = @cv_advanced.dicom_net_build_query(
    @cv_advanced.DicomQueryLevel::Patient,
    "PAT999",
    "CT",
  )
  let available : Array[@cv_advanced.DicomQuery] = []
  available.push(
    @cv_advanced.dicom_net_build_query(
      @cv_advanced.DicomQueryLevel::Patient,
      "PAT001",
      "CT",
    ),
  )
  let result = @cv_advanced.dicom_net_cfind(config, query, available)
  assert_eq(result.found, false)
  assert_eq(result.num_results, 0)
}

///|
test "dicom_net_cget: 检索影像" {
  let config = @cv_advanced.dicom_net_build_config("AE", "host", 104, 30)
  let result = @cv_advanced.dicom_net_cget(config, "1.2.840.1", 3)
  assert_eq(result.found, true)
  assert_eq(result.num_results, 3)
  assert_eq(result.study_uids.length(), 3)
}

///|
test "dicom_net_cmove: 移动影像" {
  let config = @cv_advanced.dicom_net_build_config("AE", "host", 104, 30)
  let uids = ["1.2.3", "1.2.4"]
  let result = @cv_advanced.dicom_net_cmove(config, "DEST_AE", uids)
  assert_eq(result.found, true)
  assert_eq(result.num_results, 2)
}

///|
test "dicom_net_cecho: 有效连接" {
  let config = @cv_advanced.dicom_net_build_config("AE", "host", 104, 30)
  let result = @cv_advanced.dicom_net_cecho(config)
  assert_eq(result, true)
}

///|
test "dicom_net_cecho: 无效连接" {
  let config = @cv_advanced.dicom_net_build_config("", "", 0, 0)
  let result = @cv_advanced.dicom_net_cecho(config)
  assert_eq(result, false)
}

///|
test "dicom_net_cstore: 存储影像" {
  let config = @cv_advanced.dicom_net_build_config("AE", "host", 104, 30)
  let data = [1.0, 2.0, 3.0]
  let result = @cv_advanced.dicom_net_cstore(config, "1.2.3", data)
  assert_eq(result.found, true)
  assert_eq(result.num_results, 3)
}

///|
test "dicom_net_cstore: 空数据" {
  let config = @cv_advanced.dicom_net_build_config("AE", "host", 104, 30)
  let data : Array[Double] = []
  let result = @cv_advanced.dicom_net_cstore(config, "1.2.3", data)
  assert_eq(result.found, false)
  assert_eq(result.error_message, "Empty image data")
}

///|
test "dicom_net_generate_uid: 生成UID" {
  let uid = @cv_advanced.dicom_net_generate_uid("1.2.840", 42)
  assert_eq(uid, "1.2.840.42")
}

///|
test "dicom_net_parse_uid: 解析UID" {
  let parts = @cv_advanced.dicom_net_parse_uid("1.2.840.42")
  assert_eq(parts.length(), 4)
  assert_eq(parts[0], "1")
  assert_eq(parts[3], "42")
}
