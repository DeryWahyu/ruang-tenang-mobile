import Flutter
import UIKit
import AVFoundation
import Speech

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var voiceChannel: FlutterMethodChannel?
  private var recorder: AVAudioRecorder?
  private var recordingURL: URL?
  private var speechEngine: AVAudioEngine?
  private var speechTask: SFSpeechRecognitionTask?
  private var speechRequest: SFSpeechAudioBufferRecognitionRequest?
  private var dictationResult: FlutterResult?
  private var latestTranscription = ""
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    voiceChannel = FlutterMethodChannel(name: "ruang_tenang/voice", binaryMessenger: engineBridge.applicationRegistrar.binaryMessenger)
    voiceChannel?.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(FlutterError(code: "unavailable", message: "Voice unavailable", details: nil)); return }
      switch call.method {
      case "dictate": self.dictate(result)
      case "startRecording": self.startRecording(result)
      case "stopRecording": self.stopRecording(result)
      case "cancelRecording": self.cancelRecording(); result(nil)
      default: result(FlutterMethodNotImplemented)
      }
    }
  }

  private func startRecording(_ result: @escaping FlutterResult) {
    AVAudioSession.sharedInstance().requestRecordPermission { [weak self] allowed in
      DispatchQueue.main.async {
        guard let self = self else { return }
        guard allowed else { result(FlutterError(code: "permission_denied", message: "Izin mikrofon ditolak", details: nil)); return }
        guard self.recorder == nil else { result(FlutterError(code: "busy", message: "Rekaman sedang berjalan", details: nil)); return }
        do {
          let session = AVAudioSession.sharedInstance()
          try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
          try session.setActive(true)
          let url = FileManager.default.temporaryDirectory.appendingPathComponent("ruang_tenang_voice_\(UUID().uuidString).m4a")
          let settings: [String: Any] = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 44100, AVNumberOfChannelsKey: 1, AVEncoderBitRateKey: 64000]
          let recorder = try AVAudioRecorder(url: url, settings: settings)
          guard recorder.record() else { throw NSError(domain: "Voice", code: 1) }
          self.recorder = recorder
          self.recordingURL = url
          result(nil)
        } catch { result(FlutterError(code: "recording_failed", message: error.localizedDescription, details: nil)) }
      }
    }
  }

  private func stopRecording(_ result: FlutterResult) {
    guard let recorder = recorder, let url = recordingURL else { result(FlutterError(code: "not_recording", message: "Belum ada rekaman", details: nil)); return }
    recorder.stop()
    self.recorder = nil
    self.recordingURL = nil
    result(url.path)
  }

  private func cancelRecording() {
    recorder?.stop()
    recorder = nil
    if let url = recordingURL { try? FileManager.default.removeItem(at: url) }
    recordingURL = nil
  }

  private func dictate(_ result: @escaping FlutterResult) {
    guard dictationResult == nil else { result(FlutterError(code: "busy", message: "Dikte sedang berjalan", details: nil)); return }
    SFSpeechRecognizer.requestAuthorization { [weak self] status in
      DispatchQueue.main.async {
        guard let self = self else { return }
        guard status == .authorized else { result(FlutterError(code: "permission_denied", message: "Izin pengenalan suara ditolak", details: nil)); return }
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
          DispatchQueue.main.async {
            guard allowed else { result(FlutterError(code: "permission_denied", message: "Izin mikrofon ditolak", details: nil)); return }
            self.beginDictation(result)
          }
        }
      }
    }
  }

  private func beginDictation(_ result: @escaping FlutterResult) {
    guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "id-ID")), recognizer.isAvailable else { result(FlutterError(code: "unavailable", message: "Pengenalan suara belum tersedia", details: nil)); return }
    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.record, mode: .measurement, options: .duckOthers)
      try session.setActive(true, options: .notifyOthersOnDeactivation)
      let engine = AVAudioEngine()
      let request = SFSpeechAudioBufferRecognitionRequest()
      request.shouldReportPartialResults = true
      let input = engine.inputNode
      input.installTap(onBus: 0, bufferSize: 1024, format: input.outputFormat(forBus: 0)) { buffer, _ in request.append(buffer) }
      engine.prepare()
      try engine.start()
      speechEngine = engine
      speechRequest = request
      dictationResult = result
      latestTranscription = ""
      speechTask = recognizer.recognitionTask(with: request) { [weak self] recognition, error in
        DispatchQueue.main.async {
          guard let self = self, self.dictationResult != nil else { return }
          if let recognition = recognition {
            self.latestTranscription = recognition.bestTranscription.formattedString
            if recognition.isFinal { self.finishDictation(self.latestTranscription) }
          } else if let error = error { self.finishDictationError(error) }
        }
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 18) { [weak self] in
        if let self = self, self.dictationResult != nil { self.finishDictation(self.latestTranscription) }
      }
    } catch { finishDictationError(error, fallback: result) }
  }

  private func finishDictation(_ text: String) {
    let result = dictationResult
    dictationResult = nil
    speechEngine?.inputNode.removeTap(onBus: 0)
    speechEngine?.stop()
    speechRequest?.endAudio()
    speechTask?.cancel()
    speechEngine = nil
    speechRequest = nil
    speechTask = nil
    latestTranscription = ""
    result?(text)
  }

  private func finishDictationError(_ error: Error, fallback: FlutterResult? = nil) {
    let result = dictationResult ?? fallback
    dictationResult = nil
    speechEngine?.inputNode.removeTap(onBus: 0)
    speechEngine?.stop()
    speechTask?.cancel()
    speechEngine = nil
    speechRequest = nil
    speechTask = nil
    if !latestTranscription.isEmpty { result?(latestTranscription) }
    else { result?(FlutterError(code: "speech_failed", message: error.localizedDescription, details: nil)) }
    latestTranscription = ""
  }
}
