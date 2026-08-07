// 图像统计信息（纯 MoonBit）：mean / stddev / min_max

///|
/// 图像统计结果
pub(all) struct ImageStats {
  mean : Float
  stddev : Float
  min_val : Int
  max_val : Int
} derive(Eq, @debug.Debug)

///|
/// 计算图像统计信息（均值、标准差、最小值、最大值）。
/// 统计所有通道的像素值。
pub fn compute_stats(img : @core.Image) -> ImageStats {
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
  let stddev = @math.powf(if variance < 0.0F { 0.0F } else { variance }, 0.5F)
  ImageStats::{ mean, stddev, min_val: min_v, max_val: max_v }
}

///|
/// 计算图像均值（所有通道所有像素的平均值）。
pub fn mean_value(img : @core.Image) -> Float {
  let n = img.width * img.height * img.channels
  let mut sum = 0
  for i in 0..<n {
    sum += img.data[i].to_int()
  }
  Float::from_int(sum) / Float::from_int(n)
}
