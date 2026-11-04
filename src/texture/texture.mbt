// 纹理映射 — UV/烘焙/采样
// Texture mapping: UV / baking / sampling
//
// Phase 18 v408: 3D视觉与渲染大扩展 — 纹理映射。

///|
/// 纹理过滤模式。
/// Texture filter mode.
pub(all) enum TextureFilterMode {
  NearestFilter // 最近邻
  BilinearFilter // 双线性
  TrilinearFilter // 三线性（简化为双线性）
} derive(Eq, @debug.Debug)

///|
pub extend TextureFilterMode with @debug.Debug::{to_repr}

///|
pub extend TextureFilterMode with Eq::{not_equal, equal}

///|
/// 纹理映射方法。
/// Texture mapping method.
pub(all) enum TextureMappingMethod {
  PlanarMapping // 平面映射
  SphericalMapping // 球面映射
  CylindricalMapping // 柱面映射
} derive(Eq, @debug.Debug)

///|
pub extend TextureMappingMethod with @debug.Debug::{to_repr}

///|
pub extend TextureMappingMethod with Eq::{not_equal, equal}

///|
/// 纹理坐标。
/// Texture coordinate.
pub(all) struct TextureCoord {
  u : Double
  v : Double
} derive(Eq, @debug.Debug)

///|
pub extend TextureCoord with @debug.Debug::{to_repr}

///|
pub extend TextureCoord with Eq::{not_equal, equal}

///|
/// 2D纹理。
/// 2D texture.
pub(all) struct Texture2D {
  image : @types.Image
  filter_mode : TextureFilterMode
  wrap_u : Bool // U方向是否循环
  wrap_v : Bool // V方向是否循环
} derive(Eq, @debug.Debug)

///|
pub extend Texture2D with @debug.Debug::{to_repr}

///|
pub extend Texture2D with Eq::{not_equal, equal}

///|
/// 纹理配置。
/// Texture configuration.
pub(all) struct TextureConfig {
  mapping_method : TextureMappingMethod
  filter_mode : TextureFilterMode
  wrap_u : Bool
  wrap_v : Bool
} derive(Eq, @debug.Debug)

///|
pub extend TextureConfig with @debug.Debug::{to_repr}

///|
pub extend TextureConfig with Eq::{not_equal, equal}

///|
/// 默认纹理配置。
/// Default texture configuration.
pub fn default_texture_config() -> TextureConfig {
  {
    mapping_method: PlanarMapping,
    filter_mode: BilinearFilter,
    wrap_u: true,
    wrap_v: true,
  }
}

///|
/// 从图像创建纹理。
/// Create texture from image.
pub fn create_texture(img : @types.Image, config : TextureConfig) -> Texture2D {
  {
    image: img,
    filter_mode: config.filter_mode,
    wrap_u: config.wrap_u,
    wrap_v: config.wrap_v,
  }
}

///|
/// 包装坐标：处理超出[0,1)范围的坐标。
/// Wrap coordinate: handle coordinates outside [0,1).
fn wrap_coord(coord : Double, wrap : Bool) -> Double {
  if wrap {
    let c = coord % 1.0
    if c < 0.0 {
      c + 1.0
    } else {
      c
    }
  } else {
    coord.clamp(min=0.0, max=0.9999)
  }
}

///|
/// 最近邻采样。
/// Nearest neighbor sampling.
pub fn nearest_sample(
  tex : Texture2D,
  u : Double,
  v : Double,
) -> (Double, Double, Double) {
  let w = tex.image.width
  let h = tex.image.height
  let ch = tex.image.channels
  let uu = wrap_coord(u, tex.wrap_u)
  let vv = wrap_coord(v, tex.wrap_v)
  let x = (uu * w.to_double()).to_int().clamp(min=0, max=w - 1)
  let y = (vv * h.to_double()).to_int().clamp(min=0, max=h - 1)
  let idx = (y * w + x) * ch
  let r = tex.image.data[idx].to_double()
  let g = if ch > 1 { tex.image.data[idx + 1].to_double() } else { r }
  let b = if ch > 2 { tex.image.data[idx + 2].to_double() } else { r }
  (r, g, b)
}

///|
/// 双线性采样。
/// Bilinear sampling.
pub fn bilinear_sample(
  tex : Texture2D,
  u : Double,
  v : Double,
) -> (Double, Double, Double) {
  let w = tex.image.width
  let h = tex.image.height
  let ch = tex.image.channels
  let uu = wrap_coord(u, tex.wrap_u)
  let vv = wrap_coord(v, tex.wrap_v)
  let fx = uu * w.to_double()
  let fy = vv * h.to_double()
  let x0 = fx.to_int().clamp(min=0, max=w - 1)
  let y0 = fy.to_int().clamp(min=0, max=h - 1)
  let x1 = if x0 + 1 < w { x0 + 1 } else { x0 }
  let y1 = if y0 + 1 < h { y0 + 1 } else { y0 }
  let dx = fx - x0.to_double()
  let dy = fy - y0.to_double()
  let idx00 = (y0 * w + x0) * ch
  let idx01 = (y0 * w + x1) * ch
  let idx10 = (y1 * w + x0) * ch
  let idx11 = (y1 * w + x1) * ch
  let sample_ch = fn(c : Int32) -> Double {
    let v00 = tex.image.data[idx00 + c].to_double()
    let v01 = tex.image.data[idx01 + c].to_double()
    let v10 = tex.image.data[idx10 + c].to_double()
    let v11 = tex.image.data[idx11 + c].to_double()
    v00 * (1.0 - dx) * (1.0 - dy) +
    v01 * dx * (1.0 - dy) +
    v10 * (1.0 - dx) * dy +
    v11 * dx * dy
  }
  let r = sample_ch(0)
  let g = if ch > 1 { sample_ch(1) } else { r }
  let b = if ch > 2 { sample_ch(2) } else { r }
  (r, g, b)
}

///|
/// 纹理采样主流程。
/// Texture sampling pipeline.
pub fn sample_texture(
  tex : Texture2D,
  u : Double,
  v : Double,
) -> (Double, Double, Double) {
  match tex.filter_mode {
    NearestFilter => nearest_sample(tex, u, v)
    BilinearFilter => bilinear_sample(tex, u, v)
    TrilinearFilter => bilinear_sample(tex, u, v)
  }
}

///|
/// 平面映射：将3D坐标映射到UV。
/// Planar mapping: map 3D coordinates to UV.
pub fn planar_mapping(x : Double, y : Double, _z : Double) -> TextureCoord {
  { u: (x + 1.0) / 2.0, v: (y + 1.0) / 2.0, }
}

///|
/// 球面映射：将3D坐标映射到UV。
/// Spherical mapping: map 3D coordinates to UV.
pub fn spherical_mapping(x : Double, y : Double, z : Double) -> TextureCoord {
  let r = (x * x + y * y + z * z).sqrt()
  if r < 0.0001 {
    return { u: 0.0, v: 0.0, }
  }
  let theta = @math.acos(z / r)
  let phi = @math.atan2(y, x)
  { u: (phi / 3.141592653589793 + 1.0) / 2.0, v: theta / 3.141592653589793, }
}

///|
/// 柱面映射：将3D坐标映射到UV。
/// Cylindrical mapping: map 3D coordinates to UV.
pub fn cylindrical_mapping(x : Double, y : Double, z : Double) -> TextureCoord {
  let theta = @math.atan2(y, x)
  { u: (theta / 3.141592653589793 + 1.0) / 2.0, v: (z + 1.0) / 2.0, }
}

///|
/// 计算UV映射。
/// Compute UV mapping.
pub fn compute_uv_mapping(
  vertices : Array[(Double, Double, Double)],
  map_method : TextureMappingMethod,
) -> Array[TextureCoord] {
  let result : Array[TextureCoord] = []
  for v in vertices {
    let (x, y, z) = v
    let coord = match map_method {
      PlanarMapping => planar_mapping(x, y, z)
      SphericalMapping => spherical_mapping(x, y, z)
      CylindricalMapping => cylindrical_mapping(x, y, z)
    }
    result.push(coord)
  }
  result
}

///|
/// 烘焙纹理：将顶点颜色烘焙到纹理。
/// Bake texture: bake vertex colors to texture.
pub fn bake_texture(
  vertices : Array[(Double, Double, Double)],
  colors : Array[(Double, Double, Double)],
  uv_coords : Array[TextureCoord],
  tex_width : Int32,
  tex_height : Int32,
) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(tex_width * tex_height * 3) {
    data.push(0)
  }
  let n = vertices.length()
  for i in 0..<n {
    if i >= uv_coords.length() || i >= colors.length() {
      continue
    }
    let u = uv_coords[i].u.clamp(min=0.0, max=0.9999)
    let v = uv_coords[i].v.clamp(min=0.0, max=0.9999)
    let x = (u * tex_width.to_double()).to_int().clamp(min=0, max=tex_width - 1)
    let y = (v * tex_height.to_double())
      .to_int()
      .clamp(min=0, max=tex_height - 1)
    let (r, g, b) = colors[i]
    let idx = (y * tex_width + x) * 3
    data[idx] = r.clamp(min=0.0, max=255.0).to_int().to_byte()
    data[idx + 1] = g.clamp(min=0.0, max=255.0).to_int().to_byte()
    data[idx + 2] = b.clamp(min=0.0, max=255.0).to_int().to_byte()
  }
  {
    width: tex_width,
    height: tex_height,
    channels: 3,
    data: Bytes::from_array(data),
  }
}

///|
/// 纹理映射流水线：UV映射 → 烘焙 → 采样。
/// Texture mapping pipeline: UV mapping → bake → sample.
pub fn texture_pipeline(
  vertices : Array[(Double, Double, Double)],
  colors : Array[(Double, Double, Double)],
  config : TextureConfig,
  tex_width : Int32,
  tex_height : Int32,
) -> (Array[TextureCoord], @types.Image) {
  let uv_coords = compute_uv_mapping(vertices, config.mapping_method)
  let baked = bake_texture(vertices, colors, uv_coords, tex_width, tex_height)
  (uv_coords, baked)
}
