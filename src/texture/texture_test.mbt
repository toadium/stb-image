///|
test "TextureFilterMode: 枚举值" {
  assert_true(@texture.NearestFilter is @texture.NearestFilter)
  assert_true(@texture.BilinearFilter is @texture.BilinearFilter)
  assert_true(@texture.TrilinearFilter is @texture.TrilinearFilter)
}

///|
test "TextureMappingMethod: 枚举值" {
  assert_true(@texture.PlanarMapping is @texture.PlanarMapping)
  assert_true(@texture.SphericalMapping is @texture.SphericalMapping)
  assert_true(@texture.CylindricalMapping is @texture.CylindricalMapping)
}

///|
test "TextureCoord: 构造与字段" {
  let coord : @texture.TextureCoord = { u: 0.5, v: 0.7, }
  assert_eq(coord.u, 0.5)
  assert_eq(coord.v, 0.7)
}

///|
test "TextureConfig: 构造与字段" {
  let config : @texture.TextureConfig = {
    mapping_method: @texture.SphericalMapping,
    filter_mode: @texture.NearestFilter,
    wrap_u: false,
    wrap_v: true,
  }
  assert_true(config.mapping_method is @texture.SphericalMapping)
  assert_true(config.filter_mode is @texture.NearestFilter)
  assert_eq(config.wrap_u, false)
  assert_eq(config.wrap_v, true)
}

///|
test "default_texture_config: 默认值" {
  let config = @texture.default_texture_config()
  assert_true(config.mapping_method is @texture.PlanarMapping)
  assert_true(config.filter_mode is @texture.BilinearFilter)
  assert_eq(config.wrap_u, true)
  assert_eq(config.wrap_v, true)
}

///|
test "create_texture: 创建纹理" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array([
      255, 0, 0, 0, 255, 0, 0, 0, 255, 255, 255, 0, 128, 128, 128, 64, 64, 64, 200,
      200, 200, 100, 100, 100, 50, 50, 50, 150, 150, 150, 75, 75, 75, 175, 175, 175,
      10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120,
    ]),
  }
  let config = @texture.default_texture_config()
  let tex = @texture.create_texture(img, config)
  assert_eq(tex.image.width, 4)
  assert_eq(tex.image.height, 4)
}

///|
test "nearest_sample: 最近邻采样" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 3,
    data: Bytes::from_array([255, 0, 0, 0, 255, 0, 0, 0, 255, 255, 255, 0]),
  }
  let config = @texture.default_texture_config()
  let tex = @texture.create_texture(img, config)
  let (r, g, b) = @texture.nearest_sample(tex, 0.0, 0.0)
  assert_eq(r, 255.0)
  assert_eq(g, 0.0)
  assert_eq(b, 0.0)
}

///|
test "bilinear_sample: 双线性采样" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([0, 100, 200, 255]),
  }
  let config = @texture.default_texture_config()
  let tex = @texture.create_texture(img, config)
  let (r, _, _) = @texture.bilinear_sample(tex, 0.25, 0.25)
  // 非中心采样应得到插值
  assert_true(r > 0.0)
  assert_true(r < 255.0)
}

///|
test "sample_texture: 各过滤模式" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([0, 100, 200, 255]),
  }
  let config = @texture.default_texture_config()
  let tex = @texture.create_texture(img, config)
  let (r, _, _) = @texture.sample_texture(tex, 0.25, 0.25)
  assert_true(r >= 0.0)
  assert_true(r <= 255.0)
}

///|
test "planar_mapping: 平面映射" {
  let coord = @texture.planar_mapping(0.0, 0.0, 0.0)
  assert_eq(coord.u, 0.5)
  assert_eq(coord.v, 0.5)
}

///|
test "spherical_mapping: 球面映射" {
  let coord = @texture.spherical_mapping(0.0, 0.0, 1.0)
  assert_true(coord.u >= 0.0)
  assert_true(coord.u <= 1.0)
  assert_true(coord.v >= 0.0)
  assert_true(coord.v <= 1.0)
}

///|
test "cylindrical_mapping: 柱面映射" {
  let coord = @texture.cylindrical_mapping(1.0, 0.0, 0.0)
  assert_true(coord.u >= 0.0)
  assert_true(coord.u <= 1.0)
}

///|
test "compute_uv_mapping: 各方法" {
  let vertices : Array[(Double, Double, Double)] = [
    (0.0, 0.0, 0.0),
    (1.0, 0.0, 0.0),
    (0.0, 1.0, 0.0),
  ]
  let uv = @texture.compute_uv_mapping(vertices, @texture.PlanarMapping)
  assert_eq(uv.length(), 3)
}

///|
test "bake_texture: 烘焙" {
  let vertices : Array[(Double, Double, Double)] = [
    (0.0, 0.0, 0.0),
    (1.0, 1.0, 0.0),
  ]
  let colors : Array[(Double, Double, Double)] = [
    (255.0, 0.0, 0.0),
    (0.0, 255.0, 0.0),
  ]
  let uv_coords : Array[@texture.TextureCoord] = [
    { u: 0.0, v: 0.0, },
    { u: 0.5, v: 0.5, },
  ]
  let img = @texture.bake_texture(vertices, colors, uv_coords, 4, 4)
  assert_eq(img.width, 4)
  assert_eq(img.height, 4)
  assert_eq(img.channels, 3)
}

///|
test "texture_pipeline: 完整流水线" {
  let vertices : Array[(Double, Double, Double)] = [
    (0.0, 0.0, 0.0),
    (1.0, 0.0, 0.0),
    (0.0, 1.0, 0.0),
  ]
  let colors : Array[(Double, Double, Double)] = [
    (255.0, 0.0, 0.0),
    (0.0, 255.0, 0.0),
    (0.0, 0.0, 255.0),
  ]
  let config = @texture.default_texture_config()
  let (uv, baked) = @texture.texture_pipeline(vertices, colors, config, 4, 4)
  assert_eq(uv.length(), 3)
  assert_eq(baked.width, 4)
  assert_eq(baked.height, 4)
}

///|
test "Texture2D: 构造与字段" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([128]),
  }
  let tex : @texture.Texture2D = {
    image: img,
    filter_mode: @texture.NearestFilter,
    wrap_u: false,
    wrap_v: false,
  }
  assert_eq(tex.image.width, 1)
  assert_true(tex.filter_mode is @texture.NearestFilter)
}
