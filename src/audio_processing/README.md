# walkzzz/image/process/audio_processing

> 音频信号处理

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 20 |
| 公开类型 | 13 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum ASRModelType {
pub(all) struct AudioClassificationResult {
pub(all) struct AudioConfig {
pub(all) struct AudioData {
pub(all) enum AudioFeatureType {
pub(all) struct AudioFeatures {
pub(all) enum AudioTaskType {
pub(all) struct MusicIRResult {
pub(all) struct SpeakerIdentificationResult {
pub(all) struct SpeechEmotionResult {
pub(all) enum SpeechEmotionType {
pub(all) struct SpeechRecognitionResult {
pub(all) struct VADResult {
```

## API

```moonbit
pub fn audio_processing_report_to_string(AudioTaskType, AudioConfig, AudioData, String) -> String
pub fn compute_mel_spectrogram(AudioData, AudioConfig) -> AudioFeatures
pub fn compute_mfcc(AudioData, AudioConfig) -> AudioFeatures
pub fn create_audio_data(Array[Double], Int, Int) -> AudioData
pub fn create_default_audio_config() -> AudioConfig
pub fn detect_speech_activity(AudioData, Double) -> VADResult
pub fn extract_music_features(AudioData) -> MusicIRResult
pub fn generate_sine_wave(Double, Double, Int, Double) -> AudioData
pub fn identify_speaker(AudioData, Array[String]) -> SpeakerIdentificationResult
pub fn pre_emphasis(AudioData, Double) -> AudioData
pub fn recognize_speech(AudioData, AudioConfig) -> SpeechRecognitionResult
pub fn recognize_speech_emotion(AudioData) -> SpeechEmotionResult
pub fn ASRModelType::equal(Self, Self) -> Bool
pub fn ASRModelType::not_equal(Self, Self) -> Bool
pub fn AudioFeatureType::equal(Self, Self) -> Bool
pub fn AudioFeatureType::not_equal(Self, Self) -> Bool
pub fn AudioTaskType::equal(Self, Self) -> Bool
pub fn AudioTaskType::not_equal(Self, Self) -> Bool
pub fn SpeechEmotionType::equal(Self, Self) -> Bool
pub fn SpeechEmotionType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
