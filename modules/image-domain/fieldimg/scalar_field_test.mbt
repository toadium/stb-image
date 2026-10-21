///|
test "@fieldimg.ScalarField::make: 有效构造" {
  let f = @fieldimg.ScalarField::make(2, 2, [0.0F, 1.0F, 2.0F, 3.0F])
  assert_eq(f.width, 2)
  assert_eq(f.height, 2)
  assert_eq(f.size(), 4)
}

///|
test "@fieldimg.ScalarField::make: 数据长度不匹配抛异常" {
  try {
    ignore(@fieldimg.ScalarField::make(2, 2, [0.0F, 1.0F]))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "@fieldimg.ScalarField::make: 尺寸为零抛异常" {
  try {
    ignore(@fieldimg.ScalarField::make(0, 2, []))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "@fieldimg.ScalarField::zeros: 全零场" {
  let f = @fieldimg.ScalarField::zeros(3, 2)
  assert_eq(f.width, 3)
  assert_eq(f.height, 2)
  for i in 0..<f.data.length() {
    assert_eq(f.data[i], 0.0F)
  }
}

///|
test "@fieldimg.ScalarField::constant: 常量场" {
  let f = @fieldimg.ScalarField::constant(2, 3, 0.5F)
  for i in 0..<f.data.length() {
    assert_eq(f.data[i], 0.5F)
  }
}

///|
test "@fieldimg.ScalarField::evaluate: 边界内取值" {
  let f = @fieldimg.ScalarField::make(3, 3, [
    0.0F, 1.0F, 2.0F, 3.0F, 4.0F, 5.0F, 6.0F, 7.0F, 8.0F,
  ])
  assert_eq(f.evaluate(0, 0), 0.0F)
  assert_eq(f.evaluate(1, 0), 1.0F)
  assert_eq(f.evaluate(2, 1), 5.0F)
  assert_eq(f.evaluate(0, 2), 6.0F)
}

///|
test "@fieldimg.ScalarField::evaluate: 边界外返回零" {
  let f = @fieldimg.ScalarField::make(2, 2, [1.0F, 2.0F, 3.0F, 4.0F])
  assert_eq(f.evaluate(-1, 0), 0.0F)
  assert_eq(f.evaluate(0, -1), 0.0F)
  assert_eq(f.evaluate(2, 0), 0.0F)
  assert_eq(f.evaluate(0, 2), 0.0F)
}

///|
test "@fieldimg.ScalarField::evaluate_clamped: 边界钳制" {
  let f = @fieldimg.ScalarField::make(2, 2, [1.0F, 2.0F, 3.0F, 4.0F])
  assert_eq(f.evaluate_clamped(-1, 0), 1.0F)
  assert_eq(f.evaluate_clamped(2, 0), 2.0F)
  assert_eq(f.evaluate_clamped(0, -1), 1.0F)
  assert_eq(f.evaluate_clamped(1, 2), 4.0F)
}

///|
test "@fieldimg.ScalarField::set: 设值" {
  let f = @fieldimg.ScalarField::zeros(2, 2)
  f.set(0, 0, 1.5F)
  f.set(1, 1, 2.5F)
  assert_eq(f.evaluate(0, 0), 1.5F)
  assert_eq(f.evaluate(1, 1), 2.5F)
  assert_eq(f.evaluate(0, 1), 0.0F)
}

///|
test "@fieldimg.ScalarField::set: 越界忽略" {
  let f = @fieldimg.ScalarField::zeros(2, 2)
  f.set(-1, 0, 1.0F)
  f.set(2, 0, 2.0F)
  assert_eq(f.evaluate(0, 0), 0.0F)
}

///|
test "@fieldimg.ScalarField::min_max_value: 最值" {
  let f = @fieldimg.ScalarField::make(2, 2, [3.0F, 1.0F, 4.0F, 2.0F])
  assert_eq(f.min_value(), 1.0F)
  assert_eq(f.max_value(), 4.0F)
}
