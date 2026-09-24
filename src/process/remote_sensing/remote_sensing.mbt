// 遥感图像处理（v12.11.0）
// NDVI、假彩色合成、多光谱指数计算

///|
/// 多光谱图像波段
pub(all) struct MultispectralImage {
  width : Int
  height : Int
  bands : Array[@types.Image] // 每个波段一个灰度图像
  band_names : Array[String] // 波段名称
}

///|
/// 创建多光谱图像
pub fn multispectral_new(
  width : Int,
  height : Int,
  bands : Array[@types.Image],
  band_names? : Array[String] = [],
) -> MultispectralImage {
  let names = if band_names.length() > 0 {
    band_names
  } else {
    let default_names : Array[String] = []
    for i in 0..<bands.length() {
      default_names.push("Band" + i.to_string())
    }
    default_names
  }
  MultispectralImage::{ width, height, bands, band_names: names }
}

///|
/// 计算 NDVI（归一化植被指数）
/// NDVI = (NIR - Red) / (NIR + Red)
pub fn compute_ndvi(nir : @types.Image, red : @types.Image) -> @types.Image {
  if nir.width != red.width || nir.height != red.height {
    return nir
  }
  let w = nir.width
  let h = nir.height
  let out_data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let nir_val = nir.data[idx].to_double()
      let red_val = red.data[idx].to_double()
      let sum = nir_val + red_val
      let ndvi = if sum > 0.0 { (nir_val - red_val) / sum } else { 0.0 }
      // 映射到 0-255（NDVI 范围 -1 到 1）
      let mapped = ((ndvi + 1.0) / 2.0 * 255.0).to_int()
      out_data[idx] = mapped.min(255).max(0).to_byte()
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(out_data),
  }
}

///|
/// 计算 NDWI（归一化水指数）
/// NDWI = (Green - NIR) / (Green + NIR)
pub fn compute_ndwi(green : @types.Image, nir : @types.Image) -> @types.Image {
  if green.width != nir.width || green.height != nir.height {
    return green
  }
  let w = green.width
  let h = green.height
  let out_data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let green_val = green.data[idx].to_double()
      let nir_val = nir.data[idx].to_double()
      let sum = green_val + nir_val
      let ndwi = if sum > 0.0 { (green_val - nir_val) / sum } else { 0.0 }
      let mapped = ((ndwi + 1.0) / 2.0 * 255.0).to_int()
      out_data[idx] = mapped.min(255).max(0).to_byte()
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(out_data),
  }
}

///|
/// 计算 NDBI（归一化建筑指数）
/// NDBI = (SWIR - NIR) / (SWIR + NIR)
pub fn compute_ndbi(swir : @types.Image, nir : @types.Image) -> @types.Image {
  if swir.width != nir.width || swir.height != nir.height {
    return swir
  }
  let w = swir.width
  let h = swir.height
  let out_data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let swir_val = swir.data[idx].to_double()
      let nir_val = nir.data[idx].to_double()
      let sum = swir_val + nir_val
      let ndbi = if sum > 0.0 { (swir_val - nir_val) / sum } else { 0.0 }
      let mapped = ((ndbi + 1.0) / 2.0 * 255.0).to_int()
      out_data[idx] = mapped.min(255).max(0).to_byte()
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(out_data),
  }
}

///|
/// 计算 EVI（增强型植被指数）
/// EVI = 2.5 * (NIR - Red) / (NIR + 6*Red - 7.5*Blue + 1)
pub fn compute_evi(
  nir : @types.Image,
  red : @types.Image,
  blue : @types.Image,
) -> @types.Image {
  if nir.width != red.width ||
    nir.height != red.height ||
    nir.width != blue.width ||
    nir.height != blue.height {
    return nir
  }
  let w = nir.width
  let h = nir.height
  let out_data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let nir_val = nir.data[idx].to_double()
      let red_val = red.data[idx].to_double()
      let blue_val = blue.data[idx].to_double()
      let denominator = nir_val + 6.0 * red_val - 7.5 * blue_val + 1.0
      let evi = if denominator.abs() > 0.0001 {
        2.5 * (nir_val - red_val) / denominator
      } else {
        0.0
      }
      let mapped = ((evi + 1.0) / 2.0 * 255.0).to_int()
      out_data[idx] = mapped.min(255).max(0).to_byte()
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(out_data),
  }
}

///|
/// 假彩色合成（标准假彩色：NIR=红, Red=绿, Green=蓝）
pub fn false_color_composite(
  nir : @types.Image,
  red : @types.Image,
  green : @types.Image,
) -> @types.Image {
  if nir.width != red.width ||
    nir.height != red.height ||
    nir.width != green.width ||
    nir.height != green.height {
    return nir
  }
  let w = nir.width
  let h = nir.height
  let out_data : Array[Byte] = Array::make(w * h * 3, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let out_idx = idx * 3
      // 标准假彩色：NIR -> 红, Red -> 绿, Green -> 蓝
      out_data[out_idx] = nir.data[idx]
      out_data[out_idx + 1] = red.data[idx]
      out_data[out_idx + 2] = green.data[idx]
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(out_data),
  }
}

///|
/// 真彩色合成（Red=红, Green=绿, Blue=蓝）
pub fn true_color_composite(
  red : @types.Image,
  green : @types.Image,
  blue : @types.Image,
) -> @types.Image {
  if red.width != green.width ||
    red.height != green.height ||
    red.width != blue.width ||
    red.height != blue.height {
    return red
  }
  let w = red.width
  let h = red.height
  let out_data : Array[Byte] = Array::make(w * h * 3, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let out_idx = idx * 3
      out_data[out_idx] = red.data[idx]
      out_data[out_idx + 1] = green.data[idx]
      out_data[out_idx + 2] = blue.data[idx]
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(out_data),
  }
}

///|
/// 植被覆盖度估算（基于 NDVI 阈值法）
pub fn vegetation_coverage(
  ndvi : @types.Image,
  ndvi_soil? : Double = 0.2,
  ndvi_veg? : Double = 0.8,
) -> @types.Image {
  let soil = ndvi_soil
  let veg = ndvi_veg
  let w = ndvi.width
  let h = ndvi.height
  let out_data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      // 将 0-255 映射回 -1 到 1
      let ndvi_val = ndvi.data[idx].to_double() / 255.0 * 2.0 - 1.0
      let coverage = if ndvi_val <= soil {
        0.0
      } else if ndvi_val >= veg {
        1.0
      } else {
        (ndvi_val - soil) / (veg - soil)
      }
      out_data[idx] = (coverage * 255.0).to_int().min(255).max(0).to_byte()
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(out_data),
  }
}

///|
/// 土地覆盖分类（简单的基于指数的分类）
/// 返回分类图：0=水体, 1=植被, 2=建筑, 3=裸土, 4=其他
pub fn land_cover_classification(
  ndvi : @types.Image,
  ndwi : @types.Image,
  ndbi : @types.Image,
) -> @types.Image {
  if ndvi.width != ndwi.width ||
    ndvi.height != ndwi.height ||
    ndvi.width != ndbi.width ||
    ndvi.height != ndbi.height {
    return ndvi
  }
  let w = ndvi.width
  let h = ndvi.height
  let out_data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      // 将 0-255 映射回 -1 到 1
      let ndvi_val = ndvi.data[idx].to_double() / 255.0 * 2.0 - 1.0
      let ndwi_val = ndwi.data[idx].to_double() / 255.0 * 2.0 - 1.0
      let ndbi_val = ndbi.data[idx].to_double() / 255.0 * 2.0 - 1.0
      // 简单分类规则
      let class_id = if ndwi_val > 0.2 {
        0 // 水体
      } else if ndvi_val > 0.3 {
        1 // 植被
      } else if ndbi_val > 0.1 {
        2 // 建筑
      } else if ndvi_val > 0.1 {
        3 // 裸土
      } else {
        4 // 其他
      }
      out_data[idx] = class_id.to_byte()
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(out_data),
  }
}

///|
/// 分类图彩色可视化
pub fn classification_colormap(classification : @types.Image) -> @types.Image {
  let w = classification.width
  let h = classification.height
  let out_data : Array[Byte] = Array::make(w * h * 3, b'\x00')
  // 分类颜色：0=水体(蓝), 1=植被(绿), 2=建筑(红), 3=裸土(黄), 4=其他(灰)
  let colors = [
    (0, 0, 255), // 水体 - 蓝
    (0, 255, 0), // 植被 - 绿
    (255, 0, 0), // 建筑 - 红
    (255, 255, 0), // 裸土 - 黄
    (128, 128, 128), // 其他 - 灰
  ]
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let class_id = classification.data[idx].to_int()
      let out_idx = idx * 3
      let color_idx = class_id.min(colors.length() - 1).max(0)
      let (r, g, b) = colors[color_idx]
      out_data[out_idx] = r.to_byte()
      out_data[out_idx + 1] = g.to_byte()
      out_data[out_idx + 2] = b.to_byte()
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(out_data),
  }
}
