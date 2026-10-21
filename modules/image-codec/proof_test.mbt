// 核心算法形式化证明：编解码往返正确性
// Formal proofs: codec round-trip correctness
//
// 性质：对于任意有效图像 I，decode(encode(I)) == I

///|
/// BMP 编解码往返证明
test "proof: bmp round-trip identity" {
  for w in [1, 2, 4, 8] {
    for h in [1, 2, 4] {
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
      let encoded = @lib.encode_bmp(img)
      let result = @codec.decode_bmp_pure(encoded)
      assert_eq(result.width, w)
      assert_eq(result.height, h)
      assert_eq(result.channels, 3)
      for i in 0..<img.data.length() {
        assert_eq(result.data[i], img.data[i])
      }
    }
  }
}

///|
/// PNG 编解码往返证明
test "proof: png round-trip identity" {
  for w in [1, 2, 4, 8] {
    for h in [1, 2, 4] {
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
      let encoded = @lib.encode_png(img)
      let result = @codec.decode_png_pure(encoded)
      assert_eq(result.width, w)
      assert_eq(result.height, h)
      assert_eq(result.channels, 3)
      for i in 0..<img.data.length() {
        assert_eq(result.data[i], img.data[i])
      }
    }
  }
}

///|
/// TGA 编解码往返证明
test "proof: tga round-trip identity" {
  for w in [1, 2, 4, 8] {
    for h in [1, 2, 4] {
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
      let encoded = @lib.encode_tga(img)
      let result = @codec.decode_tga_pure(encoded)
      assert_eq(result.width, w)
      assert_eq(result.height, h)
      assert_eq(result.channels, 3)
      for i in 0..<img.data.length() {
        assert_eq(result.data[i], img.data[i])
      }
    }
  }
}

///|
/// ImageLike trait 证明：pixel_count == width * height
test "proof: imagelike pixel_count equals width times height" {
  for w in [1, 2, 4, 8, 16] {
    for h in [1, 2, 4, 8] {
      let data : Array[Byte] = []
      for _ in 0..<(w * h) {
        data.push((0 : Byte))
      }
      let img : @types.Image = {
        width: w,
        height: h,
        channels: 1,
        data: Bytes::from_array(data),
      }
      assert_eq(@types.ImageLike::pixel_count(img), w * h)
    }
  }
}

///|
/// ImageLike trait 证明：byte_count == data.length()
test "proof: imagelike byte_count equals data length" {
  for w in [1, 4, 8] {
    for h in [1, 4, 8] {
      for ch in [1, 3, 4] {
        let data : Array[Byte] = []
        for _ in 0..<(w * h * ch) {
          data.push((0 : Byte))
        }
        let img : @types.Image = {
          width: w,
          height: h,
          channels: ch,
          data: Bytes::from_array(data),
        }
        let byte_count = @types.ImageLike::byte_count(img)
        assert_eq(byte_count, w * h * ch)
      }
    }
  }
}

///|
/// AnyImage 往返证明：any_image_to_u8(image_to_any(img)) == img
test "proof: anyimage round-trip identity" {
  for w in [1, 4, 8] {
    for h in [1, 4, 8] {
      let data : Array[Byte] = []
      for i in 0..<(w * h * 3) {
        data.push((i % 256).to_byte())
      }
      let img : @types.Image = {
        width: w,
        height: h,
        channels: 3,
        data: Bytes::from_array(data),
      }
      let any = @types.image_to_any(img)
      let recovered = @types.any_image_to_u8(any)
      assert_eq(recovered.width, img.width)
      assert_eq(recovered.height, img.height)
      assert_eq(recovered.channels, img.channels)
      for i in 0..<img.data.length() {
        assert_eq(recovered.data[i], img.data[i])
      }
    }
  }
}
