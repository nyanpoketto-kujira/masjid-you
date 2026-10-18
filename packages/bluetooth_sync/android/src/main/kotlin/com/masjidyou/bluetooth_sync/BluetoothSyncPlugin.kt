package com.masjidyou.bluetooth_sync

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothServerSocket
import android.bluetooth.BluetoothSocket
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.UUID
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledFuture
import java.util.concurrent.ScheduledThreadPoolExecutor
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Transport Bluetooth Classic (RFCOMM) untuk Masjid You.
 *
 * Host (TV): startHost() -> accept-loop, satu Remote pada satu waktu.
 * Client (Remote): startDiscovery() -> connect().
 *
 * Framing: 4 byte big-endian panjang + payload (host & client sama).
 */
class BluetoothSyncPlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler, ActivityAware {

    private lateinit var applicationContext: Context
    private var activityBinding: ActivityPluginBinding? = null
    private var permListener: PluginRegistry.RequestPermissionsResultListener? = null
    private var activityResultListener: PluginRegistry.ActivityResultListener? = null

    private var methodChannel: MethodChannel? = null

    @Volatile
    private var eventSink: EventChannel.EventSink? = null

    // Loop accept() host, connect() client, dan tulis frame dipisah supaya
    // connect() tidak menunggu accept-loop dan dua send() tidak interleave.
    private val hostExecutor = Executors.newSingleThreadExecutor()
    private val clientExecutor = Executors.newSingleThreadExecutor()
    private val writeExecutor = Executors.newSingleThreadExecutor()
    private val timeoutExecutor = ScheduledThreadPoolExecutor(1).apply {
        removeOnCancelPolicy = true
    }

    private val mainHandler = Handler(Looper.getMainLooper())

    private var adapter: BluetoothAdapter? = null

    @Volatile
    private var serverSocket: BluetoothServerSocket? = null

    /** Socket hasil accept() (host) atau hasil connect() (client). */
    @Volatile
    private var activeSocket: BluetoothSocket? = null

    @Volatile
    private var hostRunning = false

    @Volatile
    private var connectPending = false

    @Volatile
    private var connectSocket: BluetoothSocket? = null

    private val discoveryActive = AtomicBoolean(false)
    private var discoveryReceiver: DiscoveryReceiver? = null
    private var discoveryTimeout: Runnable? = null

    private var pendingPermission: MethodChannel.Result? = null
    private var pendingEnableResult: MethodChannel.Result? = null
    private var pendingDiscoverable: MethodChannel.Result? = null
    private var discoverableTimeout: ScheduledFuture<*>? = null

    private companion object {
        const val CHANNEL = "com.masjidyou/bluetooth_sync"
        const val EVENT_CHANNEL = "com.masjidyou/bluetooth_sync/events"

        // UUID unik aplikasi untuk RFCOMM (harus sama di host & client).
        val SERVICE_UUID: UUID = UUID.fromString("8f5f0b1a-2c3d-4e5f-8a9b-1c2d3e4f5a6b")

        const val PERM_REQ_CODE = 7001
        const val DISCOVERABLE_REQ_CODE = 7002
        const val REQUEST_ENABLE_REQ_CODE = 7003

        const val MAX_FRAME_BYTES = 64 * 1024 * 1024
        const val CONNECT_TIMEOUT_MS = 15_000L

        // Android membatasi durasi discoverable ke maksimal 300 detik.
        const val MAX_DISCOVERABLE_SECONDS = 300

        // Buffer watchdog: dialog durasi N detik + buffer ini.
        const val DISCOVERABLE_WATCHDOG_BUFFER_MS = 15_000L
    }

    // ---- FlutterPlugin lifecycle --------------------------------------

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler(this)
        EventChannel(binding.binaryMessenger, EVENT_CHANNEL).setStreamHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        eventSink = null
        stopDiscoveryInternal(emitFinished = false)
        stopHostInternal()
        disconnectInternal()
        hostExecutor.shutdown()
        clientExecutor.shutdown()
        writeExecutor.shutdown()
        timeoutExecutor.shutdownNow()
        completePendingPermission(errorMessage = "Engine detach")
        completePendingEnable(false)
        completePendingDiscoverable(Activity.RESULT_CANCELED)
    }

    // ---- ActivityAware -------------------------------------------------

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        detachActivityBinding()
        attachActivityBinding(binding)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        // Config change: binding lama sudah hilang, cukup daftar ke binding baru.
        attachActivityBinding(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // Config change: binding lama sudah hilang, jangan lepas listener dari
        // binding yang tidak valid — cukup set null.
        activityBinding = null
        permListener = null
        activityResultListener = null
        // Dialog discoverable milik Activity lama ikut hilang -> hasilnya tak
        // akan pernah sampai. Jawab false sekarang agar request berikutnya
        // tidak kena DISCOVERABLE_PENDING.
        completePendingDiscoverable(Activity.RESULT_CANCELED)
    }

    override fun onDetachedFromActivity() {
        detachActivityBinding()
        // Tanpa Activity dialog izin tak akan pernah dibalas -> jangan biarkan
        // Dart menunggu selamanya.
        completePendingPermission(errorMessage = "Activity tidak tersedia")
        completePendingEnable(false)
        completePendingDiscoverable(Activity.RESULT_CANCELED)
    }

    private fun attachActivityBinding(binding: ActivityPluginBinding) {
        // Guard: pending dari Activity sebelumnya (config change) bersifat
        // yatim — listener lama sudah lepas. Tutup sebelum pasang yang baru.
        completePendingDiscoverable(Activity.RESULT_CANCELED)
        activityBinding = binding
        val perm = PluginRegistry.RequestPermissionsResultListener { requestCode, _, grantResults ->
            if (requestCode == PERM_REQ_CODE) {
                val granted = grantResults.isNotEmpty() &&
                    grantResults.all { it == PackageManager.PERMISSION_GRANTED }
                completePendingPermission(grantedResult = granted)
                true
            } else false
        }
        val actResult = PluginRegistry.ActivityResultListener { requestCode, resultCode, _ ->
            when (requestCode) {
                DISCOVERABLE_REQ_CODE -> {
                    // Dialog discoverable: RESULT_CANCELED = user menolak / gagal.
                    val accepted = resultCode != Activity.RESULT_CANCELED
                    completePendingDiscoverable(
                        if (accepted) Activity.RESULT_OK else Activity.RESULT_CANCELED
                    )
                    true
                }
                REQUEST_ENABLE_REQ_CODE -> {
                    completePendingEnable(getAdapter()?.isEnabled == true)
                    true
                }
                else -> false
            }
        }
        permListener = perm
        activityResultListener = actResult
        binding.addRequestPermissionsResultListener(perm)
        binding.addActivityResultListener(actResult)
    }

    private fun detachActivityBinding() {
        val binding = activityBinding
        permListener?.let { binding?.removeRequestPermissionsResultListener(it) }
        activityResultListener?.let { binding?.removeActivityResultListener(it) }
        permListener = null
        activityResultListener = null
        activityBinding = null
    }

    // ---- Method call handler ------------------------------------------

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSupported" -> {
                result.success(getAdapter() != null)
            }
            "isEnabled" -> {
                result.success(getAdapter()?.isEnabled == true)
            }
            "enable" -> {
                enable(result)
            }
            "hasPermission" -> {
                val mode = call.argument<String>("mode") ?: "client"
                result.success(hasPermission(mode))
            }
            "requestPermission" -> {
                val mode = call.argument<String>("mode") ?: "client"
                requestRuntimePermission(mode, result)
            }
            "makeDiscoverable" -> {
                val seconds = (call.argument<Int>("seconds") ?: 120)
                    .coerceIn(1, MAX_DISCOVERABLE_SECONDS)
                makeDiscoverable(seconds, result)
            }
            "startHost" -> {
                val serviceName = call.argument<String>("serviceName") ?: "MasjidYou"
                startHost(serviceName)
                result.success(null)
            }
            "stopHost" -> {
                stopHostInternal()
                result.success(null)
            }
            "startDiscovery" -> {
                val timeoutMs = call.argument<Int>("timeoutMs") ?: 15000
                startDiscovery(timeoutMs)
                result.success(null)
            }
            "stopDiscovery" -> {
                stopDiscoveryInternal(emitFinished = true)
                result.success(null)
            }
            "connect" -> {
                val address = call.argument<String>("address")
                if (address.isNullOrBlank()) {
                    result.error("INVALID_ADDRESS", "address kosong", null)
                    return
                }
                val accepted = connect(address)
                result.success(accepted)
            }
            "disconnect" -> {
                disconnectInternal()
                result.success(null)
            }
            "send" -> {
                val bytes = call.argument<ByteArray>("bytes")
                if (bytes == null) {
                    result.error("NO_DATA", "bytes kosong", null)
                    return
                }
                try {
                    writeExecutor.execute {
                        try {
                            sendLocked(bytes)
                            mainHandler.post { result.success(null) }
                        } catch (e: Exception) {
                            mainHandler.post {
                                result.error("SEND_FAILED", e.message ?: "Send gagal", null)
                            }
                        }
                    }
                } catch (e: Exception) {
                    result.error("SEND_FAILED", e.message ?: "Send gagal", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    // ---- Event channel ------------------------------------------------

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun postEvent(map: Map<String, Any?>) {
        mainHandler.post {
            try {
                eventSink?.success(map)
            } catch (_: Exception) {
                // Sink sudah dicabut; abaikan.
            }
        }
    }

    private fun postError(message: String) {
        postEvent(mapOf("type" to "error", "error" to message))
    }

    // ---- Adapter & izin -----------------------------------------------

    private fun getAdapter(): BluetoothAdapter? {
        if (adapter != null) return adapter
        val manager = applicationContext.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        adapter = manager?.adapter
        return adapter
    }

    private fun enable(result: MethodChannel.Result) {
        val adapter = getAdapter()
        if (adapter == null) {
            result.success(false)
            return
        }
        if (adapter.isEnabled) {
            result.success(true)
            return
        }
        if (pendingEnableResult != null) {
            // Sudah ada dialog aktif; jawab yang baru dengan status sekarang.
            result.success(false)
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // API 31+: app tidak bisa menyalakan BT sendiri; gunakan Intent.
            val activity = activityBinding?.activity
            if (activity == null) {
                result.success(false)
                return
            }
            try {
                pendingEnableResult = result
                val enableIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                @Suppress("DEPRECATION")
                activity.startActivityForResult(enableIntent, REQUEST_ENABLE_REQ_CODE)
            } catch (e: Exception) {
                completePendingEnable(false)
            }
        } else {
            @Suppress("DEPRECATION")
            val enabled = try {
                adapter.enable()
            } catch (e: SecurityException) {
                false
            }
            result.success(enabled)
        }
    }

    /** Android 12+ butuh CONNECT + (SCAN client / ADVERTISE host); lama: lokasi. */
    private fun hasPermission(mode: String): Boolean {
        val ctx = applicationContext
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val hasConnect =
                ctx.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
            val rolePermission = if (mode == "host") {
                Manifest.permission.BLUETOOTH_ADVERTISE
            } else {
                Manifest.permission.BLUETOOTH_SCAN
            }
            hasConnect && ctx.checkSelfPermission(rolePermission) == PackageManager.PERMISSION_GRANTED
        } else {
            ctx.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun neededPermissions(mode: String): Array<String> {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (mode == "host") {
                arrayOf(Manifest.permission.BLUETOOTH_CONNECT, Manifest.permission.BLUETOOTH_ADVERTISE)
            } else {
                arrayOf(Manifest.permission.BLUETOOTH_CONNECT, Manifest.permission.BLUETOOTH_SCAN)
            }
        } else {
            arrayOf(Manifest.permission.ACCESS_FINE_LOCATION)
        }
    }

    private fun requestRuntimePermission(mode: String, result: MethodChannel.Result) {
        val ctx = applicationContext
        val missing = neededPermissions(mode)
            .filter { ctx.checkSelfPermission(it) != PackageManager.PERMISSION_GRANTED }
        if (missing.isEmpty()) {
            result.success(true)
            return
        }
        val activity = activityBinding?.activity
        if (activity == null) {
            result.error("NO_ACTIVITY", "butuh Activity untuk minta izin", null)
            return
        }
        if (pendingPermission != null) {
            // Hanya satu dialog izin dalam satu waktu.
            result.error("PERMISSION_PENDING", "permintaan izin lain sedang berjalan", null)
            return
        }
        pendingPermission = result
        try {
            activity.requestPermissions(missing.toTypedArray(), PERM_REQ_CODE)
        } catch (e: Exception) {
            completePendingPermission(errorMessage = e.message ?: "Permintaan izin gagal")
        }
    }

    private fun completePendingPermission(grantedResult: Boolean? = null, errorMessage: String? = null) {
        val pending = pendingPermission ?: return
        pendingPermission = null
        if (errorMessage != null) {
            pending.error("PERMISSION_FAILED", errorMessage, null)
        } else {
            pending.success(grantedResult == true)
        }
    }

    private fun completePendingEnable(enabled: Boolean) {
        val pending = pendingEnableResult ?: return
        pendingEnableResult = null
        pending.success(enabled)
    }

    /**
     * Munculkan dialog "buat perangkat terlihat" (semua versi Android) dan
     * baru jawab `true` setelah user menyetujui. `false` bila ditolak/tidak
     * ada Activity. Bila Activity dilepas sebelum hasil datang, watchdog
     * menjawab `false` supaya Dart tidak menggantung.
     */
    private fun makeDiscoverable(seconds: Int, result: MethodChannel.Result) {
        val adapter = getAdapter()
        if (adapter == null) {
            result.error("UNSUPPORTED", "Bluetooth tidak didukung", null)
            return
        }
        if (!adapter.isEnabled) {
            result.error("BT_DISABLED", "Bluetooth mati", null)
            return
        }
        if (pendingDiscoverable != null) {
            result.error("DISCOVERABLE_PENDING", "dialog discoverable masih terbuka", null)
            return
        }
        val activity = activityBinding?.activity
        if (activity == null) {
            result.error("NO_ACTIVITY", "butuh Activity untuk membuat perangkat terlihat", null)
            return
        }
        val discoverableIntent = Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE).apply {
            putExtra(BluetoothAdapter.EXTRA_DISCOVERABLE_DURATION, seconds)
        }
        pendingDiscoverable = result
        discoverableTimeout?.cancel(false)
        // Watchdog harus > durasi dialog (seconds*1000 + buffer) supaya tidak
        // menembak saat Activity config-change meninggalkan dialog yatim.
        val watchdogMs = seconds * 1000L + DISCOVERABLE_WATCHDOG_BUFFER_MS
        discoverableTimeout = timeoutExecutor.schedule({
            completePendingDiscoverable(Activity.RESULT_CANCELED)
        }, watchdogMs, TimeUnit.MILLISECONDS)
        try {
            @Suppress("DEPRECATION")
            activity.startActivityForResult(discoverableIntent, DISCOVERABLE_REQ_CODE)
        } catch (e: Exception) {
            completePendingDiscoverable(Activity.RESULT_CANCELED)
        }
    }

    private fun completePendingDiscoverable(resultCode: Int) {
        val pending = pendingDiscoverable ?: return
        pendingDiscoverable = null
        discoverableTimeout?.cancel(false)
        discoverableTimeout = null
        // Selalu success(false) untuk RESULT_CANCELED (termasuk timeout/watchdog
        // dan Activity detach) — tidak mengirim error supaya Dart tidak
        // memicu PlatformException; host cukup anggap false.
        if (resultCode == Activity.RESULT_CANCELED) {
            pending.success(false)
        } else {
            pending.success(true)
        }
    }

    // ---- Host (TV) -----------------------------------------------------

    private fun startHost(serviceName: String) {
        val adapter = getAdapter() ?: run {
            postError("Bluetooth tidak didukung")
            return
        }
        if (hostRunning) return
        if (!adapter.isEnabled) {
            postError("Bluetooth mati")
            return
        }
        // Android 12+: listenUsingInsecureRfcomm butuh BLUETOOTH_CONNECT.
        if (!hasPermission("host")) {
            postError("Izin Bluetooth belum diberikan")
            return
        }
        hostRunning = true
        hostExecutor.execute { acceptLoop(adapter, serviceName) }
    }

    private fun acceptLoop(adapter: BluetoothAdapter, serviceName: String) {
        try {
            serverSocket = adapter.listenUsingInsecureRfcommWithServiceRecord(serviceName, SERVICE_UUID)
            postEvent(mapOf("type" to "listening"))
            while (hostRunning && !Thread.currentThread().isInterrupted) {
                val sock = try {
                    serverSocket?.accept() ?: break
                } catch (e: IOException) {
                    // accept() gagal -> server ditutup atau error adapter.
                    break
                }
                activeSocket = sock
                postEvent(
                    mapOf(
                        "type" to "connected",
                        "address" to remoteAddress(sock),
                        "name" to remoteName(sock),
                    )
                )
                readLoop(sock)
                if (activeSocket === sock) activeSocket = null
                closeQuietly(sock)
                postEvent(mapOf("type" to "disconnected"))
            }
        } catch (e: IOException) {
            if (hostRunning) postError(e.message ?: "Host error")
        } catch (e: SecurityException) {
            if (hostRunning) postError(e.message ?: "Izin Bluetooth ditolak")
        } finally {
            serverSocket = null
            if (hostRunning) hostRunning = false
        }
    }

    private fun stopHostInternal() {
        hostRunning = false
        val server = serverSocket
        serverSocket = null
        try {
            server?.close()
        } catch (_: IOException) {
        }
        // Client yang sedang tersambung harus ikut ditutup supaya readLoop
        // dan accept-loop bisa keluar.
        val sock = activeSocket
        activeSocket = null
        closeQuietly(sock)
        // Beri tahu Dart host kalau ada socket aktif yang ditutup supaya
        // keluar dari state connected.
        if (sock != null) postEvent(mapOf("type" to "disconnected"))
    }

    // ---- Client (Remote) ----------------------------------------------

    private fun startDiscovery(timeoutMs: Int) {
        val adapter = getAdapter()
        if (adapter == null) {
            postError("Bluetooth tidak didukung")
            return
        }
        if (discoveryActive.get()) return

        // Gagal-soft bila izin kurang.
        if (!hasPermission("client")) {
            postError("Izin Bluetooth belum diberikan")
            postEvent(mapOf("type" to "discoveryFinished"))
            return
        }

        discoveryActive.set(true)

        val receiver = DiscoveryReceiver()
        discoveryReceiver = receiver
        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_FOUND)
            addAction(BluetoothAdapter.ACTION_DISCOVERY_STARTED)
            addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        }
        try {
            applicationContext.registerReceiver(receiver, filter)
        } catch (e: Exception) {
            postError(e.message ?: "Gagal mendaftarkan receiver discovery")
            discoveryActive.set(false)
            discoveryReceiver = null
            postEvent(mapOf("type" to "discoveryFinished"))
            return
        }
        try {
            if (adapter.isDiscovering) adapter.cancelDiscovery()
            adapter.startDiscovery()
        } catch (e: SecurityException) {
            finishDiscovery()
            postError(e.message ?: "Izin scan Bluetooth ditolak")
            return
        }

        val timeout = Runnable { finishDiscovery() }
        discoveryTimeout = timeout
        mainHandler.postDelayed(timeout, timeoutMs.toLong())
    }

    private inner class DiscoveryReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                BluetoothDevice.ACTION_FOUND -> {
                    val device: BluetoothDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
                    } else {
                        @Suppress("DEPRECATION")
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    }
                    if (device != null) {
                        // Nama bisa disembunyikan sampai discovery selesai
                        // (BLUETOOTH_CONNECT) -> kirim apa adanya, Dart
                        // menampilkan "?" alih-alih membuang perangkat.
                        val address = try {
                            device.address
                        } catch (_: SecurityException) {
                            null
                        } ?: return
                        val name = try {
                            device.name
                        } catch (_: SecurityException) {
                            null
                        }
                        val bonded = try {
                            device.bondState == BluetoothDevice.BOND_BONDED
                        } catch (_: SecurityException) {
                            false
                        }
                        postEvent(
                            mapOf(
                                "type" to "discovered",
                                "address" to address,
                                "name" to name,
                                "bonded" to bonded,
                            )
                        )
                    }
                }
                BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                    finishDiscovery()
                }
            }
        }
    }

    /** Selesaikan discovery sekali saja dan emit `discoveryFinished`. */
    private fun finishDiscovery() {
        if (!discoveryActive.getAndSet(false)) return
        discoveryTimeout?.let { mainHandler.removeCallbacks(it) }
        discoveryTimeout = null
        try {
            getAdapter()?.cancelDiscovery()
        } catch (_: Exception) {
        }
        try {
            discoveryReceiver?.let { applicationContext.unregisterReceiver(it) }
        } catch (_: Exception) {
        }
        discoveryReceiver = null
        postEvent(mapOf("type" to "discoveryFinished"))
    }

    private fun stopDiscoveryInternal(emitFinished: Boolean) {
        if (discoveryActive.getAndSet(false)) {
            try {
                getAdapter()?.cancelDiscovery()
            } catch (_: Exception) {
            }
            try {
                discoveryReceiver?.let { applicationContext.unregisterReceiver(it) }
            } catch (_: Exception) {
            }
            discoveryReceiver = null
            discoveryTimeout?.let { mainHandler.removeCallbacks(it) }
            discoveryTimeout = null
        }
        if (emitFinished) {
            postEvent(mapOf("type" to "discoveryFinished"))
        }
    }

    private fun connect(address: String): Boolean {
        val adapter = getAdapter()
        if (adapter == null) {
            postError("Bluetooth tidak didukung")
            return false
        }
        if (!hasPermission("client")) {
            postError("Izin Bluetooth belum diberikan")
            return false
        }
        if (connectPending) return false
        // Tutup socket lama sebelum mulai koneksi baru (cegah dua socket).
        if (activeSocket != null) disconnectInternal()
        connectPending = true
        clientExecutor.execute {
            val sock = try {
                if (adapter.isDiscovering) adapter.cancelDiscovery()
                val device = adapter.getRemoteDevice(address)
                device.createInsecureRfcommSocketToServiceRecord(SERVICE_UUID)
            } catch (e: Exception) {
                postError(e.message ?: "Koneksi gagal")
                connectPending = false
                return@execute
            }
            connectSocket = sock
            try {
                // connect() RFCOMM bisa menggantung: batasi waktu, socket
                // ditutup oleh watchdog sehingga connect() melempar.
                val watchdog = timeoutExecutor.schedule({
                    if (connectSocket === sock) closeQuietly(sock)
                }, CONNECT_TIMEOUT_MS, TimeUnit.MILLISECONDS)
                try {
                    sock.connect()
                } finally {
                    watchdog.cancel(false)
                    if (connectSocket === sock) connectSocket = null
                }
                if (!connectPending) {
                    // disconnect() dipanggil ketika connect sedang berjalan.
                    closeQuietly(sock)
                    return@execute
                }
                connectPending = false
                activeSocket = sock
                postEvent(
                    mapOf(
                        "type" to "connected",
                        "address" to address,
                        "name" to remoteName(sock),
                    )
                )
                readLoop(sock)
                if (activeSocket === sock) activeSocket = null
                closeQuietly(sock)
                postEvent(mapOf("type" to "disconnected"))
            } catch (e: Exception) {
                connectPending = false
                activeSocket = null
                closeQuietly(sock)
                postError(e.message ?: "Koneksi gagal")
            }
        }
        return true
    }

    private fun disconnectInternal() {
        connectPending = false
        val pendingSocket = connectSocket
        connectSocket = null
        closeQuietly(pendingSocket)
        val sock = activeSocket
        activeSocket = null
        closeQuietly(sock)
    }

    // ---- I/O frame ------------------------------------------------------

    private fun readLoop(sock: BluetoothSocket) {
        val input: InputStream = try {
            sock.inputStream
        } catch (e: Exception) {
            postError(e.message ?: "Stream tidak tersedia")
            return
        }
        try {
            while (true) {
                // Keluar bila socket sudah diganti/ditutup oleh disconnect/stop.
                if (activeSocket !== sock) break
                val lenBytes = ByteArray(4)
                readFully(input, lenBytes)
                val len = ((lenBytes[0].toInt() and 0xff) shl 24) or
                    ((lenBytes[1].toInt() and 0xff) shl 16) or
                    ((lenBytes[2].toInt() and 0xff) shl 8) or
                    (lenBytes[3].toInt() and 0xff)
                if (len <= 0 || len > MAX_FRAME_BYTES) {
                    throw IOException("Panjang frame tidak valid: $len")
                }
                val payload = ByteArray(len)
                readFully(input, payload)
                postEvent(mapOf("type" to "data", "bytes" to payload))
            }
        } catch (e: Exception) {
            // Penutupan yang disengaja (disconnect/stopHost) bukan error.
            if (activeSocket === sock) {
                postError(e.message ?: "Read error")
            }
        }
    }

    private fun readFully(input: InputStream, buffer: ByteArray) {
        var offset = 0
        while (offset < buffer.size) {
            val read = input.read(buffer, offset, buffer.size - offset)
            if (read < 0) throw IOException("Stream tertutup")
            offset += read
        }
    }

    /** Dipanggil hanya dari [writeExecutor] sehingga frame tidak interleave. */
    private fun sendLocked(payload: ByteArray) {
        val sock = activeSocket ?: throw IOException("Belum ada koneksi aktif")
        val out: OutputStream = sock.outputStream
        val len = payload.size
        out.write(
            byteArrayOf(
                ((len ushr 24) and 0xff).toByte(),
                ((len ushr 16) and 0xff).toByte(),
                ((len ushr 8) and 0xff).toByte(),
                (len and 0xff).toByte(),
            )
        )
        out.write(payload)
        out.flush()
    }

    // ---- Helper ---------------------------------------------------------

    private fun remoteAddress(sock: BluetoothSocket): String {
        return try {
            sock.remoteDevice.address
        } catch (_: SecurityException) {
            ""
        }
    }

    private fun remoteName(sock: BluetoothSocket): String {
        return try {
            sock.remoteDevice.name ?: "?"
        } catch (_: SecurityException) {
            "?"
        }
    }

    private fun closeQuietly(sock: BluetoothSocket?) {
        if (sock == null) return
        try {
            sock.close()
        } catch (_: Exception) {
        }
    }
}
