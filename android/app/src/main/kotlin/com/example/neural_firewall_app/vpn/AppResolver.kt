// AppResolver.kt
// Resolves the owning app (uid → package → label) of a captured connection so
// the IDS can attribute traffic and decide whether it is OS/system traffic.
//
// Packets read from TUN are OUTBOUND (device → internet), so the LOCAL side of
// the connection is the device (the TUN address + source port) and the REMOTE
// side is the destination server. ConnectivityManager.getConnectionOwnerUid()
// (API 29+) takes exactly that (protocol, local, remote) and returns the uid of
// the app that owns the socket — the supported way for a VPN to attribute flows.
package com.example.neural_firewall_app.vpn

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.os.Build
import android.os.Process
import android.system.OsConstants
import java.net.InetSocketAddress
import java.util.concurrent.ConcurrentHashMap

// Plain container describing who owns a connection.
data class ConnectionOwner(
    val appName: String,
    val appPackage: String,
    val isSystem: Boolean
)

class AppResolver(context: Context) {

    private val appContext = context.applicationContext
    private val connectivityManager =
        appContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    private val packageManager: PackageManager = appContext.packageManager

    // uid → owner. PackageManager lookups are comparatively expensive, so the
    // (stable) uid result is memoised for the life of the service.
    private val uidCache = ConcurrentHashMap<Int, ConnectionOwner>()

    // connection 4-tuple → owner. A single flow produces many packets; caching
    // by tuple keeps us from issuing a binder call (getConnectionOwnerUid) on
    // every packet. Successful results only — misses are retried.
    private val flowCache = ConcurrentHashMap<String, ConnectionOwner>()

    private val unknown = ConnectionOwner("", "", false)

    /**
     * Best-effort owner of an outbound connection. Returns [unknown] (all empty
     * / isSystem=false) when attribution isn't possible (pre-Android 10, ICMP,
     * connection already gone, or any error) — callers treat that as "not
     * system" and fall back to normal ML scoring.
     */
    fun resolve(
        protocol: Int,
        srcIp: String,
        srcPort: Int,
        dstIp: String,
        dstPort: Int,
    ): ConnectionOwner {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return unknown

        val ipProto = when (protocol) {
            6 -> OsConstants.IPPROTO_TCP
            17 -> OsConstants.IPPROTO_UDP
            else -> return unknown
        }

        val key = "$protocol:$srcPort:$dstIp:$dstPort"
        flowCache[key]?.let { return it }

        val owner = try {
            val uid = connectivityManager.getConnectionOwnerUid(
                ipProto,
                InetSocketAddress(srcIp, srcPort),
                InetSocketAddress(dstIp, dstPort),
            )
            if (uid == Process.INVALID_UID || uid < 0) {
                unknown
            } else {
                uidCache.getOrPut(uid) { ownerForUid(uid) }
            }
        } catch (e: Exception) {
            unknown
        }

        if (owner !== unknown) {
            // Bound memory: flows churn constantly, so clear rather than evict.
            if (flowCache.size > 4096) flowCache.clear()
            flowCache[key] = owner
        }
        return owner
    }

    private fun ownerForUid(uid: Int): ConnectionOwner {
        // Kernel / root / android-system UIDs have no user-facing package.
        if (uid < Process.FIRST_APPLICATION_UID) {
            return ConnectionOwner(systemUidName(uid), "android", true)
        }

        val packages = packageManager.getPackagesForUid(uid)
        if (packages.isNullOrEmpty()) {
            return ConnectionOwner("UID $uid", "", false)
        }

        val pkg = packages[0]
        return try {
            val info = packageManager.getApplicationInfo(pkg, 0)
            val label = packageManager.getApplicationLabel(info).toString()
            val isSystem = (info.flags and ApplicationInfo.FLAG_SYSTEM) != 0 ||
                (info.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0
            ConnectionOwner(label, pkg, isSystem)
        } catch (e: PackageManager.NameNotFoundException) {
            ConnectionOwner(pkg, pkg, false)
        }
    }

    private fun systemUidName(uid: Int): String = when (uid) {
        Process.ROOT_UID -> "Android (root)"
        Process.SYSTEM_UID -> "Android System"
        else -> "Android System"
    }
}
