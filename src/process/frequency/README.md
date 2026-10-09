# walkzzz/image/process/frequency

> 频率域处理（FFT、DCT、Haar 小波、频率滤波）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 29 |
| 公开类型 | 4 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub struct Complex {
pub struct FFTResult {
pub(all) enum FreqFilterType {
pub struct HaarWaveletResult {
```

## API

```moonbit
pub fn dct_2d(@types.Image) -> Array[Array[Double]]
pub fn dct_2d_16(@types.Image16) -> Array[Array[Double]]
pub fn dct_2d_f(@types.ImageF) -> Array[Array[Double]]
pub fn fft_2d(@types.Image) -> Array[FFTResult] raise @types.LoadError
pub fn fft_2d_16(@types.Image16) -> Array[FFTResult] raise @types.LoadError
pub fn fft_2d_f(@types.ImageF) -> Array[FFTResult] raise @types.LoadError
pub fn fft_magnitude(FFTResult, Bool) -> @types.Image
pub fn fft_magnitude_16(FFTResult, Bool) -> @types.Image16
pub fn fft_magnitude_f(FFTResult, Bool) -> @types.ImageF
pub fn fft_shift(FFTResult) -> FFTResult
pub fn freq_filter(@types.Image, FreqFilterType, Float, band_width? : Float) -> @types.Image raise @types.LoadError
pub fn freq_filter_gaussian(@types.Image, FreqFilterType, Float, band_width? : Float) -> @types.Image raise @types.LoadError
pub fn haar_denoise(@types.Image, threshold? : Float, soft? : Bool, levels? : Int) -> @types.Image raise @types.LoadError
pub fn haar_denoise_16(@types.Image16, threshold? : Float, soft? : Bool, levels? : Int) -> @types.Image16 raise @types.LoadError
pub fn haar_denoise_f(@types.ImageF, threshold? : Float, soft? : Bool, levels? : Int) -> @types.ImageF raise @types.LoadError
pub fn haar_inverse_transform_2d(HaarWaveletResult) -> @types.Image
pub fn haar_inverse_transform_2d_16(HaarWaveletResult) -> @types.Image16
pub fn haar_inverse_transform_2d_f(HaarWaveletResult) -> @types.ImageF
pub fn haar_transform_1d(Array[Float]) -> Array[Float]
pub fn haar_transform_2d(@types.Image, levels? : Int) -> HaarWaveletResult raise @types.LoadError
pub fn haar_transform_2d_16(@types.Image16, levels? : Int) -> HaarWaveletResult raise @types.LoadError
pub fn haar_transform_2d_f(@types.ImageF, levels? : Int) -> HaarWaveletResult raise @types.LoadError
pub fn idct_2d(Array[Array[Double]]) -> @types.Image
pub fn idct_2d_16(Array[Array[Double]]) -> @types.Image16
pub fn idct_2d_f(Array[Array[Double]]) -> @types.ImageF
pub fn ifft_2d(FFTResult) -> @types.Image
pub fn ifft_2d_16(FFTResult) -> @types.Image16
pub fn ifft_2d_f(FFTResult) -> @types.ImageF
pub fn ihaar_transform_1d(Array[Float]) -> Array[Float]
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
