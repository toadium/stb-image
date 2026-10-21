///|
test "@fieldimg.VectorField::make: 有效构造" {
  let f = @fieldimg.VectorField::make(2, 2, 2, [
    0.0F, 1.0F, 2.0F, 3.0F, 4.0F, 5.0F, 6.0F, 7.0F,
  ])
  assert_eq(f.width, 2)
  assert_eq(f.height, 2)
  assert_eq(f.dim, 2)
}

///|
test "@fieldimg.VectorField::make: 数据长度不匹配抛异常" {
  try {
    ignore(@fieldimg.VectorField::make(2, 2, 2, [0.0F, 1.0F]))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "@fieldimg.VectorField::zeros: 全零场" {
  let f = @fieldimg.VectorField::zeros(2, 2, 3)
  assert_eq(f.dim, 3)
  for i in 0..<f.data.length() {
    assert_eq(f.data[i], 0.0F)
  }
}

///|
test "@fieldimg.VectorField::evaluate_component: 取分量" {
  let f = @fieldimg.VectorField::make(2, 1, 3, [
    1.0F, 2.0F, 3.0F, 4.0F, 5.0F, 6.0F,
  ])
  assert_eq(f.evaluate_component(0, 0, 0), 1.0F)
  assert_eq(f.evaluate_component(0, 0, 1), 2.0F)
  assert_eq(f.evaluate_component(0, 0, 2), 3.0F)
  assert_eq(f.evaluate_component(1, 0, 0), 4.0F)
  assert_eq(f.evaluate_component(1, 0, 2), 6.0F)
}

///|
test "@fieldimg.VectorField::evaluate_component: 边界外返回零" {
  let f = @fieldimg.VectorField::make(2, 1, 2, [1.0F, 2.0F, 3.0F, 4.0F])
  assert_eq(f.evaluate_component(-1, 0, 0), 0.0F)
  assert_eq(f.evaluate_component(0, 0, 2), 0.0F)
}

///|
test "@fieldimg.VectorField::set_component: 设分量" {
  let f = @fieldimg.VectorField::zeros(2, 1, 2)
  f.set_component(0, 0, 0, 1.5F)
  f.set_component(1, 0, 1, 2.5F)
  assert_eq(f.evaluate_component(0, 0, 0), 1.5F)
  assert_eq(f.evaluate_component(1, 0, 1), 2.5F)
}

///|
test "@fieldimg.VectorField::magnitude: 矢量模长" {
  // 2D 矢量 (3, 4) 模长 = 5
  let f = @fieldimg.VectorField::make(1, 1, 2, [3.0F, 4.0F])
  let mag = f.magnitude()
  assert_eq(mag.evaluate(0, 0), 5.0F)
}

///|
test "@fieldimg.VectorField::magnitude: 零矢量模长为零" {
  let f = @fieldimg.VectorField::zeros(2, 2, 3)
  let mag = f.magnitude()
  for i in 0..<mag.data.length() {
    assert_eq(mag.data[i], 0.0F)
  }
}

///|
test "@fieldimg.VectorField::magnitude: 3D 矢量模长" {
  // 3D 矢量 (1, 2, 2) 模长 = 3
  let f = @fieldimg.VectorField::make(1, 1, 3, [1.0F, 2.0F, 2.0F])
  let mag = f.magnitude()
  assert_eq(mag.evaluate(0, 0), 3.0F)
}
