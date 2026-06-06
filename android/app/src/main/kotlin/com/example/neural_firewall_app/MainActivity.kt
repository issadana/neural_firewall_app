package com.example.neural_firewall_app

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import com.example.neural_firewall_app.vpn.NeuralVpnService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val vpnChannelName = "com.neuralfw/vpn"
    private val packetChannelName = "com.neuralfw/packets"
    private val vpnPermissionRequestCode = 1001

    private var pendingVpnResult: MethodChannel.Result? = null

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

                    else -> result.notImplemented()
                }
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
