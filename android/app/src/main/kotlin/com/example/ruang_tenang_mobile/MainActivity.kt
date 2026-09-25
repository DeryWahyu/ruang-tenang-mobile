package com.example.ruang_tenang_mobile

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaRecorder
import android.os.Build
import android.speech.RecognizerIntent
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private var recorder: MediaRecorder? = null
    private var recordingFile: File? = null
    private var pendingPermissionResult: MethodChannel.Result? = null
    private var pendingDictationResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ruang_tenang/voice").setMethodCallHandler { call, result ->
            when (call.method) {
                "dictate" -> {
                    if (pendingDictationResult != null) { result.error("busy", "Dikte sedang berjalan", null); return@setMethodCallHandler }
                    try {
                        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "id-ID")
                            putExtra(RecognizerIntent.EXTRA_PROMPT, "Ceritakan dengan suaramu")
                        }
                        pendingDictationResult = result
                        startActivityForResult(intent, 702)
                    } catch (error: Exception) {
                        pendingDictationResult = null
                        result.error("unavailable", error.message, null)
                    }
                }
                "startRecording" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
                        pendingPermissionResult = result
                        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECORD_AUDIO), 703)
                    } else startRecording(result)
                }
                "stopRecording" -> {
                    val file = recordingFile
                    val active = recorder
                    if (file == null || active == null) { result.error("not_recording", "Belum ada rekaman", null); return@setMethodCallHandler }
                    try {
                        active.stop()
                        active.release()
                        recorder = null
                        recordingFile = null
                        result.success(file.absolutePath)
                    } catch (error: Exception) {
                        active.release()
                        recorder = null
                        recordingFile = null
                        file.delete()
                        result.error("recording_failed", error.message, null)
                    }
                }
                "cancelRecording" -> {
                    try { recorder?.stop() } catch (_: Exception) { }
                    recorder?.release()
                    recorder = null
                    recordingFile?.delete()
                    recordingFile = null
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startRecording(result: MethodChannel.Result) {
        if (recorder != null) { result.error("busy", "Rekaman sedang berjalan", null); return }
        var file: File? = null
        var active: MediaRecorder? = null
        try {
            val nextFile = File.createTempFile("ruang_tenang_voice_", ".m4a", cacheDir)
            file = nextFile
            @Suppress("DEPRECATION")
            val nextRecorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) MediaRecorder(this) else MediaRecorder()
            active = nextRecorder
            nextRecorder.setAudioSource(MediaRecorder.AudioSource.MIC)
            nextRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
            nextRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            nextRecorder.setOutputFile(nextFile.absolutePath)
            nextRecorder.prepare()
            nextRecorder.start()
            recorder = nextRecorder
            recordingFile = nextFile
            result.success(null)
        } catch (error: Exception) {
            active?.release()
            file?.delete()
            result.error("recording_failed", error.message, null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 702) {
            val result = pendingDictationResult ?: return
            pendingDictationResult = null
            if (resultCode == Activity.RESULT_OK) result.success(data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)?.firstOrNull() ?: "")
            else result.success("")
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 703) {
            val result = pendingPermissionResult ?: return
            pendingPermissionResult = null
            if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) startRecording(result)
            else result.error("permission_denied", "Izin mikrofon ditolak", null)
        }
    }
}
