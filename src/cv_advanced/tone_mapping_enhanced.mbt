// 色调映射扩展 — 全局/局部/可逆色调映射
// Tone mapping enhancement: global / local / invertible
//
// Phase 16 v386: 计算摄影大扩展 — 色调映射。

///|
/// 色调映射方法。
/// Tone mapping method.
pub(all) enum ToneMappingMethod {
  Reinhard // Reinhard 全局
  Drago // Drago 对数映射
  Gamma // Gamma 校正
  Logarithmic // 对数映射
  LocalLaplacian // 局部拉普拉斯
  Bilateral // 双边滤波色调映射
} derive(Eq, @debug.Debug)

///|
pub extend ToneMappingMethod with @debug.Debug::{to_repr}

///|
pub extend ToneMappingMethod with Eq::{not_equal, equal}

///|
/// 色调映射参数。
/// Tone mapping parameters.
pub(all) struct ToneMappingParams {
  tm_method : ToneMappingMethod
  exposure : Double // 曝光补偿 (-2.0~2.0)
  gamma : Double // Gamma 值
  white_point : Double // 白点（Reinhard）
  saturation : Double // 饱和度保持 (0.0~1.0)
} derive(Eq, @debug.Debug)

///|
pub extend ToneMappingParams with @debug.Debug::{to_repr}

///|
pub extend ToneMappingParams with Eq::{not_equal, equal}

///|
/// Reinhard 全局色调映射。
/// Reinhard global tone mapping: L_out = L * (1 + L/L_white) / (1 + L)
pub fn tone_map_reinhard(
  img : @types.Image,
  exposure : Double,
  white_point : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  let wp = if white_point > 0.0 { white_point } else { 1.0 }
  let wp_sq = wp * wp
  for i in 0..<(w * h * ch) {
    let val = img.data[i].to_int().to_double() / 255.0
    let exposed = val * @math.exp(exposure)
    let mapped = exposed * (1.0 + exposed / wp_sq) / (1.0 + exposed)
    data.push((mapped * 255.0).clamp(min=0.0, max=255.0).to_int().to_byte())
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// Drago 对数色调映射。
/// Drago logarithmic tone mapping.
pub fn tone_map_drago(
  img : @types.Image,
  exposure : Double,
  bias : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  let lw_max = 1.0
  let bias_factor = bias.clamp(min=0.5, max=0.99)
  let divisor = @math.log10(1.0 + lw_max) / bias_factor
  for i in 0..<(w * h * ch) {
    let val = img.data[i].to_int().to_double() / 255.0
    let exposed = val * @math.exp(exposure)
    if exposed <= 0.0 {
      data.push((0 : Byte))
    } else {
      let mapped = @math.log10(1.0 + exposed) / divisor
      data.push((mapped * 255.0).clamp(min=0.0, max=255.0).to_int().to_byte())
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// Gamma 色调映射。
/// Gamma tone mapping.
pub fn tone_map_gamma(
  img : @types.Image,
  exposure : Double,
  gamma : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let g = if gamma > 0.0 { gamma } else { 1.0 }
  let inv_gamma = 1.0 / g
  let data : Array[Byte] = []
  for i in 0..<(w * h * ch) {
    let val = img.data[i].to_int().to_double() / 255.0
    let exposed = val * @math.exp(exposure)
    let mapped = @math.pow(exposed.clamp(min=0.0, max=1.0), inv_gamma)
    data.push((mapped * 255.0).clamp(min=0.0, max=255.0).to_int().to_byte())
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 对数色调映射。
/// Logarithmic tone mapping.
pub fn tone_map_logarithmic(
  img : @types.Image,
  exposure : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  for i in 0..<(w * h * ch) {
    let val = img.data[i].to_int().to_double() / 255.0
    let exposed = val * @math.exp(exposure)
    let mapped = @math.log10(1.0 + exposed) / @math.log10(2.0)
    data.push((mapped * 255.0).clamp(min=0.0, max=255.0).to_int().to_byte())
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 局部拉普拉斯色调映射（简化版）。
/// Local Laplacian tone mapping (simplified).
pub fn tone_map_local_laplacian(
  img : @types.Image,
  exposure : Double,
  sigma : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let pi = (y * w + x) * ch + c
        let val = img.data[pi].to_int().to_double() / 255.0
        let exposed = val * @math.exp(exposure)
        let mut local_mean = 0.0
        let mut count = 0.0
        for dy in [-1, 0, 1] {
          for dx in [-1, 0, 1] {
            let nx = x + dx
            let ny = y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let npi = (ny * w + nx) * ch + c
              local_mean = local_mean +
                img.data[npi].to_int().to_double() / 255.0
              count = count + 1.0
            }
          }
        }
        let mean = if count > 0.0 { local_mean / count } else { exposed }
        let detail = exposed - mean
        let compressed_detail = detail * sigma / (sigma + detail.abs())
        let mapped = mean + compressed_detail
        data.push((mapped * 255.0).clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 双边滤波色调映射（简化版）。
/// Bilateral filter tone mapping (simplified).
pub fn tone_map_bilateral(
  img : @types.Image,
  exposure : Double,
  detail_strength : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let pi = (y * w + x) * ch + c
        let val = img.data[pi].to_int().to_double() / 255.0
        let exposed = val * @math.exp(exposure)
        let mut base = 0.0
        let mut count = 0.0
        for dy in [-1, 0, 1] {
          for dx in [-1, 0, 1] {
            let nx = x + dx
            let ny = y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let npi = (ny * w + nx) * ch + c
              base = base + img.data[npi].to_int().to_double() / 255.0
              count = count + 1.0
            }
          }
        }
        base = if count > 0.0 { base / count } else { exposed }
        let detail = exposed - base
        let compressed_base = base / (1.0 + base)
        let enhanced_detail = detail * (1.0 + detail_strength)
        let mapped = compressed_base + enhanced_detail
        data.push((mapped * 255.0).clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 色调映射流水线。
/// Tone mapping pipeline.
pub fn tone_mapping_pipeline(
  img : @types.Image,
  params : ToneMappingParams,
) -> @types.Image {
  match params.tm_method {
    Reinhard => tone_map_reinhard(img, params.exposure, params.white_point)
    Drago => tone_map_drago(img, params.exposure, 0.85)
    Gamma => tone_map_gamma(img, params.exposure, params.gamma)
    Logarithmic => tone_map_logarithmic(img, params.exposure)
    LocalLaplacian => tone_map_local_laplacian(img, params.exposure, 0.3)
    Bilateral => tone_map_bilateral(img, params.exposure, 0.5)
  }
}

///|
/// 创建默认色调映射参数。
/// Create default tone mapping parameters.
pub fn default_tone_mapping_params(
  tm_method : ToneMappingMethod,
) -> ToneMappingParams {
  { tm_method, exposure: 0.0, gamma: 2.2, white_point: 1.0, saturation: 1.0, }
}

///|
/// 估计图像动态范围。
/// Estimate image dynamic range.
/// 返回 (min, max, range)
pub fn estimate_dynamic_range(img : @types.Image) -> (Double, Double, Double) {
  let mut min_val = 1.0
  let mut max_val = 0.0
  for i in 0..<img.data.length() {
    let v = img.data[i].to_int().to_double() / 255.0
    if v < min_val {
      min_val = v
    }
    if v > max_val {
      max_val = v
    }
  }
  let dynamic_range = max_val - min_val
  (min_val, max_val, dynamic_range)
}
