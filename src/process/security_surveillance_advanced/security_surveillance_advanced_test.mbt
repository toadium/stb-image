///|
test "create_default_security_config: returns intrusion detection config" {
  let config = @security_surveillance_advanced.create_default_security_config()
  assert_eq(config.detection_threshold, 0.5)
  assert_eq(config.recognition_threshold, 0.7)
  assert_eq(config.alert_threshold, 0.8)
  assert_eq(config.loitering_time, 30.0)
  assert_true(config.use_face_recognition)
  assert_true(config.use_behavior_analysis)
  assert_true(config.use_crowd_analysis)
  assert_false(config.use_license_plate)
  assert_true(config.auto_alert)
  assert_true(
    config.task_type
    is @security_surveillance_advanced.SecuritySurveillanceTaskType::IntrusionDetection,
  )
}

///|
test "detect_people: returns person detections" {
  let config = @security_surveillance_advanced.create_default_security_config()
  let image : Array[Double] = []
  for _ in 0..<100000 {
    image.push(128.0)
  }
  let people = @security_surveillance_advanced.detect_people(
    image, 500, 500, config,
  )
  assert_eq(people.length(), 5)
  for p in people {
    assert_eq(p.bounding_box.length(), 4)
    assert_eq(p.face_embedding.length(), 128)
    assert_eq(p.body_embedding.length(), 128)
    assert_eq(p.velocity.length(), 2)
  }
}

///|
test "detect_intrusion: detects people in zone" {
  let config = @security_surveillance_advanced.create_default_security_config()
  let person = @security_surveillance_advanced.DetectedPerson::{
    person_id: 0,
    bounding_box: [100, 100, 200, 300],
    confidence: 0.9,
    face_embedding: [],
    body_embedding: [],
    velocity: [0.0, 0.0],
    trajectory: [],
    age_estimate: 30,
    gender_estimate: "unknown",
    is_known: false,
    identity: "unknown",
  }
  let events = @security_surveillance_advanced.detect_intrusion(
    [person],
    [0, 0, 500, 500],
    config,
  )
  assert_eq(events.length(), 1)
  assert_true(
    events[0].alert_level
    is @security_surveillance_advanced.AlertLevel::Critical,
  )
  assert_true(
    events[0].intrusion_type
    is @security_surveillance_advanced.IntrusionType::AreaEntry,
  )
}

///|
test "detect_intrusion: no people in zone" {
  let config = @security_surveillance_advanced.create_default_security_config()
  let person = @security_surveillance_advanced.DetectedPerson::{
    person_id: 0,
    bounding_box: [600, 600, 700, 800],
    confidence: 0.9,
    face_embedding: [],
    body_embedding: [],
    velocity: [0.0, 0.0],
    trajectory: [],
    age_estimate: 30,
    gender_estimate: "unknown",
    is_known: false,
    identity: "unknown",
  }
  let events = @security_surveillance_advanced.detect_intrusion(
    [person],
    [0, 0, 500, 500],
    config,
  )
  assert_eq(events.length(), 0)
}

///|
test "analyze_behavior: suspicious behavior for static person" {
  let config = @security_surveillance_advanced.create_default_security_config()
  let person = @security_surveillance_advanced.DetectedPerson::{
    person_id: 0,
    bounding_box: [100, 100, 200, 300],
    confidence: 0.9,
    face_embedding: [],
    body_embedding: [],
    velocity: [0.0, 0.0],
    trajectory: [],
    age_estimate: 30,
    gender_estimate: "unknown",
    is_known: false,
    identity: "unknown",
  }
  let result = @security_surveillance_advanced.analyze_behavior(person, config)
  assert_eq(result.person_id, 0)
  assert_true(result.is_suspicious)
  assert_true(result.risk_score > 0.5)
  assert_true(
    result.behavior_type
    is @security_surveillance_advanced.BehaviorType::Suspicious,
  )
}

///|
test "analyze_behavior: walking behavior" {
  let config = @security_surveillance_advanced.create_default_security_config()
  let person = @security_surveillance_advanced.DetectedPerson::{
    person_id: 1,
    bounding_box: [100, 100, 200, 300],
    confidence: 0.9,
    face_embedding: [],
    body_embedding: [],
    velocity: [1.5, 1.5],
    trajectory: [],
    age_estimate: 25,
    gender_estimate: "male",
    is_known: false,
    identity: "unknown",
  }
  let result = @security_surveillance_advanced.analyze_behavior(person, config)
  assert_false(result.is_suspicious)
  assert_true(
    result.behavior_type
    is @security_surveillance_advanced.BehaviorType::Walking,
  )
}

///|
test "analyze_crowd: analyzes crowd density" {
  let config = @security_surveillance_advanced.create_default_security_config()
  let people : Array[@security_surveillance_advanced.DetectedPerson] = []
  for i in 0..<10 {
    let p = @security_surveillance_advanced.DetectedPerson::{
      person_id: i,
      bounding_box: [i * 50, 0, i * 50 + 50, 200],
      confidence: 0.8,
      face_embedding: [],
      body_embedding: [],
      velocity: [0.0, 0.0],
      trajectory: [],
      age_estimate: 30,
      gender_estimate: "unknown",
      is_known: false,
      identity: "unknown",
    }
    people.push(p)
  }
  let result = @security_surveillance_advanced.analyze_crowd(
    people, 500, 500, config,
  )
  assert_eq(result.num_people, 10)
  assert_true(result.density > 0.0)
  assert_eq(result.crowd_direction.length(), 2)
}

///|
test "recognize_license_plate: returns plate result" {
  let config = @security_surveillance_advanced.create_default_security_config()
  let image : Array[Double] = []
  for _ in 0..<10000 {
    image.push(128.0)
  }
  let result = @security_surveillance_advanced.recognize_license_plate(
    image, 100, 100, config,
  )
  assert_eq(result.plate_number.length(), 7)
  assert_true(result.is_valid)
  assert_eq(result.bounding_box.length(), 4)
  assert_eq(result.vehicle_type, "sedan")
  assert_eq(result.plate_color, "blue")
}

///|
test "security_surveillance_report_to_string: contains task info" {
  let config = @security_surveillance_advanced.create_default_security_config()
  let report = @security_surveillance_advanced.security_surveillance_report_to_string(
    @security_surveillance_advanced.SecuritySurveillanceTaskType::BehaviorAnalysis,
    config,
    "Detected running",
  )
  assert_true(report.contains("安防监控高级报告"))
  assert_true(report.contains("行为分析"))
  assert_true(report.contains("Detected running"))
}
