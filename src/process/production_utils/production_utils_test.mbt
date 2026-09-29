// v45.0.0 生产工具测试

///|
test "validate_image: 有效图像" {
  let img = make_test_image(4, 4)
  let result = validate_image(img)
  assert_eq(result.is_valid, true)
}

///|
test "validate_image: 无效图像" {
  let img = @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::make(10, b'\x00'),
  }
  let result = validate_image(img)
  assert_eq(result.is_valid, false)
}

///|
test "validate_image_or_raise: 有效图像不抛异常" {
  let img = make_test_image(4, 4)
  validate_image_or_raise(img) catch {
    _ => assert_true(false)
  }
  assert_true(true)
}

///|
test "validate_channels: 匹配通道" {
  let img = make_test_image(4, 4)
  let result = validate_channels(img, [1])
  assert_eq(result, true)
}

///|
test "validate_channels: 不匹配通道" {
  let img = make_test_image(4, 4)
  let result = validate_channels(img, [3])
  assert_eq(result, false)
}

///|
test "validate_channels_or_raise: 匹配通道不抛异常" {
  let img = make_test_image(4, 4)
  validate_channels_or_raise(img, [1], "test") catch {
    _ => assert_true(false)
  }
  assert_true(true)
}

///|
test "validate_range: 有效范围" {
  let result = validate_range(0.5, 0.0, 1.0, "test")
  assert_true(result is Ok(_))
}

///|
test "validate_range: 无效范围" {
  let result = validate_range(1.5, 0.0, 1.0, "test")
  assert_true(result is Err(_))
}

///|
test "validate_range_or_raise: 有效范围不抛异常" {
  validate_range_or_raise(0.5, 0.0, 1.0, "test") catch {
    _ => assert_true(false)
  }
  assert_true(true)
}

///|
test "validate_int_range: 有效范围" {
  let result = validate_int_range(5, 0, 10, "test")
  assert_true(result is Ok(_))
}

///|
test "validate_int_range: 无效范围" {
  let result = validate_int_range(15, 0, 10, "test")
  assert_true(result is Err(_))
}

///|
test "validate_int_range_or_raise: 有效范围不抛异常" {
  validate_int_range_or_raise(5, 0, 10, "test") catch {
    _ => assert_true(false)
  }
  assert_true(true)
}

///|
test "clamp_pixel_value: 基本测试" {
  assert_eq(clamp_pixel_value(128), 128)
  assert_eq(clamp_pixel_value(-1), 0)
  assert_eq(clamp_pixel_value(256), 255)
}

///|
test "clamp_pixel_value_double: 基本测试" {
  assert_eq(clamp_pixel_value_double(128.0), 128.0)
  assert_eq(clamp_pixel_value_double(-1.0), 0.0)
  assert_eq(clamp_pixel_value_double(256.0), 255.0)
}

///|
test "is_valid_index: 基本测试" {
  assert_eq(is_valid_index(5, 10), true)
  assert_eq(is_valid_index(-1, 10), false)
  assert_eq(is_valid_index(10, 10), false)
}

///|
test "is_valid_2d_index: 基本测试" {
  assert_eq(is_valid_2d_index(3, 3, 4, 4), true)
  assert_eq(is_valid_2d_index(4, 3, 4, 4), false)
  assert_eq(is_valid_2d_index(3, 4, 4, 4), false)
}

///|
test "create_performance_timer: 基本测试" {
  let timer = create_performance_timer("test_op")
  assert_eq(timer.operation_name, "test_op")
}

///|
test "create_memory_stats: 基本测试" {
  let stats = create_memory_stats()
  assert_true(stats.allocated_bytes >= 0)
}

///|
test "create_production_error: 基本测试" {
  let err = create_production_error(
    ProductionErrorCode::InvalidInput,
    "test error",
    "test_fn",
  )
  assert_true(err.code is ProductionErrorCode::InvalidInput)
  assert_eq(err.message, "test error")
}

///|
test "create_default_retry_config: 基本测试" {
  let config = create_default_retry_config()
  assert_true(config.max_retries > 0)
}

///|
test "calculate_retry_delay: 基本测试" {
  let config = create_default_retry_config()
  let delay = calculate_retry_delay(config, 1)
  assert_true(delay >= 0.0)
}

///|
test "validation_result_to_string: 基本测试" {
  let img = make_test_image(4, 4)
  let result = validate_image(img)
  let report = validation_result_to_string(result)
  assert_true(report.length() > 0)
}

///|
test "production_error_to_string: 基本测试" {
  let err = create_production_error(
    ProductionErrorCode::InvalidInput,
    "test error",
    "test_fn",
  )
  let report = production_error_to_string(err)
  assert_true(report.length() > 0)
}

///|
fn make_test_image(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = []
  for i in 0..<(w * h) {
    let v : Int = i % 256
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}
