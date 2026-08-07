// 频域滤波（基于 FFT）

///|
/// 频域滤波类型
pub(all) enum FreqFilterType {
  LowPass // 低通滤波（保留低频，去除高频）
  HighPass // 高通滤波（保留高频，去除低频）
  BandPass // 带通滤波（保留中频）
  BandStop // 带阻滤波（去除中频）
}

///|
/// 频域滤波。对灰度图做 FFT，应用指定滤波器，再做 IFFT 回空域。
/// cutoff 为截止频率（像素数，从中心算起），band_width 为带宽（仅 BandPass/BandStop 使用）。
pub fn freq_filter(
  img : @core.Image,
  filter_type : FreqFilterType,
  cutoff : Float,
  band_width~ : Float = 0.0F
) -> @core.Image raise @core.LoadError {
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("freq_filter 仅支持 channels=1/3/4")
  }
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { 1 }
  let ffts = fft_2d(img)
  let filtered : Array[FFTResult] = []
  for c in 0..<color_ch {
    let shifted = fft_shift(ffts[c])
    let w = shifted.width
    let h = shifted.height
    let cx = w / 2
    let cy = h / 2
    let n = w * h
    let out_data : Array[Complex] = Array::make(n, Complex::{ re: 0.0F, im: 0.0F })
    for i in 0..<n {
      let y = i / w
      let x = i % w
      let dist = @math.powf(
        Float::from_int((x - cx) * (x - cx) + (y - cy) * (y - cy)),
        0.5F,
      )
      let gain = filter_gain(filter_type, dist, cutoff, band_width)
      out_data[i] = Complex::{
        re: shifted.data[i].re * gain,
        im: shifted.data[i].im * gain,
      }
    }
    let filtered_fft = FFTResult::{ width: w, height: h, data: out_data }
    let unshifted = fft_shift(filtered_fft)
    filtered.push(unshifted)
  }
  if color_ch == 1 {
    return ifft_2d(filtered[0])
  }
  let pw = filtered[0].width
  let ph = filtered[0].height
  let n = pw * ph
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for c in 0..<color_ch {
    let channel_img = ifft_2d(filtered[c])
    for i in 0..<n {
      out[i * ch + c] = channel_img.data[i]
    }
  }
  if ch == 4 {
    for i in 0..<n {
      out[i * 4 + 3] = img.data[i * 4 + 3]
    }
  }
  @core.Image::{ width: pw, height: ph, channels: ch, data: Bytes::from_array(out) }
}

///|
/// 理想滤波器增益
fn filter_gain(
  filter_type : FreqFilterType,
  dist : Float,
  cutoff : Float,
  band_width : Float
) -> Float {
  match filter_type {
    LowPass => if dist <= cutoff { 1.0F } else { 0.0F }
    HighPass => if dist >= cutoff { 1.0F } else { 0.0F }
    BandPass => {
      let lo = cutoff - band_width / 2.0F
      let hi = cutoff + band_width / 2.0F
      if dist >= lo && dist <= hi { 1.0F } else { 0.0F }
    }
    BandStop => {
      let lo = cutoff - band_width / 2.0F
      let hi = cutoff + band_width / 2.0F
      if dist >= lo && dist <= hi { 0.0F } else { 1.0F }
    }
  }
}

///|
/// 高斯频域滤波。使用高斯传递函数而非理想滤波器，更平滑。
pub fn freq_filter_gaussian(
  img : @core.Image,
  filter_type : FreqFilterType,
  cutoff : Float,
  band_width~ : Float = 0.0F
) -> @core.Image raise @core.LoadError {
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("freq_filter_gaussian 仅支持 channels=1/3/4")
  }
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { 1 }
  let ffts = fft_2d(img)
  let filtered : Array[FFTResult] = []
  for c in 0..<color_ch {
    let shifted = fft_shift(ffts[c])
    let w = shifted.width
    let h = shifted.height
    let cx = w / 2
    let cy = h / 2
    let n = w * h
    let out_data : Array[Complex] = Array::make(n, Complex::{ re: 0.0F, im: 0.0F })
    for i in 0..<n {
      let y = i / w
      let x = i % w
      let dist = @math.powf(
        Float::from_int((x - cx) * (x - cx) + (y - cy) * (y - cy)),
        0.5F,
      )
      let gain = gaussian_gain(filter_type, dist, cutoff, band_width)
      out_data[i] = Complex::{
        re: shifted.data[i].re * gain,
        im: shifted.data[i].im * gain,
      }
    }
    let filtered_fft = FFTResult::{ width: w, height: h, data: out_data }
    let unshifted = fft_shift(filtered_fft)
    filtered.push(unshifted)
  }
  if color_ch == 1 {
    return ifft_2d(filtered[0])
  }
  let pw = filtered[0].width
  let ph = filtered[0].height
  let n = pw * ph
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for c in 0..<color_ch {
    let channel_img = ifft_2d(filtered[c])
    for i in 0..<n {
      out[i * ch + c] = channel_img.data[i]
    }
  }
  if ch == 4 {
    for i in 0..<n {
      out[i * 4 + 3] = img.data[i * 4 + 3]
    }
  }
  @core.Image::{ width: pw, height: ph, channels: ch, data: Bytes::from_array(out) }
}

///|
/// 高斯传递函数增益
fn gaussian_gain(
  filter_type : FreqFilterType,
  dist : Float,
  cutoff : Float,
  band_width : Float
) -> Float {
  let eps = 0.0001F
  let c2 = cutoff * cutoff
  match filter_type {
    LowPass => @math.expf(-(dist * dist) / (c2 + eps))
    HighPass => 1.0F - @math.expf(-(dist * dist) / (c2 + eps))
    BandPass => {
      let lp = @math.expf(-(dist * dist) / (c2 + eps))
      let lo = cutoff - band_width / 2.0F
      let lp2 = @math.expf(-(dist * dist) / (lo * lo + eps))
      lp2 - lp
    }
    BandStop => {
      let lp = @math.expf(-(dist * dist) / (c2 + eps))
      let lo = cutoff - band_width / 2.0F
      let lp2 = @math.expf(-(dist * dist) / (lo * lo + eps))
      1.0F - (lp2 - lp)
    }
  }
}