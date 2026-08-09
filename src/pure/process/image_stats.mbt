// 纯 MoonBit 图像统计信息（全目标可用：native/wasm/js）
// 仅依赖 @types，不依赖 @core/FFI
// 移植自 src/util/image_stats.mbt:1-47 的图像统计

///|
/// 图像统计结果（纯 MoonBit，全目标可用）
pub(all) struct ImageStats {
  mean : Float
  stddev : Float
  min_val : Int
  max_val : Int
} derive(Eq, @debug.Debug)

///|
/// 计算图像统计信息（均值、标准差、最小值、最大值，纯 MoonBit，全目标可用）。
/// 统计所有通道的像素值。
pub fn compute_stats_pure(img : @types.Image) -> ImageStats {
  let n = img.width * img.height * img.channels
  let mut sum = 0
  let mut sum_sq = 0
  let mut min_v = 255
  let mut max_v = 0
  for i in 0..<n {
    let v = img.data[i].to_int()
    sum += v
    sum_sq += v * v
    if v < min_v {
      min_v = v
    }
    if v > max_v {
      max_v = v
    }
  }
  let mean = Float::from_int(sum) / Float::from_int(n)
  let variance = Float::from_int(sum_sq) / Float::from_int(n) - mean * mean
  let stddev = (if variance < 0.0F { 0.0F } else { variance }).sqrt()
  ImageStats::{ mean, stddev, min_val: min_v, max_val: max_v }
}

///|
/// 计算图像均值（所有通道所有像素的平均值，纯 MoonBit，全目标可用）。
pub fn mean_value_pure(img : @types.Image) -> Float {
  let n = img.width * img.height * img.channels
  let mut sum = 0
  for i in 0..<n {
    sum += img.data[i].to_int()
  }
  Float::from_int(sum) / Float::from_int(n)
}
