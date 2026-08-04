package com.example.nirpay

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val HCE_CHANNEL = "nirpay.com/hce"
    private val BLE_CHANNEL = "nirpay.com/ble"
    private val prefsName = "FlutterSharedPreferences"

    private var bleService: BlePeripheralService? = null
    private var bleBound = false
    private var bleResult: MethodChannel.Result? = null

    private val bleConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            android.util.Log.d("MainActivity", "BLE service connected")
            val binder = service as BlePeripheralService.LocalBinder
            bleService = binder.getService()
            bleBound = true

            bleService?.onDataReceived = { data ->
                runOnUiThread {
                    flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                        MethodChannel(messenger, BLE_CHANNEL).invokeMethod("onDataReceived", data)
                    }
                }
            }

            bleService?.onStateChanged = { state ->
                runOnUiThread {
                    flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                        MethodChannel(messenger, BLE_CHANNEL).invokeMethod("onStateChanged", state)
                    }
                }
            }

            // Start BLE peripheral
            bleService?.start()

            // Return success to Flutter
            bleResult?.success(true)
            bleResult = null
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            android.util.Log.d("MainActivity", "BLE service disconnected")
            bleService = null
            bleBound = false
        }

        override fun onBindingDied(name: ComponentName?) {
            android.util.Log.e("MainActivity", "BLE service binding died")
            bleResult?.error("BINDING_DIED", "Service binding died", null)
            bleResult = null
        }

        override fun onNullBinding(name: ComponentName?) {
            android.util.Log.e("MainActivity", "BLE service returned null binding")
            bleResult?.error("NULL_BINDING", "Service returned null binding", null)
            bleResult = null
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ─── HCE Channel (NFC) ───
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HCE_CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "setNfcData") {
                val data = call.argument<String>("data")
                val transactionId = call.argument<String>("transactionId")
                if (data != null) {
                    val prefs = getSharedPreferences(prefsName, Context.MODE_PRIVATE)
                    prefs.edit()
                        .putString("flutter.hce_data", data)
                        .putString("flutter.hce_transaction_id", transactionId ?: "")
                        .putString("flutter.hce_status", "READY_TO_SEND")
                        .putString("flutter.hce_ack_status", "WAITING_FOR_READ")
                        .putLong("flutter.hce_prepared_at", System.currentTimeMillis())
                        .remove("flutter.hce_sent_at")
                        .remove("flutter.hce_ack_received_at")
                        .apply()
                    result.success(true)
                } else {
                    result.error("UNAVAILABLE", "Data is null", null)
                }
            } else if (call.method == "getNfcTransferStatus") {
                val prefs = getSharedPreferences(prefsName, Context.MODE_PRIVATE)
                result.success(hashMapOf(
                    "transactionId" to (prefs.getString("flutter.hce_transaction_id", "") ?: ""),
                    "status" to (prefs.getString("flutter.hce_status", "IDLE") ?: "IDLE"),
                    "ackStatus" to (prefs.getString("flutter.hce_ack_status", "WAITING_FOR_READ") ?: "WAITING_FOR_READ"),
                    "preparedAt" to prefs.getLong("flutter.hce_prepared_at", 0L),
                    "sentAt" to prefs.getLong("flutter.hce_sent_at", 0L),
                    "ackReceivedAt" to prefs.getLong("flutter.hce_ack_received_at", 0L)
                ))
            } else if (call.method == "markNoAck") {
                val prefs = getSharedPreferences(prefsName, Context.MODE_PRIVATE)
                prefs.edit()
                    .putString("flutter.hce_status", "NO_ACK")
                    .putString("flutter.hce_ack_status", "NO_ACK")
                    .apply()
                result.success(true)
            } else {
                result.notImplemented()
            }
        }

        // ─── BLE Peripheral Channel ───
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BLE_CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "startReceiver" -> {
                    android.util.Log.d("MainActivity", "startReceiver called")
                    bleResult = result
                    try {
                        val intent = Intent(this, BlePeripheralService::class.java)
                        val bindResult = bindService(intent, bleConnection, Context.BIND_AUTO_CREATE)
                        android.util.Log.d("MainActivity", "bindService result: $bindResult")
                        if (!bindResult) {
                            android.util.Log.e("MainActivity", "bindService returned false")
                            result.error("BIND_FAILED", "Failed to bind BLE service", null)
                            bleResult = null
                        }
                    } catch (e: Exception) {
                        android.util.Log.e("MainActivity", "bindService exception: ${e.message}")
                        result.error("BIND_EXCEPTION", e.message, null)
                        bleResult = null
                    }
                }
                "stopReceiver" -> {
                    bleService?.stop()
                    if (bleBound) {
                        unbindService(bleConnection)
                        bleBound = false
                    }
                    result.success(true)
                }
                "sendAck" -> {
                    val txId = call.argument<String>("transactionId") ?: ""
                    bleService?.sendAck(txId)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        if (bleBound) {
            unbindService(bleConnection)
            bleBound = false
        }
        super.onDestroy()
    }
}
