package com.mygenie.online

import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import org.json.JSONObject

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "pinelabs_payment"
    private val REQUEST_CODE_PINE = 1001
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "startPayment") {

                    if (pendingResult != null) {
                        result.error("BUSY", "Payment already in progress", null)
                        return@setMethodCallHandler
                    }

                    val amount = call.argument<Int>("amount")
                    val billingRefNo = call.argument<String>("billingRefNo")

                    startHybridPayment(amount, billingRefNo, result)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun startHybridPayment(
        amount: Int?,
        billingRefNo: String?,
        result: MethodChannel.Result
    ) {
        try {
            // ---------- DETAIL ----------
            val detail = JSONObject().apply {
                put("BillingRefNo", billingRefNo)
                put("PaymentAmount", amount)      // paise
                put("TransactionType", 4001)      // ⭐ CARD SALE
            }

            // ---------- HEADER ----------
            val header = JSONObject().apply {
                put("MessageCode", 1001) // ⭐ REQUIRED
                put("ApplicationId", "7db7f4bcde57494792c4621dd540c39d")
                put("MethodId", "1001")
                put("UserId", "mygenie_user")
                put("VersionNo", "1.0")
            }

            val requestJson = JSONObject().apply {
                put("Header", header)
                put("Detail", detail)
            }

            // ---------- INTENT ----------
            val intent = Intent("com.pinelabs.masterapp.HYBRID_REQUEST").apply {
                setPackage("com.pinelabs.masterapp")
                putExtra("REQUEST_DATA", requestJson.toString())
                putExtra("packageName", applicationContext.packageName)
            }

            pendingResult = result
            startActivityForResult(intent, REQUEST_CODE_PINE)

        } catch (e: Exception) {
            pendingResult = null
            result.error("PINE_ERROR", e.message, null)
        }
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != REQUEST_CODE_PINE) return

        val result = pendingResult ?: return
        pendingResult = null

        try {
            val response = data?.getStringExtra("RESPONSE_DATA")
            result.success(mapOf("rawResponse" to response))
        } catch (e: Exception) {
            result.error("RESPONSE_ERROR", e.message, null)
        }
    }
}
