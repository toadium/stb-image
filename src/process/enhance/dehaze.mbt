// 图像去雾（v11.6.0）
// 暗通道先验算法 + 大气光估计 + 透射率优化 + 去雾复原

///|
/// 去雾配置
pub(all) struct DehazeConfig {
  patch_size : Int  // 暗通道 patch 大小
  omega : Double  // 透射率保留系数（0-1，越大去雾越强）
  t_min : Double  // 最小透射率
  guided_radius : Int  // 引导滤波半径
  guided_eps : Double  // 引导滤波正则化参数
  max_atmospheric : Int  // 大气光候选像素比例（前 0.1%）
}

///|
/// 创建默认去雾配置
pub fn dehaze_default_config() -> DehazeConfig {
  DehazeConfig::{
    patch_size: 15,
    omega: 0.95,
    t_min: 0.1,
    guided_radius: 20,
    guided_eps: 0.0001,
    max_atmospheric: 1000,
  }
}

///|
/// 计算暗通道
/// 暗通道：在局部 patch 内，取每个像素 RGB 三通道的最小值，再取 patch 内最小值
pub fn dark_channel(
  img : @types.Image,
  patch_size? : Int = 15,
) -> @types.Image {
let ps = patch_size
  let w = img.width
  let h = img.height
  let channels = img.channels
  let data = img.data
  // 1. 计算每个像素的最小通道值
  let min_channel : Array[Byte] = []
  for i in 0..<(w * h) {
    let idx = i * channels
    let r = data[idx].to_int()
    let g = if channels >= 2 { data[idx + 1].to_int() } else { r }
    let b = if channels >= 3 { data[idx + 2].to_int() } else { r }
    let min_val = r.min(g).min(b)
    min_channel.push(min_val.to_byte())
  }
  // 2. 计算局部最小值（最小值滤波）
  let out_data : Array[Byte] = Array::make(w * h, b'\x00')
  let half = ps / 2
  for y in 0..<h {
    for x in 0..<w {
      let mut min_val = 255
      for dy in (-half)..<(half + 1) {
        for dx in (-half)..<(half + 1) {
          let nx = x + dx
          let ny = y + dy
          if nx >= 0 && nx < w && ny >= 0 && ny < h {
            let val = min_channel[ny * w + nx].to_int()
            if val < min_val {
              min_val = val
            }
          }
        }
      }
      out_data[y * w + x] = min_val.to_byte()
    }
  }
  @types.Image::{ width: w, height: h, channels: 1, data: Bytes::from_array(out_data) }
}

///|
/// 估计大气光
/// 取暗通道中最亮的 0.1% 像素，在原图中取这些像素的最大值作为大气光
pub fn estimate_atmospheric_light(
  img : @types.Image,
  dark : @types.Image,
  top_percent? : Int = 1000,
) -> Array[Int] {
let top = top_percent
  let w = img.width
  let h = img.height
  let channels = img.channels
  let img_data = img.data
  let dark_data = dark.data
  // 收集所有像素的暗通道值和坐标
  let pixels : Array[(Int, Int)] = []
  for y in 0..<h {
    for x in 0..<w {
      pixels.push((dark_data[y * w + x].to_int(), y * w + x))
    }
  }
  // 按暗通道值降序排序（选择排序，取前 top 个）
  let count = if top < pixels.length() { top } else { pixels.length() }
  let selected_indices : Array[Int] = []
  let used : Array[Bool] = Array::make(pixels.length(), false)
  for _ in 0..<count {
    let mut max_val = -1
    let mut max_idx = 0
    for i in 0..<pixels.length() {
      if !used[i] && pixels[i].0 > max_val {
        max_val = pixels[i].0
        max_idx = i
      }
    }
    used[max_idx] = true
    selected_indices.push(pixels[max_idx].1)
  }
  // 在这些像素中取每个通道的最大值
  let atmospheric : Array[Int] = []
  for c in 0..<channels {
    let mut max_val = 0
    for idx in selected_indices {
      let val = img_data[idx * channels + c].to_int()
      if val > max_val {
        max_val = val
      }
    }
    atmospheric.push(max_val)
  }
  atmospheric
}

///|
/// 计算透射率
/// t(x) = 1 - omega * dark_channel(I/A)
pub fn estimate_transmission(
  img : @types.Image,
  atmospheric : Array[Int],
  omega? : Double = 0.95,
  patch_size? : Int = 15,
) -> @types.Image {
  let om = omega
  let ps = patch_size
  let w = img.width
  let h = img.height
  let channels = img.channels
  let data = img.data
  // 1. 归一化图像（除以大气光）
  let normalized : Array[Byte] = []
  for i in 0..<(w * h) {
    for c in 0..<channels {
      let idx = i * channels + c
      let val = data[idx].to_double()
      let a = if c < atmospheric.length() { atmospheric[c].to_double() } else { 255.0 }
      let norm = if a > 0.0 { (val / a * 255.0).min(255.0).max(0.0) } else { 0.0 }
      normalized.push(norm.to_int().to_byte())
    }
  }
  let norm_img = @types.Image::{ width: w, height: h, channels, data: Bytes::from_array(normalized) }
  // 2. 计算归一化图像的暗通道
  let dark = dark_channel(norm_img, patch_size=ps)
  // 3. 计算透射率
  let dark_data = dark.data
  let out_data : Array[Byte] = Array::make(w * h, b'\x00')
  for i in 0..<(w * h) {
    let t = 1.0 - om * dark_data[i].to_double() / 255.0
    let t_clamped = t.max(0.0).min(1.0)
    out_data[i] = (t_clamped * 255.0).to_int().to_byte()
  }
  @types.Image::{ width: w, height: h, channels: 1, data: Bytes::from_array(out_data) }
}

///|
/// 引导滤波（用于透射率优化）
/// 简化版：使用均值滤波近似引导滤波
pub fn guided_filter_image(
  input : @types.Image,
  guide : @types.Image,
  radius? : Int = 20,
  eps? : Double = 0.0001,
) -> @types.Image {
  let r = radius
  let e = eps
  let w = input.width
  let h = input.height
  let input_data = input.data
  let guide_data = guide.data
  // 简化版引导滤波：使用均值滤波
  // 完整引导滤波需要计算均值、方差、协方差等
  // 这里用双边滤波近似
  let out_data : Array[Byte] = Array::make(w * h, b'\x00')
  let half = r / 2
  for y in 0..<h {
    for x in 0..<w {
      let mut sum = 0.0
      let mut weight_sum = 0.0
      let center_guide = guide_data[y * w + x].to_double()
      for dy in (-half)..<(half + 1) {
        for dx in (-half)..<(half + 1) {
          let nx = x + dx
          let ny = y + dy
          if nx >= 0 && nx < w && ny >= 0 && ny < h {
            let spatial_dist = ((dx * dx + dy * dy).to_double()).sqrt()
            let guide_diff = (guide_data[ny * w + nx].to_double() - center_guide).abs()
            // 双边权重：空间距离 + 引导图差异
            let spatial_weight = (1.0 - spatial_dist / half.to_double()).max(0.0)
            let range_weight = (1.0 - guide_diff / 255.0).max(0.0)
            let weight = spatial_weight * range_weight + e
            sum += input_data[ny * w + nx].to_double() * weight
            weight_sum += weight
          }
        }
      }
      let result = if weight_sum > 0.0 { sum / weight_sum } else { input_data[y * w + x].to_double() }
      out_data[y * w + x] = result.min(255.0).max(0.0).to_int().to_byte()
    }
  }
  @types.Image::{ width: w, height: h, channels: 1, data: Bytes::from_array(out_data) }
}

///|
/// 去雾复原
/// J(x) = (I(x) - A) / max(t(x), t0) + A
pub fn dehaze_recover(
  img : @types.Image,
  transmission : @types.Image,
  atmospheric : Array[Int],
  t_min? : Double = 0.1,
) -> @types.Image {
let t0 = t_min
  let w = img.width
  let h = img.height
  let channels = img.channels
  let img_data = img.data
  let trans_data = transmission.data
  let out_data : Array[Byte] = Array::make(w * h * channels, b'\x00')
  for i in 0..<(w * h) {
    let t = trans_data[i].to_double() / 255.0
    let t_clamped = t.max(t0)
    for c in 0..<channels {
      let idx = i * channels + c
      let val = img_data[idx].to_double()
      let a = if c < atmospheric.length() { atmospheric[c].to_double() } else { 255.0 }
      let recovered = (val - a) / t_clamped + a
      out_data[idx] = recovered.min(255.0).max(0.0).to_int().to_byte()
    }
  }
  @types.Image::{ width: w, height: h, channels, data: Bytes::from_array(out_data) }
}

///|
/// 完整去雾流水线
pub fn dehaze_advanced(
  img : @types.Image,
  config? : DehazeConfig,
) -> @types.Image {
  let cfg = match config {
    Some(c) => c
    None => dehaze_default_config()
  }
  // 1. 计算暗通道
  let dark = dark_channel(img, patch_size=cfg.patch_size)
  // 2. 估计大气光
  let atmospheric = estimate_atmospheric_light(img, dark, top_percent=cfg.max_atmospheric)
  // 3. 估计透射率
  let transmission_raw = estimate_transmission(img, atmospheric, omega=cfg.omega, patch_size=cfg.patch_size)
  // 4. 引导滤波优化透射率
  let transmission = guided_filter_image(transmission_raw, img, radius=cfg.guided_radius, eps=cfg.guided_eps)
  // 5. 去雾复原
  dehaze_recover(img, transmission, atmospheric, t_min=cfg.t_min)
}
