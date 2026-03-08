package com.ocr.app

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import com.benjaminwan.ocrlibrary.OcrEngine
import com.benjaminwan.ocrlibrary.OcrResult
import com.benjaminwan.ocrlibrary.TextBlock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ocr.app/rapidocr"
    private var ocrEngine: OcrEngine? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    val success = initializeOcr()
                    result.success(success)
                }
                "recognizeText" -> {
                    val imagePath = call.argument<String>("imagePath")
                    if (imagePath != null) {
                        val ocrResult = recognizeText(imagePath)
                        result.success(ocrResult)
                    } else {
                        result.error("INVALID_ARGUMENT", "imagePath is required", null)
                    }
                }
                "recognizeTextFromBytes" -> {
                    val imageBytes = call.argument<ByteArray>("imageBytes")
                    if (imageBytes != null) {
                        val ocrResult = recognizeTextFromBytes(imageBytes)
                        result.success(ocrResult)
                    } else {
                        result.error("INVALID_ARGUMENT", "imageBytes is required", null)
                    }
                }
                "release" -> {
                    releaseOcr()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun initializeOcr(): Boolean {
        return try {
            if (ocrEngine != null) return true
            
            ocrEngine = OcrEngine(applicationContext)
            
            Log.d("OCR", "OCR engine initialized successfully")
            true
        } catch (e: Exception) {
            Log.e("OCR", "Failed to initialize OCR engine", e)
            false
        }
    }

    private fun recognizeText(imagePath: String): Map<String, Any?> {
        val file = File(imagePath)
        if (!file.exists()) {
            return mapOf("text" to "", "confidence" to 0.0, "error" to "File not found")
        }

        var bitmap: Bitmap? = null
        return try {
            bitmap = BitmapFactory.decodeFile(imagePath)
                ?: return mapOf("text" to "", "confidence" to 0.0, "error" to "Failed to decode image")
            recognizeTextFromBitmap(bitmap)
        } catch (e: Exception) {
            Log.e("OCR", "Failed to recognize text from image", e)
            mapOf("text" to "", "confidence" to 0.0, "error" to e.message)
        } finally {
            bitmap?.recycle()
        }
    }

    private fun recognizeTextFromBytes(imageBytes: ByteArray): Map<String, Any?> {
        var bitmap: Bitmap? = null
        return try {
            bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                ?: return mapOf("text" to "", "confidence" to 0.0, "error" to "Failed to decode image bytes")
            recognizeTextFromBitmap(bitmap)
        } catch (e: Exception) {
            Log.e("OCR", "Failed to recognize text from bytes", e)
            mapOf("text" to "", "confidence" to 0.0, "error" to e.message)
        } finally {
            bitmap?.recycle()
        }
    }

    private fun recognizeTextFromBitmap(inputBitmap: Bitmap): Map<String, Any?> {
        if (ocrEngine == null) {
            val initialized = initializeOcr()
            if (!initialized) {
                return mapOf("text" to "", "confidence" to 0.0, "error" to "OCR engine not initialized")
            }
        }

        var outputBitmap: Bitmap? = null
        return try {
            val maxSideLen = 1024
            outputBitmap = Bitmap.createBitmap(inputBitmap.width, inputBitmap.height, Bitmap.Config.ARGB_8888)
            
            val result: OcrResult = ocrEngine!!.detect(inputBitmap, outputBitmap, maxSideLen)
            
            val textBlocks = result.textBlocks.map { block ->
                mapOf(
                    "text" to block.text,
                    "confidence" to getBlockConfidence(block),
                    "boundingBox" to getBoundingBox(block)
                )
            }
            
            val avgConfidence = if (textBlocks.isNotEmpty()) {
                textBlocks.map { it["confidence"] as Double }.average()
            } else {
                0.0
            }
            
            mapOf(
                "text" to result.strRes,
                "confidence" to avgConfidence,
                "blocks" to textBlocks,
                "detectTime" to result.detectTime
            )
        } catch (e: Exception) {
            Log.e("OCR", "OCR recognition failed", e)
            mapOf("text" to "", "confidence" to 0.0, "error" to e.message)
        } finally {
            outputBitmap?.recycle()
        }
    }
    
    private fun getBlockConfidence(block: TextBlock): Double {
        return if (block.charScores.isNotEmpty()) {
            block.charScores.average().toDouble()
        } else {
            block.boxScore.toDouble()
        }
    }
    
    private fun getBoundingBox(block: TextBlock): Map<String, Int> {
        val points = block.boxPoint
        if (points.isEmpty()) {
            return mapOf("left" to 0, "top" to 0, "right" to 0, "bottom" to 0)
        }
        
        var minX = Int.MAX_VALUE
        var minY = Int.MAX_VALUE
        var maxX = Int.MIN_VALUE
        var maxY = Int.MIN_VALUE
        
        for (point in points) {
            minX = minOf(minX, point.x)
            minY = minOf(minY, point.y)
            maxX = maxOf(maxX, point.x)
            maxY = maxOf(maxY, point.y)
        }
        
        return mapOf(
            "left" to minX,
            "top" to minY,
            "right" to maxX,
            "bottom" to maxY
        )
    }

    private fun releaseOcr() {
        ocrEngine = null
        System.gc()
        Log.d("OCR", "OCR engine released")
    }

    override fun onDestroy() {
        releaseOcr()
        super.onDestroy()
    }
}
