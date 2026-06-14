package com.example.neural_firewall_app

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.BatteryManager
import android.os.SystemClock
import com.example.neural_firewall_app.vpn.NeuralVpnService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val vpnChannelName = "com.neuralfw/vpn"
    private val packetChannelName = "com.neuralfw/packets"
    private val hardwareChannelName = "com.sentri.app/hardware"
    private val vpnPermissionRequestCode = 1001

    private var pendingVpnResult: MethodChannel.Result? = null

    // Hardware sampling does blocking I/O (/proc reads + a short CPU sampling
    // window), so it must run off the main thread to avoid ANRs.
    private val hardwareExecutor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, packetChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    NeuralVpnService.setEventSink { data -> events.success(data) }
                }
                override fun onCancel(arguments: Any?) {
                    NeuralVpnService.setEventSink(null)
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, vpnChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startVPN" -> startVpn(result)
                    "stopVPN" -> {
                        stopService(Intent(this, NeuralVpnService::class.java))
                        result.success(null)
                    }
                    "isVPNRunning" -> result.success(NeuralVpnService.isRunning)
                    "checkVPNPermission" -> result.success(VpnService.prepare(this) == null)
                    "requestVPNPermission" -> requestPermission(result)
                    "getNetworkInterfaces" -> result.success(emptyList<String>())

                    // ── IP blocking — called by Flutter when AI flags a threat ──
                    "blockIp" -> {
                        val ip = call.argument<String>("ip")
                        if (ip != null) {
                            NeuralVpnService.blockIp(ip)
                            result.success(null)
                        } else {
                            result.error("INVALID_ARG", "ip argument is required", null)
                        }
                    }
                    "unblockIp" -> {
                        val ip = call.argument<String>("ip")
                        if (ip != null) {
                            NeuralVpnService.unblockIp(ip)
                            result.success(null)
                        } else {
                            result.error("INVALID_ARG", "ip argument is required", null)
                        }
                    }
                    "isIpBlocked" -> {
                        val ip = call.argument<String>("ip")
                        result.success(if (ip != null) NeuralVpnService.isIpBlocked(ip) else false)
                    }
                    // Recovery: forget every block, including the persisted copy.
                    "clearAllBlockedIps" -> {
                        NeuralVpnService.clearAllBlockedIps()
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }

        // ── Hardware metrics — sampled on demand by the Flutter cubit ────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, hardwareChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getHardwareSnapshot" -> {
                        hardwareExecutor.execute {
                            val snapshot = collectHardwareSnapshot()
                            runOnUiThread { result.success(snapshot) }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Collects a point-in-time hardware snapshot. Keys match what
     * [HardwareLocalDataSource] expects: cpuUsage (Double, %), ramUsedMb (Int),
     * ramTotalMb (Int), batteryLevel (Double?, %). Each field is computed
     * defensively so a single failure can't take down the whole snapshot.
     */
    private fun collectHardwareSnapshot(): Map<String, Any?> {
        // ── RAM (device-wide) ───────────────────────────────────────────────
        var ramUsedMb = 0
        var ramTotalMb = 0
        try {
            val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val mi = ActivityManager.MemoryInfo()
            am.getMemoryInfo(mi)
            val bytesPerMb = 1024L * 1024L
            ramTotalMb = (mi.totalMem / bytesPerMb).toInt()
            ramUsedMb = ((mi.totalMem - mi.availMem) / bytesPerMb).toInt()
        } catch (_: Exception) {
        }

        // ── Battery level (%) ───────────────────────────────────────────────
        var batteryLevel: Double? = null
        try {
            val bm = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            val level = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
            if (level in 0..100) batteryLevel = level.toDouble()
        } catch (_: Exception) {
        }

        // ── CPU usage of this app's process, as a % of total device capacity ─
        // Device-wide /proc/stat is unreadable on Android 8+, so we measure the
        // app's own CPU consumption over a short window — which is what actually
        // matters for "how is the app behaving on this device".
        var cpuUsage = 0.0
        try {
            val cores = Runtime.getRuntime().availableProcessors().coerceAtLeast(1)
            val clockTicksPerSec = 100.0 // _SC_CLK_TCK is 100 on Android.
            val proc1 = readProcessCpuJiffies()
            val t1 = SystemClock.elapsedRealtime()
            Thread.sleep(400)
            val proc2 = readProcessCpuJiffies()
            val t2 = SystemClock.elapsedRealtime()
            val elapsedSec = (t2 - t1) / 1000.0
            if (proc1 >= 0 && proc2 >= 0 && elapsedSec > 0) {
                val usedSec = (proc2 - proc1) / clockTicksPerSec
                cpuUsage = (usedSec / (elapsedSec * cores) * 100.0).coerceIn(0.0, 100.0)
            }
        } catch (_: Exception) {
        }

        return mapOf(
            "cpuUsage" to cpuUsage,
            "ramUsedMb" to ramUsedMb,
            "ramTotalMb" to ramTotalMb,
            "batteryLevel" to batteryLevel,
        )
    }

    /** Returns utime + stime from /proc/self/stat in clock ticks, or -1 on failure. */
    private fun readProcessCpuJiffies(): Long {
        return try {
            val content = File("/proc/self/stat").readText()
            // The comm field (2nd) can contain spaces/parens, so parse after the
            // last ')'. The remainder begins at field 3 (state) == index 0, which
            // puts utime (field 14) at index 11 and stime (field 15) at index 12.
            val fields = content.substring(content.lastIndexOf(')') + 1)
                .trim()
                .split(Regex("\\s+"))
            fields[11].toLong() + fields[12].toLong()
        } catch (_: Exception) {
            -1L
        }
    }

    private fun startVpn(result: MethodChannel.Result) {
        val permissionIntent = VpnService.prepare(this)
        if (permissionIntent != null) {
            pendingVpnResult = result
            @Suppress("DEPRECATION")
            startActivityForResult(permissionIntent, vpnPermissionRequestCode)
        } else {
            startService(Intent(this, NeuralVpnService::class.java))
            result.success(null)
        }
    }

    private fun requestPermission(result: MethodChannel.Result) {
        val permissionIntent = VpnService.prepare(this)
        if (permissionIntent != null) {
            pendingVpnResult = result
            @Suppress("DEPRECATION")
            startActivityForResult(permissionIntent, vpnPermissionRequestCode)
        } else {
            result.success(true)
        }
    }

    @Suppress("DEPRECATION", "OVERRIDE_DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == vpnPermissionRequestCode) {
            val pending = pendingVpnResult
            pendingVpnResult = null
            if (resultCode == Activity.RESULT_OK) {
                startService(Intent(this, NeuralVpnService::class.java))
                pending?.success(null)
            } else {
                pending?.error("VPN_PERMISSION_DENIED", "User denied VPN permission", null)
            }
        }
    }
}
