///|
test "@fieldimg.TensorField::make: 有效构造" {
  let f = @fieldimg.TensorField::make(1, 1, 2, 2, [1.0F, 0.0F, 0.0F, 1.0F])
  assert_eq(f.width, 1)
  assert_eq(f.height, 1)
  assert_eq(f.rows, 2)
  assert_eq(f.cols, 2)
}

///|
test "@fieldimg.TensorField::make: 数据长度不匹配抛异常" {
  try {
    ignore(@fieldimg.TensorField::make(1, 1, 2, 2, [1.0F, 0.0F]))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "@fieldimg.TensorField::zeros: 全零张量场" {
  let f = @fieldimg.TensorField::zeros(2, 2, 2, 2)
  for i in 0..<f.data.length() {
    assert_eq(f.data[i], 0.0F)
  }
}

///|
test "@fieldimg.TensorField::evaluate: 取元素" {
  let f = @fieldimg.TensorField::make(1, 1, 2, 2, [1.0F, 2.0F, 3.0F, 4.0F])
  assert_eq(f.evaluate(0, 0, 0, 0), 1.0F)
  assert_eq(f.evaluate(0, 0, 0, 1), 2.0F)
  assert_eq(f.evaluate(0, 0, 1, 0), 3.0F)
  assert_eq(f.evaluate(0, 0, 1, 1), 4.0F)
}

///|
test "@fieldimg.TensorField::set: 设元素" {
  let f = @fieldimg.TensorField::zeros(1, 1, 2, 2)
  f.set(0, 0, 0, 0, 1.5F)
  f.set(0, 0, 1, 1, 2.5F)
  assert_eq(f.evaluate(0, 0, 0, 0), 1.5F)
  assert_eq(f.evaluate(0, 0, 1, 1), 2.5F)
}

///|
test "@fieldimg.TensorField::structure_tensor: 由梯度场构建" {
  // 梯度 (Ix=1, Iy=0) → J = [[1, 0], [0, 0]]
  let grad = @fieldimg.VectorField::make(1, 1, 2, [1.0F, 0.0F])
  let st = @fieldimg.TensorField::structure_tensor(grad)
  assert_eq(st.evaluate(0, 0, 0, 0), 1.0F)
  assert_eq(st.evaluate(0, 0, 0, 1), 0.0F)
  assert_eq(st.evaluate(0, 0, 1, 0), 0.0F)
  assert_eq(st.evaluate(0, 0, 1, 1), 0.0F)
}

///|
test "@fieldimg.TensorField::structure_tensor: 非零梯度" {
  // 梯度 (Ix=3, Iy=4) → J = [[9, 12], [12, 16]]
  let grad = @fieldimg.VectorField::make(1, 1, 2, [3.0F, 4.0F])
  let st = @fieldimg.TensorField::structure_tensor(grad)
  assert_eq(st.evaluate(0, 0, 0, 0), 9.0F)
  assert_eq(st.evaluate(0, 0, 0, 1), 12.0F)
  assert_eq(st.evaluate(0, 0, 1, 0), 12.0F)
  assert_eq(st.evaluate(0, 0, 1, 1), 16.0F)
}

///|
test "@fieldimg.TensorField::structure_tensor: 维度非2抛异常" {
  let grad = @fieldimg.VectorField::make(1, 1, 3, [1.0F, 0.0F, 0.0F])
  try {
    ignore(@fieldimg.TensorField::structure_tensor(grad))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "@fieldimg.TensorField::eigenvalues_2x2: 对角矩阵" {
  // J = [[4, 0], [0, 2]] → λ1=4, λ2=2
  let st = @fieldimg.TensorField::make(1, 1, 2, 2, [4.0F, 0.0F, 0.0F, 2.0F])
  let eig = @fieldimg.TensorField::eigenvalues_2x2(st)
  assert_eq(eig.evaluate_component(0, 0, 0), 4.0F)
  assert_eq(eig.evaluate_component(0, 0, 1), 2.0F)
}

///|
test "@fieldimg.TensorField::eigenvalues_2x2: 单位矩阵" {
  // J = [[1, 0], [0, 1]] → λ1=1, λ2=1
  let st = @fieldimg.TensorField::make(1, 1, 2, 2, [1.0F, 0.0F, 0.0F, 1.0F])
  let eig = @fieldimg.TensorField::eigenvalues_2x2(st)
  assert_eq(eig.evaluate_component(0, 0, 0), 1.0F)
  assert_eq(eig.evaluate_component(0, 0, 1), 1.0F)
}

///|
test "@fieldimg.TensorField::eigenvalues_2x2: 结构张量特征值" {
  // J = [[9, 12], [12, 16]] → trace=25, det=0 → λ1=25, λ2=0
  let st = @fieldimg.TensorField::make(1, 1, 2, 2, [9.0F, 12.0F, 12.0F, 16.0F])
  let eig = @fieldimg.TensorField::eigenvalues_2x2(st)
  assert_eq(eig.evaluate_component(0, 0, 0), 25.0F)
  assert_eq(eig.evaluate_component(0, 0, 1), 0.0F)
}
