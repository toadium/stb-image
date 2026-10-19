// 背景建模 — GMM/KNN/VIBE
// Background modeling: GMM / KNN / VIBE
//
// Phase 12 v323: 大规模扩展 CV 算法库 — 背景建模。

///|
/// 背景建模方法。
/// Background modeling method.
pub(all) enum BackgroundMethod {
  GMM
  KNN
  VIBE
} derive(Eq, @debug.Debug)

///|
pub extend BackgroundMethod with @debug.Debug::{to_repr}

///|
pub extend BackgroundMethod with Eq::{not_equal, equal}

///|
/// 背景模型参数。
/// Background model parameters.
pub(all) struct BackgroundParams {
  bg_method : BackgroundMethod
  threshold : Double
  learning_rate : Double
  history : Int
  var_init : Double
} derive(Eq, @debug.Debug)

///|
pub extend BackgroundParams with @debug.Debug::{to_repr}

///|
pub extend BackgroundParams with Eq::{not_equal, equal}

///|
/// 背景模型。
/// Background model.
pub(all) struct BackgroundModel {
  width : Int
  height : Int
  means : Array[Double]
  variances : Array[Double]
  weights : Array[Double]
  frame_count : Int
  params : BackgroundParams
} derive(Eq, @debug.Debug)

///|
pub extend BackgroundModel with @debug.Debug::{to_repr}

///|
pub extend BackgroundModel with Eq::{not_equal, equal}

///|
/// 前景掩码。
/// Foreground mask.
pub(all) struct ForegroundMask {
  width : Int
  height : Int
  mask : Array[Bool]
} derive(Eq, @debug.Debug)

///|
pub extend ForegroundMask with @debug.Debug::{to_repr}

///|
pub extend ForegroundMask with Eq::{not_equal, equal}

///|
/// 初始化背景模型。
/// Initialize background model.
pub fn init_background_model(
  img : @types.Image,
  params : BackgroundParams,
) -> BackgroundModel {
  let w = img.width
  let h = img.height
  let means : Array[Double] = []
  let variances : Array[Double] = []
  let weights : Array[Double] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = (y * w + x) * img.channels
      means.push(img.data[idx].to_int().to_double())
      variances.push(params.var_init)
      weights.push(1.0)
    }
  }
  { width: w, height: h, means, variances, weights, frame_count: 1, params, }
}

///|
/// 更新背景模型。
/// Update background model.
pub fn update_background_model(
  model : BackgroundModel,
  img : @types.Image,
) -> BackgroundModel {
  let w = model.width
  let h = model.height
  let lr = model.params.learning_rate
  let means : Array[Double] = []
  let variances : Array[Double] = []
  let weights : Array[Double] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let pix_idx = idx * img.channels
      let pixel = img.data[pix_idx].to_int().to_double()
      let old_mean = model.means[idx]
      let old_var = model.variances[idx]
      let diff = pixel - old_mean
      let new_mean = old_mean + lr * diff
      let new_var = old_var + lr * (diff * diff - old_var)
      let new_weight = model.weights[idx] + lr * (1.0 - model.weights[idx])
      means.push(new_mean)
      variances.push(if new_var > 1.0 { new_var } else { 1.0 })
      weights.push(new_weight)
    }
  }
  {
    width: w,
    height: h,
    means,
    variances,
    weights,
    frame_count: model.frame_count + 1,
    params: model.params,
  }
}

///|
/// 背景减除（计算前景掩码）。
/// Background subtraction (compute foreground mask).
pub fn subtract_background(
  model : BackgroundModel,
  img : @types.Image,
) -> ForegroundMask {
  let w = model.width
  let h = model.height
  let mask : Array[Bool] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let pix_idx = idx * img.channels
      let pixel = img.data[pix_idx].to_int().to_double()
      let diff = pixel - model.means[idx]
      let dist_sq = diff * diff
      let threshold_sq = model.params.threshold *
        model.params.threshold *
        model.variances[idx]
      mask.push(dist_sq > threshold_sq)
    }
  }
  { width: w, height: h, mask, }
}

///|
/// GMM 更新（高斯混合模型）。
/// GMM update (Gaussian Mixture Model).
pub fn gmm_update(
  model : BackgroundModel,
  img : @types.Image,
) -> BackgroundModel {
  update_background_model(model, img)
}

///|
/// KNN 背景更新。
/// KNN background update.
pub fn knn_update(
  model : BackgroundModel,
  img : @types.Image,
) -> BackgroundModel {
  let w = model.width
  let h = model.height
  let lr = model.params.learning_rate * 0.5
  let means : Array[Double] = []
  let variances : Array[Double] = []
  let weights : Array[Double] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let pix_idx = idx * img.channels
      let pixel = img.data[pix_idx].to_int().to_double()
      let old_mean = model.means[idx]
      let diff = pixel - old_mean
      let dist_sq = diff * diff
      let new_mean = if dist_sq < model.variances[idx] * model.params.threshold {
        old_mean + lr * diff
      } else {
        old_mean + lr * 0.1 * diff
      }
      means.push(new_mean)
      variances.push(model.variances[idx])
      weights.push(model.weights[idx])
    }
  }
  {
    width: w,
    height: h,
    means,
    variances,
    weights,
    frame_count: model.frame_count + 1,
    params: model.params,
  }
}

///|
/// VIBE 背景更新（简化版）。
/// VIBE background update (simplified).
pub fn vibe_update(
  model : BackgroundModel,
  img : @types.Image,
) -> BackgroundModel {
  let w = model.width
  let h = model.height
  let means : Array[Double] = []
  let variances : Array[Double] = []
  let weights : Array[Double] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let pix_idx = idx * img.channels
      let pixel = img.data[pix_idx].to_int().to_double()
      let old_mean = model.means[idx]
      let diff = (pixel - old_mean).abs()
      let new_mean = if diff <
        model.params.threshold * model.variances[idx].sqrt() {
        old_mean * 0.9 + pixel * 0.1
      } else {
        old_mean * 0.99 + pixel * 0.01
      }
      means.push(new_mean)
      variances.push(model.variances[idx])
      weights.push(model.weights[idx])
    }
  }
  {
    width: w,
    height: h,
    means,
    variances,
    weights,
    frame_count: model.frame_count + 1,
    params: model.params,
  }
}

///|
/// 清理前景掩码（形态学开运算简化）。
/// Clean foreground mask (simplified morphological opening).
pub fn clean_foreground_mask(mask : ForegroundMask) -> ForegroundMask {
  let w = mask.width
  let h = mask.height
  let cleaned : Array[Bool] = []
  for y in 0..<h {
    for x in 0..<w {
      let mut count = 0
      for dy in [-1, 0, 1] {
        for dx in [-1, 0, 1] {
          let nx = x + dx
          let ny = y + dy
          if nx >= 0 && nx < w && ny >= 0 && ny < h {
            let nidx = ny * w + nx
            if mask.mask[nidx] {
              count = count + 1
            }
          }
        }
      }
      cleaned.push(count >= 5)
    }
  }
  { width: w, height: h, mask: cleaned, }
}
