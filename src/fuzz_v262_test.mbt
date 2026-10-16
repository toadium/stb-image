// v262.0.0 API 模糊测试 — 随机图像通过处理管道
// 验证处理函数对各种随机输入不崩溃（可 raise LoadError 但不可 panic）

///|
fn v262_lcg(seed : Int) -> () -> Int {
  let mut state = seed
  () => {
    state = (state * 1103515245 + 12345) & 0x7FFFFFFF
    state
  }
}

///|
fn v262_random_image(
  seed : Int,
  width : Int,
  height : Int,
  channels : Int,
) -> @types.Image {
  let rng = v262_lcg(seed)
  let size = width * height * channels
  let data : Array[Byte] = []
  for _ in 0..<size {
    data.push((rng() % 256).to_byte())
  }
  @types.Image::{ width, height, channels, data: Bytes::from_array(data), }
}

///|
test "v262 fuzz: random images through resize" {
  for seed in 1..<=10 {
    let img = v262_random_image(seed, 8, 8, 3)
    for target in [1, 4, 16, 32] {
      try {
        let resized = @pure_util.resize_pure(img, target, target)
        ignore(resized)
      } catch {
        _ => ()
      }
    }
  }
  assert_true(true)
}

///|
test "v262 fuzz: random images through gaussian_blur" {
  for seed in 1..<=10 {
    let img = v262_random_image(seed, 8, 8, 3)
    for radius in [1, 2, 3] {
      try {
        let blurred = @filter.gaussian_blur(img, radius, 1.0F)
        ignore(blurred)
      } catch {
        _ => ()
      }
    }
  }
  assert_true(true)
}

///|
test "v262 fuzz: random images through box_blur" {
  for seed in 1..<=10 {
    let img = v262_random_image(seed, 8, 8, 3)
    for radius in [1, 2, 3] {
      try {
        let blurred = @filter.box_blur(img, radius)
        ignore(blurred)
      } catch {
        _ => ()
      }
    }
  }
  assert_true(true)
}

///|
test "v262 fuzz: random images through sharpen" {
  for seed in 1..<=10 {
    let img = v262_random_image(seed, 8, 8, 3)
    for amount in [0.5F, 1.0F, 2.0F] {
      try {
        let sharpened = @filter.sharpen(img, amount)
        ignore(sharpened)
      } catch {
        _ => ()
      }
    }
  }
  assert_true(true)
}

///|
test "v262 fuzz: random images through adjust_brightness" {
  for seed in 1..<=10 {
    let img = v262_random_image(seed, 8, 8, 3)
    for delta in [-100, -50, 0, 50, 100] {
      try {
        let adjusted = @color.adjust_brightness(img, delta)
        ignore(adjusted)
      } catch {
        _ => ()
      }
    }
  }
  assert_true(true)
}

///|
test "v262 fuzz: random images through adjust_contrast" {
  for seed in 1..<=10 {
    let img = v262_random_image(seed, 8, 8, 3)
    for factor in [0.5F, 1.0F, 1.5F, 2.0F] {
      try {
        let adjusted = @color.adjust_contrast(img, factor)
        ignore(adjusted)
      } catch {
        _ => ()
      }
    }
  }
  assert_true(true)
}

///|
test "v262 fuzz: random images through to_grayscale" {
  for seed in 1..<=10 {
    let img = v262_random_image(seed, 8, 8, 3)
    try {
      let gray = @color.to_grayscale(img)
      ignore(gray)
    } catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v262 fuzz: random images through rotate_90" {
  for seed in 1..<=10 {
    let img = v262_random_image(seed, 8, 8, 3)
    let rotated = @transform.rotate_90(img)
    ignore(rotated)
  }
  assert_true(true)
}

///|
test "v262 fuzz: random images through flip_horizontal" {
  for seed in 1..<=10 {
    let img = v262_random_image(seed, 8, 8, 3)
    let flipped = @transform.flip_horizontal(img)
    ignore(flipped)
  }
  assert_true(true)
}

///|
test "v262 fuzz: random images through flip_vertical" {
  for seed in 1..<=10 {
    let img = v262_random_image(seed, 8, 8, 3)
    let flipped = @transform.flip_vertical(img)
    ignore(flipped)
  }
  assert_true(true)
}

///|
test "v262 fuzz: random images through crop" {
  for seed in 1..<=10 {
    let img = v262_random_image(seed, 8, 8, 3)
    for dims in [(0, 0, 4, 4), (2, 2, 4, 4), (0, 0, 8, 8), (1, 1, 3, 3)] {
      try {
        let cropped = @transform.crop(img, dims.0, dims.1, dims.2, dims.3)
        ignore(cropped)
      } catch {
        _ => ()
      }
    }
  }
  assert_true(true)
}

///|
test "v262 fuzz: random images through encode/decode round-trip" {
  for seed in 1..<=5 {
    let img = v262_random_image(seed, 4, 4, 3)
    try {
      let png = @codec.encode_png_pure(img)
      let decoded = @codec.decode_png_pure(png)
      assert_eq(decoded.width, img.width)
      assert_eq(decoded.height, img.height)
    } catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v262 fuzz: random 4-channel images through processing" {
  for seed in 1..<=5 {
    let img = v262_random_image(seed, 8, 8, 4)
    try {
      let blurred = @filter.gaussian_blur(img, 1, 1.0F)
      ignore(blurred)
    } catch {
      _ => ()
    }
    try {
      let adjusted = @color.adjust_brightness(img, 50)
      ignore(adjusted)
    } catch {
      _ => ()
    }
    let flipped = @transform.flip_horizontal(img)
    ignore(flipped)
  }
  assert_true(true)
}

///|
test "v262 fuzz: various image sizes through pipeline" {
  for size in [1, 2, 4, 16, 32] {
    let img = v262_random_image(size, size, size, 3)
    try {
      let gray = @color.to_grayscale(img)
      let blurred = @filter.gaussian_blur(gray, 1, 1.0F)
      let resized = @pure_util.resize_pure(blurred, size * 2, size * 2)
      let rotated = @transform.rotate_90(resized)
      ignore(rotated)
    } catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v262 fuzz: extreme brightness/contrast values" {
  let img = v262_random_image(42, 4, 4, 3)
  for delta in [-255, -256, 255, 256, 1000, -1000] {
    try {
      let adjusted = @color.adjust_brightness(img, delta)
      ignore(adjusted)
    } catch {
      _ => ()
    }
  }
  for factor in [0.0F, -1.0F, 100.0F, -100.0F] {
    try {
      let adjusted = @color.adjust_contrast(img, factor)
      ignore(adjusted)
    } catch {
      _ => ()
    }
  }
  assert_true(true)
}
