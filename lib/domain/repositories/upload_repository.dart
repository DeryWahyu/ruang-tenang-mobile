import 'dart:io';

abstract class UploadRepository {
  Future<String> uploadImage(File file);
  Future<String> uploadAudio(File file);
}