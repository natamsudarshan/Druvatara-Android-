package com.druvatara.guardian.vpn

import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.util.Log
import com.druvatara.guardian.policy.WebSafetyRules
import com.druvatara.guardian.policy.SafeZone
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.InetAddress
import java.net.InetSocketAddress
import java.nio.ByteBuffer
import java.nio.channels.FileChannel
import java.util.concurrent.ConcurrentHashMap

class VpnFilterEngine(
    private val context: Context,
    private val scope: CoroutineScope,
) {
    private val TAG = "VpnFilterEngine"
    private var vpnInterface: ParcelFileDescriptor? = null
    private var vpnThread: Thread? = null
    private var isRunning = false
    private var currentRules: WebSafetyRules = WebSafetyRules.getDefault()
    private val allowedDomains = ConcurrentHashMap<String, Boolean>()
    private val blockedDomains = ConcurrentHashMap<String, Boolean>()
    private val categoryCache = ConcurrentHashMap<String, String>()

    companion object {
        const val VPN_REQUEST_CODE = 1001
        private const val MTU = 1400
    }

    fun prepareVpn(activity: Activity) {
        val intent = VpnService.prepare(context)
        if (intent != null) {
            activity.startActivityForResult(intent, VPN_REQUEST_CODE)
        } else {
            onVpnPrepared()
        }
    }

    fun onVpnPrepared() {
        startVpn()
    }

    private fun startVpn() {
        if (isRunning) return

        val intent = Intent(context, VpnService::class.java)
        val builder = android.net.VpnService.Builder()
            .setSession("Druvatara Guardian")
            .setConfigureIntent(PendingIntent.getActivity(
                context, 0, Intent(context, VpnSettingsActivity::class.java), PendingIntent.FLAG_IMMUTABLE
            ))

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            builder.addAllowedApplication(context.packageName)
            builder.addDisallowedApplication("com.android.chrome")
        }

        try {
            vpnInterface = builder.establish()
            isRunning = true
            startPacketProcessing()
            Log.d(TAG, "VPN started successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start VPN", e)
            isRunning = false
        }
    }

    private fun startPacketProcessing() {
        vpnThread = Thread {
            val inputStream = FileInputStream(vpnInterface!!.fileDescriptor)
            val outputStream = FileOutputStream(vpnInterface!!.fileDescriptor)
            val packet = ByteBuffer.allocateDirect(MTU)

            while (isRunning && !Thread.currentThread().isInterrupted) {
                try {
                    val length = inputStream.read(packet.array())
                    if (length > 0) {
                        processPacket(packet, length, outputStream)
                    }
                } catch (e: Exception) {
                    if (isRunning) Log.e(TAG, "Error processing packet", e)
                }
            }
        }.apply { start() }
    }

    private fun processPacket(packet: ByteBuffer, length: Int, outputStream: FileOutputStream) {
        // Parse IP header to get destination
        val destIp = parseDestinationIp(packet, length)
        if (destIp != null) {
            val domain = resolveDomain(destIp)
            if (domain != null) {
                val decision = evaluateDomain(domain)
                if (decision == FilterDecision.BLOCK) {
                    Log.d(TAG, "Blocking domain: $domain")
                    return // Drop packet
                }
            }
        }

        // Forward packet
        try {
            packet.limit(length)
            outputStream.write(packet.array(), 0, length)
        } catch (e: Exception) {
            Log.e(TAG, "Error forwarding packet", e)
        }
    }

    private fun parseDestinationIp(packet: ByteBuffer, length: Int): String? {
        // Simplified IP parsing - in production use a proper packet parsing library
        return try {
            // IPv4 header is at least 20 bytes
            if (length < 20) return null
            val destBytes = ByteArray(4)
            packet.position(16)
            packet.get(destBytes)
            InetAddress.getByAddress(destBytes).hostAddress
        } catch (e: Exception) {
            null
        }
    }

    private fun resolveDomain(ip: String): String? {
        // In production, use a proper DNS cache or reverse DNS lookup
        // For now, return null to allow all traffic
        return null
    }

    private fun evaluateDomain(domain: String): FilterDecision {
        // Check allowlist first
        if (allowedDomains.containsKey(domain)) return FilterDecision.ALLOW
        if (currentRules.allowlist.any { domain.endsWith(it) }) {
            allowedDomains[domain] = true
            return FilterDecision.ALLOW
        }

        // Check blocklist
        if (blockedDomains.containsKey(domain)) return FilterDecision.BLOCK
        if (currentRules.blocklist.any { domain.endsWith(it) }) {
            blockedDomains[domain] = true
            return FilterDecision.BLOCK
        }

        // Check category
        val category = categoryCache[domain] ?: "UNKNOWN"
        if (category in currentRules.categories) {
            return FilterDecision.BLOCK
        }

        // Check safe search
        if (currentRules.safeSearch && isSearchEngine(domain)) {
            // Would enforce safe search parameters
        }

        return FilterDecision.ALLOW
    }

    private fun isSearchEngine(domain: String): Boolean {
        return domain.contains("google.") || domain.contains("bing.") || domain.contains("duckduckgo.")
    }

    suspend fun applyFilterRules(rules: WebSafetyRules) = withContext(Dispatchers.IO) {
        currentRules = rules
        // Update caches
        allowedDomains.clear()
        blockedDomains.clear()
        currentRules.allowlist.forEach { allowedDomains[it] = true }
        currentRules.blocklist.forEach { blockedDomains[it] = true }
    }

    fun isVpnActive(): Boolean = isRunning

    fun stopVpn() {
        isRunning = false
        vpnThread?.interrupt()
        vpnThread = null
        try {
            vpnInterface?.close()
        } catch (e: Exception) {
            Log.e(TAG, "Error closing VPN", e)
        }
        vpnInterface = null
    }

    fun updateFilterRules() {
        // Rules are applied via applyFilterRules
    }

    enum class FilterDecision {
        ALLOW, BLOCK, BLOCK_CATEGORY, BLOCK_THREAT, ALLOW_PARENT_OVERRIDE, UNKNOWN, ERROR
    }
}