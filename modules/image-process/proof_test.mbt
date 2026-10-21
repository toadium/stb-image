// 核心算法形式化证明：几何变换往返正确性
// Formal proofs: geometric transform round-trip correctness
//
// 性质：
// 1. rotate_90^4 == identity（旋转4次90度 = 恒等）
// 2. flip_horizontal^2 == identity（翻转2次 = 恒等）
// 3. flip_vertical^2 == identity

///|
/// 辅助函数：验证两个图像完全相等
fn images_equal(a : @types.Image, b : @types.Image) -> Bool {
  if a.width != b.width || a.height != b.height || a.channels != b.channels {
    return false
  }
  for i in 0..<a.data.length() {
    if a.data[i] != b.data[i] {
      return false
    }
  }
  true
}

///|
/// 旋转 90 度四次 = 恒等变换
/// rotate_90(rotate_90(rotate_90(rotate_90(img)))) == img
test "proof: rotate_90 four times is identity" {
  for w in [2, 4, 8] {
    for h in [2, 4, 8] {
      let data : Array[Byte] = []
      for y in 0..<h {
        for x in 0..<w {
          data.push(
            (x * 255 / w.clamp(min=1, max=255)).clamp(min=0, max=255).to_byte(),
          )
          data.push(
            (y * 255 / h.clamp(min=1, max=255)).clamp(min=0, max=255).to_byte(),
          )
          data.push(((x + y) * 16 % 256).to_byte())
        }
      }
      let img : @types.Image = {
        width: w,
        height: h,
        channels: 3,
        data: Bytes::from_array(data),
      }
      // 旋转 4 次
      let r1 = @transform.rotate_90(img)
      let r2 = @transform.rotate_90(r1)
      let r3 = @transform.rotate_90(r2)
      let r4 = @transform.rotate_90(r3)
      // 性质：旋转 4 次后应与原图一致
      assert_true(images_equal(img, r4))
    }
  }
}

///|
/// 水平翻转两次 = 恒等变换
/// flip_horizontal(flip_horizontal(img)) == img
test "proof: flip_horizontal twice is identity" {
  for w in [2, 4, 8] {
    for h in [2, 4, 8] {
      let data : Array[Byte] = []
      for y in 0..<h {
        for x in 0..<w {
          data.push(
            (x * 255 / w.clamp(min=1, max=255)).clamp(min=0, max=255).to_byte(),
          )
          data.push(
            (y * 255 / h.clamp(min=1, max=255)).clamp(min=0, max=255).to_byte(),
          )
          data.push(((x + y) * 16 % 256).to_byte())
        }
      }
      let img : @types.Image = {
        width: w,
        height: h,
        channels: 3,
        data: Bytes::from_array(data),
      }
      let f1 = @transform.flip_horizontal(img)
      let f2 = @transform.flip_horizontal(f1)
      assert_true(images_equal(img, f2))
    }
  }
}

///|
/// 垂直翻转两次 = 恒等变换
test "proof: flip_vertical twice is identity" {
  for w in [2, 4, 8] {
    for h in [2, 4, 8] {
      let data : Array[Byte] = []
      for y in 0..<h {
        for x in 0..<w {
          data.push(
            (x * 255 / w.clamp(min=1, max=255)).clamp(min=0, max=255).to_byte(),
          )
          data.push(
            (y * 255 / h.clamp(min=1, max=255)).clamp(min=0, max=255).to_byte(),
          )
          data.push(((x + y) * 16 % 256).to_byte())
        }
      }
      let img : @types.Image = {
        width: w,
        height: h,
        channels: 3,
        data: Bytes::from_array(data),
      }
      let f1 = @transform.flip_vertical(img)
      let f2 = @transform.flip_vertical(f1)
      assert_true(images_equal(img, f2))
    }
  }
}

///|
/// 旋转 180 度 = 旋转 90 度两次
/// rotate_180(img) == rotate_90(rotate_90(img))
test "proof: rotate_180 equals rotate_90 twice" {
  for w in [2, 4, 8] {
    for h in [2, 4, 6] {
      let data : Array[Byte] = []
      for y in 0..<h {
        for x in 0..<w {
          data.push(
            (x * 255 / w.clamp(min=1, max=255)).clamp(min=0, max=255).to_byte(),
          )
          data.push(
            (y * 255 / h.clamp(min=1, max=255)).clamp(min=0, max=255).to_byte(),
          )
          data.push(((x + y) * 16 % 256).to_byte())
        }
      }
      let img : @types.Image = {
        width: w,
        height: h,
        channels: 3,
        data: Bytes::from_array(data),
      }
      let r180 = @transform.rotate_180(img)
      let r90_twice = @transform.rotate_90(@transform.rotate_90(img))
      assert_true(images_equal(r180, r90_twice))
    }
  }
}
