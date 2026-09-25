import 'dart:io';
import 'package:flutter/services.dart';

class VoiceInputService {
  static const MethodChannel _channel = MethodChannel('ruang_tenang/voice');

  Future<String> dictate() async =>
      (await _channel.invokeMethod<String>('dictate'))?.trim() ?? '';
  Future<void> startRecording() =>
      _channel.invokeMethod<void>('startRecording');
  Future<File> stopRecording() async {
    final path = await _channel.invokeMethod<String>('stopRecording');
    if (path == null || path.isEmpty) {
      throw PlatformException(
        code: 'empty_recording',
        message: 'Rekaman kosong',
      );
    }
    return File(path);
  }

  Future<void> cancelRecording() =>
      _channel.invokeMethod<void>('cancelRecording');
}
