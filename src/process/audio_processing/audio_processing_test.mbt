// v45.0.0 音频处理测试

///|
test "create_default_audio_config: 基本测试" {
  let config = create_default_audio_config()
  assert_true(config.task_type is AudioTaskType::SpeechRecognition)
  assert_true(config.asr_model is ASRModelType::Whisper)
}

///|
test "create_audio_data: 基本测试" {
  let audio = create_audio_data([0.5, 0.3, 0.8, 0.1], 16000, 1)
  assert_eq(audio.num_samples, 4)
  assert_eq(audio.sample_rate, 16000)
  assert_eq(audio.num_channels, 1)
}

///|
test "generate_sine_wave: 基本测试" {
  let audio = generate_sine_wave(440.0, 0.01, 16000, 1.0)
  assert_true(audio.num_samples > 0)
  assert_eq(audio.sample_rate, 16000)
}

///|
test "pre_emphasis: 基本测试" {
  let audio = create_audio_data([0.5, 0.3, 0.8, 0.1], 16000, 1)
  let result = pre_emphasis(audio, 0.97)
  assert_eq(result.num_samples, 4)
  assert_eq(result.sample_rate, 16000)
}

///|
test "compute_mfcc: 基本测试" {
  let audio = generate_sine_wave(440.0, 0.05, 16000, 1.0)
  let config = create_default_audio_config()
  let features = compute_mfcc(audio, config)
  assert_true(features.num_frames > 0)
  assert_true(features.feature_dim > 0)
}

///|
test "compute_mel_spectrogram: 基本测试" {
  let audio = generate_sine_wave(440.0, 0.05, 16000, 1.0)
  let config = create_default_audio_config()
  let features = compute_mel_spectrogram(audio, config)
  assert_true(features.num_frames > 0)
  assert_true(features.feature_dim > 0)
}

///|
test "recognize_speech: 基本测试" {
  let audio = generate_sine_wave(440.0, 0.05, 16000, 1.0)
  let config = create_default_audio_config()
  let result = recognize_speech(audio, config)
  assert_true(result.transcript.length() >= 0)
  assert_true(result.confidence >= 0.0)
}

///|
test "identify_speaker: 基本测试" {
  let audio = generate_sine_wave(440.0, 0.05, 16000, 1.0)
  let result = identify_speaker(audio, ["speaker1", "speaker2"])
  assert_true(result.speaker_id.length() >= 0)
  assert_true(result.num_speakers >= 0)
}

///|
test "recognize_speech_emotion: 基本测试" {
  let audio = generate_sine_wave(440.0, 0.05, 16000, 1.0)
  let result = recognize_speech_emotion(audio)
  assert_true(result.confidence >= 0.0)
}

///|
test "extract_music_features: 基本测试" {
  let audio = generate_sine_wave(440.0, 0.1, 16000, 1.0)
  let result = extract_music_features(audio)
  assert_true(result.tempo >= 0.0)
  assert_true(result.key.length() >= 0)
}

///|
test "detect_speech_activity: 基本测试" {
  let audio = generate_sine_wave(440.0, 0.1, 16000, 1.0)
  let result = detect_speech_activity(audio, 0.5)
  assert_true(result.num_segments >= 0)
  assert_true(result.speech_ratio >= 0.0)
}

///|
test "audio_processing_report_to_string: 基本测试" {
  let audio = create_audio_data([0.5, 0.3], 16000, 1)
  let config = create_default_audio_config()
  let report = audio_processing_report_to_string(
    AudioTaskType::SpeechRecognition,
    config,
    audio,
    "测试结果",
  )
  assert_true(report.length() > 0)
}
