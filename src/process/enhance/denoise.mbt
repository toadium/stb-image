// 图像去噪（v12.1.0）
// 非局部均值（NLM）+ 双边滤波增强 + 中值滤波增强

///|
/// 非局部均值去噪配置
pub(all) struct NlmConfig {
  search_window : Int  // 搜索窗口大小
  patch_size : Int  // 补丁大小
  h : Double  // 滤波强度参数
  sigma : Double  // 噪声标准差
}

///|
/// 创建默认 NLM 配置
pub fn nlm_default_config() -> NlmConfig {
  NlmConfig::{
    search_window: 21,
    patch_size: 7,
    h: 10.0,
    sigma: 10.0,
  }
}

///|
/// 非局部均值去噪（简化版）
/// 基于图像块相似度的加权平均去噪
pub fn denoise_nlm(
  img : @types.Image,
  config? : NlmConfig,
) -> @types.Image {
  let cfg = match config {
    Some(c) => c
    None => nlm_default_config()
  }
  let w = img.width
  let h = img.height
  let channels = img.channels
  let data = img.data
  let out_data : Array[Byte] = Array::make(w * h * channels, b'\x00')
  let half_search = cfg.search_window / 2
  let half_patch = cfg.patch_size / 2
  let h2 = cfg.h * cfg.h
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<channels {
        let mut weighted_sum = 0.0
        let mut weight_sum = 0.0
        // 在搜索窗口内寻找相似块
        for dy in (-half_search)..<(half_search + 1) {
          for dx in (-half_search)..<(half_search + 1) {
            let nx = x + dx
            let ny = y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              // 计算两个块的相似度（欧氏距离）
              let mut dist = 0.0
              let mut count = 0
              for py in (-half_patch)..<(half_patch + 1) {
                for px in (-half_patch)..<(half_patch + 1) {
                  let p1x = x + px
                  let p1y = y + py
                  let p2x = nx + px
                  let p2y = ny + py
                  if p1x >= 0 && p1x < w && p1y >= 0 && p1y < h &&
                     p2x >= 0 && p2x < w && p2y >= 0 && p2y < h {
                    let v1 = data[(p1y * w + p1x) * channels + c].to_double()
                    let v2 = data[(p2y * w + p2x) * channels + c].to_double()
                    let diff = v1 - v2
                    dist += diff * diff
                    count += 1
                  }
                }
              }
              if count > 0 {
                dist = dist / count.to_double()
                // 高斯权重
                let weight = @math.exp(-dist / h2)
                weighted_sum += data[(ny * w + nx) * channels + c].to_double() * weight
                weight_sum += weight
              }
            }
          }
        }
        if weight_sum > 0.0 {
          out_data[(y * w + x) * channels + c] = (weighted_sum / weight_sum).min(255.0).max(0.0).to_int().to_byte()
        } else {
          out_data[(y * w + x) * channels + c] = data[(y * w + x) * channels + c]
        }
      }
    }
  }
  @types.Image::{ width: w, height: h, channels, data: Bytes::from_array(out_data) }
}

///|
/// 双边滤波增强版
/// 同时考虑空间距离和像素值差异
pub fn denoise_bilateral(
  img : @types.Image,
  diameter? : Int = 9,
  sigma_color? : Double = 75.0,
  sigma_space? : Double = 75.0,
) -> @types.Image {
  let d = diameter
  let sc = sigma_color
  let ss = sigma_space
  let w = img.width
  let h = img.height
  let channels = img.channels
  let data = img.data
  let out_data : Array[Byte] = Array::make(w * h * channels, b'\x00')
  let half = d / 2
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<channels {
        let center_val = data[(y * w + x) * channels + c].to_double()
        let mut weighted_sum = 0.0
        let mut weight_sum = 0.0
        for dy in (-half)..<(half + 1) {
          for dx in (-half)..<(half + 1) {
            let nx = x + dx
            let ny = y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let neighbor_val = data[(ny * w + nx) * channels + c].to_double()
              // 空间距离权重
              let spatial_dist = ((dx * dx + dy * dy).to_double()).sqrt()
              let spatial_weight = @math.exp(-(spatial_dist * spatial_dist) / (2.0 * ss * ss))
              // 像素值差异权重
              let color_diff = (center_val - neighbor_val).abs()
              let color_weight = @math.exp(-(color_diff * color_diff) / (2.0 * sc * sc))
              // 组合权重
              let weight = spatial_weight * color_weight
              weighted_sum += neighbor_val * weight
              weight_sum += weight
            }
          }
        }
        if weight_sum > 0.0 {
          out_data[(y * w + x) * channels + c] = (weighted_sum / weight_sum).min(255.0).max(0.0).to_int().to_byte()
        } else {
          out_data[(y * w + x) * channels + c] = data[(y * w + x) * channels + c]
        }
      }
    }
  }
  @types.Image::{ width: w, height: h, channels, data: Bytes::from_array(out_data) }
}

///|
/// 中值滤波增强版（支持任意核大小）
pub fn denoise_median(
  img : @types.Image,
  kernel_size? : Int = 3,
) -> @types.Image {
let ks = kernel_size
  let w = img.width
  let h = img.height
  let channels = img.channels
  let data = img.data
  let out_data : Array[Byte] = Array::make(w * h * channels, b'\x00')
  let half = ks / 2
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<channels {
        // 收集邻域像素
        let neighborhood : Array[Int] = []
        for dy in (-half)..<(half + 1) {
          for dx in (-half)..<(half + 1) {
            let nx = x + dx
            let ny = y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              neighborhood.push(data[(ny * w + nx) * channels + c].to_int())
            }
          }
        }
        // 排序取中值（选择排序）
        let n = neighborhood.length()
        for i in 0..<(n / 2 + 1) {
          let mut min_idx = i
          for j in (i + 1)..<n {
            if neighborhood[j] < neighborhood[min_idx] {
              min_idx = j
            }
          }
          if min_idx != i {
            let tmp = neighborhood[i]
            neighborhood[i] = neighborhood[min_idx]
            neighborhood[min_idx] = tmp
          }
        }
        let median = if n > 0 { neighborhood[n / 2] } else { data[(y * w + x) * channels + c].to_int() }
        out_data[(y * w + x) * channels + c] = median.to_byte()
      }
    }
  }
  @types.Image::{ width: w, height: h, channels, data: Bytes::from_array(out_data) }
}

///|
/// 通用去噪接口
pub fn denoise(
  img : @types.Image,
  method : String,
) -> @types.Image {
  match method {
    "nlm" => denoise_nlm(img)
    "bilateral" => denoise_bilateral(img)
    "median" => denoise_median(img)
    _ => denoise_bilateral(img)
  }
}
