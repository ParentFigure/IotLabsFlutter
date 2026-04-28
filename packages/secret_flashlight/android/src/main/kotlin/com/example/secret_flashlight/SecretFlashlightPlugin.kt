package com.example.secret_flashlight

import android.content.Context
import android.hardware.camera2.CameraAccessException
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class SecretFlashlightPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var cameraManager: CameraManager
    private var torchCameraId: String? = null
    private var isTorchEnabled = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        cameraManager = binding.applicationContext.getSystemService(
            Context.CAMERA_SERVICE,
        ) as CameraManager
        torchCameraId = findTorchCameraId()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "toggleTorch" -> toggleTorch(result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun toggleTorch(result: Result) {
        val cameraId = torchCameraId
        if (cameraId == null) {
            result.error(
                "NO_FLASHLIGHT",
                "This Android device does not have a controllable flashlight.",
                null,
            )
            return
        }

        try {
            isTorchEnabled = !isTorchEnabled
            cameraManager.setTorchMode(cameraId, isTorchEnabled)
            result.success(isTorchEnabled)
        } catch (exception: CameraAccessException) {
            result.error(
                "CAMERA_ACCESS_ERROR",
                exception.localizedMessage,
                null,
            )
        } catch (exception: SecurityException) {
            result.error(
                "CAMERA_PERMISSION_ERROR",
                exception.localizedMessage,
                null,
            )
        }
    }

    private fun findTorchCameraId(): String? {
        return try {
            cameraManager.cameraIdList.firstOrNull { cameraId ->
                val characteristics = cameraManager.getCameraCharacteristics(
                    cameraId,
                )
                val hasFlash = characteristics.get(
                    CameraCharacteristics.FLASH_INFO_AVAILABLE,
                ) == true
                val lensFacing = characteristics.get(
                    CameraCharacteristics.LENS_FACING,
                )

                hasFlash && lensFacing == CameraCharacteristics.LENS_FACING_BACK
            }
        } catch (exception: CameraAccessException) {
            null
        } catch (exception: SecurityException) {
            null
        }
    }

    private companion object {
        const val CHANNEL_NAME = "secret_flashlight"
    }
}
