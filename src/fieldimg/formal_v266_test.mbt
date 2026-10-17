// v266.0.0 形式化验证 + FAKE + MOCK + E2E 多策略测试
// 对 ScalarField / VectorField / TensorField + 场算子 + Image双向转换
// approx_eq 定义在 field_ops_test.mbt 中，同包共享

// ============================================================
// FAKE: 结构化假场生成器
// ============================================================

///|
fn v266_fake_constant(
  w : Int,
  h : Int,
  val : Float,
) -> @fieldimg.ScalarField raise @types.LoadError {
  @fieldimg.ScalarField::constant(w, h, val)
}

///|
fn v266_fake_linear(
  w : Int,
  h : Int,
) -> @fieldimg.ScalarField raise @types.LoadError {
  let data : Array[Float] = []
  for y in 0..<h {
    for x in 0..<w {
      data.push(Float::from_int(x + y))
    }
  }
  @fieldimg.ScalarField::make(w, h, data)
}

///|
fn v266_fake_quadratic(
  w : Int,
  h : Int,
) -> @fieldimg.ScalarField raise @types.LoadError {
  let data : Array[Float] = []
  for y in 0..<h {
    for x in 0..<w {
      let xf = Float::from_int(x)
      let yf = Float::from_int(y)
      data.push(xf * xf + yf * yf)
    }
  }
  @fieldimg.ScalarField::make(w, h, data)
}

///|
fn v266_lcg(seed : Int) -> () -> Int {
  let mut state = seed
  () => {
    state = (state * 1103515245 + 12345) & 0x7FFFFFFF
    state
  }
}

///|
fn v266_fake_random_scalar(
  seed : Int,
  w : Int,
  h : Int,
) -> @fieldimg.ScalarField raise @types.LoadError {
  let rng = v266_lcg(seed)
  let data : Array[Float] = []
  for _ in 0..<(w * h) {
    data.push(Float::from_int(rng() % 1000) / 100.0F)
  }
  @fieldimg.ScalarField::make(w, h, data)
}

///|
fn v266_fake_random_vector(
  seed : Int,
  w : Int,
  h : Int,
  dim : Int,
) -> @fieldimg.VectorField raise @types.LoadError {
  let rng = v266_lcg(seed)
  let data : Array[Float] = []
  for _ in 0..<(w * h * dim) {
    data.push(Float::from_int(rng() % 1000) / 100.0F)
  }
  @fieldimg.VectorField::make(w, h, dim, data)
}

///|
fn v266_fake_gray_image(w : Int, h : Int, val : Int) -> @types.Image {
  {
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, val.to_byte())),
  }
}

///|
fn v266_fake_rgb_image(
  w : Int,
  h : Int,
  r : Int,
  g : Int,
  b : Int,
) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(w * h) {
    data.push(r.to_byte())
    data.push(g.to_byte())
    data.push(b.to_byte())
  }
  { width: w, height: h, channels: 3, data: Bytes::from_array(data), }
}

///|
fn v266_scalar_eq(
  a : @fieldimg.ScalarField,
  b : @fieldimg.ScalarField,
  eps : Float,
) -> Bool {
  if a.width != b.width || a.height != b.height {
    return false
  }
  for i in 0..<a.data.length() {
    if !approx_eq(a.data[i], b.data[i], eps) {
      return false
    }
  }
  true
}

// ============================================================
// 形式化证明: 数学恒等式（多 seed 随机验证）
// ============================================================

///|
test "v266 formal: curl(gradient) = 0 for random fields (irrotational)" {
  for seed in 1..<=10 {
    let f = v266_fake_random_scalar(seed, 6, 6)
    let grad = @fieldimg.field_gradient(f)
    let c = @fieldimg.field_curl(grad)
    // 内部点 (x in [2,3], y in [2,3]) 旋度应接近 0
    for y in 2..<4 {
      for x in 2..<4 {
        assert_true(approx_eq(c.evaluate(x, y), 0.0F, 0.01F))
      }
    }
  }
}

///|
test "v266 formal: div(grad(f)) = laplacian(f) for quadratic fields" {
  // 二次场 f=x²+y²，两种离散化在内部点都精确等于 4
  let f = v266_fake_quadratic(7, 7)
  let grad = @fieldimg.field_gradient(f)
  let div_grad = @fieldimg.field_divergence(grad)
  let lap = @fieldimg.field_laplacian(f)
  // 内部点 x in [2,4], y in [2,4]
  for y in 2..<5 {
    for x in 2..<5 {
      assert_true(
        approx_eq(div_grad.evaluate(x, y), lap.evaluate(x, y), 0.001F),
      )
    }
  }
}

///|
test "v266 formal: field_sub(field_add(a,b),b) = a (additive inverse)" {
  for seed in 1..<=10 {
    let a = v266_fake_random_scalar(seed, 4, 4)
    let b = v266_fake_random_scalar(seed + 100, 4, 4)
    let sum = @fieldimg.field_add(a, b)
    let restored = @fieldimg.field_sub(sum, b)
    assert_true(v266_scalar_eq(restored, a, 0.0001F))
  }
}

///|
test "v266 formal: field_add(a,b) = field_add(b,a) (commutativity)" {
  for seed in 1..<=10 {
    let a = v266_fake_random_scalar(seed, 3, 3)
    let b = v266_fake_random_scalar(seed + 50, 3, 3)
    let ab = @fieldimg.field_add(a, b)
    let ba = @fieldimg.field_add(b, a)
    assert_true(v266_scalar_eq(ab, ba, 0.0001F))
  }
}

///|
test "v266 formal: field_mul(a,b) = field_mul(b,a) (commutativity)" {
  for seed in 1..<=10 {
    let a = v266_fake_random_scalar(seed, 3, 3)
    let b = v266_fake_random_scalar(seed + 50, 3, 3)
    let ab = @fieldimg.field_mul(a, b)
    let ba = @fieldimg.field_mul(b, a)
    assert_true(v266_scalar_eq(ab, ba, 0.0001F))
  }
}

///|
test "v266 formal: field_blend(a,b,0) = a (boundary)" {
  for seed in 1..<=5 {
    let a = v266_fake_random_scalar(seed, 3, 3)
    let b = v266_fake_random_scalar(seed + 50, 3, 3)
    let r = @fieldimg.field_blend(a, b, 0.0F)
    assert_true(v266_scalar_eq(r, a, 0.0001F))
  }
}

///|
test "v266 formal: field_blend(a,b,1) = b (boundary)" {
  for seed in 1..<=5 {
    let a = v266_fake_random_scalar(seed, 3, 3)
    let b = v266_fake_random_scalar(seed + 50, 3, 3)
    let r = @fieldimg.field_blend(a, b, 1.0F)
    assert_true(v266_scalar_eq(r, b, 0.0001F))
  }
}

///|
test "v266 formal: field_clamp is idempotent (clamp∘clamp = clamp)" {
  for seed in 1..<=5 {
    let f = v266_fake_random_scalar(seed, 4, 4)
    let c1 = @fieldimg.field_clamp(f, 2.0F, 8.0F)
    let c2 = @fieldimg.field_clamp(c1, 2.0F, 8.0F)
    assert_true(v266_scalar_eq(c1, c2, 0.0001F))
  }
}

///|
test "v266 formal: field_mask output is binary (only 0.0 or 1.0)" {
  for seed in 1..<=10 {
    let f = v266_fake_random_scalar(seed, 4, 4)
    let mask = @fieldimg.field_mask(f, 5.0F)
    for i in 0..<mask.data.length() {
      let v = mask.data[i]
      assert_true(v == 0.0F || v == 1.0F)
    }
  }
}

///|
test "v266 formal: field_mul_scalar(f, 0) = zeros" {
  for seed in 1..<=5 {
    let f = v266_fake_random_scalar(seed, 3, 3)
    let z = @fieldimg.field_mul_scalar(f, 0.0F)
    for i in 0..<z.data.length() {
      assert_eq(z.data[i], 0.0F)
    }
  }
}

///|
test "v266 formal: field_mul_scalar(f, 1) = f (identity)" {
  for seed in 1..<=5 {
    let f = v266_fake_random_scalar(seed, 3, 3)
    let r = @fieldimg.field_mul_scalar(f, 1.0F)
    assert_true(v266_scalar_eq(r, f, 0.0001F))
  }
}

///|
test "v266 formal: structure_tensor is symmetric (J[0,1] = J[1,0])" {
  for seed in 1..<=5 {
    let f = v266_fake_random_scalar(seed, 4, 4)
    let grad = @fieldimg.field_gradient(f)
    let st = @fieldimg.TensorField::structure_tensor(grad)
    for y in 0..<4 {
      for x in 0..<4 {
        let j01 = st.evaluate(x, y, 0, 1)
        let j10 = st.evaluate(x, y, 1, 0)
        assert_true(approx_eq(j01, j10, 0.0001F))
      }
    }
  }
}

///|
test "v266 formal: eigenvalues_2x2 gives λ1 >= λ2" {
  for seed in 1..<=5 {
    let f = v266_fake_random_scalar(seed, 4, 4)
    let grad = @fieldimg.field_gradient(f)
    let st = @fieldimg.TensorField::structure_tensor(grad)
    let eig = @fieldimg.TensorField::eigenvalues_2x2(st)
    for y in 0..<4 {
      for x in 0..<4 {
        let l1 = eig.evaluate_component(x, y, 0)
        let l2 = eig.evaluate_component(x, y, 1)
        assert_true(l1 >= l2)
      }
    }
  }
}

// ============================================================
// 形式化证明: 维度保持属性
// ============================================================

///|
test "v266 formal: field_gradient preserves dimensions (dim=2)" {
  for seed in 1..<=5 {
    let f = v266_fake_random_scalar(seed, 5, 7)
    let grad = @fieldimg.field_gradient(f)
    assert_eq(grad.width, 5)
    assert_eq(grad.height, 7)
    assert_eq(grad.dim, 2)
  }
}

///|
test "v266 formal: field_laplacian preserves dimensions" {
  for seed in 1..<=5 {
    let f = v266_fake_random_scalar(seed, 5, 7)
    let lap = @fieldimg.field_laplacian(f)
    assert_eq(lap.width, 5)
    assert_eq(lap.height, 7)
  }
}

///|
test "v266 formal: field_divergence preserves dimensions" {
  for seed in 1..<=5 {
    let v = v266_fake_random_vector(seed, 5, 7, 2)
    let div = @fieldimg.field_divergence(v)
    assert_eq(div.width, 5)
    assert_eq(div.height, 7)
  }
}

///|
test "v266 formal: field_curl preserves dimensions" {
  for seed in 1..<=5 {
    let v = v266_fake_random_vector(seed, 5, 7, 2)
    let c = @fieldimg.field_curl(v)
    assert_eq(c.width, 5)
    assert_eq(c.height, 7)
  }
}

///|
test "v266 formal: VectorField::magnitude returns ScalarField of same size" {
  for seed in 1..<=5 {
    let v = v266_fake_random_vector(seed, 5, 7, 3)
    let m = v.magnitude()
    assert_eq(m.width, 5)
    assert_eq(m.height, 7)
  }
}

// ============================================================
// 形式化证明: FAKE 生成器属性
// ============================================================

///|
test "v266 fake: constant field has uniform values" {
  let f = v266_fake_constant(4, 4, 3.14F)
  for i in 0..<f.data.length() {
    assert_eq(f.data[i], 3.14F)
  }
}

///|
test "v266 fake: linear field f(x,y) = x+y has correct values" {
  let f = v266_fake_linear(3, 3)
  assert_eq(f.evaluate(0, 0), 0.0F)
  assert_eq(f.evaluate(1, 0), 1.0F)
  assert_eq(f.evaluate(0, 1), 1.0F)
  assert_eq(f.evaluate(2, 2), 4.0F)
}

///|
test "v266 fake: quadratic field f(x,y) = x²+y² has correct values" {
  let f = v266_fake_quadratic(3, 3)
  assert_eq(f.evaluate(0, 0), 0.0F)
  assert_eq(f.evaluate(1, 0), 1.0F)
  assert_eq(f.evaluate(0, 1), 1.0F)
  assert_eq(f.evaluate(2, 2), 8.0F)
}

///|
test "v266 fake: zeros field has all zero values" {
  let f = @fieldimg.ScalarField::zeros(4, 4)
  for i in 0..<f.data.length() {
    assert_eq(f.data[i], 0.0F)
  }
}

// ============================================================
// MOCK: 错误分派与边界条件模拟
// ============================================================

///|
test "v266 mock: ScalarField::make rejects mismatched data length" {
  try {
    ignore(@fieldimg.ScalarField::make(2, 2, [1.0F, 2.0F, 3.0F]))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v266 mock: ScalarField::make rejects zero dimensions" {
  try {
    ignore(@fieldimg.ScalarField::make(0, 2, []))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v266 mock: VectorField::make rejects mismatched data length" {
  try {
    ignore(@fieldimg.VectorField::make(2, 2, 2, [1.0F, 2.0F, 3.0F]))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v266 mock: field_divergence rejects dim != 2" {
  let v = v266_fake_random_vector(42, 3, 3, 3)
  try {
    ignore(@fieldimg.field_divergence(v))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v266 mock: image_to_scalar_field rejects zero-size image" {
  let img : @types.Image = {
    width: 0,
    height: 1,
    channels: 1,
    data: Bytes::from_array([]),
  }
  try {
    ignore(@fieldimg.image_to_scalar_field(img))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v266 mock: structure_tensor rejects non-2D gradient" {
  let v = v266_fake_random_vector(42, 3, 3, 3)
  try {
    ignore(@fieldimg.TensorField::structure_tensor(v))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ============================================================
// E2E: 端到端全流水线测试
// ============================================================

///|
test "v266 e2e: Image→ScalarField→gradient→magnitude→Image (edge detection)" {
  let img = v266_fake_gray_image(8, 8, 128)
  let sf = @fieldimg.image_to_scalar_field(img)
  let grad = @fieldimg.field_gradient(sf)
  let mag = grad.magnitude()
  let result = @fieldimg.scalar_field_to_image(mag)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
  assert_eq(result.channels, 1)
}

///|
test "v266 e2e: Image→ScalarField→laplacian→clamp→mask→Image (sharpen+threshold)" {
  let img = v266_fake_gray_image(8, 8, 100)
  let sf = @fieldimg.image_to_scalar_field(img)
  let lap = @fieldimg.field_laplacian(sf)
  let clamped = @fieldimg.field_clamp(lap, 0.0F, 1.0F)
  let mask = @fieldimg.field_mask(clamped, 0.5F)
  let result = @fieldimg.scalar_field_to_image(mask)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
  assert_eq(result.channels, 1)
}

///|
test "v266 e2e: Image→VectorField→magnitude→ScalarField→gradient→Image (multi-stage)" {
  let img = v266_fake_rgb_image(6, 6, 200, 100, 50)
  let vf = @fieldimg.image_to_vector_field(img)
  let mag = vf.magnitude()
  let grad = @fieldimg.field_gradient(mag)
  let result = @fieldimg.scalar_field_to_image(grad.magnitude())
  assert_eq(result.width, 6)
  assert_eq(result.height, 6)
}

///|
test "v266 e2e: random→add→sub→verify identity (algebraic pipeline)" {
  let a = v266_fake_random_scalar(7, 5, 5)
  let b = v266_fake_random_scalar(99, 5, 5)
  let sum = @fieldimg.field_add(a, b)
  let restored = @fieldimg.field_sub(sum, b)
  assert_true(v266_scalar_eq(restored, a, 0.0001F))
}

///|
test "v266 e2e: gradient→structure_tensor→eigenvalues→magnitude (corner detection)" {
  let f = v266_fake_random_scalar(42, 6, 6)
  let grad = @fieldimg.field_gradient(f)
  let st = @fieldimg.TensorField::structure_tensor(grad)
  let eig = @fieldimg.TensorField::eigenvalues_2x2(st)
  let mag = eig.magnitude()
  let result = @fieldimg.scalar_field_to_image(mag)
  assert_eq(result.width, 6)
  assert_eq(result.height, 6)
}

///|
test "v266 e2e: Image→ScalarField→clamp→blend→Image (blend pipeline)" {
  let img1 = v266_fake_gray_image(4, 4, 50)
  let img2 = v266_fake_gray_image(4, 4, 200)
  let sf1 = @fieldimg.image_to_scalar_field(img1)
  let sf2 = @fieldimg.image_to_scalar_field(img2)
  let c1 = @fieldimg.field_clamp(sf1, 0.0F, 1.0F)
  let c2 = @fieldimg.field_clamp(sf2, 0.0F, 1.0F)
  let blended = @fieldimg.field_blend(c1, c2, 0.5F)
  let result = @fieldimg.scalar_field_to_image(blended)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "v266 e2e: gray image round-trip through scalar field" {
  for val in [0, 64, 128, 192, 255] {
    let img = v266_fake_gray_image(4, 4, val)
    let sf = @fieldimg.image_to_scalar_field(img)
    let restored = @fieldimg.scalar_field_to_image(sf)
    for i in 0..<restored.data.length() {
      assert_eq(restored.data[i], img.data[i])
    }
  }
}

///|
test "v266 e2e: RGB image round-trip through vector field" {
  let img = v266_fake_rgb_image(3, 3, 100, 150, 200)
  let vf = @fieldimg.image_to_vector_field(img)
  let restored = @fieldimg.vector_field_to_image(vf)
  assert_eq(restored.width, 3)
  assert_eq(restored.height, 3)
  assert_eq(restored.channels, 3)
  for i in 0..<restored.data.length() {
    assert_eq(restored.data[i], img.data[i])
  }
}

///|
test "v266 e2e: histogram total count equals field size" {
  let f = v266_fake_random_scalar(42, 4, 4)
  let hist = @fieldimg.field_histogram(f, 0.0F, 10.0F, 10)
  let mut total = 0
  for i in 0..<hist.length() {
    total = total + hist[i]
  }
  // 所有值都在 [0, 10) 范围内（因为 rng%1000/100 ∈ [0, 9.99]）
  assert_eq(total, f.width * f.height)
}
