package com.example.gel_rule_app

import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.BatteryManager
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "rulegel/downloads")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "saveToDownloads" -> {
                            val path = call.argument<String>("path") ?: error("Missing path")
                            val fileName = call.argument<String>("fileName") ?: File(path).name
                            val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
                            val subDir = call.argument<String>("subDir")
                            result.success(saveToDownloads(path, fileName, mimeType, subDir))
                        }
                        "openFile" -> {
                            val path = call.argument<String>("path") ?: error("Missing path")
                            val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
                            openFile(path, mimeType)
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Throwable) {
                    result.error("download_failed", error.message, null)
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "rulegel/device")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "getBatteryLevel" -> result.success(batteryLevel())
                        "getSupportedRefreshRates" -> result.success(supportedRefreshRates())
                        "setPreferredRefreshRate" -> {
                            val hz = call.argument<Double>("hz")
                                ?: call.argument<Int>("hz")?.toDouble()
                                ?: 60.0
                            setPreferredRefreshRate(hz.toFloat())
                            result.success(null)
                        }
                        "getSupportedAbis" -> result.success(Build.SUPPORTED_ABIS.toList())
                        "getPrimaryAbi" -> result.success(Build.SUPPORTED_ABIS.firstOrNull() ?: "armeabi-v7a")
                        else -> result.notImplemented()
                    }
                } catch (error: Throwable) {
                    result.error("device_failed", error.message, null)
                }
            }
    }

    private fun saveToDownloads(path: String, fileName: String, mimeType: String, subDir: String? = null): String {
        val source = File(path)
        val relPath = if (!subDir.isNullOrBlank()) {
            val clean = subDir.trim().removePrefix("/").removeSuffix("/")
            "${Environment.DIRECTORY_DOWNLOADS}/$clean"
        } else {
            Environment.DIRECTORY_DOWNLOADS
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                put(MediaStore.Downloads.MIME_TYPE, mimeType)
                put(MediaStore.Downloads.RELATIVE_PATH, relPath)
                put(MediaStore.Downloads.IS_PENDING, 1)
            }
            val resolver = applicationContext.contentResolver
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: error("Could not create Downloads entry")
            resolver.openOutputStream(uri)?.use { output ->
                FileInputStream(source).use { input -> input.copyTo(output) }
            } ?: error("Could not open Downloads output stream")
            values.clear()
            values.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            return fileName
        }

        @Suppress("DEPRECATION")
        val baseDownloads = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        val targetDir = if (!subDir.isNullOrBlank()) File(baseDownloads, subDir.trim()) else baseDownloads
        targetDir.mkdirs()
        val destination = File(targetDir, fileName)
        FileInputStream(source).use { input ->
            FileOutputStream(destination).use { output -> input.copyTo(output) }
        }
        return destination.absolutePath
    }

    private fun batteryLevel(): Int? {
        val manager = getSystemService(Context.BATTERY_SERVICE) as? BatteryManager ?: return null
        val level = manager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        return if (level in 0..100) level else null
    }

    private fun openFile(path: String, mimeType: String) {
        val file = File(path)
        val uri = FileProvider.getUriForFile(
            this,
            "${applicationContext.packageName}.fileprovider",
            file
        )
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, mimeType)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(Intent.createChooser(intent, "Open update"))
    }

    private fun supportedRefreshRates(): List<Double> {
        val display = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) display else windowManager.defaultDisplay
        return display?.supportedModes
            ?.map { it.refreshRate.toDouble() }
            ?.distinct()
            ?.sorted()
            ?: emptyList()
    }

    private fun setPreferredRefreshRate(targetHz: Float) {
        val display = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) display else windowManager.defaultDisplay
        val mode = display?.supportedModes?.minByOrNull {
            kotlin.math.abs(it.refreshRate - targetHz)
        } ?: return
        val attrs = window.attributes
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            attrs.preferredDisplayModeId = mode.modeId
        } else {
            @Suppress("DEPRECATION")
            attrs.preferredRefreshRate = mode.refreshRate
        }
        window.attributes = attrs
    }
}
