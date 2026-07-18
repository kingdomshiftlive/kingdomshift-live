package com.kingdomshift.live

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.MediaRecorder
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.util.DisplayMetrics
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.kingdomshift.live/screen_record"
    private val REQUEST_CODE = 1001

    private var mediaProjectionManager: MediaProjectionManager? = null
    private var mediaProjection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var mediaRecorder: MediaRecorder? = null
    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        mediaProjectionManager =
            getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> {
                    pendingPermissionResult = result
                    val serviceIntent = Intent(this, ScreenRecordForegroundService::class.java)
                    ContextCompat.startForegroundService(this, serviceIntent)
                    val intent = mediaProjectionManager!!.createScreenCaptureIntent()
                    startActivityForResult(intent, REQUEST_CODE)
                }
                "startRecording" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.success(false)
                    } else {
                        val started = startScreenRecording(path)
                        result.success(started)
                    }
                }
                "stopRecording" -> {
                    stopScreenRecording()
                    stopService(Intent(this, ScreenRecordForegroundService::class.java))
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                try {
                    mediaProjection = mediaProjectionManager!!.getMediaProjection(resultCode, data)
                    pendingPermissionResult?.success(true)
                } catch (e: Exception) {
                    e.printStackTrace()
                    stopService(Intent(this, ScreenRecordForegroundService::class.java))
                    pendingPermissionResult?.success(false)
                }
            } else {
                stopService(Intent(this, ScreenRecordForegroundService::class.java))
                pendingPermissionResult?.success(false)
            }
            pendingPermissionResult = null
        }
    }

    private fun startScreenRecording(path: String): Boolean {
        if (mediaProjection == null) return false
        try {
            val metrics = DisplayMetrics()
            windowManager.defaultDisplay.getRealMetrics(metrics)
            val width = metrics.widthPixels
            val height = metrics.heightPixels
            val density = metrics.densityDpi

            mediaRecorder = MediaRecorder().apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setVideoSource(MediaRecorder.VideoSource.SURFACE)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setVideoEncoder(MediaRecorder.VideoEncoder.H264)
                setVideoSize(width, height)
                setVideoEncodingBitRate(6 * 1024 * 1024)
                setVideoFrameRate(30)
                setOutputFile(path)
                prepare()
            }

            virtualDisplay = mediaProjection!!.createVirtualDisplay(
                "KingdomShiftScreenRecord",
                width, height, density,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                mediaRecorder!!.surface,
                null, null
            )

            mediaRecorder!!.start()
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    private fun stopScreenRecording() {
        try {
            mediaRecorder?.stop()
            mediaRecorder?.reset()
        } catch (e: Exception) {
            e.printStackTrace()
        }
        mediaRecorder?.release()
        mediaRecorder = null
        virtualDisplay?.release()
        virtualDisplay = null
        mediaProjection?.stop()
        mediaProjection = null
    }
}
