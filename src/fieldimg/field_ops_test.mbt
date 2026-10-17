// 场算子测试：梯度、散度、旋度、拉普拉斯、积分、阈值、掩码、代数、等值、直方图。
// 包含关键数学恒等式属性测试。

///|
fn approx_eq(a : Float, b : Float, eps : Float) -> Bool {
  let diff = a - b
  let abs_diff = if diff < 0.0F { -diff } else { diff }
  abs_diff < eps
}

///|
test "@fieldimg.field_gradient: 常量场梯度为零" {
  let f = @fieldimg.ScalarField::constant(3, 3, 5.0F)
  let grad = @fieldimg.field_gradient(f)
  for i in 0..<grad.data.length() {
    assert_eq(grad.data[i], 0.0F)
  }
}

///|
test "@fieldimg.field_gradient: 线性场梯度为常数" {
  // f(x, y) = x，则 gx = 1, gy = 0
  let f = @fieldimg.ScalarField::make(3, 3, [
    0.0F, 1.0F, 2.0F, 0.0F, 1.0F, 2.0F, 0.0F, 1.0F, 2.0F,
  ])
  let grad = @fieldimg.field_gradient(f)
  // 内部点 (1, 1): gx = (f[2,1] - f[0,1]) / 2 = (2 - 0) / 2 = 1
  assert_eq(grad.evaluate_component(1, 1, 0), 1.0F)
  assert_eq(grad.evaluate_component(1, 1, 1), 0.0F)
}

///|
test "@fieldimg.field_gradient: y 线性场" {
  // f(x, y) = y，则 gx = 0, gy = 1
  let f = @fieldimg.ScalarField::make(3, 3, [
    0.0F, 0.0F, 0.0F, 1.0F, 1.0F, 1.0F, 2.0F, 2.0F, 2.0F,
  ])
  let grad = @fieldimg.field_gradient(f)
  assert_eq(grad.evaluate_component(1, 1, 0), 0.0F)
  assert_eq(grad.evaluate_component(1, 1, 1), 1.0F)
}

///|
test "@fieldimg.field_laplacian: 常量场拉普拉斯为零" {
  let f = @fieldimg.ScalarField::constant(3, 3, 7.0F)
  let lap = @fieldimg.field_laplacian(f)
  for i in 0..<lap.data.length() {
    assert_eq(lap.data[i], 0.0F)
  }
}

///|
test "@fieldimg.field_laplacian: 线性场拉普拉斯为零" {
  // f(x, y) = x，拉普拉斯 = 0
  let f = @fieldimg.ScalarField::make(3, 3, [
    0.0F, 1.0F, 2.0F, 0.0F, 1.0F, 2.0F, 0.0F, 1.0F, 2.0F,
  ])
  let lap = @fieldimg.field_laplacian(f)
  // 内部点拉普拉斯应为 0
  assert_true(approx_eq(lap.evaluate(1, 1), 0.0F, 0.000001F))
}

///|
test "@fieldimg.field_laplacian: 二次场拉普拉斯为常数" {
  // f(x, y) = x²，在离散网格上 lap = f[x+1] + f[x-1] - 2*f[x] = 2
  let f = @fieldimg.ScalarField::make(3, 1, [0.0F, 1.0F, 4.0F])
  let lap = @fieldimg.field_laplacian(f)
  // 内部点 (1, 0): lap = f[0] + f[2] - 2*f[1] = 0 + 4 - 2 = 2
  assert_eq(lap.evaluate(1, 0), 2.0F)
}

///|
test "@fieldimg.field_integrate: 全场求和" {
  let f = @fieldimg.ScalarField::make(2, 2, [1.0F, 2.0F, 3.0F, 4.0F])
  assert_eq(@fieldimg.field_integrate(f), 10.0F)
}

///|
test "@fieldimg.field_integrate: 常量场积分" {
  let f = @fieldimg.ScalarField::constant(3, 3, 2.0F)
  assert_eq(@fieldimg.field_integrate(f), 18.0F)
}

///|
test "@fieldimg.field_integrate_region: 区域积分" {
  let f = @fieldimg.ScalarField::make(3, 3, [
    1.0F, 2.0F, 3.0F, 4.0F, 5.0F, 6.0F, 7.0F, 8.0F, 9.0F,
  ])
  // 区域 [1, 3) × [0, 2) = {2, 3, 5, 6} = 16
  assert_eq(@fieldimg.field_integrate_region(f, 1, 0, 3, 2), 16.0F)
}

///|
test "@fieldimg.field_clamp: 钳制场值" {
  let f = @fieldimg.ScalarField::make(1, 3, [-1.0F, 0.5F, 2.0F])
  let clamped = @fieldimg.field_clamp(f, 0.0F, 1.0F)
  assert_eq(clamped.evaluate(0, 0), 0.0F)
  assert_eq(clamped.evaluate(0, 1), 0.5F)
  assert_eq(clamped.evaluate(0, 2), 1.0F)
}

///|
test "@fieldimg.field_mask: 阈值掩码" {
  let f = @fieldimg.ScalarField::make(1, 4, [0.1F, 0.5F, 0.8F, 1.0F])
  let mask = @fieldimg.field_mask(f, 0.5F)
  assert_eq(mask.evaluate(0, 0), 0.0F)
  assert_eq(mask.evaluate(0, 1), 1.0F)
  assert_eq(mask.evaluate(0, 2), 1.0F)
  assert_eq(mask.evaluate(0, 3), 1.0F)
}

///|
test "@fieldimg.field_add: 场加法" {
  let a = @fieldimg.ScalarField::make(1, 2, [1.0F, 2.0F])
  let b = @fieldimg.ScalarField::make(1, 2, [3.0F, 4.0F])
  let c = @fieldimg.field_add(a, b)
  assert_eq(c.evaluate(0, 0), 4.0F)
  assert_eq(c.evaluate(0, 1), 6.0F)
}

///|
test "@fieldimg.field_sub: 场减法" {
  let a = @fieldimg.ScalarField::make(1, 2, [5.0F, 7.0F])
  let b = @fieldimg.ScalarField::make(1, 2, [2.0F, 3.0F])
  let c = @fieldimg.field_sub(a, b)
  assert_eq(c.evaluate(0, 0), 3.0F)
  assert_eq(c.evaluate(0, 1), 4.0F)
}

///|
test "@fieldimg.field_mul_scalar: 标量乘法" {
  let f = @fieldimg.ScalarField::make(1, 2, [1.0F, 2.5F])
  let r = @fieldimg.field_mul_scalar(f, 4.0F)
  assert_eq(r.evaluate(0, 0), 4.0F)
  assert_eq(r.evaluate(0, 1), 10.0F)
}

///|
test "@fieldimg.field_mul: 逐元素乘法" {
  let a = @fieldimg.ScalarField::make(1, 2, [2.0F, 3.0F])
  let b = @fieldimg.ScalarField::make(1, 2, [4.0F, 5.0F])
  let c = @fieldimg.field_mul(a, b)
  assert_eq(c.evaluate(0, 0), 8.0F)
  assert_eq(c.evaluate(0, 1), 15.0F)
}

///|
test "@fieldimg.field_blend: 场混合" {
  let a = @fieldimg.ScalarField::make(1, 1, [0.0F])
  let b = @fieldimg.ScalarField::make(1, 1, [10.0F])
  let r = @fieldimg.field_blend(a, b, 0.3F)
  assert_true(approx_eq(r.evaluate(0, 0), 3.0F, 0.000001F))
}

///|
test "@fieldimg.field_blend: alpha=0 返回 a" {
  let a = @fieldimg.ScalarField::make(1, 1, [5.0F])
  let b = @fieldimg.ScalarField::make(1, 1, [10.0F])
  let r = @fieldimg.field_blend(a, b, 0.0F)
  assert_eq(r.evaluate(0, 0), 5.0F)
}

///|
test "@fieldimg.field_blend: alpha=1 返回 b" {
  let a = @fieldimg.ScalarField::make(1, 1, [5.0F])
  let b = @fieldimg.ScalarField::make(1, 1, [10.0F])
  let r = @fieldimg.field_blend(a, b, 1.0F)
  assert_eq(r.evaluate(0, 0), 10.0F)
}

///|
test "@fieldimg.field_isosurface: 等值线提取" {
  let f = @fieldimg.ScalarField::make(1, 4, [0.0F, 0.5F, 1.0F, 1.5F])
  // level=1.0, epsilon=0.01 → 只有 1.0 处标记
  let iso = @fieldimg.field_isosurface(f, 1.0F, 0.01F)
  assert_eq(iso.evaluate(0, 0), 0.0F)
  assert_eq(iso.evaluate(0, 1), 0.0F)
  assert_eq(iso.evaluate(0, 2), 1.0F)
  assert_eq(iso.evaluate(0, 3), 0.0F)
}

///|
test "@fieldimg.field_histogram: 直方图统计" {
  let f = @fieldimg.ScalarField::make(1, 4, [0.0F, 0.3F, 0.6F, 0.9F])
  // bins=3, range=[0, 1): [0, 0.33), [0.33, 0.66), [0.66, 1.0)
  // 0.0 → bin 0, 0.3 → bin 0, 0.6 → bin 1, 0.9 → bin 2
  let hist = @fieldimg.field_histogram(f, 0.0F, 1.0F, 3)
  assert_eq(hist[0], 2)
  assert_eq(hist[1], 1)
  assert_eq(hist[2], 1)
}

///|
test "@fieldimg.field_add: 尺寸不一致抛异常" {
  let a = @fieldimg.ScalarField::make(2, 2, [0.0F, 0.0F, 0.0F, 0.0F])
  let b = @fieldimg.ScalarField::make(1, 1, [0.0F])
  try {
    ignore(@fieldimg.field_add(a, b))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// === 属性测试：数学恒等式 ===

///|
test "property: curl(gradient) = 0（无旋场）" {
  // 任何标量场的梯度都是无旋的：curl(grad(f)) = 0
  let f = @fieldimg.ScalarField::make(4, 4, [
    0.0F, 1.0F, 3.0F, 6.0F, 1.0F, 2.0F, 5.0F, 8.0F, 3.0F, 4.0F, 7.0F, 10.0F, 6.0F,
    7.0F, 9.0F, 12.0F,
  ])
  let grad = @fieldimg.field_gradient(f)
  let c = @fieldimg.field_curl(grad)
  // 内部点旋度应接近 0
  for y in 1..<3 {
    for x in 1..<3 {
      assert_true(approx_eq(c.evaluate(x, y), 0.0F, 0.00001F))
    }
  }
}

///|
test "property: @fieldimg.field_sub(@fieldimg.field_add(a, b), b) = a（加法逆元）" {
  let a = @fieldimg.ScalarField::make(2, 2, [1.0F, 2.0F, 3.0F, 4.0F])
  let b = @fieldimg.ScalarField::make(2, 2, [0.5F, 1.5F, 2.5F, 3.5F])
  let sum = @fieldimg.field_add(a, b)
  let restored = @fieldimg.field_sub(sum, b)
  for i in 0..<4 {
    assert_true(approx_eq(restored.data[i], a.data[i], 0.000001F))
  }
}
