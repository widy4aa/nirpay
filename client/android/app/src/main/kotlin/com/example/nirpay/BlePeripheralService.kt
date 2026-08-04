package com.example.nirpay

import android.app.Service
import android.bluetooth.*
import android.bluetooth.le.*
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.ParcelUuid
import android.util.Log
import java.util.UUID

/**
 * BLE GATT Server Service — HP jadi receiver yang bisa di-scan & connect.
 * Auto-restart advertising jika gagal atau berhenti.
 */
class BlePeripheralService : Service() {

    companion object {
        private const val TAG = "BlePeripheral"
        private const val ADVERTISE_NAME = "NirPay-Receiver"
        private const val RESTART_DELAY_MS = 2000L
        private const val MAX_RESTART_ATTEMPTS = 10
        private const val KEEPALIVE_INTERVAL_MS = 5000L

        val SERVICE_UUID: UUID = UUID.fromString("12345678-1234-1234-1234-123456789abc")
        val RX_CHAR_UUID: UUID = UUID.fromString("12345678-1234-1234-1234-123456789ab2")
        val ACK_CHAR_UUID: UUID = UUID.fromString("12345678-1234-1234-1234-123456789ab3")
    }

    private var bluetoothAdapter: BluetoothAdapter? = null
    private var advertiser: BluetoothLeAdvertiser? = null
    private var gattServer: BluetoothGattServer? = null
    private var currentDevice: BluetoothDevice? = null
    private var ackCharacteristic: BluetoothGattCharacteristic? = null

    private val handler = Handler(Looper.getMainLooper())
    private var restartCount = 0
    private var isAdvertising = false
    private var isRunning = false

    var onDataReceived: ((String) -> Unit)? = null
    var onStateChanged: ((String) -> Unit)? = null

    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): BlePeripheralService = this@BlePeripheralService
    }

    override fun onBind(intent: Intent?): IBinder = binder

    fun start() {
        Log.d(TAG, "=== STARTING BLE PERIPHERAL ===")
        isRunning = true
        restartCount = 0

        val manager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = manager.adapter

        if (bluetoothAdapter == null) {
            Log.e(TAG, "Bluetooth not supported")
            onStateChanged?.invoke("error:Bluetooth tidak didukung")
            return
        }

        if (!bluetoothAdapter!!.isEnabled) {
            Log.e(TAG, "Bluetooth is OFF")
            onStateChanged?.invoke("error:Bluetooth mati")
            return
        }

        advertiser = bluetoothAdapter!!.bluetoothLeAdvertiser
        if (advertiser == null) {
            Log.e(TAG, "BLE advertising not supported")
            onStateChanged?.invoke("error:BLE advertising tidak didukung")
            return
        }

        val deviceName = bluetoothAdapter?.name ?: "Unknown"
        Log.d(TAG, "Device: $deviceName")
        onStateChanged?.invoke("deviceName:$deviceName")

        setupGattServer()
        startAdvertisingWithRetry()
        startKeepAlive()
    }

    fun stop() {
        Log.d(TAG, "=== STOPPING BLE PERIPHERAL ===")
        isRunning = false
        isAdvertising = false

        handler.removeCallbacksAndMessages(null)

        try { advertiser?.stopAdvertising(advertiseCallback) } catch (e: Exception) {
            Log.e(TAG, "Stop advertise error: ${e.message}")
        }
        try { gattServer?.close() } catch (e: Exception) {
            Log.e(TAG, "Close GATT error: ${e.message}")
        }

        advertiser = null
        gattServer = null
        currentDevice = null
        onStateChanged?.invoke("stopped")
    }

    fun sendAck(transactionId: String) {
        val ack = """{"status":"ACK","transactionId":"$transactionId","receivedAt":"${System.currentTimeMillis()}"}"""
        val char = ackCharacteristic ?: return
        val device = currentDevice ?: return

        char.value = ack.toByteArray()
        gattServer?.notifyCharacteristicChanged(device, char, false)
        Log.d(TAG, "ACK sent to ${device.name}")
    }

    // ─── Advertising with Auto-Restart ───

    private fun startAdvertisingWithRetry() {
        if (!isRunning) return

        try {
            advertiser?.stopAdvertising(advertiseCallback)
        } catch (_: Exception) {}

        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
            .setConnectable(true)
            .setTimeout(0)
            .build()

        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(false)
            .addServiceUuid(ParcelUuid(SERVICE_UUID))
            .build()

        val scanResponse = AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .build()

        Log.d(TAG, "Starting advertising (attempt ${restartCount + 1})...")
        advertiser?.startAdvertising(settings, data, scanResponse, advertiseCallback)
    }

    private fun scheduleRestart() {
        if (!isRunning) return
        if (restartCount >= MAX_RESTART_ATTEMPTS) {
            Log.e(TAG, "Max restart attempts reached!")
            onStateChanged?.invoke("error:Gagal setelah $MAX_RESTART_ATTEMPTS percobaan")
            return
        }

        restartCount++
        val delay = RESTART_DELAY_MS * restartCount
        Log.d(TAG, "Scheduling restart #${restartCount} in ${delay}ms")

        handler.postDelayed({
            if (isRunning) {
                Log.d(TAG, "Restarting advertising...")
                startAdvertisingWithRetry()
            }
        }, delay)
    }

    // ─── Keep-Alive Timer ───

    private fun startKeepAlive() {
        handler.postDelayed(object : Runnable {
            override fun run() {
                if (!isRunning) return

                if (!isAdvertising) {
                    Log.w(TAG, "Keep-alive: advertising stopped, restarting...")
                    restartCount = 0
                    startAdvertisingWithRetry()
                } else {
                    Log.d(TAG, "Keep-alive: advertising OK")
                }

                handler.postDelayed(this, KEEPALIVE_INTERVAL_MS)
            }
        }, KEEPALIVE_INTERVAL_MS)
    }

    // ─── GATT Server ───

    private fun setupGattServer() {
        val manager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        gattServer = manager.openGattServer(this, gattServerCallback)

        val service = BluetoothGattService(SERVICE_UUID, BluetoothGattService.SERVICE_TYPE_PRIMARY)

        val rxChar = BluetoothGattCharacteristic(
            RX_CHAR_UUID,
            BluetoothGattCharacteristic.PROPERTY_WRITE or BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE,
            BluetoothGattCharacteristic.PERMISSION_WRITE
        )
        service.addCharacteristic(rxChar)

        ackCharacteristic = BluetoothGattCharacteristic(
            ACK_CHAR_UUID,
            BluetoothGattCharacteristic.PROPERTY_NOTIFY or BluetoothGattCharacteristic.PROPERTY_READ,
            BluetoothGattCharacteristic.PERMISSION_READ
        )
        service.addCharacteristic(ackCharacteristic!!)

        gattServer?.addService(service)
        Log.d(TAG, "GATT server setup done")
    }

    private val gattServerCallback = object : BluetoothGattServerCallback() {

        override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
            val stateStr = when (newState) {
                BluetoothProfile.STATE_CONNECTED -> "CONNECTED"
                BluetoothProfile.STATE_DISCONNECTED -> "DISCONNECTED"
                else -> "UNKNOWN($newState)"
            }
            Log.d(TAG, "Connection: ${device.name} (${device.address}) → $stateStr")

            if (newState == BluetoothProfile.STATE_CONNECTED) {
                currentDevice = device
                onStateChanged?.invoke("connected:${device.name ?: device.address}")
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                currentDevice = null
                onStateChanged?.invoke("advertising") // Kembali ke advertising
            }
        }

        override fun onCharacteristicWriteRequest(
            device: BluetoothDevice, requestId: Int,
            characteristic: BluetoothGattCharacteristic,
            preparedWrite: Boolean, responseNeeded: Boolean,
            offset: Int, value: ByteArray?
        ) {
            if (characteristic.uuid == RX_CHAR_UUID && value != null) {
                val data = String(value, Charsets.UTF_8)
                Log.d(TAG, "📦 Data from ${device.name}: $data")
                onDataReceived?.invoke(data)

                if (responseNeeded) {
                    gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, null)
                }
            }
        }

        override fun onDescriptorWriteRequest(
            device: BluetoothDevice, requestId: Int,
            descriptor: BluetoothGattDescriptor,
            preparedWrite: Boolean, responseNeeded: Boolean,
            offset: Int, value: ByteArray?
        ) {
            if (responseNeeded) {
                gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, null)
            }
        }

        override fun onNotificationSent(device: BluetoothDevice, status: Int) {
            Log.d(TAG, "📤 Notification sent to ${device.name}, status=$status")
        }

        override fun onServiceAdded(status: Int, service: BluetoothGattService) {
            Log.d(TAG, "Service added: ${service.uuid}, status=$status")
        }
    }

    // ─── Advertising Callback ───

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
            isAdvertising = true
            restartCount = 0
            Log.d(TAG, "✅ ADVERTISING STARTED — '$ADVERTISE_NAME'")
            onStateChanged?.invoke("advertising")
        }

        override fun onStartFailure(errorCode: Int) {
            isAdvertising = false
            val msg = when (errorCode) {
                ADVERTISE_FAILED_DATA_TOO_LARGE -> "Data too large"
                ADVERTISE_FAILED_TOO_MANY_ADVERTISERS -> "Too many advertisers"
                ADVERTISE_FAILED_ALREADY_STARTED -> "Already started"
                ADVERTISE_FAILED_INTERNAL_ERROR -> "Internal error"
                ADVERTISE_FAILED_FEATURE_UNSUPPORTED -> "Feature unsupported"
                else -> "Unknown error $errorCode"
            }
            Log.e(TAG, "❌ ADVERTISING FAILED: $msg (code=$errorCode)")
            onStateChanged?.invoke("error:$msg")

            // Auto-restart
            if (errorCode != ADVERTISE_FAILED_FEATURE_UNSUPPORTED) {
                scheduleRestart()
            }
        }
    }

    override fun onDestroy() {
        stop()
        super.onDestroy()
    }
}
